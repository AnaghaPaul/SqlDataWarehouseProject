-- ___________________________________________________________Cohort Analysis___________________________________________________________________________________
/* A Cohort Analysis compares similar groups over time.*/
-- Type of cohort analysis - Returnship - Repeat Purchase Behaviour

-- Assigning each customers to cohorts according to the acquisition year

SELECT
MIN(o.order_year) AS cohort,
s.customer_key AS customer_key
FROM
gold.fact_sales AS s
JOIN
gold.dim_order_date AS o
ON s.order_date_key = o.order_date_key
GROUP BY s.customer_key
ORDER BY MIN(o.order_year);

-- Total customers in each cohort
WITH customer_cohort AS
(
SELECT
s.customer_key AS customer_key,
MIN(o.order_year) AS cohort
FROM
gold.fact_sales AS s
JOIN
gold.dim_order_date AS o
ON s.order_date_key = o.order_date_key
GROUP BY s.customer_key
)
SELECT cohort, 
COUNT(DISTINCT customer_key) AS total_customers
FROM customer_cohort
GROUP BY cohort
ORDER BY cohort;
/*
cohort	    total_customers
NULL	    2
2010	    14
2011	    2216
2012	    3225
2013	    12521
2014	    506
*/

-- Revenue acquired in each year per cohort

WITH customer_cohort AS
(
SELECT
    s.customer_key,
    MIN(o.order_year) AS cohort
FROM gold.fact_sales s
JOIN gold.dim_order_date o
    ON s.order_date_key = o.order_date_key
GROUP BY s.customer_key
)

SELECT
    c.cohort,
    SUM(CASE WHEN o.order_year IS NULL THEN s.sales_amount ELSE 0 END) AS revenue_null,
    SUM(CASE WHEN o.order_year = 2010 THEN s.sales_amount ELSE 0 END) AS revenue_2010,
    SUM(CASE WHEN o.order_year = 2011 THEN s.sales_amount ELSE 0 END) AS revenue_2011,
    SUM(CASE WHEN o.order_year = 2012 THEN s.sales_amount ELSE 0 END) AS revenue_2012,
    SUM(CASE WHEN o.order_year = 2013 THEN s.sales_amount ELSE 0 END) AS revenue_2013,
    SUM(CASE WHEN o.order_year = 2014 THEN s.sales_amount ELSE 0 END) AS revenue_2014

FROM customer_cohort c
JOIN gold.fact_sales s
    ON c.customer_key = s.customer_key
JOIN gold.dim_order_date o
    ON s.order_date_key = o.order_date_key

GROUP BY c.cohort
    
/*
cohort	revenue_null	revenue_2010	revenue_2011	revenue_2012	revenue_2013	revenue_2014
NULL	34             	0            	0            	0              	0            	0
2010	0            	43419        	0            	0            	33796        	0
2011	2344           	0            	7075088	        60955	        4325414        	0
2012	2295        	0            	0            	5781276	        6096229        	0
2013	319            	0	            0            	0	            5889439	        19593
2014	0            	0	            0            	0            	0            	26049
*/

-- Revenue growth each year
WITH customer_cohort AS
(
SELECT
    s.customer_key,
    MIN(o.order_year) AS cohort
FROM gold.fact_sales s
JOIN gold.dim_order_date o
    ON s.order_date_key = o.order_date_key
GROUP BY s.customer_key
),

cohort_revenue AS
(
SELECT
    c.cohort,
    SUM(CASE WHEN o.order_year = 2010 THEN s.sales_amount ELSE 0 END) AS revenue_2010,
    SUM(CASE WHEN o.order_year = 2011 THEN s.sales_amount ELSE 0 END) AS revenue_2011,
    SUM(CASE WHEN o.order_year = 2012 THEN s.sales_amount ELSE 0 END) AS revenue_2012,
    SUM(CASE WHEN o.order_year = 2013 THEN s.sales_amount ELSE 0 END) AS revenue_2013,
    SUM(CASE WHEN o.order_year = 2014 THEN s.sales_amount ELSE 0 END) AS revenue_2014

FROM customer_cohort c
JOIN gold.fact_sales s
    ON c.customer_key = s.customer_key
JOIN gold.dim_order_date o
    ON s.order_date_key = o.order_date_key

GROUP BY c.cohort
)

SELECT
    cohort,
	(revenue_2011 - revenue_2010) * 100.0 / NULLIF(revenue_2010,0) AS growth_2011,
    (revenue_2012 - revenue_2011) * 100.0 / NULLIF(revenue_2011,0) AS growth_2012,
    (revenue_2013 - revenue_2012) * 100.0 / NULLIF(revenue_2012,0) AS growth_2013,
    (revenue_2014 - revenue_2013) * 100.0 / NULLIF(revenue_2013,0) AS growth_2014

FROM cohort_revenue
ORDER BY cohort;

/*
cohort    	growth_2011            	growth_2012            	growth_2013	            growth_2014
NULL	    NULL                   	NULL	                NULL	                NULL
2010	    -100.000000000000	    NULL	                NULL	                -100.000000000000
2011	    NULL	                -99.138455945706	    6996.077434172750	    -100.000000000000
2012	    NULL                	NULL                	5.447811175249	        -100.000000000000
2013	    NULL                	NULL                	NULL                	-99.667319756601
2014    	NULL	                NULL                	NULL                	NULL
*/
--_____________________________________________________________________YEAR 2013 - comparing customers according to the month they arrived_________________________________
WITH customer_cohort AS
(SELECT
        f.customer_key AS customer_key,
        MIN(s.shipping_year) AS first_shipping_year,
        MIN(s.shipping_month) AS first_shipping_month,
        s.shipping_month_name AS month
    FROM gold.fact_sales AS f
    JOIN gold.dim_shipping_date AS s
        ON f.shipping_date_key = s.shipping_date_key
    GROUP BY f.customer_key, s.shipping_month_name, s.shipping_month)
SELECT
c.month,
COUNT(DISTINCT c.customer_key) AS total_customers
FROM customer_cohort c
JOIN gold.fact_sales s
    ON c.customer_key = s.customer_key
JOIN gold.dim_order_date o
    ON s.order_date_key = o.order_date_key
WHERE c.first_shipping_year = 2013
GROUP BY c.month,c.first_shipping_month
ORDER BY c.first_shipping_month
/*
month	    customers
January	    465
October	    1923
November	2018
December	2117
February	1242
March	    1596
April	    1538
May        	1621
June	    1886
July	    1756
August	    1828
September	1746
*/

WITH customer_cohort AS
(
SELECT
    f.customer_key,
    MIN(o.order_year)  AS first_order_year,
    MIN(o.order_month) AS first_order_month
FROM gold.fact_sales f
JOIN gold.dim_order_date o
    ON f.order_date_key = o.order_date_key
GROUP BY f.customer_key
)

SELECT
    c.first_order_month,

    SUM(CASE WHEN o.order_month = 1  THEN s.sales_amount ELSE 0 END) AS revenue_jan,
    SUM(CASE WHEN o.order_month = 2  THEN s.sales_amount ELSE 0 END) AS revenue_feb,
    SUM(CASE WHEN o.order_month = 3  THEN s.sales_amount ELSE 0 END) AS revenue_mar,
    SUM(CASE WHEN o.order_month = 4  THEN s.sales_amount ELSE 0 END) AS revenue_apr,
    SUM(CASE WHEN o.order_month = 5  THEN s.sales_amount ELSE 0 END) AS revenue_may,
    SUM(CASE WHEN o.order_month = 6  THEN s.sales_amount ELSE 0 END) AS revenue_jun,
    SUM(CASE WHEN o.order_month = 7  THEN s.sales_amount ELSE 0 END) AS revenue_jul,
    SUM(CASE WHEN o.order_month = 8  THEN s.sales_amount ELSE 0 END) AS revenue_aug,
    SUM(CASE WHEN o.order_month = 9  THEN s.sales_amount ELSE 0 END) AS revenue_sep,
    SUM(CASE WHEN o.order_month = 10 THEN s.sales_amount ELSE 0 END) AS revenue_oct,
    SUM(CASE WHEN o.order_month = 11 THEN s.sales_amount ELSE 0 END) AS revenue_nov,
    SUM(CASE WHEN o.order_month = 12 THEN s.sales_amount ELSE 0 END) AS revenue_dec

FROM customer_cohort c
JOIN gold.fact_sales s
    ON c.customer_key = s.customer_key
JOIN gold.dim_order_date o
    ON s.order_date_key = o.order_date_key

WHERE c.first_order_year = 2013

GROUP BY c.first_order_month
ORDER BY c.first_order_month;
