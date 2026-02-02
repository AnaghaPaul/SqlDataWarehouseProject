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
