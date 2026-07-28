/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Drop views if they exist (refresh)
-- =============================================================================
IF OBJECT_ID('gold.dim_customer', 'V') IS NOT NULL
    DROP VIEW gold.dim_customer;

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

-- =============================================================================
-- Create Dimension: gold.dim_customer
-- =============================================================================
CREATE VIEW gold.dim_customer as
SELECT  
       row_number() over(order by ci.cst_id) as customer_key,
       ci.cst_id as customer_id,
       ci.cst_key as customer_number,
       ci.cst_firstname as first_name,
       ci.cst_lastname as last_name,
       cu.cntry as country,
       ci.cst_marital_status as marital_status,
       case when ci.cst_gndr != 'n/a' then ci.cst_gndr
            else coalesce(gen , 'n/a')
        end as gender,
       lc.bdate as birthdate,
       ci.cst_create_date as create_date
FROM silver.crm_cust_info as ci
left join silver.erp_cust_az12 as lc
on ci.cst_key = lc.cid
left join silver.erp_loc_a101 as cu
on ci.cst_key = cu.cid;
GO

-- =============================================================================
-- Create Dimension: gold.dim_product
-- =============================================================================
CREATE VIEW gold.dim_product AS
SELECT
      row_number() over(order by p1.prd_start_dt,p1.prd_key) as product_key,
      p1.prd_id as product_id,
      p1.prd_key as product_number,
      p1.prd_nm as product_name,
      p1.cat_id as category_id,
      p2.cat as category,
      p2.subcat as subcategory,
      p1.prd_cost cost,
      p1.prd_line as product_line,     
      p2.maintenance,
      p1.prd_start_dt as start_date
FROM silver.crm_prd_info as p1
left join silver.erp_px_cat_g1v2 as p2
on p1.cat_id = p2.id
where p1.prd_end_dt is null; -- filterout historical data
GO

-- =============================================================================
-- Create Fact: gold.fact_sales
-- =============================================================================
CREATE VIEW gold.fact_sales AS
SELECT  
      sa.sls_ord_num as order_number,
      pr.product_key,
      cu.customer_key,
      sa.sls_order_dt as order_date,
      sa.sls_ship_dt as shipping_date,
      sa.sls_due_dt as due_date,
      sa.sls_sales as sales_amount,
      sa.sls_quantity as Quantity,
      sa.sls_price as price
FROM silver.crm_sales_details sa
left join gold.dim_product pr
on sa.sls_prd_key = pr.product_number
left join gold.dim_customer cu 
on sa.sls_cust_id = cu.customer_id;
GO

-- =============================================================================
-- Execution Summary
-- =============================================================================
PRINT '============================================';
PRINT '✓ Gold Layer Views Created Successfully!';
PRINT '============================================';
PRINT 'Views Created:';
PRINT '  1. gold.dim_customer';
PRINT '  2. gold.dim_product';
PRINT '  3. gold.fact_sales';
PRINT '============================================';
