
/*===============================================================================
    
    Project: Data Warehouse & Analytics Project
  

=================================================================================
Purpose
=================================================================================
This script creates all tables required for the Bronze layer of the Data
Warehouse. Before creating each table, the script checks whether it already
exists. If the table is found, it is dropped and recreated to ensure a clean
and consistent database structure.

The Bronze layer stores raw data exactly as received from the source systems
without applying any transformations or business rules.

=================================================================================
Warning
=================================================================================
• Running this script will permanently delete all existing Bronze tables.
• Any data stored in these tables will be lost.
• Execute this script only during the initial setup or when rebuilding the
  Bronze layer from scratch.
=================================================================================
*/
SET NOCOUNT ON;

BEGIN TRY

    PRINT '================================================';
    PRINT ' Creating Bronze Layer Tables';
    PRINT '================================================';

    PRINT '================================================';
    PRINT ' Creating Bronze Layer Tables';
    PRINT '================================================';
    
    
    ----------------------------------------------------------
    -- CRM Customer Information
    ----------------------------------------------------------
    
    PRINT 'Creating table: bronze.crm_cust_info';
    
    IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    BEGIN
        PRINT 'Dropping existing table: bronze.crm_cust_info';
        DROP TABLE bronze.crm_cust_info;
    END
    
    CREATE TABLE bronze.crm_cust_info
    (
        cst_id              INT,
        cst_key             NVARCHAR(50),
        cst_firstname       NVARCHAR(50),
        cst_lastname        NVARCHAR(50),
        cst_marital_status  NVARCHAR(50),
        cst_gndr            NVARCHAR(50),
        cst_create_date     DATE
    );
    
    PRINT 'Table created successfully.';
    PRINT '';
    
    
    ----------------------------------------------------------
    -- CRM Product Information
    ----------------------------------------------------------
    
    PRINT 'Creating table: bronze.crm_prd_info';
    
    IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    BEGIN
        PRINT 'Dropping existing table: bronze.crm_prd_info';
        DROP TABLE bronze.crm_prd_info;
    END
    
    CREATE TABLE bronze.crm_prd_info
    (
        prd_id          INT,
        prd_key         NVARCHAR(50),
        prd_nm          NVARCHAR(50),
        prd_cost        INT,
        prd_line        NVARCHAR(50),
        prd_start_dt    DATETIME,
        prd_end_dt      DATETIME
    );
    
    PRINT 'Table created successfully.';
    PRINT '';
    
    
    ----------------------------------------------------------
    -- CRM Sales Details
    ----------------------------------------------------------
    
    PRINT 'Creating table: bronze.crm_sales_details';
    
    IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    BEGIN
        PRINT 'Dropping existing table: bronze.crm_sales_details';
        DROP TABLE bronze.crm_sales_details;
    END
    
    CREATE TABLE bronze.crm_sales_details
    (
        sls_ord_num     NVARCHAR(50),
        sls_prd_key     NVARCHAR(50),
        sls_cust_id     INT,
        sls_order_dt    INT,
        sls_ship_dt     INT,
        sls_due_dt      INT,
        sls_sales       INT,
        sls_quantity    INT,
        sls_price       INT
    );
    
    PRINT 'Table created successfully.';
    PRINT '';
    
    
    ----------------------------------------------------------
    -- ERP Customer Information
    ----------------------------------------------------------
    
    PRINT 'Creating table: bronze.erp_cust_az12';
    
    IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    BEGIN
        PRINT 'Dropping existing table: bronze.erp_cust_az12';
        DROP TABLE bronze.erp_cust_az12;
    END
    
    CREATE TABLE bronze.erp_cust_az12
    (
        CID     NVARCHAR(50),
        BDATE   DATE,
        GEN     NVARCHAR(50)
    );
    
    PRINT 'Table created successfully.';
    PRINT '';
    
    
    ----------------------------------------------------------
    -- ERP Location Information
    ----------------------------------------------------------
    
    PRINT 'Creating table: bronze.erp_loc_a101';
    
    IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    BEGIN
        PRINT 'Dropping existing table: bronze.erp_loc_a101';
        DROP TABLE bronze.erp_loc_a101;
    END
    
    CREATE TABLE bronze.erp_loc_a101
    (
        CID     NVARCHAR(50),
        CNTRY   NVARCHAR(50)
    );
    
    PRINT 'Table created successfully.';
    PRINT '';
    
    
    ----------------------------------------------------------
    -- ERP Product Category
    ----------------------------------------------------------
    
    PRINT 'Creating table: bronze.erp_px_cat_g1v2';
    
    IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    BEGIN
        PRINT 'Dropping existing table: bronze.erp_px_cat_g1v2';
        DROP TABLE bronze.erp_px_cat_g1v2;
    END
    
    CREATE TABLE bronze.erp_px_cat_g1v2
    (
        ID              NVARCHAR(50),
        CAT             NVARCHAR(50),
        SUBCAT          NVARCHAR(50),
        MAINTENANCE     NVARCHAR(50)
    );
    
    PRINT 'Table created successfully.';
    PRINT '';
    
    
    PRINT '================================================';
    PRINT ' Bronze Layer Tables Created Successfully';
    PRINT '================================================';

    PRINT '================================================';
    PRINT ' Bronze Layer Tables Created Successfully';
    PRINT '================================================';

END TRY

BEGIN CATCH

    PRINT '================================================';
    PRINT ' ERROR OCCURRED WHILE CREATING BRONZE TABLES';
    PRINT '================================================';

    PRINT 'Error Number   : '
        + CAST(ERROR_NUMBER() AS NVARCHAR(10));

    PRINT 'Error Message  : '
        + ERROR_MESSAGE();

    PRINT 'Error Line     : '
        + CAST(ERROR_LINE() AS NVARCHAR(10));

    PRINT 'Error State    : '
        + CAST(ERROR_STATE() AS NVARCHAR(10));

    PRINT 'Error Severity : '
        + CAST(ERROR_SEVERITY() AS NVARCHAR(10));

    PRINT 'Procedure Name : '
        + ISNULL(CAST(ERROR_PROCEDURE() AS NVARCHAR(128)), 'Ad-hoc Script');

    PRINT '================================================';

    THROW;

END CATCH;
