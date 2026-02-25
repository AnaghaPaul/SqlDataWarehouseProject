-- __________________________________Cohort Analysis_________________________________________
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
cohort_year	customers
2011	      2178
2012	      3220
2013	      12371
2014	      715
*/

