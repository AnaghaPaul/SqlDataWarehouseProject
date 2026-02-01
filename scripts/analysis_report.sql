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
-- =====================================================================================================================================
-- >> Profile 
-- -------------------------------------------------------------------------------------------------------------------------------------
-- Identifying the domain the data or business falls in
-- >>The business is Ecommerce business model.
-- Checking data quality
-- -------------------------------------------------------------------------------------------------------------------------------------
-- >>> Profile  ---- Detecting Duplicates
SELECT COUNT(*)
FROM
(SELECT 
	order_number,
	product_key,
	customer_key,
	order_date,
	shipping_date,
	due_date,
	sales_amount,
	quantity,
	price,
COUNT(*) as records
FROM gold.fact_sales
GROUP BY 
	order_number,
	product_key,
	customer_key,
	order_date,
	shipping_date,
	due_date,
	sales_amount,
	quantity,
	price
)a
WHERE records > 1;
--  RESULT :
-- 0

-- The Data does not have any duplicates.
-- ====================================================================================================================================
-- Profile -- Null values
 SELECT
        COUNT(*) AS total_rows,
		COUNT(order_number) AS order_number_filled,
		COUNT(product_key) AS product_key_filled,
		COUNT(customer_key) AS customer_key_filled,
        COUNT(order_date) AS order_date_filled,
        COUNT(shipping_date) AS shipping_date_filled,
        COUNT(due_date) AS due_date_filled,
        COUNT(sales_amount) AS sales_amount_filled,
        COUNT(quantity) AS quantity_filled,
        COUNT(price) AS price_filled
    FROM gold.fact_sales

/*RESULT :
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
total_rows	order_number_filled	product_key_filled	customer_key_filled	order_date_filled	shipping_date_filled	due_date_filled	sales_amount_filled	quantity_filled	price_filled
60398		60398				60398				60398				60379				 60398					 60398			60398				60398			60398
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
-->> Mising values in order date--19 values
/*The order dates were set to NULL intentionally because the source values are invalid. 
Updating them in ETL would require guessing a value, which would introduce assumptions and mask the fact that the original data was invalid. 
This could mislead analysts, as they would have no visibility into the underlying data quality issue.
At this stage, the rows should remain NULL to explicitly indicate invalid data.
Any decision to correct or derive values should only be made after consulting with domain experts and,
if required in the future, handled explicitly in ETL or stored as a separate derived field.
Besides the shipping_date is available - In our business model,  the sales month is defined as the shipping month (the date the product leaves the warehouse and ownership transfers to the buyer). */
-- ======================================================================================================================================
-- Profile - Distributions
-- Checking Distributions or frequency checks
-->> Objective
-- allows to understand the range of values that exist in the data
-- how often they occur
-- whether there are nulls
-- whether negative values exist alongside positive ones
-- --------------------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>- gold.fact_sales ->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
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
-- 		   >> This is the reason for the duplicates in the field.
-- ----------------------------------------------------------------------------------------------------------------------------------------
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
-- ---------------------------------------------------------------------------------------------------------------------------------------
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
-- ---------------------------------------------------------------------------------------------------------------------------------------
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
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- ===========================================================================================================================================
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Prepare>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- -------------------------------------------------------------------------------------------------------------------------------------------
-->> Shaping 

-- Total sales amount per order
SELECT 
order_number, 
customer_key,
SUM(sales_amount) AS total_amount
FROM gold.fact_sales
GROUP BY order_number, customer_key;
-- Result (Note : Limited to 5 rows)
/*
order_number	customer_key	total_amount
SO52587			16730			13
SO67633			16251			2517
SO68943			10480			1149
SO72957			17594			35
SO74163			15529			129
*/
-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- Customer Life Time Value of each customer

WITH customer_metrics AS (
    SELECT
        customer_key,
        MIN(YEAR(shipping_date)) AS acquisition_year,
        COUNT(DISTINCT order_number) AS no_of_orders,
        SUM(sales_amount) AS customer_lifetime_value
    FROM gold.fact_sales
    GROUP BY customer_key
)
SELECT 
dim_customers.customer_id,
dim_customers.customer_number,
dim_customers.first_name,
dim_customers.last_name,
dim_customers.country,
dim_customers.marital_status,
dim_customers.birthdate,
customer_metrics.acquisition_year,
customer_metrics.no_of_orders,
customer_metrics.customer_lifetime_value
FROM gold.dim_customers AS dim_customers
LEFT JOIN
customer_metrics
ON
dim_customers.customer_key =customer_metrics.customer_key
ORDER BY dim_customers.customer_key;

-- Result (Note : Limited to 5 rows)
/*
customer_id	customer_number	first_name	last_name	country		marital_status	birthdate		acquisition_year	no_of_orders	customer_lifetime_value
11000		AW00011000		Jon			Yang		Australia	Married			1971-10-06		2011				3				8249
11001		AW00011001		Eugene		Huang		Australia	Single			1976-05-10		2011				3				6384
11002		AW00011002		Ruben		Torres		Australia	Married			1971-02-09		2011				3				8114
11003		AW00011003		Christy		Zhu			Australia	Single			1973-08-14		2011				3				8139
11004		AW00011004		Elizabeth	Johnson		Australia	Single			1979-08-05		2011				3				8196
*/
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
	 
-- ==============================================================================================================================================
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Analysis>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.>
-- ----------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Trend Analysis>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- --------------------------------------------------------------------------------------------------------------------------------------
-- Sales Trend
-- YoY
SELECT 
	YEAR(shipping_date) AS sales_year,
	SUM(sales_amount) as total_sales
FROM
gold.fact_sales
GROUP BY YEAR(shipping_date)
ORDER BY YEAR(shipping_date);
-->>> Result :
-- The result can be visualized using line plots to identify patterns and trends.
/*
sales_year	total_sales
2011		6978386
2012		5800826
2013		16279963
2014		297075
*/	
-- ----------------------------------------------------------------------------------------------------------------------------------------
-- Sales Trend
-- MoM
SELECT
YEAR(shipping_date) AS sales_year,
CASE MONTH(shipping_date)
	WHEN 1 THEN 'january'
	WHEN 2 THEN 'february'
	WHEN 3 THEN 'march'
	WHEN 4 THEN 'april'
	WHEN 5 THEN 'may'
	WHEN 6 THEN 'june'
	WHEN 7 THEN 'july'
	WHEN 8 THEN 'august'
	WHEN 9 THEN 'september'
	WHEN 10 THEN 'october'
	WHEN 11 THEN 'november'
	WHEN 12 THEN 'december'
	END AS sales_month,
SUM(sales_amount) as total_sales
FROM
gold.fact_sales
GROUP BY YEAR(shipping_date), MONTH(shipping_date)
ORDER BY YEAR(shipping_date), MONTH(shipping_date) ;
-- >>> Result :
-- The result can be visualized using line plots to identify patterns and trends.
/*
sales_year	sales_month	total_sales
2011		january		406476
2011		february	461058
2011		march		492253
2011		april		498552
2011		may			557262
2011		june		689791
2011		july		643803
2011		august		586934
2011		september	632758
2011		october		624961
2011		november	738263
2011		december	646275
2012		january		534284
2012		february	497886
2012		march		404137
2012		april		395466
2012		may			347214
2012		june		536737
2012		july		463752
2012		august		538066
2012		september	429777
2012		october		545698
2012		november	518383
2012		december	589426
2013		january		840652
2013		february	777978
2013		march		1037653
2013		april		1010572
2013		may			1182485
2013		june		1621741
2013		july		1404303
2013		august		1545666
2013		september	1424867
2013		october		1596842
2013		november	1835728
2013		december	2001476
2014		january		289367
2014		february	7708
*/
-- -------------------------------------------------------------------------------------------------------------------------------------------------

