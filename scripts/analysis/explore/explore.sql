-- ===================================================================================================================================
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.Queries and Analysis*/>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- ====================================================================================================================================
-- >> Explore 
-- Where Data was generated ?
-- Databases which data is stored?
-- ------------------------------------------------------------------------------------------------------------------------------------
-- Solution
/* 
1)  Data was generated as result of business process of a E-commerce web based retailer which specializes on selling products related to
sports such as bikes, clothings, gears and so on.
2) The data is stored in the DataWarehouse database which follows a medallion architecture.
The cleaned and analysis ready data is stored in the gold layer of the databse, as 3 objects or views.
- dim.customers
- dim.products
- fact_sales
*/
-- Query out Overview of database organization and objects in a database
SELECT * FROM INFORMATION_SCHEMA.TABLES;
/*
-- =======================================================================================================================================
Result :
-- ----------------------------------------------------------------------------------------------------------------------------------------

TABLE_CATALOG	  TABLE_SCHEMA	TABLE_NAME        	TABLE_TYPE
DataWarehouse  	silver      	crm_sales_details  	BASE TABLE
DataWarehouse	  gold        	dim_customers      	VIEW
DataWarehouse	  gold        	dim_products      	VIEW
DataWarehouse	  gold        	fact_sales        	VIEW
DataWarehouse  	bronze      	crm_prd_info      	BASE TABLE
DataWarehouse  	bronze      	erp_cust_az12	      BASE TABLE
DataWarehouse  	bronze      	erp_loc_a101      	BASE TABLE
DataWarehouse  	bronze      	erp_px_cat_g1v2    	BASE TABLE
DataWarehouse  	bronze      	crm_cust_info      	BASE TABLE
DataWarehouse	  bronze      	crm_sales_details  	BASE TABLE
DataWarehouse  	silver      	crm_cust_info      	BASE TABLE
DataWarehouse  	silver	      erp_cust_az12      	BASE TABLE
DataWarehouse  	silver      	erp_loc_a101	      BASE TABLE
DataWarehouse	  silver      	erp_px_cat_g1v2    	BASE TABLE
DataWarehouse  	silver      	crm_prd_info      	BASE TABLE*/
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
COLUMN_NAME    	DATA_TYPE    	MAX_LENGTH
order_number  	nvarchar    	50
product_key    	bigint      	NULL
customer_key  	bigint      	NULL
order_date    	date        	NULL
shipping_date  	date        	NULL
due_date      	date        	NULL
sales_amount  	int          	NULL
quantity      	int          	NULL
price	          int          	NULL
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

