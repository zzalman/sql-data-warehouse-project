/*===============================================================================
    Script: init_database.sql
    Author : Muhammad Salman Saleem

=================================================================================
Purpose
=================================================================================
This script initializes the Data Warehouse environment by:

1. Checking whether the 'DataWarehouse' database already exists.
2. Dropping the existing database (if found) to ensure a clean setup.
3. Creating a new 'DataWarehouse' database.
4. Creating the Bronze, Silver, and Gold schemas based on the
   Medallion Architecture.

Running this script guarantees a fresh and consistent database
environment before executing ETL pipelines or creating warehouse objects.
=================================================================================
*/
USE master;
GO

/*===============================================================================
 Step 1 : Check whether the database already exists
================================================================================*/

IF DB_ID('DataWarehouse') IS NOT NULL
BEGIN
    PRINT 'Existing database found...';

    /*-------------------------------------------------------------------------
      Force the database into SINGLE_USER mode.

      This closes all active connections so the database can be dropped
      without "database is currently in use" errors.
    -------------------------------------------------------------------------*/
    ALTER DATABASE DataWarehouse
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    /*-------------------------------------------------------------------------
      Drop the existing database
    -------------------------------------------------------------------------*/
    DROP DATABASE DataWarehouse;

    PRINT 'Existing database dropped successfully.';
END
ELSE
BEGIN
    PRINT 'Database does not exist. Creating a new one...';
END
GO

/*===============================================================================
 Step 2 : Create a brand-new database
================================================================================*/

CREATE DATABASE DataWarehouse;
GO

/*===============================================================================
 Step 3 : Switch to the newly created database
================================================================================*/

USE DataWarehouse;
GO

/*===============================================================================
 Step 4 : Create project schemas (Medallion Architecture)
================================================================================*/

/*-------------------------------------------------------------------------
 Bronze Schema
 -------------------------------------------------------------------------*/
CREATE SCHEMA bronze;
GO

/*-------------------------------------------------------------------------
 Silver Schema
-------------------------------------------------------------------------*/
CREATE SCHEMA silver;
GO

/*-------------------------------------------------------------------------
 Gold Schema
-------------------------------------------------------------------------*/
CREATE SCHEMA gold;
GO

PRINT '===========================================================';
PRINT ' DataWarehouse database created successfully.';
PRINT ' Bronze, Silver, and Gold schemas are ready.';
PRINT '===========================================================';
GO
