/* Stored procedure : Load gold Layer (Silver -> Gold)
=============================================================================================
Purpose: This stored procedure performs the ETL (Extract, Transform, Load) process 
to  populate the 'gold' schema tables from 'bronze' schema.
Actions performed: 
-Truncates Gold tables.
- Dimensional modeling
-Inserts transformed and cleansed data from Silver into Gold tables.
Warning : The script will truncate any existing data in the table, so execute with precaution.
===============================================================================
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC gold.load_silver;
===============================================================================*/
CREATE OR ALTER PROCEDURE gold.load_gold AS -- stored procedure
  BEGIN
    DECLARE @start_load_time DATETIME, @end_load_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;-- start_load_time, end_load time, batch_start time, batch_end_time
    BEGIN TRY 
      SET @batch_start_time = GETDATE();
      PRINT '=================================================================================================';
			PRINT 'Loading Gold Layer';
			PRINT '=================================================================================================';
			PRINT 'Loading Dimension Tables';
			PRINT '==================================================================================================';
			PRINT '--------------------------------------------------------------------------------------------------';
			PRINT 'Loading Customer Dimension';
			PRINT '-------------------------------------------------------------------------------------------------';
-- ==========================================================================
-- Truncating and Inserting Data into gold.dim_customers
    PRINT '>>Preparing to truncate and load gold.dim_customers';
    SET @start_load_time = GETDATE();
-- Truncate
    PRINT'>> Truncating Table : gold.dim_customers';
    TRUNCATE TABLE gold.dim_customers;
    PRINT'>> Inserting Data Into : gold.dim_customers';
--Insert
  INSERT INTO gold.dim_customers
  (
  	customer_key,
  	customer_id,
  	customer_number,
  	first_name,
  	last_name,
  	country,
  	marital_status,
  	gender,
  	birthdate,
  	create_date
  )
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

  SET @end_load_time = GETDATE();
  PRINT '>>Loading to gold.dim_customers completed successfully';
  			PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
  			PRINT '-------------------------------------------------------------------------------------------------';
-- Loading completed for gold.dim_customers
-- ===================================================================================================================
-- Truncating and Inserting Data into gold.dim_products
	PRINT '>>Preparing to truncate and load gold.dim_products';
	SET @start_load_time = GETDATE();
-- Truncate
	PRINT'>> Truncating Table : gold.dim_products';
	TRUNCATE TABLE gold.dim_products;
	PRINT'>> Inserting Data Into : gold.dim_products';
-- Insert
	INSERT INTO gold.dim_products(
	product_key,
	product_id,
	product_number,
	product_name,
	category_id,
	category,
	subcategory,
	maintenance,
	cost,
	product_line,
	start_date
	)
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
		
	SET @end_load_time = GETDATE();
	PRINT '>>Loading to gold.dim_products completed successfully';
	PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
	PRINT '-------------------------------------------------------------------------------------------------';
-- ---------------------------------------------------------------------------------------------------------------------
	PRINT '>>Preparing to truncate and load gold.dim_date';
	SET @start_load_time = GETDATE();
-- Truncate
	PRINT'>> Truncating Table : gold.dim_date';
	TRUNCATE TABLE gold.dim_date;
	PRINT'>> Inserting Data Into : gold.dim_date';
-- Insert
	INSERT INTO gold.dim_date
	(
	    date_key, 
	    date,
	    full_date,-- Date in MM-dd-yyyy format
	    day_of_month, -- Field will hold day number of Month
	    day_suffix, -- Apply suffix as 1st, 2nd ,3rd etc
	    day_name, -- Contains name of the day, Sunday, Monday 
	    day_of_week,-- First Day Sunday=1 and Saturday=7
	    day_of_week_in_month, --1st Monday or 2nd Monday in Month
	    day_of_week_in_year,
	    day_of_quarter, 
	    day_of_year,
	    week_of_month,-- Week Number of Month 
	    week_of_quarter, --Week Number of the Quarter
	    week_of_year,--Week Number of the Year
	    month, --Number of the Month 1 to 12
	    month_name,--January, February etc
	    month_of_quarter,-- Month Number belongs to Quarter
	    quarter,
	    quarter_name,--First,Second..
	    year,-- Year value of Date stored in Row
	    year_name, --CY 2012,CY 2013
	    month_year, --Jan-2013,Feb-2013
	    mmyyyy,
	    first_day_of_month,
	    last_day_of_month,
	    first_day_of_quarter,
	    last_day_of_quarter,
	    first_day_of_year,
	    last_day_of_year,
		season,
		is_holiday,-- Flag 1=Global Holiday, 0-No Global Holiday
	    is_weekday,-- 0=Week End ,1=Week Day
		holiday_name,--Name of Global
		fiscal_day_of_year,
		fiscal_week_of_year,
		fiscal_month,
		fiscal_quarter,
		fiscal_quarter_name,
		fiscal_year,
		fiscal_year_name,
		fiscal_month_year,
		fiscal_mmyyyy,
		fiscal_first_day_of_month,
		fiscal_last_day_of_month,
		fiscal_first_day_of_quarter,
		fiscal_last_day_of_quarter,
		fiscal_first_day_of_year,
		fiscal_last_day_of_year
	)
	SELECT
		date_key, 
	    date,
	    full_date,
	    day_of_month,
	    day_suffix,
	    day_name,
	    day_of_week,
	    day_of_week_in_month,
	    day_of_week_in_year,
	    day_of_quarter, 
	    day_of_year,
	    week_of_month,
	    week_of_quarter,
	    week_of_year,
	    month,
	    month_name,
	    month_of_quarter,
	    quarter,
	    quarter_name,
	    year,
	    year_name,
	    month_year,
	    mmyyyy,
	    first_day_of_month,
	    last_day_of_month,
	    first_day_of_quarter,
	    last_day_of_quarter,
	    first_day_of_year,
	    last_day_of_year,
		season,
		is_holiday,
	    is_weekday,
		holiday_name,
		fiscal_day_of_year,
		fiscal_week_of_year,
		fiscal_month,
		fiscal_quarter,
		fiscal_quarter_name,
		fiscal_year,
		fiscal_year_name,
		fiscal_month_year,
		fiscal_mmyyyy,
		fiscal_first_day_of_month,
		fiscal_last_day_of_month,
		fiscal_first_day_of_quarter,
		fiscal_last_day_of_quarter,
		fiscal_first_day_of_year,
		fiscal_last_day_of_year
	FROM silver.dwh_dim_date
	SET @end_load_time = GETDATE();
	PRINT '>>Loading to gold.dim_date completed successfully';
	PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
	PRINT '-------------------------------------------------------------------------------------------------';

	PRINT '>> Dimension Tables loaded successfully.';
	PRINT '=================================================================================================';
-- =========================================================================================================================
	--Sales Fact
	PRINT '------------------------------------------';
	PRINT 'Loading Fact Table';
	PRINT '------------------------------------------';

	-- gold.fact_sales
	PRINT '>>Preparing to truncate and load gold.fact_sales';
	SET @start_load_time = GETDATE();
-- Truncate
	PRINT'>> Truncating Table : gold.fact_sales';
	TRUNCATE TABLE gold.fact_sales;
	PRINT'>> Inserting Data Into : gold.fact_sales';
-- Insert

	
	
	



	
	
	



