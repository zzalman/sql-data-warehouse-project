/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source → Bronze)
===============================================================================
Description:
    This stored procedure loads raw data from external CSV files into the
    Bronze layer of the Data Warehouse. During execution, it performs the
    following tasks:

    - Clears existing data from the Bronze tables using TRUNCATE TABLE.
    - Imports the latest data from CSV files using BULK INSERT.
    - Reports the execution progress and loading duration for each table.
    - Provides detailed error information if the loading process fails.

Parameters:
    None.
    This stored procedure does not accept any input parameters or return
    any values.

Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

    DECLARE @StartTime DATETIME,
            @EndTime DATETIME,
            @BronzeStart DATETIME,
            @BronzeEnd DATETIME;

    BEGIN TRY

        SET @BronzeStart = GETDATE();

        PRINT '================================================';
        PRINT '           Executing Bronze Layer';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT '           Executing CRM Tables';
        PRINT '------------------------------------------------';


        ----------------------------------------------------------
        -- CRM Customer Information
        ----------------------------------------------------------

        SET @StartTime = GETDATE();

        PRINT '>>> Truncating table: crm_cust_info';

        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>>> Loading data into: crm_cust_info';

        BULK INSERT bronze.crm_cust_info
        FROM 'S:\Disk E\Disk E\comset addmision\Data with bara SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT COUNT(*) AS TotalRows
        FROM bronze.crm_cust_info;

        SET @EndTime = GETDATE();

        PRINT '>>> crm_cust_info loaded successfully.';
        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS NVARCHAR(10))
            + ' Seconds';

        PRINT ' ';


        ----------------------------------------------------------
        -- CRM Product Information
        ----------------------------------------------------------

        SET @StartTime = GETDATE();

        PRINT '>>> Truncating table: crm_prd_info';

        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>>> Loading data into: crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM 'S:\Disk E\Disk E\comset addmision\Data with bara SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT COUNT(*) AS TotalRows
        FROM bronze.crm_prd_info;

        SET @EndTime = GETDATE();

        PRINT '>>> crm_prd_info loaded successfully.';
        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS NVARCHAR(10))
            + ' Seconds';

        PRINT ' ';


        ----------------------------------------------------------
        -- CRM Sales Details
        ----------------------------------------------------------

        SET @StartTime = GETDATE();

        PRINT '>>> Truncating table: crm_sales_details';

        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>>> Loading data into: crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM 'S:\Disk E\Disk E\comset addmision\Data with bara SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT COUNT(*) AS TotalRows
        FROM bronze.crm_sales_details;

        SET @EndTime = GETDATE();

        PRINT '>>> crm_sales_details loaded successfully.';
        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS NVARCHAR(10))
            + ' Seconds';

        PRINT ' ';


        PRINT '------------------------------------------------';
        PRINT '           Executing ERP Tables';
        PRINT '------------------------------------------------';


        ----------------------------------------------------------
        -- ERP Customer Information
        ----------------------------------------------------------

        SET @StartTime = GETDATE();

        PRINT '>>> Truncating table: erp_cust_az12';

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>>> Loading data into: erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM 'S:\Disk E\Disk E\comset addmision\Data with bara SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT COUNT(*) AS TotalRows
        FROM bronze.erp_cust_az12;

        SET @EndTime = GETDATE();

        PRINT '>>> erp_cust_az12 loaded successfully.';
        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS NVARCHAR(10))
            + ' Seconds';

        PRINT ' ';
                ----------------------------------------------------------
        -- ERP Location Information
        ----------------------------------------------------------

        SET @StartTime = GETDATE();

        PRINT '>>> Truncating table: erp_loc_a101';

        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>>> Loading data into: erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM 'S:\Disk E\Disk E\comset addmision\Data with bara SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT COUNT(*) AS TotalRows
        FROM bronze.erp_loc_a101;

        SET @EndTime = GETDATE();

        PRINT '>>> erp_loc_a101 loaded successfully.';
        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS NVARCHAR(10))
            + ' Seconds';

        PRINT ' ';


        ----------------------------------------------------------
        -- ERP Product Category
        ----------------------------------------------------------

        SET @StartTime = GETDATE();

        PRINT '>>> Truncating table: erp_px_cat_g1v2';

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>>> Loading data into: erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'S:\Disk E\Disk E\comset addmision\Data with bara SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT COUNT(*) AS TotalRows
        FROM bronze.erp_px_cat_g1v2;

        SET @EndTime = GETDATE();

        PRINT '>>> erp_px_cat_g1v2 loaded successfully.';
        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS NVARCHAR(10))
            + ' Seconds';

        PRINT ' ';


        ----------------------------------------------------------
        -- Bronze Layer Completed
        ----------------------------------------------------------

        SET @BronzeEnd = GETDATE();

        PRINT '================================================';
        PRINT '         Bronze Layer Completed Successfully';
        PRINT '================================================';

        PRINT 'Total Execution Time: '
            + CAST(DATEDIFF(SECOND,@BronzeStart,@BronzeEnd) AS NVARCHAR(10))
            + ' Seconds';

        PRINT '================================================';

    END TRY

    BEGIN CATCH

        PRINT '================================================';
        PRINT ' ERROR OCCURRED DURING BRONZE LAYER EXECUTION';
        PRINT '================================================';

        PRINT 'Error Number    : '
            + CAST(ERROR_NUMBER() AS NVARCHAR(10));

        PRINT 'Error Message   : '
            + ERROR_MESSAGE();

        PRINT 'Error Line      : '
            + CAST(ERROR_LINE() AS NVARCHAR(10));

        PRINT 'Error State     : '
            + CAST(ERROR_STATE() AS NVARCHAR(10));

        PRINT 'Error Severity  : '
            + CAST(ERROR_SEVERITY() AS NVARCHAR(10));

        PRINT 'Procedure Name  : '
            + ISNULL(CAST(ERROR_PROCEDURE() AS NVARCHAR(128)), 'bronze.load_bronze');

        PRINT '================================================';

        THROW;

    END CATCH

END;
GO
