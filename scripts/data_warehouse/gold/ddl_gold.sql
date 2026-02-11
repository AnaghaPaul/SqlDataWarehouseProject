/*
==================================================================================
DDL Script : Create Gold Views
==================================================================================
Script Purpose :
  This script creates views for the Gold layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables (Star Schema)

  Each view performs transformations and combines data from the silver layer
  to produce a clea, enriched, and business-ready dataset.
Usage:
  - These views can be querified directly for analytics and reporting.
====================================================================================
*/
-- =================================================================================
-- Create Dimension : gold.dim_customers
-- ================================================================================
-- gold.dim_customers
IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
  SELECT
  		ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
  		ci.cst_id AS customer_id,
  		ci.cst_key AS customer_number,
  		ci.cst_firstname AS first_name,
  		ci.cst_lastname AS last_name,
  		la.cntry AS country,
  		ci.cst_marital_status AS marital_status,
  		CASE  WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
  			  ELSE COALESCE(ca.gen,'n/a')
  		END AS gender,
  		ca.bdate AS birthdate,
  		ci.cst_create_date AS create_date	
  FROM silver.crm_cust_info ci
  LEFT JOIN silver.erp_cust_az12 ca
  ON		  ci.cst_key = ca.cid
  LEFT JOIN silver.erp_loc_a101 la
  ON        ci.cst_key = la.cid;

-- =================================================================================
-- Create Dimension : gold.dim_products
-- ================================================================================
-- gold.dim_products
IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

-- gold.dim_products

CREATE VIEW gold.dim_products AS
  SELECT
  	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, 
  	pn.prd_id AS product_id,
  	pn.prd_key AS product_number,
  	pn.prd_name AS product_name,
  	pn.cat_id AS category_id,
  	pc.cat AS category,
  	pc.subcat AS subcategory,
  	pc.maintenance,
  	pn.prd_cost AS cost,
  	pn.prd_line AS product_line,
  	pn.prd_start_dt AS start_date
  FROM silver.crm_prd_info pn
  LEFT JOIN silver.erp_px_cat_g1v2 pc
  ON        pn.cat_id = pc.id
  WHERE prd_end_dt IS NULL-- Filter out all historicaldata

-- =================================================================================
-- Create fact : gold.fact_sales
-- ================================================================================
-- gold.fact_sales
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
--gold.fact_sales
CREATE VIEW gold.fact_sales AS
  SELECT 
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key, 
    YEAR(sd.sls_order_dt) * 10000 + MONTH(sd.sls_order_dt) * 100 + DAY(sd.sls_order_dt) AS order_date_key,
    YEAR(sd.sls_ship_dt) * 10000 + MONTH(sd.sls_ship_dt)*100 +DAY(sd.sls_ship_dt) AS shipping_date_key,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
  FROM silver.crm_sales_details sd
  LEFT JOIN gold.dim_products pr
  ON		  sd.sls_prd_key = pr.product_number
  LEFT JOIN gold.dim_customers cu
  ON		  sd.sls_cust_id = cu.customer_id;

-- ======================================================================================
  -- Create roleplaying views of Dimension Date
  -- =======================================================================================


-- -------------------------------------------------------------------------------------------
-- dim_order_date
-- -------------------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_order_date','V') IS NOT NULL
    DROP VIEW gold.dim_order_date;
GO
  CREATE VIEW gold.dim_order_date AS
  SELECT
  	date_key AS order_date_key, 
    date AS order_date,
    full_date AS order_full_date,-- Date in MM-dd-yyyy format
    day_of_month AS order_day_of_month, -- Field will hold day number of Month
    day_suffix AS order_day_suffix, -- Apply suffix as 1st, 2nd ,3rd etc
    day_name AS order_day_name, -- Contains name of the day, Sunday, Monday 
    day_of_week AS order_day_of_week,-- First Day Sunday=1 and Saturday=7
    day_of_week_in_month AS order_day_of_week_in_month, --1st Monday or 2nd Monday in Month
    day_of_week_in_year AS order_day_of_week_in_year,
    day_of_quarter AS order_day_of_quarter, 
    day_of_year AS order_day_of_year,
    week_of_month AS order_week_of_month,-- Week Number of Month 
    week_of_quarter AS order_week_of_quarter, --Week Number of the Quarter
    week_of_year AS order_week_of_year,--Week Number of the Year
    month AS order_month, --Number of the Month 1 to 12
    month_name AS order_month_name,--January, February etc
    month_of_quarter AS order_month_of_quarter,-- Month Number belongs to Quarter
    quarter AS order_quarter,
    quarter_name AS order_quarter_name,--First,Second..
    year AS order_year,-- Year value of Date stored in Row
    year_name AS order_year_name, --CY 2012,CY 2013
    month_year AS order_month_year, --Jan-2013,Feb-2013
    mmyyyy AS order_mmyyyy,
    first_day_of_month AS order_first_day_of_month,
    last_day_of_month AS order_last_day_of_month,
    first_day_of_quarter AS order_first_day_of_quarter,
    last_day_of_quarter AS order_last_day_of_quarter,
    first_day_of_year AS order_first_day_of_year,
    last_day_of_year AS order_last_day_of_year,
    is_weekday AS order_is_weekday-- 0=Week End ,1=Week Day
	
  FROM silver.dwh_dim_date

-- ------------------------------------------------------------------------------------------------
-- dim_shipping_date
-- -------------------------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_shipping_date','V') IS NOT NULL
    DROP VIEW gold.dim_shipping_date;
GO
  CREATE VIEW gold.dim_shipping_date AS
  SELECT
  	date_key AS shipping_date_key, 
    date AS shipping_date,
    full_date AS shipping_full_date,-- Date in MM-dd-yyyy format
    day_of_month AS shipping_day_of_month, -- Field will hold day number of Month
    day_suffix AS shipping_day_suffix, -- Apply suffix as 1st, 2nd ,3rd etc
    day_name AS shipping_day_name, -- Contains name of the day, Sunday, Monday 
    day_of_week AS shipping_day_of_week,-- First Day Sunday=1 and Saturday=7
    day_of_week_in_month AS shipping_day_of_week_in_month, --1st Monday or 2nd Monday in Month
    day_of_week_in_year AS shipping_day_of_week_in_year,
    day_of_quarter AS shipping_day_of_quarter, 
    day_of_year AS shipping_day_of_year,
    week_of_month AS shipping_week_of_month,-- Week Number of Month 
    week_of_quarter AS shipping_week_of_quarter, --Week Number of the Quarter
    week_of_year AS shipping_week_of_year,--Week Number of the Year
    month AS shipping_month, --Number of the Month 1 to 12
    month_name AS shipping_month_name,--January, February etc
    month_of_quarter AS shipping_month_of_quarter,-- Month Number belongs to Quarter
    quarter AS shipping_quarter,
    quarter_name AS shipping_quarter_name,--First,Second..
    year AS shipping_year,-- Year value of Date stored in Row
    year_name AS shipping_year_name, --CY 2012,CY 2013
    month_year AS shipping_month_year, --Jan-2013,Feb-2013
    mmyyyy AS shipping_mmyyyy,
    first_day_of_month AS shipping_first_day_of_month,
    last_day_of_month AS shipping_last_day_of_month,
    first_day_of_quarter AS shipping_first_day_of_quarter,
    last_day_of_quarter AS shipping_last_day_of_quarter,
    first_day_of_year AS shipping_first_day_of_year,
    last_day_of_year AS shipping_last_day_of_year,
    is_weekday AS shipping_is_weekday-- 0=Week End ,1=Week Day
	
  FROM silver.dwh_dim_date
-- ---------------------------------------------------------------------------------------------------------------------------------
-- dim_due_date
-- ---------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_due_date','V') IS NOT NULL
    DROP VIEW gold.dim_due_date;
GO
  CREATE VIEW gold.dim_due_date AS
  SELECT
  	date_key AS due_date_key, 
    date AS due_date,
    full_date AS due_full_date,-- Date in MM-dd-yyyy format
    day_of_month AS due_day_of_month, -- Field will hold day number of Month
    day_suffix AS due_day_suffix, -- Apply suffix as 1st, 2nd ,3rd etc
    day_name AS due_day_name, -- Contains name of the day, Sunday, Monday 
    day_of_week AS due_day_of_week,-- First Day Sunday=1 and Saturday=7
    day_of_week_in_month AS due_day_of_week_in_month, --1st Monday or 2nd Monday in Month
    day_of_week_in_year AS due_day_of_week_in_year,
    day_of_quarter AS due_day_of_quarter, 
    day_of_year AS due_day_of_year,
    week_of_month AS due_week_of_month,-- Week Number of Month 
    week_of_quarter AS due_week_of_quarter, --Week Number of the Quarter
    week_of_year AS due_week_of_year,--Week Number of the Year
    month AS due_month, --Number of the Month 1 to 12
    month_name AS due_month_name,--January, February etc
    month_of_quarter AS due_month_of_quarter,-- Month Number belongs to Quarter
    quarter AS due_quarter,
    quarter_name AS due_quarter_name,--First,Second..
    year AS due_year,-- Year value of Date stored in Row
    year_name AS due_year_name, --CY 2012,CY 2013
    month_year AS due_month_year, --Jan-2013,Feb-2013
    mmyyyy AS due_mmyyyy,
    first_day_of_month AS due_first_day_of_month,
    last_day_of_month AS due_last_day_of_month,
    first_day_of_quarter AS due_first_day_of_quarter,
    last_day_of_quarter AS due_last_day_of_quarter,
    first_day_of_year AS due_first_day_of_year,
    last_day_of_year AS due_last_day_of_year,
    is_weekday AS due_is_weekday-- 0=Week End ,1=Week Day
	
  FROM silver.dwh_dim_date
