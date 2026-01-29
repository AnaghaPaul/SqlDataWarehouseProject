/* Analysis*/
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






