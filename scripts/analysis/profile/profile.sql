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
