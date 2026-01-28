/* Analysis*/
/* The type of business is E-commerce , where  a visitor buys something from a web based retailer*/
-- Before we do any further analysis , let's look the objective or aim of the business - where should the business focus ? 
-- This can be identified by deciding the mode of E-commerce the company falls in.
-- This can be derived from the data, by looking at the annual re-purchase rate of this year compared to previous year.
-- The historical data of sales orders can be queried from silver layer from silver.crm_sales_details
--To find the distinct years
SELECT
  DISTINCT(YEAR(sls_order_dt)) 
  FROM silver.crm_sales_details; 
--Result : 2010, 2011, 2012, 2013, 2014
-- annual repurchase rate
WITH yearly_customers AS (
    SELECT DISTINCT
        sls_cust_id,
        YEAR(sls_order_dt) AS order_year
    FROM silver.crm_sales_details
    WHERE YEAR(sls_order_dt) IN (2013, 2014)
)
SELECT
    100.0 *
    COUNT(DISTINCT CASE 
        WHEN y2013.sls_cust_id IS NOT NULL 
         AND y2014.sls_cust_id IS NOT NULL 
        THEN y2013.sls_cust_id 
    END)
    /
    NULLIF(COUNT(DISTINCT y2013.sls_cust_id), 0) 
    AS annual_repurchase_rate
FROM yearly_customers y2013
  
LEFT JOIN yearly_customers y2014
    ON y2013.sls_cust_id = y2014.sls_cust_id
   AND y2014.order_year = 2014
WHERE y2013.order_year = 2013;

/*result : 1.88% < 40% --> E-Commerce type is aquisition mode, the buyers of this business usually do not repurchase the product,
this may be due to the business selling one-time purchase products and customer does not need to up-grade soon.
Loyalty programs are not good long-term investments, instead the company need to focus on acquiring new customers*/
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



