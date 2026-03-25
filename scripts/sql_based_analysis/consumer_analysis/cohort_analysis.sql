-- =========================================================
-- COHORT ANALYSIS: CUSTOMER BEHAVIOR & REVENUE TRENDS
-- =========================================================

-- Definition:
-- A cohort is a group of customers who share a common
-- characteristic — here, their FIRST purchase date.

-- Cohort Type:
-- Acquisition Cohort (based on first purchase)
WITH first_purchase_info AS
(
SELECT customer_key,
MIN(order_date_key) AS first_purchase_date_key
FROM 
gold.fact_sales 
GROUP BY
customer_key
),
customer_cohort
AS
(
SELECT
f.customer_key,
o.order_fiscal_year AS cohort_year,
o.order_fiscal_month AS cohort_month,
o.order_fiscal_quarter AS cohort_quarter,
o.order_fiscal_mmyyyy AS cohort_mmyyyy,
o.order_fiscal_month_year AS cohort_month_year
FROM
first_purchase_info AS f
JOIN
gold.dim_order_date AS o
ON
f.first_purchase_date_key = o.order_date_key
WHERE f.first_purchase_date_key != -1
),
purchase_info AS(
SELECT 
c.customer_key,
c.cohort_year,
c.cohort_month,
c.cohort_quarter,
c.cohort_mmyyyy,
c.cohort_month_year,
s.order_number ,
s.order_date_key AS order_date_key,
o.order_date AS order_date,
o.order_fiscal_year AS order_year,
o.order_fiscal_month AS order_month,
o.order_fiscal_quarter AS order_quarter,
(o.order_fiscal_year - c.cohort_year) * 12 + (o.order_fiscal_month - c.cohort_month) AS month_offset,
s.sales_amount
FROM 
customer_cohort AS c
JOIN
gold.fact_sales s
ON c.customer_key=s.customer_key
JOIN
gold.dim_order_date AS o
ON s.order_date_key = o.order_date_key)
SELECT
	cohort_year,
	cohort_month,
	cohort_mmyyyy,
    cohort_month_year,  -- display label
	SUM(CASE WHEN month_offset = 0 THEN sales_amount ELSE 0 END) AS M0,
    SUM(CASE WHEN month_offset = 1 THEN sales_amount ELSE 0 END) AS M1,
    SUM(CASE WHEN month_offset = 2 THEN sales_amount ELSE 0 END) AS M2,
    SUM(CASE WHEN month_offset = 3 THEN sales_amount ELSE 0 END) AS M3,
    SUM(CASE WHEN month_offset = 4 THEN sales_amount ELSE 0 END) AS M4,
    SUM(CASE WHEN month_offset = 5 THEN sales_amount ELSE 0 END) AS M5,
    SUM(CASE WHEN month_offset = 6 THEN sales_amount ELSE 0 END) AS M6,
    SUM(CASE WHEN month_offset = 7 THEN sales_amount ELSE 0 END) AS M7,
    SUM(CASE WHEN month_offset = 8 THEN sales_amount ELSE 0 END) AS M8,
    SUM(CASE WHEN month_offset = 9 THEN sales_amount ELSE 0 END) AS M9,
    SUM(CASE WHEN month_offset = 10 THEN sales_amount ELSE 0 END) AS M10,
    SUM(CASE WHEN month_offset = 11 THEN sales_amount ELSE 0 END) AS M11
	FROM purchase_info
	GROUP BY cohort_year,cohort_month,cohort_mmyyyy, cohort_month_year
	ORDER BY cohort_year,cohort_month;


/*
cohort_year	cohort_month	cohort_mmyyyy	cohort_month_year	M0				M1				M2				M3				M4				M5				M6				M7				M8					M9				M10				M11
2011		1				012011			Jan-2011		  	426260			0				0				0				0				0				0				0				0					0				0				0
2011		2				022011			Feb-2011  			448926 			0				0				0				0				0				0				0				0					0				0				0
2011		3				032011			Mar-2011  			542465			0				0				0				0				0				0				0				0					0				0				0
2011		4				042011			Apr-2011  			481444			0				0				0				0				0				0				0				0					0				0				0
2011		5				052011			May-2011  			516506			0				0				0				0				0				0				0				0					0				0				0
2011		6				062011			Jun-2011  			800335			0				0				0				0				0				0				0				0					0				0				0
2011		7				072011			Jul-2011  			552865			0				0				0				0				0				0				0				0					0				0				0
2011		8				082011			Aug-2011  			534427			0				0				0				0				0				0				0				0					0				0				0
2011		9				092011			Sep-2011  			737016			0				0				0				0				0				0				0				0					0				0				0
2011		10				102011			Oct-2011  			582025			0				0				0				0				0				0				0				0					0				0				0
2011		11				112011			Nov-2011  			687675			0				0				0				0				0				0				0				0					0				0				0
2011		12				122011			Dec-2011  			739889			0				0				0				0				0				0				0				0					0				0				0
2012		1				012012			Jan-2012  			459259			0				0				0				0				0				0				0				0					0				0				646
2012		2				022012			Feb-2012  			477369			0				0				0				0				0				0				0				0					0				0				5747
2012		3				032012			Mar-2012  			451883			0				0				0				0				0				0				0				0					2507			9936			7917
2012		4				042012			Apr-2012 		 	383713		-	0				0				0				0				0				0				0				1269				3996			6500			21056
2012		5				052012			May-2012  			297896			0				0				0				0				0				0				3725			5721				1186			16822			21409
2012		6				062012			Jun-2012  			622552			0				0				0				0				0				6133			17479			12342				39390			23261			43717
2012		7				072012			Jul-2012  			411779			0				0				0				0				0				22859			7970			14684				5545			36772			62982
2012		8				082012			Aug-2012  			485461			0				0				0				3149			27177			17363			27917			27139				19906			67477			48495
2012		9				092012			Sep-2012  			524614			0				0				4686			16346			20955			32040			29050			18381				76935			30792			99607
2012		10				102012			Oct-2012  			483866			0			 	2355			22622			16304			17573			7389			5968			81372				26390			21457			109964
2012		11				112012			Nov-2012  			624794			2939			14982			26977			17847			12054			43232			56063			68239				22158			89577			158189
2012		12				122012			Dec-2012  			611197			14114			17704			28378			13171			31601			38664			57383			37298				66398			61547			137808
2013		1				012013			Jan-2013  			295407			810				498				5489			3123			801				1056			5488			394					1547			4506			2216
2013		2				022013			Feb-2013  			295175			4679			4169			8522			11173			4480			2854			4475			3941				4050			4905			3413
2013		3				032013			Mar-2013  			388986			2185			2769			9847			12035			11357			3059			2413			2660				2681			2221			0
2013		4				042013			Apr-2013  			375364			1508			5245			8581			1477			4843			1530			1151			2061				1659			0				0
2013		5				052013			May-2013  			416393			2267			8473			13204			10999			1189			1490			1740			1885				0				0				0
2013		6				062013			Jun-2013  			617001			1281			4604			7047			27967			7105			2225			1433			0					0				0				0
2013		7				072013			Jul-2013  			325126			724				1676			1488			3669			21337			1462			0				0					0				0				0
2013		8				082013			Aug-2013  			341536			1307			2303			1663			14096			1338			0				0				0					0				0				0
2013		9				092013			Sep-2013  			479696			2479			1591			2095			1713			0				0				0				0					0				0				0
2013		10				102013			Oct-2013  			516918			1416			1419			985				0				0				0				0				0					0				0				0
2013		11				112013			Nov-2013  			692415			1437			1220			0				0				0				0				0				0					0				0				0
2013		12				122013			Dec-2013  			829423			1523			0				0				0				0				0				0				0					0				0				0
2014		1				012014			Jan-2014  			26049			0				0				0				0				0				0				0				0					0				0				0

*/

WITH first_purchase_info AS
(
    SELECT 
        customer_key,
        MIN(order_date_key) AS first_purchase_date_key
    FROM gold.fact_sales 
    GROUP BY customer_key
),
customer_cohort AS
(
    SELECT
        f.customer_key,
        o.order_fiscal_year AS cohort_year,
        o.order_fiscal_month AS cohort_month,
        o.order_fiscal_quarter AS cohort_quarter,
        o.order_fiscal_mmyyyy AS cohort_mmyyyy,
        o.order_fiscal_month_year AS cohort_month_year
    FROM first_purchase_info AS f
    JOIN gold.dim_order_date AS o
        ON f.first_purchase_date_key = o.order_date_key
    WHERE f.first_purchase_date_key != -1
),
purchase_info AS
(
    SELECT 
        c.customer_key,
        c.cohort_year,
        c.cohort_month,
        c.cohort_quarter,
        c.cohort_mmyyyy,
        c.cohort_month_year,
        s.order_number,
        s.order_date_key AS order_date_key,
        o.order_date AS order_date,
        o.order_fiscal_year AS order_year,
        o.order_fiscal_month AS order_month,
        o.order_fiscal_quarter AS order_quarter,
        (o.order_fiscal_year - c.cohort_year) * 12 + (o.order_fiscal_month - c.cohort_month) AS month_offset,
        s.sales_amount
    FROM customer_cohort AS c
    JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date AS o
        ON s.order_date_key = o.order_date_key
),
cohort_summary AS
(
    SELECT
        cohort_year,
        cohort_month,
        cohort_mmyyyy,
        cohort_month_year,
        COUNT(DISTINCT customer_key) AS num_customers,
        SUM(CASE WHEN month_offset = 0 THEN sales_amount ELSE 0 END) AS M0,
        SUM(CASE WHEN month_offset = 1 THEN sales_amount ELSE 0 END) AS M1,
        SUM(CASE WHEN month_offset = 2 THEN sales_amount ELSE 0 END) AS M2,
        SUM(CASE WHEN month_offset = 3 THEN sales_amount ELSE 0 END) AS M3,
        SUM(CASE WHEN month_offset = 4 THEN sales_amount ELSE 0 END) AS M4,
        SUM(CASE WHEN month_offset = 5 THEN sales_amount ELSE 0 END) AS M5,
        SUM(CASE WHEN month_offset = 6 THEN sales_amount ELSE 0 END) AS M6,
        SUM(CASE WHEN month_offset = 7 THEN sales_amount ELSE 0 END) AS M7,
        SUM(CASE WHEN month_offset = 8 THEN sales_amount ELSE 0 END) AS M8,
        SUM(CASE WHEN month_offset = 9 THEN sales_amount ELSE 0 END) AS M9,
        SUM(CASE WHEN month_offset = 10 THEN sales_amount ELSE 0 END) AS M10,
        SUM(CASE WHEN month_offset = 11 THEN sales_amount ELSE 0 END) AS M11
    FROM purchase_info
    GROUP BY cohort_year, cohort_month, cohort_mmyyyy, cohort_month_year
)
SELECT
    cohort_year,
    cohort_month,
    cohort_mmyyyy,
    cohort_month_year,
    num_customers,
    ROUND(M0 / NULLIF(num_customers,0),2) AS ARPC_M0,
    ROUND(M1 / NULLIF(num_customers,0),2) AS ARPC_M1,
    ROUND(M2 / NULLIF(num_customers,0),2) AS ARPC_M2,
    ROUND(M3 / NULLIF(num_customers,0),2) AS ARPC_M3,
    ROUND(M4 / NULLIF(num_customers,0),2) AS ARPC_M4,
    ROUND(M5 / NULLIF(num_customers,0),2) AS ARPC_M5,
    ROUND(M6 / NULLIF(num_customers,0),2) AS ARPC_M6,
    ROUND(M7 / NULLIF(num_customers,0),2) AS ARPC_M7,
    ROUND(M8 / NULLIF(num_customers,0),2) AS ARPC_M8,
    ROUND(M9 / NULLIF(num_customers,0),2) AS ARPC_M9,
    ROUND(M10 / NULLIF(num_customers,0),2) AS ARPC_M10,
    ROUND(M11 / NULLIF(num_customers,0),2) AS ARPC_M11
FROM cohort_summary
ORDER BY cohort_year, cohort_month;




WITH customer_cohort AS
(
    SELECT
        customer_key,
        MIN(order_date_key) AS first_order_date_key
    FROM gold.fact_sales
    GROUP BY customer_key
)

SELECT
    d.order_fiscal_year AS cohort_fiscal_year,
    COUNT(*) AS total_customers
FROM customer_cohort c
JOIN gold.dim_order_date d
    ON c.first_order_date_key = d.order_date_key
GROUP BY
    d.order_fiscal_year
ORDER BY
    d.order_fiscal_year;

/*
cohort_fiscal_year	total_customers
NULL	            15
2011	            2199
2012	            3258
2013	            12506
2014	            506
*/
-- The null values are the results of invalid order dates in the source data.
-- =========================================================
-- STEP 3: COHORT REVENUE OVER TIME
-- =========================================================

-- Objective:
-- Track revenue generated by each cohort across years.

-- Key Concept:
-- year_offset = years since customer acquisition

-- Interpretation:
-- Y0 → Revenue in acquisition year
-- Y1 → Revenue 1 year after acquisition
-- ...

-- Use Case:
-- Evaluate long-term value and retention quality.
WITH customer_cohort AS
(
    SELECT
        f.customer_key,
        MIN(d.order_date) AS first_order_date
    FROM gold.fact_sales f
    JOIN gold.dim_order_date d
        ON f.order_date_key = d.order_date_key
    GROUP BY f.customer_key
),
cohort_with_fiscal AS
(
    SELECT
        c.customer_key,
        c.first_order_date,
        d.order_fiscal_year AS cohort_fiscal_year
    FROM customer_cohort c
    JOIN gold.dim_order_date d
        ON c.first_order_date = d.order_date
),
cohort_activity AS
(
    SELECT
        c.customer_key,
        c.cohort_fiscal_year,
        c.first_order_date,
        d.order_date AS activity_date,
        s.sales_amount,

        FLOOR(DATEDIFF(DAY, c.first_order_date, d.order_date) / 365.0) AS year_offset

    FROM cohort_with_fiscal c
    JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date d
        ON s.order_date_key = d.order_date_key
)
SELECT
    cohort_fiscal_year,

    SUM(CASE WHEN year_offset = 0 THEN sales_amount ELSE 0 END) AS Y0,
    SUM(CASE WHEN year_offset = 1 THEN sales_amount ELSE 0 END) AS Y1,
    SUM(CASE WHEN year_offset = 2 THEN sales_amount ELSE 0 END) AS Y2,
    SUM(CASE WHEN year_offset = 3 THEN sales_amount ELSE 0 END) AS Y3,
    SUM(CASE WHEN year_offset = 4 THEN sales_amount ELSE 0 END) AS Y4

FROM cohort_activity
WHERE cohort_fiscal_year IS NOT NULL
GROUP BY cohort_fiscal_year
ORDER BY cohort_fiscal_year;
   
/*
cohort_fiscal_year	Y0	        Y1	        Y2	        Y3	    Y4
2011	            7053411	    2537374    	1817078	    0	    0
2012	            8449243	    3566232	    0	        0	    0
2013	            5901871	    0	        0	        0	    0
2014	            26049	    0	        0	        0	    0
*/
--_____________________________________________________________________YEAR 2013 - comparing customers according to the month they arrived_________________________________
-- =========================================================
-- STEP 4: MONTHLY COHORT ANALYSIS (YEAR = 2013)
-- =========================================================

-- Objective:
-- Break down cohorts by acquisition month for granular insights.

-- Output:
-- Number of customers acquired each month in 2013

-- Use Case:
-- Detect seasonality in acquisition (e.g., campaigns, holidays)
WITH customer_cohort AS
(
    SELECT
        f.customer_key,
        MIN(f.order_date_key) AS first_order_date_key
    FROM gold.fact_sales f
    GROUP BY f.customer_key
)

SELECT
    d.order_fiscal_month_year AS cohort_period,
    COUNT(DISTINCT c.customer_key) AS total_customers
FROM customer_cohort c
JOIN gold.dim_order_date d
    ON c.first_order_date_key = d.order_date_key
WHERE d.order_fiscal_year = 2013
GROUP BY
    d.order_fiscal_month_year
ORDER BY
    d.order_fiscal_month_year;
/*
cohort_period	total_customers
Apr-2013      	1017
Aug-2013      	970
Dec-2013      	1285
Feb-2013      	1091
Jan-2013      	249
Jul-2013      	951
Jun-2013  	    1342
Mar-2013  	    1302
May-2013  	    1015
Nov-2013  	    1063
Oct-2013  	    1012
Sep-2013  	    1209
*/
-- =========================================================
-- STEP 4: MONTHLY COHORT ANALYSIS (YEAR = 2013)
-- =========================================================

-- Objective:
-- Break down cohorts by acquisition month for granular insights.

-- Output:
-- Number of customers acquired each month in 2013

-- Use Case:
-- Detect seasonality in acquisition (e.g., campaigns, holidays)
WITH customer_cohort AS (
    -- Identify the first purchase date per customer
    SELECT
        f.customer_key,
        MIN(d.order_date) AS first_order_date
    FROM gold.fact_sales f
    JOIN gold.dim_order_date d
        ON f.order_date_key = d.order_date_key
    GROUP BY f.customer_key
),
cohort_with_period AS (
    -- Map each customer to their cohort period string
    SELECT
        c.customer_key,
        c.first_order_date,
        d.order_fiscal_month_year AS cohort_period
    FROM customer_cohort c
    JOIN gold.dim_order_date d
        ON c.first_order_date = d.order_date
	WHERE d.order_fiscal_year = 2013
),
cohort_activity AS (
    -- Join all orders for these customers and calculate month offset
    SELECT
        c.customer_key,
        c.cohort_period,
        s.sales_amount,
        d.order_date AS activity_date,
        FLOOR(DATEDIFF(DAY, c.first_order_date, d.order_date) / 30.44) AS month_offset
    FROM cohort_with_period c
    JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date d
        ON s.order_date_key = d.order_date_key
)
SELECT
    cohort_period,
    SUM(CASE WHEN month_offset = 0 THEN sales_amount ELSE 0 END) AS M0,
    SUM(CASE WHEN month_offset = 1 THEN sales_amount ELSE 0 END) AS M1,
    SUM(CASE WHEN month_offset = 2 THEN sales_amount ELSE 0 END) AS M2,
    SUM(CASE WHEN month_offset = 3 THEN sales_amount ELSE 0 END) AS M3,
    SUM(CASE WHEN month_offset = 4 THEN sales_amount ELSE 0 END) AS M4,
    SUM(CASE WHEN month_offset = 5 THEN sales_amount ELSE 0 END) AS M5,
    SUM(CASE WHEN month_offset = 6 THEN sales_amount ELSE 0 END) AS M6,
    SUM(CASE WHEN month_offset = 7 THEN sales_amount ELSE 0 END) AS M7,
    SUM(CASE WHEN month_offset = 8 THEN sales_amount ELSE 0 END) AS M8,
    SUM(CASE WHEN month_offset = 9 THEN sales_amount ELSE 0 END) AS M9,
    SUM(CASE WHEN month_offset = 10 THEN sales_amount ELSE 0 END) AS M10,
    SUM(CASE WHEN month_offset = 11 THEN sales_amount ELSE 0 END) AS M11
FROM cohort_activity
GROUP BY cohort_period
ORDER BY MIN(activity_date);

/*
cohort_period	M0	        M1    	M2	        M3    	M4    	M5	    M6	    M7    	M8	    M9	    M10	     M11
Jan-2013  	    296217	    484	    596	        5617	3144	1126	5564	284    	1581	2256	4345	665
Feb-2013  	    297243	    4413	8808	    6108	9722	3872	3090	4456	4760	4441	3739	2204
Mar-2013  	    390165	    2156	2561	    12364	12197	9274	2810	2239	2784	2891	772    	0
Apr-2013  	    376308	    1662	7363	    6097	4297	2041	1566	1323	1619	1143	0	    0
May-2013  	    417302	    6457	8505	    11255	8468	1501	1357	1389	1406	0	    0    	0
Jun-2013  	    617676	    1509	7473	    15860	21714	2170	1584	677	    0	    0	    0    	0
Jul-2013  	    325660	    936    	1657	    1569	13543	11445	672    	0	    0	    0	    0    	0
Aug-2013  	    342637	    708    	3017	    6258	9374	622	    0	    0	    0	    0	    0    	0
Sep-2013  	    482736	    2956	1755	    1767	803	    0	    0	    0	    0	    0	    0    	0
Oct-2013  	    519960	    1452	1140	    516    	0	    0	    0	    0	    0	    0	    0    	0
Nov-2013      	692863	    1378	831	        0	    0	    0    	0	    0	    0	    0	    0    	0
Dec-2013  	    829904	    893	    149	        0	    0	    0	    0	    0	    0	    0	    0	    0
*/
-- =========================================================
-- STEP 5: MONTHLY REVENUE RETENTION MATRIX
-- =========================================================

-- Objective:
-- Track how each monthly cohort spends over time.

-- Key Metric:
-- month_offset = months since first purchase

-- Interpretation:
-- M0 → Revenue in acquisition month
-- M1 → Revenue next month
-- ...

-- Insight:
-- Helps visualize retention decay and repeat purchase behavior.

WITH customer_cohort AS
(
    SELECT
        f.customer_key,
        MIN(f.order_date_key) AS first_order_date_key -- first_purchase_date
    FROM gold.fact_sales f
    GROUP BY f.customer_key
),
cohort_base AS
(
    SELECT
        d.order_fiscal_year,
        d.order_fiscal_month,
        d.order_fiscal_month_year AS cohort_period,
        COUNT(DISTINCT c.customer_key) AS total_customers
    FROM customer_cohort c
    JOIN gold.dim_order_date d
        ON c.first_order_date_key = d.order_date_key 
    WHERE d.order_fiscal_year = 2013
    GROUP BY
        d.order_fiscal_year,
        d.order_fiscal_month,
        d.order_fiscal_month_year
),
cohort_with_date AS
(
    SELECT
        c.customer_key,
        d.order_fiscal_year,
        d.order_fiscal_month,
        d.order_fiscal_month_year AS cohort_period,
        d.order_date AS first_order_date
    FROM customer_cohort c
    JOIN gold.dim_order_date d
        ON c.first_order_date_key = d.order_date_key
),
cohort_activity AS
(
    SELECT
        c.customer_key,
        c.cohort_period,
        c.order_fiscal_year AS cohort_year,
        c.order_fiscal_month AS cohort_month,
        d.order_fiscal_year AS activity_year,
        d.order_fiscal_month AS activity_month,
        s.sales_amount,

         FLOOR(DATEDIFF(DAY, c.first_order_date, d.order_date) / 30.44) AS month_offset

    FROM cohort_with_date c
    JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date d
        ON s.order_date_key = d.order_date_key
    WHERE c.order_fiscal_year = 2013
)
SELECT
    a.cohort_period,
    b.total_customers,
    CAST(SUM(CASE WHEN month_offset = 0 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M0,
    CAST(SUM(CASE WHEN month_offset = 1 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M1,
    CAST(SUM(CASE WHEN month_offset = 2 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M2,
    CAST(SUM(CASE WHEN month_offset = 3 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M3,
    CAST(SUM(CASE WHEN month_offset = 4 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M4,
    CAST(SUM(CASE WHEN month_offset = 5 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M5,
    CAST(SUM(CASE WHEN month_offset = 6 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M6,
    CAST(SUM(CASE WHEN month_offset = 7 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M7,
    CAST(SUM(CASE WHEN month_offset = 8 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M8,
    CAST(SUM(CASE WHEN month_offset = 9 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M9,
    CAST(SUM(CASE WHEN month_offset = 10 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M10,
    CAST(SUM(CASE WHEN month_offset = 11 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers AS DECIMAL(10,2)) AS ARPU_M11

FROM cohort_activity a
JOIN cohort_base b
    ON a.cohort_period = b.cohort_period
GROUP BY
    a.cohort_period,
    b.total_customers
ORDER BY MIN(a.cohort_month);
/*
cohort_period	total_customers		ARPU_M0		ARPU_M1		ARPU_M2		ARPU_M3		ARPU_M4		ARPU_M5		ARPU_M6		ARPU_M7		ARPU_M8		ARPU_M9		ARPU_M10	ARPU_M11
Jan-2013  		249					1189.63		1.94		2.39		22.56		12.63		4.52		22.35		1.14		6.35		9.06		17.45		2.67
Feb-2013  		1091				272.40		3.94		8.01		5.47		8.85		3.50		2.73		3.97		4.35		4.03		3.40		1.84
Mar-2013  		1302				299.67		1.66		1.97		9.50		9.37		7.12		2.16		1.72		2.14		2.22		0.59		0.00
Apr-2013  		1017				370.02		1.63		7.24		6.00		4.23		2.01		1.54		1.30		1.59		1.12		0.00		0.00
May-2013  		1015				411.13		6.36		8.38		11.09		8.34		1.48		1.34		1.37		1.39		0.00		0.00		0.00
Jun-2013  		1342				460.27		1.12		5.57		11.82		16.18		1.62		1.18		0.50		0.00		0.00		0.00		0.00
Jul-2013  		951					342.44		0.98		1.74		1.65		14.24		12.03		0.71		0.00		0.00		0.00		0.00		0.00
Aug-2013  		970					352.95		0.69		3.11		6.45		9.60		0.64		0.00		0.00		0.00		0.00		0.00		0.00
Sep-2013  		1209				397.26		2.44		1.45		1.46		0.66		0.00		0.00		0.00		0.00		0.00		0.00		0.00
Oct-2013  		1012				511.49		1.43		1.13		0.51		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00
Nov-2013  		1063				651.80		1.30		0.78		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00
Dec-2013  		1285				645.84		0.69		0.12		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00
Dec-2013  	    1285	      	    645.19		1.09		0.37		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00
*/	

WITH customer_cohort AS
(
    SELECT
        f.customer_key,
        MIN(f.order_date_key) AS first_order_date_key
    FROM gold.fact_sales f
    GROUP BY f.customer_key
),
cohort_base AS
(
    SELECT
        d.order_fiscal_month_year AS cohort_period,
        d.order_fiscal_year,
        d.order_fiscal_month,
        COUNT(DISTINCT c.customer_key) AS total_customers
    FROM customer_cohort c
    JOIN gold.dim_order_date d
        ON c.first_order_date_key = d.order_date_key
    WHERE d.order_fiscal_year = 2013
    GROUP BY
        d.order_fiscal_month_year,
        d.order_fiscal_year,
        d.order_fiscal_month
),
cohort_with_date AS
(
    SELECT
        c.customer_key,
        d.order_fiscal_month_year AS cohort_period,
        d.order_fiscal_year,
        d.order_fiscal_month
    FROM customer_cohort c
    JOIN gold.dim_order_date d
        ON c.first_order_date_key = d.order_date_key
),
cohort_activity AS
(
    SELECT DISTINCT
        c.customer_key,
        c.cohort_period,
        c.order_fiscal_year AS cohort_year,
        c.order_fiscal_month AS cohort_month,

        d.order_fiscal_year AS activity_year,
        d.order_fiscal_month AS activity_month,

        (d.order_fiscal_year - c.order_fiscal_year) * 12 +
        (d.order_fiscal_month - c.order_fiscal_month) AS month_offset
    FROM cohort_with_date c
    JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date d
        ON s.order_date_key = d.order_date_key
    WHERE c.order_fiscal_year = 2013
)
SELECT
    a.cohort_period,
    b.total_customers,

    CAST(COUNT(DISTINCT CASE WHEN month_offset = 0 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R0,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 1 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R1,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 2 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R2,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 3 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R3,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 4 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R4,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 5 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R5,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 6 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R6,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 7 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R7,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 8 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R8,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 9 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R9,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 10 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R10,
    CAST(COUNT(DISTINCT CASE WHEN month_offset = 11 THEN a.customer_key END) * 1.0 / b.total_customers AS DECIMAL(5,2)) AS R11

FROM cohort_activity a
JOIN cohort_base b
    ON a.cohort_period = b.cohort_period

GROUP BY
    a.cohort_period,
    b.total_customers

ORDER BY MIN(a.cohort_month);

/*
cohort_period	total_customers    	R0	    R1	    R2    	R3	    R4	    R5	    R6	    R7	    R8	    R9	    R10	    R11
Jan-2013      	249	                1.00	0.04	0.03	0.05	0.04	0.04	0.04	0.04	0.04	0.04	0.04	0.05
Feb-2013      	1091	            1.00	0.06	0.05	0.05	0.06	0.05	0.04	0.05	0.06	0.05	0.06	0.05
Mar-2013       	1302	            1.00	0.03	0.03	0.03	0.04	0.03	0.04	0.03	0.04	0.04	0.03	0.00
Apr-2013  	    1017	            1.00	0.03	0.04	0.03	0.03	0.04	0.03	0.02	0.03	0.03	0.00	0.00
May-2013  	    1015	            1.00	0.04	0.02	0.03	0.03	0.02	0.03	0.03	0.03	0.00	0.00	0.00
Jun-2013  	    1342	            1.00	0.02	0.03	0.04	0.03	0.03	0.03	0.02	0.00	0.00	0.00	0.00
Jul-2013  	    951	                1.00	0.02	0.03	0.03	0.03	0.04	0.02	0.00	0.00	0.00	0.00	0.00
Aug-2013  	    970	                1.00	0.02	0.03	0.02	0.03	0.02	0.00	0.00	0.00	0.00	0.00	0.00
Sep-2013  	    1209            	1.00	0.02	0.02	0.03	0.03	0.00	0.00	0.00	0.00	0.00	0.00	0.00
Oct-2013  	    1012	            1.00	0.02	0.02	0.02	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
Nov-2013  	    1063	            1.00	0.02	0.02	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
Dec-2013  	    1285	            1.00	0.02	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
*/
WITH customer_cohort AS
(
    SELECT
        f.customer_key,
        MIN(d.order_date) AS first_order_date
    FROM gold.fact_sales f
    JOIN gold.dim_order_date d
        ON f.order_date_key = d.order_date_key
    GROUP BY f.customer_key
),
customer_activity AS
(
    SELECT DISTINCT
        c.customer_key,
        c.first_order_date,
        d.order_date AS activity_date,

        FLOOR(DATEDIFF(DAY, c.first_order_date, d.order_date) / 365.0) AS year_offset

    FROM customer_cohort c
    JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date d
        ON s.order_date_key = d.order_date_key
),
pivot_activity AS
(
    SELECT
        customer_key,
        MIN(first_order_date) AS first_order_date,

        MAX(CASE WHEN year_offset = 0 THEN 1 ELSE 0 END) AS Y0,
        MAX(CASE WHEN year_offset = 1 THEN 1 ELSE 0 END) AS Y1,
        MAX(CASE WHEN year_offset = 2 THEN 1 ELSE 0 END) AS Y2,
        MAX(CASE WHEN year_offset = 3 THEN 1 ELSE 0 END) AS Y3,
        MAX(CASE WHEN year_offset = 4 THEN 1 ELSE 0 END) AS Y4

    FROM customer_activity
    GROUP BY customer_key
),
cohort_size AS
(
    SELECT
        YEAR(first_order_date) AS cohort_year,
        COUNT(*) AS total_customers
    FROM pivot_activity
    GROUP BY YEAR(first_order_date)
)
SELECT
    YEAR(p.first_order_date) AS cohort_year,
    c.total_customers,

    1.0 AS R0,

    CAST(SUM(CASE WHEN Y1 = 1 THEN 1 ELSE 0 END) * 1.0 / c.total_customers AS DECIMAL(5,2)) AS R1,

    CAST(SUM(CASE WHEN Y1 = 1 AND Y2 = 1 THEN 1 ELSE 0 END) * 1.0 / c.total_customers AS DECIMAL(5,2)) AS R2,

    CAST(SUM(CASE WHEN Y1 = 1 AND Y2 = 1 AND Y3 = 1 THEN 1 ELSE 0 END) * 1.0 / c.total_customers AS DECIMAL(5,2)) AS R3,

    CAST(SUM(CASE WHEN Y1 = 1 AND Y2 = 1 AND Y3 = 1 AND Y4 = 1 THEN 1 ELSE 0 END) * 1.0 / c.total_customers AS DECIMAL(5,2)) AS R4

FROM pivot_activity p
JOIN cohort_size c
    ON YEAR(p.first_order_date) = c.cohort_year

GROUP BY
    YEAR(p.first_order_date),
    c.total_customers

ORDER BY cohort_year;
/*
cohort_year	total_customers	        R0        	R1	    R2	    R3    	R4
2010	    14	                    1.0	        0.00	0.00	0.00	0.00
2011	    2216	                1.0	        0.52	0.08	0.00	0.00
2012	    3225	                1.0	        0.52	0.00	0.00	0.00
2013	    12521	                1.0	        0.00	0.00	0.00	0.00
2014	    506	                    1.0	        0.00	0.00	0.00	0.00
*/
