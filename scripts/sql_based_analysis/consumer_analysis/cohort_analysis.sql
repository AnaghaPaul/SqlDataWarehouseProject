-- ___________________________________________________________Cohort Analysis___________________________________________________________________________________
/* A Cohort Analysis compares similar groups over time.*/
-- Type of cohort analysis - Returnship - Repeat Purchase Behaviour
SELECT
first_shipping_year AS cohort_year,
COUNT(customer_key) AS customers
FROM
(SELECT
f.customer_key AS customer_key,
MIN(s.shipping_year) AS first_shipping_year
FROM
gold.fact_sales AS f
JOIN
gold.dim_shipping_date  AS s
ON f.shipping_date_key = s.shipping_date_key
GROUP BY f.customer_key)a
GROUP BY first_shipping_year;
/*
cohort_year	total_customers
2014      	715
2013	      12371
2012	      3220
2011	      2178
*/
WITH customer_cohort AS(
SELECT
f.customer_key,
MIN(s.shipping_year) AS cohort_year,
SUM(f.sales_amount) AS revenue_per_customer
FROM
gold.fact_sales AS f
JOIN
gold.dim_shipping_date AS s
ON f.shipping_date_key=s.shipping_date_key
GROUP BY f.customer_key)
SELECT 
customer_cohort.cohort_year,
SUM(customer_cohort.revenue_per_customer) AS total_revenue_per_cohort
FROM customer_cohort
GROUP BY customer_cohort.cohort_year
ORDER BY customer_cohort.cohort_year;
/*
cohort_year	total_revenue_per_cohort
2011	      11289072
2012	      11969678
2013	      5973822
2014	      123678
*/
WITH customer_cohort AS (
    SELECT
        f.customer_key,
        MIN(s.shipping_year) AS cohort_year,
        SUM(f.sales_amount) AS revenue_per_customer
    FROM gold.fact_sales AS f
    JOIN gold.dim_shipping_date AS s
        ON f.shipping_date_key = s.shipping_date_key
    GROUP BY f.customer_key
),
cohort_revenue AS (
    SELECT
        cohort_year,
        SUM(revenue_per_customer) AS total_revenue_per_cohort
    FROM customer_cohort
    GROUP BY cohort_year
)
SELECT
    cohort_year,
    total_revenue_per_cohort,
    LAG(total_revenue_per_cohort) OVER (ORDER BY cohort_year) AS prev_year_revenue,
    ROUND(
        (total_revenue_per_cohort - LAG(total_revenue_per_cohort) OVER (ORDER BY cohort_year)) 
        * 100.0 / LAG(total_revenue_per_cohort) OVER (ORDER BY cohort_year),
        2
    ) AS revenue_growth_pct
FROM cohort_revenue
ORDER BY cohort_year;
/*
cohort_year	total_revenue_per_cohort	prev_year_revenue	revenue_growth_pct
2011	      11289072	                 NULL	            NULL
2012	      11969678	                 11289072        	6.030000000000
2013	      5973822	                   11969678      	-50.090000000000
2014	      123678	                   5973822	        -97.930000000000
*/
WITH customer_cohort AS(
SELECT
f.customer_key,
MIN(s.shipping_year) AS cohort_year,
SUM(f.sales_amount) AS revenue_per_customer
FROM
gold.fact_sales AS f
JOIN
gold.dim_shipping_date AS s
ON f.shipping_date_key=s.shipping_date_key
GROUP BY f.customer_key)
SELECT 
customer_cohort.cohort_year,
AVG( customer_cohort.revenue_per_customer) AS average_revenue_per_customer
FROM customer_cohort
GROUP BY customer_cohort.cohort_year
ORDER BY customer_cohort.cohort_year;
/*
cohort_year	average_revenue_per_customer
2011	       5183
2012	       3717
2013	       482
2014	       172
*/
