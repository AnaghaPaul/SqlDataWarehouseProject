/* This SQL script is part of sql based data analysis, the intent of this step to explore the data warehouse and components and data profiling*/

-- Where Data was generated ?
-- How data is stored?
-- ------------------------------------------------------------------------------------------------------------------------------------
-- The data is stored in the DataWarehouse database which follows a medallion architecture.
/*
The cleaned and analysis ready data is stored in the gold layer of the databse, as 6 objects or views in which 3 are roleplaying date dimensions.
- dim.customers
- dim.products
- dim_order_date
- dim_shipping_date
- dim_due_date
- fact_sales
*/
-- Query out Overview of database organization and objects in a database
SELECT * FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA;
/*
-- =======================================================================================================================================
Result :
-- ----------------------------------------------------------------------------------------------------------------------------------------

TABLE_CATALOG	TABLE_SCHEMA	TABLE_NAME			TABLE_TYPE
DataWarehouse	bronze			crm_prd_info		BASE TABLE
DataWarehouse	bronze			erp_cust_az12		BASE TABLE
DataWarehouse	bronze			erp_loc_a101		BASE TABLE
DataWarehouse	bronze			erp_px_cat_g1v2		BASE TABLE
DataWarehouse	bronze			crm_cust_info		BASE TABLE
DataWarehouse	bronze			crm_sales_details	BASE TABLE
DataWarehouse	gold			dim_customers		VIEW
DataWarehouse	gold			dim_products		VIEW
DataWarehouse	gold			dim_order_date		VIEW
DataWarehouse	gold			dim_shipping_date	VIEW
DataWarehouse	gold			dim_due_date		VIEW
DataWarehouse	gold			fact_sales			VIEW
DataWarehouse	silver			crm_prd_info		BASE TABLE
DataWarehouse	silver			crm_sales_details	BASE TABLE
DataWarehouse	silver			erp_cust_az12		BASE TABLE
DataWarehouse	silver			erp_loc_a101		BASE TABLE
DataWarehouse	silver			erp_px_cat_g1v2		BASE TABLE
DataWarehouse	silver			dwh_dim_date		BASE TABLE
DataWarehouse	silver			crm_cust_info		BASE TABLE*/
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- ======================================================================================================================================
-- Query out columns of views in gold layer
-- dim_customers
SELECT  COLUMN_NAME,
		DATA_TYPE,
		CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'dim_customers'
-- =====================================================================================================================================
-- Result :
-- ------------------------------------------------------------------------------------------------------------------------------------
/*
COLUMN_NAME      	  DATA_TYPE    	MAX_LENGTH
customer_key      	bigint      	NULL
customer_id        	int          	NULL
customer_number    	nvarchar    	50
first_name          nvarchar    	50
last_name          	nvarchar    	50
country            	nvarchar    	50
marital_status    	nvarchar	    50
gender            	nvarchar	    50
birthdate          	date        	NULL
create_date        	date        	NULL*/
-- ------------------------------------------------------------------------------------------------------------------------------------
-- dim_products
SELECT  COLUMN_NAME,
		DATA_TYPE,
		CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'dim_products'

/*
-- =========================================================================================================================================
-- Results:
-- -----------------------------------------------------------------------------------------------------------------------------------------
COLUMN_NAME      	DATA_TYPE  	MAX_LENGTH
product_key      	bigint     	NULL
product_id      	int        	NULL
product_number  	nvarchar   	50
product_name    	nvarchar   	50
category_id	      nvarchar	  50
category	        nvarchar  	50
subcategory      	nvarchar  	50
maintenance      	nvarchar	  50
cost            	int        	NULL
product_line    	nvarchar	  50
start_date      	date	      NULL*/
-- -----------------------------------------------------------------------------------------------------------------------------------
-- dim_order_date
SELECT  COLUMN_NAME,
		DATA_TYPE,
		CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'dim_order_date'
/*
-- ======================================================================================================================================
-- Result:
-- ---------------------------------------------------------------------------------------------------------------------------------------
COLUMN_NAME							DATA_TYPE	MAX_LENGTH
order_date_key						int			NULL
order_date							datetime	NULL
order_full_date						char		10
order_day_of_month					varchar		2
order_day_suffix					varchar		4
order_day_name						varchar		9
order_day_of_week					char		1
order_day_of_week_in_month			varchar		2
order_day_of_week_in_year			varchar		2
order_day_of_quarter				varchar		3
order_day_of_year					varchar		3
order_week_of_month					varchar		1
order_week_of_quarter				varchar		2
order_week_of_year					varchar		2
order_month							varchar		2
order_month_name					varchar		9
order_month_of_quarter				varchar		2
order_quarter						char		1
order_quarter_name					varchar		9
order_year							char		4
order_year_name						char		7
order_month_year					char		10
order_mmyyyy						char		6
order_first_day_of_month			date		NULL
order_last_day_of_month				date		NULL
order_first_day_of_quarter			date		NULL
order_last_day_of_quarter			date		NULL
order_first_day_of_year				date		NULL
order_last_day_of_year				date		NULL
order_season						char		15
order_is_holiday					bit			NULL
order_is_weekday					bit			NULL
order_holiday_name					varchar		50
order_fiscal_day_of_year			varchar		3
order_fiscal_week_of_year			varchar		3
order_fiscal_month					varchar		2
order_fiscal_quarter				char		1
order_fiscal_quarter_name			varchar		9
order_fiscal_year					char		4
order_fiscal_year_name				char		7
order_fiscal_month_year				char		10
order_fiscal_mmyyyy					char		6
order_fiscal_first_day_of_month		date		NULL
order_fiscal_last_day_of_month		date		NULL
order_fiscal_first_day_of_quarter	date		NULL
order_fiscal_last_day_of_quarter	date		NULL
order_fiscal_first_day_of_year		date		NULL
order_fiscal_last_day_of_year		date		NULL
*/
-- ----------------------------------------------------------------------------------------------------------------------------------

-- fact_sales
SELECT  COLUMN_NAME,
		DATA_TYPE,
		CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'fact_sales'

/*
-- ======================================================================================================================================
-- Result:
-- ---------------------------------------------------------------------------------------------------------------------------------------
COLUMN_NAME			DATA_TYPE	MAX_LENGTH
order_number		nvarchar	50
product_key			bigint		NULL
customer_key		bigint		NULL
order_date_key		int			NULL
shipping_date_key	int			NULL
due_date_key		int			NULL
sales_amount		int			NULL
quantity			int			NULL
price				int			NULL
*/
-- ----------------------------------------------------------------------------------------------------------------------------------
-- Quering number of records in each views
SELECT COUNT(*) AS records
FROM gold.dim_customers

UNION ALL

SELECT COUNT(*) AS records
FROM gold.dim_products

UNION ALL

SELECT COUNT(*) AS records
FROM gold.fact_sales

*/
-- ===================================================================================================================================
-- Result:
-- -----------------------------------------------------------------------------------------------------------------------------------
/*
records
18484
295
60398
*/






-- ==============================================================================================================================================================================================================
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Profile>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Checking data quality
-- ==============================================================================================================================================================================================================
-- _________________________________________________________________________Fact Sales____________________________________________________________________________________________________________________________
-- STEP 1
-- Detecting Duplicates
-- Expected Result : 0
-- ______________________________________________________________________________________________________________________________________________________________________________________________________________
SELECT COUNT(*)
FROM
(SELECT 
	order_number,
	product_key,
	customer_key,
	order_date_key,
	shipping_date_key,
	due_date_key,
	sales_amount,
	quantity,
	price,
COUNT(*) as records
FROM gold.fact_sales
GROUP BY 
	order_number,
	product_key,
	customer_key,
	order_date_key,
	shipping_date_key,
	due_date_key,
	sales_amount,
	quantity,
	price
)a
WHERE records > 1;
-- **************************************************************************************************************************************************************************************************************
--  RESULT :
-- 0
-- The Fact table data does not have any duplicates.
-- **************************************************************************************************************************************************************************************************************


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STEP 2
-- Checking Null values
-- -- Expected total_rows value for each field
-- ______________________________________________________________________________________________________________________________________________________________________________________________________________
 SELECT
        COUNT(*) AS total_rows,
		COUNT(order_number) AS order_number_filled,
		COUNT(product_key) AS product_key_filled,
		COUNT(customer_key) AS customer_key_filled,
        COUNT(order_date_key) AS order_date_key_filled,
        COUNT(shipping_date_key) AS shipping_date_key_filled,
        COUNT(due_date_key) AS due_date_key_filled,
        COUNT(sales_amount) AS sales_amount_filled,
        COUNT(quantity) AS quantity_filled,
        COUNT(price) AS price_filled
    FROM gold.fact_sales

	 
-- ****************************************************************************************************************************************************************************************************************
/*RESULT :
-- Expected total_rows value for each field
total_rows	order_number_filled	product_key_filled	customer_key_filled		order_date_key_filled	shipping_date_key_filled	due_date_key_filled		sales_amount_filled		quantity_filled		price_filled
60398		60398				60398				60398					60379				 	60398						 60398					60398					60398				60398
-- ****************************************************************************************************************************************************************************************************************
*/
-- Explanation and Insight
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Invalid order dates found in source system data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- >> Mising values in order date -- 19 values
-- The order dates were set to NULL intentionally because the source values are invalid. 
-- Updating them in ETL would require guessing a value, which would introduce assumptions and mask the fact that the original data was invalid. 
-- This could mislead analysts, as they would have no visibility into the underlying data quality issue.
-- At this stage, the rows should remain NULL to explicitly indicate invalid data.
-- Any decision to correct or derive values should only be made after consulting with domain experts and,
-- if required in the future, handled explicitly in ETL or stored as a separate derived field.
-- Besides the shipping_date is available - In our business model,  the sales month is defined as the shipping month (the date the product leaves the warehouse and ownership transfers to the buyer). */
-- ================================================================================================================================================================================================================

-- Step 3	 
-- Visualizing Distributions
-- Checking Distributions or frequency checks
-->> Objective
-- allows to understand the range of values that exist in the data
-- how often they occur
-- whether there are nulls
-- whether negative values exist alongside positive ones
-- ______________________________________________________________________________________________________________________________________________________________________________________________________________
-- order_number
SELECT order_number,
	 COUNT(*) AS frequency
FROM gold.fact_sales
GROUP BY
order_number;
-- The results can be visualized through techniques including stem-and-leaf plots, box plots, and histograms.
-- Result (Note : Limited to 5 rows)
/*
order_number	frequency
SO50818			1
SO55367			4
SO62535			3
SO64083			3
SO65048			2
*/
-- Insight >> Order_number is not a unique field, multiple products bought in single order is represented as multiple records. 
-- Grain of fact_table : One row represents one product purchased by one customer in a single order (order line item level).
-- This is the reason for the duplicates in the field. The result is expected.
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- product_key (Frequency Distribution)
SELECT
	product_key,
COUNT(*) AS frequency
FROM gold.fact_sales
GROUP BY
product_key;
-- The results can be visualized through techniques including stem-and-leaf plots, box plots, and histograms.
-- Result (Note : Limited to 5 rows)
/*
product_key	frequency
46			53
115			48
138			232
284			1396
161			147
*/
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- customer_key (Frequency Distribution)
SELECT 
	customer_key,
COUNT(*) AS frequency
FROM gold.fact_sales
GROUP BY
customer_key;
-- The results can be visualized through techniques including stem-and-leaf plots, box plots, and histograms.
-- Result (Note : Limited to 5 rows)
/*
customer_key	frequency
5621			3
5692			4
451				9
4696			8
1447			4
*/
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------======
-- sales_amount (continuous variable) - needs binning
SELECT
  ntile,
  MIN(order_sales) AS lower_bound,
  MAX(order_sales) AS upper_bound,
  COUNT(*) AS orders
FROM (
  SELECT
    order_number,
    SUM(sales_amount) AS order_sales,
    NTILE(10) OVER (ORDER BY SUM(sales_amount)) AS ntile
  FROM gold.fact_sales
  GROUP BY order_number
) a
GROUP BY ntile;
/*
-- The results can be visualized through techniques including stem-and-leaf plots, box plots, and histograms.
-- >> Result :
ntile	lower_bound	upper_bound	orders
1		2			24			2766
2		24			38			2766
3		38			63			2766
4		63			94			2766
5		94			595			2766
6		595			1000		2766
7		1000		2049		2766
8		2049		2352		2766
9		2352		2451		2766
10		2451		3578		2765
*/
-- =========================================================================================================================================================================================================================
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>dim_products>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--category (Frequency Distribution)
SELECT
	category,
	COUNT(*) AS frequency
FROM gold.dim_products
GROUP BY category;
-- ==========================================================================================================================================================================================================================
-- Result :
-- The results can be visualized through techniques including stem-and-leaf plots, box plots, and histograms.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
category		frequency
NULL			7
Accessories		29
Bikes			97
Clothing		35
Components		127
*/
-- There are 7 Null values in category.
-- From filtering the null values and looking further , the 7 products are pedals of somekind, after consulting with experts it can be may be classified into components.
-- This then can be updated in silver layer and the data quality issue can be raised.
-- ==============================================================================================================================================================================================================================
-- ==============================================================================================================================================================================================================================
-- updated till now on 17th feb 2026
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Explore>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
