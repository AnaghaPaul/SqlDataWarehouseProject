/*Queries and Analysis*/
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
if required in the future, handled explicitly in ETL or stored as a separate derived field.*/
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
-->> Shaping 
SELECT order_number, 
customer_key,
SUM(sales_amount) AS total_amount
FROM gold.fact_sales
GROUP BY order_number, customer_key;

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
        MIN(YEAR(order_date)) AS acquisition_year,
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
customer_id	customer_number	first_name	last_name	country			marital_status	birthdate		acquisition_year	no_of_orders	customer_lifetime_value
11000		AW00011000		Jon			Yang		Australia		Married			1971-10-06		2011				3				8249
11001		AW00011001		Eugene		Huang		Australia		Single			1976-05-10		2011				3				6384
11002		AW00011002		Ruben		Torres		Australia		Married			1971-02-09		2011				3				8114
11003		AW00011003		Christy		Zhu			Australia		Single			1973-08-14		2010				3				8139
11004		AW00011004		Elizabeth	Johnson		Australia		Single			1979-08-05		2011				3				8196
*/
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
	 
SELECT 
category, YEAR(fs.order_date) AS order_year,
SUM(quantity) AS Total_quantity_sold,
SUM(sales_amount) AS Total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN
gold.dim_products AS dp
ON fs.product_key=dp.product_key
GROUP BY dp.category, YEAR(fs.order_date)
ORDER BY order_year ASC,Total_revenue DESC, Total_quantity_sold DESC;

-- Distribution of overall sales of 
SELECT 
category,
SUM(quantity) AS Total_quantity_sold,
SUM(sales_amount) AS Total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN
gold.dim_products AS dp
ON fs.product_key=dp.product_key
GROUP BY dp.category
ORDER BY Total_revenue DESC, Total_quantity_sold DESC;


-- Analysis 

/* The type of business is E-commerce , where  a visitor buys something from a web based retailer*/
-- Before we do any further analysis , let's look the objective or aim of the business - where should the business focus ? 
-- This can be identified by deciding the mode of E-commerce the company falls in.
-- This can be derived from the data, by looking at the annual re-purchase rate of this year compared to previous year.
-- The historical data of sales orders can be queried from fact_sales in gold layer
--To find the distinct years
WITH yearly_customers AS (
    SELECT DISTINCT
        customer_key,
        YEAR(order_date) AS order_year
    FROM gold.fact_sales
    WHERE YEAR(order_date) IN (2013, 2014)
)
SELECT
    100.0 *
    COUNT(DISTINCT CASE 
        WHEN y2013.customer_key IS NOT NULL 
         AND y2014.customer_key IS NOT NULL 
        THEN y2013.customer_key 
    END)
    /
    NULLIF(COUNT(DISTINCT y2013.customer_key), 0) 
    AS annual_repurchase_rate
FROM yearly_customers y2013
  
LEFT JOIN yearly_customers y2014
    ON y2013.customer_key = y2014.customer_key
   AND y2014.order_year = 2014
WHERE y2013.order_year = 2013;
/*result : 1.88% < 40% --> E-Commerce type is aquisition mode, the buyers of this business usually do not repurchase the product,
this may be due to the business selling one-time purchase products and customer does not need to up-grade soon.
Loyalty programs are not good long-term investments, instead the company need to focus on acquiring new customers*/
-- This is further proved by the following fact that majority of the annual customers consists of new customers
WITH first_purchase AS (
    SELECT
        customer_key,
        MIN(order_date) AS first_order_date
    FROM gold.fact_sales
    GROUP BY customer_key
)
, new_customers AS (
    SELECT
        YEAR(first_order_date) AS acquisition_year,
        COUNT(customer_key) AS new_customers
    FROM first_purchase
    GROUP BY YEAR(first_order_date)
)

, active_customers AS (
    SELECT
        YEAR(order_date) AS order_year,
        COUNT(DISTINCT customer_key) AS active_customers
    FROM gold.fact_sales
    GROUP BY YEAR(order_date)
)
SELECT
    a.order_year,
    nc.new_customers,
    a.active_customers,
    ROUND((nc.new_customers * 1.0 / a.active_customers) * 100, 2) AS new_customer_rate_percent
FROM active_customers a
LEFT JOIN new_customers nc
       ON a.order_year = nc.acquisition_year
ORDER BY a.order_year;
/*
order_year	new_customers	active_customers	new_customer_rate_percent
NULL	NULL	15	NULL
2010	14	14	100.000000000000
2011	2216	2216	100.000000000000
2012	3225	3255	99.080000000000
2013	12521	17427	71.850000000000
2014	506	834	60.670000000000*/

WITH customer_metrics AS (
    SELECT
        customer_key,
        MIN(YEAR(order_date)) AS acquisition_year,
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


/*
customer_id	customer_number	first_name	last_name	country	marital_status	birthdate	acquisition_year	no_of_orders	customer_lifetime_value
11000	AW00011000	Jon	Yang	Australia	Married	1971-10-06	2011	3	8249
11001	AW00011001	Eugene	Huang	Australia	Single	1976-05-10	2011	3	6384
11002	AW00011002	Ruben	Torres	Australia	Married	1971-02-09	2011	3	8114
11003	AW00011003	Christy	Zhu	Australia	Single	1973-08-14	2010	3	8139
11004	AW00011004	Elizabeth	Johnson	Australia	Single	1979-08-05	2011	3	8196
11005	AW00011005	Julio	Ruiz	Australia	Single	1976-08-01	2010	3	8121
11006	AW00011006	Janet	Alvarez	Australia	Single	1976-12-02	2011	3	8119
11007	AW00011007	Marco	Mehta	Australia	Married	1969-11-06	2011	3	8211
11008	AW00011008	Rob	Verhoff	Australia	Single	1975-07-04	2011	3	8106
11009	AW00011009	Shannon	Carlson	Australia	Single	1969-09-29	2011	3	8091
*/

-- >> Key Business Metric: New Customer Growth (YoY)

-- Purpose:
-- Keeping track of this metric enables the business to:
-- 1. Monitor overall business growth over time
-- 2. Assess the effectiveness of marketing and acquisition campaigns
-- 3. Identify trends in customer acquisition and seasonality
-- 4. Make data-driven decisions to improve customer acquisition strategies
-- New Customer Growth (YoY) per year
WITH first_purchase AS (
    SELECT
        customer_key,
        MIN(order_date) AS first_purchase_date
    FROM gold.fact_sales
	WHERE order_date IS NOT NULL
    GROUP BY customer_key
),
new_customers AS (
    SELECT
        YEAR(first_purchase_date) AS acquisition_year,
        COUNT(customer_key) AS new_customers
    FROM first_purchase
    GROUP BY YEAR(first_purchase_date)
)
SELECT
    acquisition_year,
    new_customers,
    LAG(new_customers) OVER (ORDER BY acquisition_year) AS prev_year_new_customers,
    ROUND(
        ((new_customers - LAG(new_customers) OVER (ORDER BY acquisition_year)) * 1.0 /
        LAG(new_customers) OVER (ORDER BY acquisition_year)) * 100, 2
    ) AS new_customer_growth_percent
FROM new_customers
ORDER BY acquisition_year;
/*
acquisition_year	new_customers	prev_year_new_customers	new_customer_growth_percent
2010	14	NULL	NULL
2011	2216	14	15728.570000000000
2012	3225	2216	45.530000000000
2013	12521	3225	288.250000000000
2014	506	12521	-95.960000000000
*/


-- Note: 
-- The YoY growth for 2014 is significantly negative because the dataset for 2014 only contains partial-year data (e.g., January). 
-- For full-year comparisons, consider using only years with complete data or calculating Year-to-Date (YTD) growth for the current year.
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS active_customers,
    SUM(quantity) AS total_units_sold,
    SUM(sales_amount) AS total_revenue,
	((SUM(sales_amount)-LAG(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date)))*1.0/
	(LAG(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date))*1.0))*100.0 AS revenue_growth
FROM gold.fact_sales
GROUP BY YEAR(order_date)
ORDER BY order_year;

/*order_year	total_orders	active_customers	total_units_sold	total_revenue	revenue_growth
NULL	15	15	19	4992	NULL
2010	14	14	14	43419	769.7716346153846000
2011	2216	2216	2216	7075088	16194.9123655542504000
2012	3269	3255	3397	5842231	-17.4253238970313000
2013	21287	17427	52807	16344878	179.7711696096919000
2014	871	834	1970	45642	-99.7207565574977000*/






