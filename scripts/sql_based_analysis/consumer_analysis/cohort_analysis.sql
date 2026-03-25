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

/*
cohort_year	cohort_month	cohort_mmyyyy	cohort_month_year	num_customers	ARPC_M0	ARPC_M1	ARPC_M2	ARPC_M3	ARPC_M4	ARPC_M5	ARPC_M6	ARPC_M7	ARPC_M8	ARPC_M9	ARPC_M10	ARPC_M11
2011	1	012011	Jan-2011  	131	3253	0	0	0	0	0	0	0	0	0	0	0
2011	2	022011	Feb-2011  	139	3229	0	0	0	0	0	0	0	0	0	0	0
2011	3	032011	Mar-2011  	168	3228	0	0	0	0	0	0	0	0	0	0	0
2011	4	042011	Apr-2011  	147	3275	0	0	0	0	0	0	0	0	0	0	0
2011	5	052011	May-2011  	163	3168	0	0	0	0	0	0	0	0	0	0	0
2011	6	062011	Jun-2011  	250	3201	0	0	0	0	0	0	0	0	0	0	0
2011	7	072011	Jul-2011  	170	3252	0	0	0	0	0	0	0	0	0	0	0
2011	8	082011	Aug-2011  	169	3162	0	0	0	0	0	0	0	0	0	0	0
2011	9	092011	Sep-2011  	229	3218	0	0	0	0	0	0	0	0	0	0	0
2011	10	102011	Oct-2011  	180	3233	0	0	0	0	0	0	0	0	0	0	0
2011	11	112011	Nov-2011  	218	3154	0	0	0	0	0	0	0	0	0	0	0
2011	12	122011	Dec-2011  	235	3148	0	0	0	0	0	0	0	0	0	0	0
2012	1	012012	Jan-2012  	229	2005	0	0	0	0	0	0	0	0	0	0	2
2012	2	022012	Feb-2012  	242	1972	0	0	0	0	0	0	0	0	0	0	23
2012	3	032012	Mar-2012  	251	1800	0	0	0	0	0	0	0	0	9	39	31
2012	4	042012	Apr-2012  	213	1801	0	0	0	0	0	0	0	5	18	30	98
2012	5	052012	May-2012  	166	1794	0	0	0	0	0	0	22	34	7	101	128
2012	6	062012	Jun-2012  	361	1724	0	0	0	0	0	16	48	34	109	64	121
2012	7	072012	Jul-2012  	232	1774	0	0	0	0	0	98	34	63	23	158	271
2012	8	082012	Aug-2012  	265	1831	0	0	0	11	102	65	105	102	75	254	183
2012	9	092012	Sep-2012  	299	1754	0	0	15	54	70	107	97	61	257	102	333
2012	10	102012	Oct-2012  	277	1746	0	8	81	58	63	26	21	293	95	77	396
2012	11	112012	Nov-2012  	371	1684	7	40	72	48	32	116	151	183	59	241	426
2012	12	122012	Dec-2012  	352	1736	40	50	80	37	89	109	163	105	188	174	391
2013	1	012013	Jan-2013  	249	1186	3	2	22	12	3	4	22	1	6	18	8
2013	2	022013	Feb-2013  	1091	270	4	3	7	10	4	2	4	3	3	4	3
2013	3	032013	Mar-2013  	1302	298	1	2	7	9	8	2	1	2	2	1	0
2013	4	042013	Apr-2013  	1017	369	1	5	8	1	4	1	1	2	1	0	0
2013	5	052013	May-2013  	1015	410	2	8	13	10	1	1	1	1	0	0	0
2013	6	062013	Jun-2013  	1342	459	0	3	5	20	5	1	1	0	0	0	0
2013	7	072013	Jul-2013  	951	341	0	1	1	3	22	1	0	0	0	0	0
2013	8	082013	Aug-2013  	970	352	1	2	1	14	1	0	0	0	0	0	0
2013	9	092013	Sep-2013  	1209	396	2	1	1	1	0	0	0	0	0	0	0
2013	10	102013	Oct-2013  	1012	510	1	1	0	0	0	0	0	0	0	0	0
2013	11	112013	Nov-2013  	1063	651	1	1	0	0	0	0	0	0	0	0	0
2013	12	122013	Dec-2013  	1285	645	1	0	0	0	0	0	0	0	0	0	0
2014	1	012014	Jan-2014  	506	51	0	0	0	0	0	0	0	0	0	0	0
*/
WITH first_purchase_info AS (
    SELECT customer_key,
           MIN(order_date_key) AS first_purchase_date_key
    FROM gold.fact_sales 
    GROUP BY customer_key
),
customer_cohort AS (
    SELECT f.customer_key,
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
purchase_info AS (
    SELECT c.customer_key,
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
cohort_summary AS (
    SELECT cohort_month,
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
           SUM(CASE WHEN month_offset = 11 THEN sales_amount ELSE 0 END) AS M11,
		   SUM(CASE WHEN month_offset > 11 THEN sales_amount ELSE 0 END) AS other
    FROM purchase_info
    GROUP BY cohort_month
)
SELECT cohort_month,
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
       ROUND(M11 / NULLIF(num_customers,0),2) AS ARPC_M11,
	   ROUND(other / NULLIF(num_customers,0),2) AS ARPC_other
FROM cohort_summary
ORDER BY cohort_month;

/*
cohort_month	num_customers	ARPC_M0	ARPC_M1	ARPC_M2	ARPC_M3	ARPC_M4	ARPC_M5	ARPC_M6	ARPC_M7	ARPC_M8	ARPC_M9	ARPC_M10	ARPC_M11	ARPC_other
1	1115	1082	0	0	4	2	0	0	4	0	1	4	2	688
2	1472	829	3	2	5	7	3	1	3	2	2	3	6	481
3	1721	803	1	1	5	6	6	1	1	1	3	7	4	455
4	1377	900	1	3	6	1	3	1	0	2	4	4	15	489
5	1344	915	1	6	9	8	0	1	4	5	0	12	15	436
6	1953	1044	0	2	3	14	3	4	9	6	20	11	22	496
7	1353	953	0	1	1	2	15	17	5	10	4	27	46	473
8	1404	969	0	1	1	12	20	12	19	19	14	48	34	391
9	1737	1002	1	0	3	10	12	18	16	10	44	17	57	455
10	1469	1077	0	2	16	11	11	5	4	55	17	14	74	375
11	1652	1213	2	9	16	10	7	26	33	41	13	54	95	390
12	1872	1164	8	9	15	7	16	20	30	19	35	32	73	302
*/
WITH first_purchase_info AS (
    SELECT customer_key,
           MIN(order_date_key) AS first_purchase_date_key
    FROM gold.fact_sales 
    GROUP BY customer_key
),
customer_cohort AS (
    SELECT f.customer_key,
           o.order_fiscal_year AS cohort_year,
           o.order_fiscal_month AS cohort_month,
           o.order_fiscal_mmyyyy AS cohort_mmyyyy
    FROM first_purchase_info AS f
    JOIN gold.dim_order_date AS o
      ON f.first_purchase_date_key = o.order_date_key
    WHERE f.first_purchase_date_key != -1
),
purchase_info AS (
    SELECT c.customer_key,
           c.cohort_year,
           c.cohort_month,
           c.cohort_mmyyyy,
           (o.order_fiscal_year - c.cohort_year) * 12 + (o.order_fiscal_month - c.cohort_month) AS month_offset,
           s.sales_amount
    FROM customer_cohort AS c
    JOIN gold.fact_sales s
      ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date AS o
      ON s.order_date_key = o.order_date_key
),
cohort_monthly AS (
    SELECT cohort_year,
           cohort_month,
           cohort_mmyyyy,
           month_offset,
           SUM(sales_amount) AS total_sales,
           COUNT(DISTINCT customer_key) AS num_customers
    FROM purchase_info
    GROUP BY cohort_year, cohort_month, cohort_mmyyyy, month_offset
)
SELECT cohort_year,
       cohort_month,
       cohort_mmyyyy,
       month_offset,
       SUM(total_sales) OVER (PARTITION BY cohort_year, cohort_month ORDER BY month_offset) 
           / SUM(num_customers) OVER (PARTITION BY cohort_year, cohort_month) AS cumulative_ARPC
FROM cohort_monthly
ORDER BY cohort_year, cohort_month, month_offset;
/*
cohort_year	cohort_month	cohort_mmyyyy	month_offset	cumulative_ARPC
2011		1				012011			0				1480
2011		1				012011			23				1504
2011		1				012011			24				1610
2011		1				012011			25				1629
2011		1				012011			26				1699
2011		1				012011			27				1727
2011		1				012011			28				1886
2011		1				012011			29				2029
2011		1				012011			30				2081
2011		1				012011			31				2104
2011		1				012011			32				2121
2011		1				012011			33				2139
2011		1				012011			34				2290
2011		1				012011			35				2491
2011		2				022011			0				1511
2011		2				022011			22				1528
2011		2				022011			23				1627
2011		2				022011			24				1688
2011		2				022011			25				1752
2011		2				022011			26				1795
2011		2				022011			27				1830
2011		2				022011			28				1919
2011		2				022011			29				1977
2011		2				022011			30				2055
2011		2				022011			31				2110
2011		2				022011			32				2152
2011		2				022011			33				2306
2011		2				022011			34				2483
2011		3				032011	0	1643
2011		3				032011	21	1675
2011		3	032011	22	1710
2011		3	032011	23	1740
2011		3	032011	24	1772
2011		3	032011	25	1795
2011		3	032011	26	1813
2011		3	032011	27	1941
2011		3	032011	28	2061
2011		3	032011	29	2140
2011		3	032011	30	2252
2011		3	032011	31	2269
2011		3	032011	32	2318
2011		3	032011	33	2497
2011		4	042011	0	1604
2011		4	042011	20	1612
2011		4	042011	21	1696
2011		4	042011	22	1713
2011	4	042011	23	1751
2011	4	042011	24	1777
2011	4	042011	25	1779
2011	4	042011	26	1946
2011	4	042011	27	2073
2011	4	042011	28	2171
2011	4	042011	29	2239
2011	4	042011	30	2334
2011	4	042011	31	2353
2011	4	042011	32	2519
2011	5	052011	0	1594
2011	5	052011	19	1630
2011	5	052011	20	1846
2011	5	052011	21	1910
2011	5	052011	22	1953
2011	5	052011	23	2012
2011	5	052011	24	2041
2011	5	052011	25	2164
2011	5	052011	26	2208
2011	5	052011	27	2277
2011	5	052011	28	2339
2011	5	052011	29	2436
2011	5	052011	30	2467
2011	5	052011	31	2521
2011	6	062011	0	1630
2011	6	062011	18	1652
2011	6	062011	19	1712
2011	6	062011	20	1831
2011	6	062011	21	1941
2011	6	062011	22	1989
2011	6	062011	23	2039
2011	6	062011	24	2116
2011	6	062011	25	2163
2011	6	062011	26	2211
2011	6	062011	27	2282
2011	6	062011	28	2338
2011	6	062011	29	2403
2011	6	062011	30	2466
2011	7	072011	0	1607
2011	7	072011	17	1622
2011	7	072011	18	1689
2011	7	072011	19	1729
2011	7	072011	20	1921
2011	7	072011	21	2009
2011	7	072011	22	2011
2011	7	072011	23	2090
2011	7	072011	24	2205
2011	7	072011	25	2238
2011	7	072011	26	2311
2011	7	072011	27	2361
2011	7	072011	28	2444
2011	7	072011	29	2500
2011	8	082011	0	1585
2011	8	082011	17	1672
2011	8	082011	18	1746
2011	8	082011	19	1816
2011	8	082011	20	1939
2011	8	082011	21	2006
2011	8	082011	22	2111
2011	8	082011	23	2154
2011	8	082011	24	2207
2011	8	082011	25	2235
2011	8	082011	26	2300
2011	8	082011	27	2330
2011	8	082011	28	2461
2011	9	092011	0	1494
2011	9	092011	15	1523
2011	9	092011	16	1620
2011	9	092011	17	1756
2011	9	092011	18	1901
2011	9	092011	19	1977
2011	9	092011	20	2106
2011	9	092011	21	2235
2011	9	092011	22	2342
2011	9	092011	23	2378
2011	9	092011	24	2447
2011	9	092011	25	2499
2011	9	092011	26	2533
2011	9	092011	27	2585
2011	10	102011	0	1477
2011	10	102011	14	1491
2011	10	102011	15	1513
2011	10	102011	16	1642
2011	10	102011	17	1738
2011	10	102011	18	1772
2011	10	102011	19	1853
2011	10	102011	20	2184
2011	10	102011	21	2262
2011	10	102011	22	2329
2011	10	102011	23	2374
2011	10	102011	24	2391
2011	10	102011	25	2443
2011	10	102011	26	2537
2011	11	112011	0	1460
2011	11	112011	14	1462
2011	11	112011	15	1567
2011	11	112011	16	1724
2011	11	112011	17	1775
2011	11	112011	18	1793
2011	11	112011	19	1927
2011	11	112011	20	2167
2011	11	112011	21	2278
2011	11	112011	22	2345
2011	11	112011	23	2398
2011	11	112011	24	2435
2011	11	112011	25	2525
2011	12	122011	0	1500
2011	12	122011	13	1504
2011	12	122011	14	1524
2011	12	122011	15	1661
2011	12	122011	16	1762
2011	12	122011	17	1767
2011	12	122011	18	1793
2011	12	122011	19	1895
2011	12	122011	20	2148
2011	12	122011	21	2228
2011	12	122011	22	2299
2011	12	122011	23	2342
2011	12	122011	24	2408
2012	1	012012	0	950
2012	1	012012	11	952
2012	1	012012	12	964
2012	1	012012	13	979
2012	1	012012	14	1079
2012	1	012012	15	1264
2012	1	012012	16	1284
2012	1	012012	17	1342
2012	1	012012	18	1402
2012	1	012012	19	1565
2012	1	012012	20	1731
2012	1	012012	21	1843
2012	1	012012	22	1904
2012	1	012012	23	1937
2012	2	022012	0	990
2012	2	022012	11	1002
2012	2	022012	12	1024
2012	2	022012	13	1057
2012	2	022012	14	1146
2012	2	022012	15	1327
2012	2	022012	16	1347
2012	2	022012	17	1354
2012	2	022012	18	1423
2012	2	022012	19	1632
2012	2	022012	20	1707
2012	2	022012	21	1807
2012	2	022012	22	1874
2012	3	032012	0	859
2012	3	032012	9	863
2012	3	032012	10	882
2012	3	032012	11	897
2012	3	032012	12	931
2012	3	032012	13	987
2012	3	032012	14	1122
2012	3	032012	15	1252
2012	3	032012	16	1286
2012	3	032012	17	1402
2012	3	032012	18	1504
2012	3	032012	19	1668
2012	3	032012	20	1809
2012	3	032012	21	1852
2012	4	042012	0	830
2012	4	042012	8	833
2012	4	042012	9	841
2012	4	042012	10	856
2012	4	042012	11	901
2012	4	042012	12	942
2012	4	042012	13	1119
2012	4	042012	14	1186
2012	4	042012	15	1198
2012	4	042012	16	1292
2012	4	042012	17	1369
2012	4	042012	18	1510
2012	4	042012	19	1674
2012	4	042012	20	1765
2012	5	052012	0	839
2012	5	052012	7	849
2012	5	052012	8	865
2012	5	052012	9	869
2012	5	052012	10	916
2012	5	052012	11	976
2012	5	052012	12	1052
2012	5	052012	13	1187
2012	5	052012	14	1198
2012	5	052012	15	1332
2012	5	052012	16	1460
2012	5	052012	17	1535
2012	5	052012	18	1662
2012	5	052012	19	1783
2012	6	062012	0	818
2012	6	062012	6	826
2012	6	062012	7	849
2012	6	062012	8	865
2012	6	062012	9	917
2012	6	062012	10	947
2012	6	062012	11	1005
2012	6	062012	12	1128
2012	6	062012	13	1190
2012	6	062012	14	1258
2012	6	062012	15	1375
2012	6	062012	16	1414
2012	6	062012	17	1530
2012	6	062012	18	1739
2012	7	072012	0	823
2012	7	072012	6	869
2012	7	072012	7	885
2012	7	072012	8	914
2012	7	072012	9	925
2012	7	072012	10	999
2012	7	072012	11	1125
2012	7	072012	12	1282
2012	7	072012	13	1407
2012	7	072012	14	1489
2012	7	072012	15	1518
2012	7	072012	16	1597
2012	7	072012	17	1790
2012	8	082012	0	850
2012	8	082012	4	855
2012	8	082012	5	903
2012	8	082012	6	933
2012	8	082012	7	982
2012	8	082012	8	1030
2012	8	082012	9	1064
2012	8	082012	10	1183
2012	8	082012	11	1268
2012	8	082012	12	1423
2012	8	082012	13	1504
2012	8	082012	14	1544
2012	8	082012	15	1574
2012	8	082012	16	1713
2012	9	092012	0	794
2012	9	092012	3	801
2012	9	092012	4	826
2012	9	092012	5	858
2012	9	092012	6	907
2012	9	092012	7	951
2012	9	092012	8	978
2012	9	092012	9	1095
2012	9	092012	10	1142
2012	9	092012	11	1293
2012	9	092012	12	1506
2012	9	092012	13	1595
2012	9	092012	14	1631
2012	9	092012	15	1677
2012	10	102012	0	862
2012	10	102012	2	866
2012	10	102012	3	907
2012	10	102012	4	936
2012	10	102012	5	967
2012	10	102012	6	980
2012	10	102012	7	991
2012	10	102012	8	1136
2012	10	102012	9	1183
2012	10	102012	10	1221
2012	10	102012	11	1417
2012	10	102012	12	1582
2012	10	102012	13	1612
2012	10	102012	14	1655
2012	11	112012	0	828
2012	11	112012	1	832
2012	11	112012	2	852
2012	11	112012	3	888
2012	11	112012	4	911
2012	11	112012	5	927
2012	11	112012	6	985
2012	11	112012	7	1059
2012	11	112012	8	1150
2012	11	112012	9	1179
2012	11	112012	10	1298
2012	11	112012	11	1508
2012	11	112012	12	1628
2012	11	112012	13	1697
2012	12	122012	0	893
2012	12	122012	1	914
2012	12	122012	2	940
2012	12	122012	3	981
2012	12	122012	4	1000
2012	12	122012	5	1047
2012	12	122012	6	1103
2012	12	122012	7	1187
2012	12	122012	8	1241
2012	12	122012	9	1339
2012	12	122012	10	1429
2012	12	122012	11	1630
2012	12	122012	12	1804
2013	1	012013	0	798
2013	1	012013	1	800
2013	1	012013	2	801
2013	1	012013	3	816
2013	1	012013	4	825
2013	1	012013	5	827
2013	1	012013	6	830
2013	1	012013	7	845
2013	1	012013	8	846
2013	1	012013	9	850
2013	1	012013	10	862
2013	1	012013	11	868
2013	1	012013	12	869
2013	2	022013	0	170
2013	2	022013	1	173
2013	2	022013	2	175
2013	2	022013	3	180
2013	2	022013	4	187
2013	2	022013	5	189
2013	2	022013	6	191
2013	2	022013	7	194
2013	2	022013	8	196
2013	2	022013	9	198
2013	2	022013	10	201
2013	2	022013	11	203
2013	3	032013	0	222
2013	3	032013	1	224
2013	3	032013	2	225
2013	3	032013	3	231
2013	3	032013	4	238
2013	3	032013	5	244
2013	3	032013	6	246
2013	3	032013	7	247
2013	3	032013	8	249
2013	3	032013	9	250
2013	3	032013	10	252
2013	4	042013	0	287
2013	4	042013	1	289
2013	4	042013	2	293
2013	4	042013	3	299
2013	4	042013	4	300
2013	4	042013	5	304
2013	4	042013	6	305
2013	4	042013	7	306
2013	4	042013	8	308
2013	4	042013	9	309
2013	5	052013	0	331
2013	5	052013	1	333
2013	5	052013	2	339
2013	5	052013	3	350
2013	5	052013	4	359
2013	5	052013	5	360
2013	5	052013	6	361
2013	5	052013	7	362
2013	5	052013	8	364
2013	6	062013	0	384
2013	6	062013	1	384
2013	6	062013	2	387
2013	6	062013	3	392
2013	6	062013	4	409
2013	6	062013	5	414
2013	6	062013	6	415
2013	6	062013	7	416
2013	7	072013	0	292
2013	7	072013	1	293
2013	7	072013	2	294
2013	7	072013	3	296
2013	7	072013	4	299
2013	7	072013	5	318
2013	7	072013	6	319
2013	8	082013	0	311
2013	8	082013	1	313
2013	8	082013	2	315
2013	8	082013	3	316
2013	8	082013	4	329
2013	8	082013	5	330
2013	9	092013	0	362
2013	9	092013	1	363
2013	9	092013	2	365
2013	9	092013	3	366
2013	9	092013	4	367
2013	10	102013	0	479
2013	10	102013	1	481
2013	10	102013	2	482
2013	10	102013	3	483
2013	11	112013	0	622
2013	11	112013	1	623
2013	11	112013	2	624
2013	12	122013	0	635
2013	12	122013	1	636
2014	1	012014	0	51
*/

