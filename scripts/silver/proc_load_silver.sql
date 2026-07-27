/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure loads and transforms data from the 'bronze' schema 
    to the 'silver' schema in the data warehouse. It performs the following:
    
    - Truncates all silver tables before loading (ensures no duplicate data)
    - Cleanses and standardizes data from bronze tables
    - Applies business rules and data quality transformations
    - Handles NULL values with appropriate defaults
    - Standardizes date formats and string values
    - Deduplicates records using ROW_NUMBER() window function
    - Provides detailed logging and performance metrics

Tables Processed (Bronze -> Silver):
    1. bronze.crm_cust_info     -> silver.crm_cust_info      (Customer master)
    2. bronze.crm_prd_info      -> silver.crm_prd_info       (Product master)
    3. bronze.crm_sales_details -> silver.crm_sales_details  (Sales transactions)
    4. bronze.erp_cust_az12     -> silver.erp_cust_az12      (ERP customer data)
    5. bronze.erp_loc_a101      -> silver.erp_loc_a101       (ERP location data)
    6. bronze.erp_px_cat_g1v2   -> silver.erp_px_cat_g1v2    (Product categories)

Transformations Applied:
    - String trimming and standardization
    - Date validation and conversion (handles 0 and invalid dates as NULL)
    - Marital status mapping (S -> Single, M -> Married)
    - Gender mapping (M -> Male, F -> Female)
    - Product line categorization (M, R, S, T -> Full descriptions)
    - Price and sales calculations (handles NULLs and negative values)
    - Surrogate key generation for product categories
    - Deduplication based on business keys

Parameters:
    None. This stored procedure does not accept any parameters.

Usage Example:
    EXEC silver.load_silver;
    -- OR --
    EXEC [DataWarehouse].[silver].[load_silver];

Dependencies:
    - Bronze tables must exist and contain data
    - Silver tables must exist (create using silver.create_silver_tables)
    - Appropriate permissions on both bronze and silver schemas

Performance Notes:
    - Uses TRUNCATE instead of DELETE for faster data removal
    - Uses BULK operations for efficient data loading
    - Execution time depends on the volume of data in bronze tables

===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    -- =============================================
-- SILVER LAYER DATA LOADING WITH ERROR HANDLING
-- =============================================

DECLARE @StartTime DATETIME = GETDATE();
DECLARE @TableStartTime DATETIME;
DECLARE @DurationSeconds INT;
DECLARE @TotalSeconds INT;

PRINT '============================================';
PRINT 'SILVER LAYER DATA LOAD STARTED';
PRINT 'Start Time: ' + CAST(@StartTime AS VARCHAR(50));
PRINT '============================================';
PRINT '';

BEGIN TRY

    -- =============================================
    -- 1. CRM Customer Info
    -- =============================================
    SET @TableStartTime = GETDATE();
    PRINT '1/6: Loading silver.crm_cust_info...';
    
    TRUNCATE TABLE silver.crm_cust_info;
    
    INSERT INTO silver.crm_cust_info
    (
        [cst_id], [cst_key], [cst_firstname], [cst_lastname],
        [cst_marital_status], [cst_gndr], [cst_create_date]
    )
    SELECT 
        [cst_id],
        [cst_key],
        TRIM([cst_firstname]),
        TRIM([cst_lastname]),
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS [cst_marital_status],
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            ELSE 'n/a' 
        END AS [cst_gndr],
        [cst_create_date]
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM [DataWarehouse].[bronze].[crm_cust_info]
        WHERE cst_id IS NOT NULL
    ) t 
    WHERE flag_last = 1;
    
    SET @DurationSeconds = DATEDIFF(SECOND, @TableStartTime, GETDATE());
    PRINT '✓ Completed in ' + CAST(@DurationSeconds AS VARCHAR(10)) + ' seconds';
    PRINT '';


    -- =============================================
    -- 2. CRM Product Info
    -- =============================================
    SET @TableStartTime = GETDATE();
    PRINT '2/6: Loading silver.crm_prd_info...';
    
    TRUNCATE TABLE silver.crm_prd_info;
    
    INSERT INTO silver.crm_prd_info
    (
        [prd_id], [cat_id], [prd_key], [prd_nm],
        [prd_cost], [prd_line], [prd_start_dt], [prd_end_dt]
    )
    SELECT 
        [prd_id],
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
        [prd_nm],
        ISNULL([prd_cost], 0) AS prd_cost,
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        CAST([prd_start_dt] AS DATE),
        CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
    FROM [DataWarehouse].[bronze].[crm_prd_info];
    
    SET @DurationSeconds = DATEDIFF(SECOND, @TableStartTime, GETDATE());
    PRINT '✓ Completed in ' + CAST(@DurationSeconds AS VARCHAR(10)) + ' seconds';
    PRINT '';


    -- =============================================
    -- 3. CRM Sales Details
    -- =============================================
    SET @TableStartTime = GETDATE();
    PRINT '3/6: Loading silver.crm_sales_details...';
    
    TRUNCATE TABLE silver.crm_sales_details;
    
    INSERT INTO silver.crm_sales_details
    (
        [sls_ord_num], [sls_prd_key], [sls_cust_id],
        [sls_order_dt], [sls_ship_dt], [sls_due_dt],
        [sls_sales], [sls_quantity], [sls_price]
    )
    SELECT
        [sls_ord_num],
        [sls_prd_key],
        [sls_cust_id],
        CASE 
            WHEN [sls_order_dt] = 0 OR LEN(CAST([sls_order_dt] AS VARCHAR(10))) != 8 THEN NULL
            ELSE CAST(CAST([sls_order_dt] AS VARCHAR(8)) AS DATE)
        END AS [sls_order_dt],
        CASE 
            WHEN [sls_ship_dt] = 0 OR LEN(CAST([sls_ship_dt] AS VARCHAR(10))) != 8 THEN NULL
            ELSE CAST(CAST([sls_ship_dt] AS VARCHAR(8)) AS DATE)
        END AS [sls_ship_dt],
        CASE 
            WHEN [sls_due_dt] = 0 OR LEN(CAST([sls_due_dt] AS VARCHAR(10))) != 8 THEN NULL
            ELSE CAST(CAST([sls_due_dt] AS VARCHAR(8)) AS DATE)
        END AS [sls_due_dt],
        CASE 
            WHEN sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS [sls_sales],
        [sls_quantity],
        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS [sls_price]
    FROM [DataWarehouse].[bronze].[crm_sales_details];
    
    SET @DurationSeconds = DATEDIFF(SECOND, @TableStartTime, GETDATE());
    PRINT '✓ Completed in ' + CAST(@DurationSeconds AS VARCHAR(10)) + ' seconds';
    PRINT '';


    -- =============================================
    -- 4. ERP Customer AZ12
    -- =============================================
    SET @TableStartTime = GETDATE();
    PRINT '4/6: Loading silver.erp_cust_az12...';
    
    TRUNCATE TABLE silver.erp_cust_az12;
    
    INSERT INTO silver.erp_cust_az12
    (
        [cid], [bdate], [gen]
    )
    SELECT 
        CASE 
            WHEN CID LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(CID))
            ELSE CID
        END AS [CID],
        CASE 
            WHEN BDATE > GETDATE() THEN NULL
            ELSE BDATE
        END AS [BDATE],
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            ELSE 'n/a'
        END AS [GEN]
    FROM [DataWarehouse].[bronze].[erp_cust_az12];
    
    SET @DurationSeconds = DATEDIFF(SECOND, @TableStartTime, GETDATE());
    PRINT '✓ Completed in ' + CAST(@DurationSeconds AS VARCHAR(10)) + ' seconds';
    PRINT '';


    -- =============================================
    -- 5. ERP Location A101
    -- =============================================
    SET @TableStartTime = GETDATE();
    PRINT '5/6: Loading silver.erp_loc_a101...';
    
    TRUNCATE TABLE silver.erp_loc_a101;
    
    INSERT INTO silver.erp_loc_a101
    (
        [cid], [cntry]
    )
    SELECT 
        REPLACE(CID, '-', '') AS cid,
        CASE UPPER(TRIM(CNTRY))
            WHEN 'DE' THEN 'Germany'
            WHEN 'GERMANY' THEN 'Germany'
            WHEN 'US' THEN 'United States'
            WHEN 'USA' THEN 'United States'
            WHEN 'UNITED STATES' THEN 'United States'
            WHEN 'FRANCE' THEN 'France'
            WHEN 'CANADA' THEN 'Canada'
            WHEN 'UNITED KINGDOM' THEN 'United Kingdom'
            WHEN 'AUSTRALIA' THEN 'Australia'
            ELSE 'n/a'
        END AS cntry
    FROM [DataWarehouse].[bronze].[erp_loc_a101];
    
    SET @DurationSeconds = DATEDIFF(SECOND, @TableStartTime, GETDATE());
    PRINT '✓ Completed in ' + CAST(@DurationSeconds AS VARCHAR(10)) + ' seconds';
    PRINT '';


    -- =============================================
    -- 6. ERP Product Category G1V2
    -- =============================================
    SET @TableStartTime = GETDATE();
    PRINT '6/6: Loading silver.erp_px_cat_g1v2...';
    
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    
    INSERT INTO silver.erp_px_cat_g1v2
    (
        [ID], [CAT], [SUBCAT], [MAINTENANCE]
    )
    SELECT 
        [ID], [CAT], [SUBCAT], [MAINTENANCE]
    FROM [DataWarehouse].[bronze].[erp_px_cat_g1v2];
    
    SET @DurationSeconds = DATEDIFF(SECOND, @TableStartTime, GETDATE());
    PRINT '✓ Completed in ' + CAST(@DurationSeconds AS VARCHAR(10)) + ' seconds';
    PRINT '';


    -- =============================================
    -- SUCCESS SUMMARY
    -- =============================================
    SET @TotalSeconds = DATEDIFF(SECOND, @StartTime, GETDATE());
    
    PRINT '============================================';
    PRINT '✓✓✓ ALL TABLES LOADED SUCCESSFULLY! ✓✓✓';
    PRINT '============================================';
    PRINT 'Total Duration: ' + CAST(@TotalSeconds AS VARCHAR(10)) + ' seconds';
    PRINT '  (' + CAST(@TotalSeconds/60 AS VARCHAR(10)) + ' minutes, ' + 
          CAST(@TotalSeconds%60 AS VARCHAR(10)) + ' seconds)';
    PRINT '============================================';

END TRY
BEGIN CATCH
    -- Built-in error handling
    PRINT '============================================';
    PRINT '✗✗✗ ERROR OCCURRED! ✗✗✗';
    PRINT '============================================';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(20));
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(20));
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(20));
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(20));
    PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT '============================================';
    
    SET @TotalSeconds = DATEDIFF(SECOND, @StartTime, GETDATE());
    PRINT 'Failed after: ' + CAST(@TotalSeconds AS VARCHAR(10)) + ' seconds';
    
    THROW;
END CATCH
END
