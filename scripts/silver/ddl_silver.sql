/*
===============================================================================
Stored Procedure: Create Silver Layer Tables
===============================================================================
Script Purpose:
    This script creates all tables in the 'silver' schema for the data warehouse.
    It performs the following actions:
    - Checks if each table already exists and drops it if found
    - Creates new tables with appropriate data types
    - Adds a DWH_CREATE_DATE column with default GETDATE() for audit purposes
    - Provides detailed logging of each step

Tables Created:
    1. silver.crm_cust_info        - Customer information from CRM
    2. silver.crm_prd_info         - Product information from CRM
    3. silver.crm_sales_details    - Sales transactions from CRM
    4. silver.erp_cust_az12        - Customer information from ERP
    5. silver.erp_loc_a101         - Location information from ERP
    6. silver.erp_px_cat_g1v2      - Product categories from ERP

Parameters:
    None. This script does not accept any parameters.

Usage Example:
    EXEC silver.create_silver_tables;
    -- OR --
    Run this script directly in SQL Server Management Studio

Dependencies:
    - 'silver' schema must exist in the database
    - Appropriate permissions to CREATE and DROP tables

===============================================================================
*/

SET NOCOUNT ON;

BEGIN TRY

    PRINT '================================================';
    PRINT '    CREATING SILVER LAYER TABLES';
    PRINT '================================================';
    PRINT 'Start Time: ' + CAST(GETDATE() AS VARCHAR(50));
    PRINT '================================================';
    PRINT '';


    -- =============================================
    -- 1. CRM Customer Information
    -- =============================================
    PRINT '1/6: Creating table: silver.crm_cust_info';
    
    IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    BEGIN
        PRINT '>>> Dropping existing table: silver.crm_cust_info';
        DROP TABLE silver.crm_cust_info;
    END
    
    CREATE TABLE silver.crm_cust_info
    (
        cst_id              INT,
        cst_key             NVARCHAR(50),
        cst_firstname       NVARCHAR(50),
        cst_lastname        NVARCHAR(50),
        cst_marital_status  NVARCHAR(50),
        cst_gndr            NVARCHAR(50),
        cst_create_date     DATE,
        dwh_create_date     DATETIME2 DEFAULT GETDATE()
    );
    
    PRINT '✓ Table created successfully.';
    PRINT '';


    -- =============================================
    -- 2. CRM Product Information
    -- =============================================
    PRINT '2/6: Creating table: silver.crm_prd_info';
    
    IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    BEGIN
        PRINT '>>> Dropping existing table: silver.crm_prd_info';
        DROP TABLE silver.crm_prd_info;
    END
    
    CREATE TABLE silver.crm_prd_info
    (
        prd_id          INT,
        cat_id          NVARCHAR(50),
        prd_key         NVARCHAR(50),
        prd_nm          NVARCHAR(50),
        prd_cost        INT,
        prd_line        NVARCHAR(50),
        prd_start_dt    DATE,
        prd_end_dt      DATE,
        dwh_create_date DATETIME2 DEFAULT GETDATE()
    );
    
    PRINT '✓ Table created successfully.';
    PRINT '';


    -- =============================================
    -- 3. CRM Sales Details
    -- =============================================
    PRINT '3/6: Creating table: silver.crm_sales_details';
    
    IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    BEGIN
        PRINT '>>> Dropping existing table: silver.crm_sales_details';
        DROP TABLE silver.crm_sales_details;
    END
    
    CREATE TABLE silver.crm_sales_details
    (
        sls_ord_num     NVARCHAR(50),
        sls_prd_key     NVARCHAR(50),
        sls_cust_id     INT,
        sls_order_dt    DATE,
        sls_ship_dt     DATE,
        sls_due_dt      DATE,
        sls_sales       INT,
        sls_quantity    INT,
        sls_price       INT,
        dwh_create_date DATETIME2 DEFAULT GETDATE()
    );
    
    PRINT '✓ Table created successfully.';
    PRINT '';


    -- =============================================
    -- 4. ERP Customer Information
    -- =============================================
    PRINT '4/6: Creating table: silver.erp_cust_az12';
    
    IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    BEGIN
        PRINT '>>> Dropping existing table: silver.erp_cust_az12';
        DROP TABLE silver.erp_cust_az12;
    END
    
    CREATE TABLE silver.erp_cust_az12
    (
        CID             NVARCHAR(50),
        BDATE           DATE,
        GEN             NVARCHAR(50),
        dwh_create_date DATETIME2 DEFAULT GETDATE()
    );
    
    PRINT '✓ Table created successfully.';
    PRINT '';


    -- =============================================
    -- 5. ERP Location Information
    -- =============================================
    PRINT '5/6: Creating table: silver.erp_loc_a101';
    
    IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    BEGIN
        PRINT '>>> Dropping existing table: silver.erp_loc_a101';
        DROP TABLE silver.erp_loc_a101;
    END
    
    CREATE TABLE silver.erp_loc_a101
    (
        CID             NVARCHAR(50),
        CNTRY           NVARCHAR(50),
        dwh_create_date DATETIME2 DEFAULT GETDATE()
    );
    
    PRINT '✓ Table created successfully.';
    PRINT '';


    -- =============================================
    -- 6. ERP Product Category
    -- =============================================
    PRINT '6/6: Creating table: silver.erp_px_cat_g1v2';
    
    IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    BEGIN
        PRINT '>>> Dropping existing table: silver.erp_px_cat_g1v2';
        DROP TABLE silver.erp_px_cat_g1v2;
    END
    
    CREATE TABLE silver.erp_px_cat_g1v2
    (
        ID              NVARCHAR(50),
        CAT             NVARCHAR(50),
        SUBCAT          NVARCHAR(50),
        MAINTENANCE     NVARCHAR(50),
        dwh_create_date DATETIME2 DEFAULT GETDATE()
    );
    
    PRINT '✓ Table created successfully.';
    PRINT '';


    -- =============================================
    -- COMPLETION SUMMARY
    -- =============================================
    PRINT '================================================';
    PRINT '    ✓ SILVER TABLES CREATED SUCCESSFULLY ✓';
    PRINT '================================================';
    PRINT 'Tables Created:';
    PRINT '  1. silver.crm_cust_info';
    PRINT '  2. silver.crm_prd_info';
    PRINT '  3. silver.crm_sales_details';
    PRINT '  4. silver.erp_cust_az12';
    PRINT '  5. silver.erp_loc_a101';
    PRINT '  6. silver.erp_px_cat_g1v2';
    PRINT '================================================';
    PRINT 'Completion Time: ' + CAST(GETDATE() AS VARCHAR(50));
    PRINT '================================================';

END TRY

BEGIN CATCH
    -- =============================================
    -- ERROR HANDLING
    -- =============================================
    PRINT '================================================';
    PRINT '    ✗✗✗ ERROR CREATING SILVER TABLES ✗✗✗';
    PRINT '================================================';
    PRINT 'Error Details:';
    PRINT '  Error Number    : ' + CAST(ERROR_NUMBER() AS VARCHAR(20));
    PRINT '  Error Severity  : ' + CAST(ERROR_SEVERITY() AS VARCHAR(20));
    PRINT '  Error State     : ' + CAST(ERROR_STATE() AS VARCHAR(20));
    PRINT '  Error Line      : ' + CAST(ERROR_LINE() AS VARCHAR(20));
    PRINT '  Error Procedure : ' + ISNULL(ERROR_PROCEDURE(), 'Ad-hoc Script');
    PRINT '  Error Message   : ' + ERROR_MESSAGE();
    PRINT '================================================';
    PRINT 'Failed at: ' + CAST(GETDATE() AS VARCHAR(50));
    PRINT '================================================';
    PRINT '';

    -- Re-throw the error
    THROW;
END CATCH;
