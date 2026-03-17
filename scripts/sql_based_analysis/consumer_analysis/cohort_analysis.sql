-- ___________________________________________________________Cohort Analysis___________________________________________________________________________________
-- The cohort analysis  compares similar groups over time. 

-- Cohort Type 1 - Users are grouped based on the year they were acquired that is the year they placed their first order.

-- Cohorts and the number of participants 
WITH customer_cohort AS
(
    SELECT
        customer_key,
        MIN(order_date_key) AS first_order_date_key
    FROM gold.fact_sales
    GROUP BY customer_key
)

SELECT
    d.order_year AS cohort_year,
    COUNT(*) AS total_customers
FROM customer_cohort c
JOIN gold.dim_order_date d
    ON c.first_order_date_key = d.order_date_key
GROUP BY
    d.order_year
ORDER BY
    d.order_year;
/*
cohort_year	total_customers
NULL		15
2010		14
2011		2215
2012		3224
2013		12510
2014		506
*/
-- The null values are the results of invalid order dates in the source data.

-- Revenue acquired in each year per cohort

WITH customer_cohort AS
(
    SELECT
        customer_key,
        MIN(order_date_key) AS first_order_date_key
    FROM gold.fact_sales
    GROUP BY customer_key
), cohort_with_year AS
(
    SELECT
        c.customer_key,
        d.order_year AS cohort_year
    FROM customer_cohort c
    JOIN gold.dim_order_date d
        ON c.first_order_date_key = d.order_date_key
), cohort_activity AS
(
    SELECT
        c.customer_key,
        c.cohort_year,
        d.order_year,
        (d.order_year - c.cohort_year) AS year_offset,
        s.sales_amount
    FROM cohort_with_year c
    JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date d
        ON s.order_date_key = d.order_date_key
)SELECT
    cohort_year,

    SUM(CASE WHEN year_offset = 0 THEN sales_amount ELSE 0 END) AS Y0,
    SUM(CASE WHEN year_offset = 1 THEN sales_amount ELSE 0 END) AS Y1,
    SUM(CASE WHEN year_offset = 2 THEN sales_amount ELSE 0 END) AS Y2,
    SUM(CASE WHEN year_offset = 3 THEN sales_amount ELSE 0 END) AS Y3,
    SUM(CASE WHEN year_offset = 4 THEN sales_amount ELSE 0 END) AS Y4

FROM cohort_activity
GROUP BY cohort_year
ORDER BY cohort_year;
    
/*
cohort_year		Y0			Y1			Y2			Y3			Y4
NULL			0			0			0			0			0
2010			43419		0			0			33796		0
2011			7071510		60955		4325399		0			0
2012			5779094		6093791		0			0			0
2013			5883470		19396		0			0			0
2014			26049		0			0			0			0
*/

--_____________________________________________________________________YEAR 2013 - comparing customers according to the month they arrived_________________________________
WITH customer_cohort AS
(
    SELECT
        f.customer_key,
        MIN(f.order_date_key) AS first_order_date_key
    FROM gold.fact_sales f
    GROUP BY f.customer_key
)

SELECT
    d.order_year,
    d.order_month,
    d.order_month_name,
    COUNT(DISTINCT c.customer_key) AS total_customers
FROM customer_cohort c
JOIN gold.dim_order_date d
    ON c.first_order_date_key = d.order_date_key
WHERE d.order_year = 2013
GROUP BY
    d.order_year,
    d.order_month,
    d.order_month_name
ORDER BY
    d.order_month;
/*
order_year	order_month	order_month_name	total_customers
2013		1			January				324
2013		2			February			1087
2013		3			March				1164
2013		4			April				1088
2013		5			May					1141
2013		6			June				1154
2013		7			July				1052
2013		8			August				1063
2013		9			September			1029
2013		10			October				1133
2013		11			November			1133
2013		12			December			1142
*/

WITH customer_cohort AS
(
    SELECT
        f.customer_key,
        MIN(f.order_date_key) AS first_order_date_key
    FROM gold.fact_sales f
    GROUP BY f.customer_key
)
, cohort_with_date AS
(
    SELECT
        c.customer_key,
        d.order_year,
        d.order_month,
        d.order_month_name,
        c.first_order_date_key
    FROM customer_cohort c
    JOIN gold.dim_order_date d
        ON c.first_order_date_key = d.order_date_key
)
, cohort_activity AS
(
    SELECT
        c.customer_key,
        c.order_year,
        c.order_month AS cohort_month,

        d.order_year AS activity_year,
        d.order_month AS activity_month,

     
        (d.order_year - c.order_year) * 12 +
        (d.order_month - c.order_month) AS month_offset,

        s.sales_amount
    FROM cohort_with_date c
    JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date d
        ON s.order_date_key = d.order_date_key
    WHERE c.order_year = 2013
)
SELECT
    cohort_month,

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
GROUP BY cohort_month
ORDER BY cohort_month;

/*
cohort_month	M0			M1			M2			M3			M4			M5			M6			M7			M8			M9			M10			M11
1				316236		978			1050		6191		3593		3520		1774		6375		785			2052		6421		1114
2				301976		4258		3779		8805		7959		4230		4997		3596		4375		4172		4085		3237
3				339511		2405		2732		6678		14656		8828		2061		2453		2506		2132		1978		0
4				403539		1562		2652		11249		1902		4475		1841		1333		1835		1705		0			0
5				477508		2282		8656		13665		11092		1273		1822		1603		2164		0			0			0
6				540536		1007		4156		6422		28103		6944		1573		1100		0			0			0			0
7				351783		1155		1692		1597		3940		21640		1530		0			0			0			0			0
8				388037		1025		3896		1546		14071		1487		0			0			0			0			0			0
9				402529		1561		1520		1713		1373		0			0			0			0			0			0			0
10				575330		1682		1440		1315		0			0			0			0			0			0			0			0
11				745494		1587		1542		0			0			0			0			0			0			0			0			0
12				736919		1048		0			0			0			0			0			0			0			0			0			0
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
    d.order_year,
    d.order_month,
    d.order_month_name,
    COUNT(DISTINCT c.customer_key) AS total_customers
FROM customer_cohort c
JOIN gold.dim_order_date d
    ON c.first_order_date_key = d.order_date_key
WHERE d.order_year = 2013
GROUP BY
    d.order_year,
    d.order_month,
    d.order_month_name
)
, cohort_with_date AS
(
    SELECT
        c.customer_key,
        d.order_year,
        d.order_month,
        d.order_month_name,
        c.first_order_date_key
    FROM customer_cohort c
    JOIN gold.dim_order_date d
        ON c.first_order_date_key = d.order_date_key
)
, cohort_activity AS
(
    SELECT
        c.customer_key,
        c.order_year,
        c.order_month AS cohort_month,

        d.order_year AS activity_year,
        d.order_month AS activity_month,

     
        (d.order_year - c.order_year) * 12 +
        (d.order_month - c.order_month) AS month_offset,

        s.sales_amount
    FROM cohort_with_date c
    JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    JOIN gold.dim_order_date d
        ON s.order_date_key = d.order_date_key
    WHERE c.order_year = 2013
)
   SELECT
    a.cohort_month,
    b.total_customers,

    CAST((SUM(CASE WHEN month_offset = 0 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M0,
    CAST((SUM(CASE WHEN month_offset = 1 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M1,
    CAST((SUM(CASE WHEN month_offset = 2 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M2,
    CAST((SUM(CASE WHEN month_offset = 3 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M3,
    CAST((SUM(CASE WHEN month_offset = 4 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M4,
    CAST((SUM(CASE WHEN month_offset = 5 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M5,
    CAST((SUM(CASE WHEN month_offset = 6 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M6,
    CAST((SUM(CASE WHEN month_offset = 7 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M7,
    CAST((SUM(CASE WHEN month_offset = 8 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M8,
    CAST((SUM(CASE WHEN month_offset = 9 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M9,
    CAST((SUM(CASE WHEN month_offset = 10 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M10,
    CAST((SUM(CASE WHEN month_offset = 11 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M11,
    CAST((SUM(CASE WHEN month_offset = 12 THEN sales_amount ELSE 0 END) * 1.0 / b.total_customers) AS DECIMAL(10,2)) AS ARPU_M12

FROM cohort_activity a
JOIN cohort_base b
    ON a.cohort_month = b.order_month
    AND a.order_year = b.order_year

GROUP BY
    a.cohort_month,
    b.total_customers

ORDER BY a.cohort_month;

/*
cohort_month	total_customers		ARPU_M0		ARPU_M1		ARPU_M2		ARPU_M3		ARPU_M4		ARPU_M5		ARPU_M6		ARPU_M7		ARPU_M8		ARPU_M9		ARPU_M10	ARPU_M11	ARPU_M12
1				324					976.04		3.02		3.24		19.11		11.09		10.86		5.48		19.68		2.42		6.33		19.82		3.44		2.83
2				1087				277.81		3.92		3.48		8.10		7.32		3.89		4.60		3.31		4.02		3.84		3.76		2.98		0.00
3				1164				291.68		2.07		2.35		5.74		12.59		7.58		1.77		2.11		2.15		1.83		1.70		0.00		0.00
4				1088				370.90		1.44		2.44		10.34		1.75		4.11		1.69		1.23		1.69		1.57		0.00		0.00		0.00
5				1141				418.50		2.00		7.59		11.98		9.72		1.12		1.60		1.40		1.90		0.00		0.00		0.00		0.00
6				1154				468.40		0.87		3.60		5.56		24.35		6.02		1.36		0.95		0.00		0.00		0.00		0.00		0.00
7				1052				334.39		1.10		1.61		1.52		3.75		20.57		1.45		0.00		0.00		0.00		0.00		0.00		0.00
8				1063				365.04		0.96		3.67		1.45		13.24		1.40		0.00		0.00		0.00		0.00		0.00		0.00		0.00
9				1029				391.18		1.52		1.48		1.66		1.33		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00
10				1133				507.79		1.48		1.27		1.16		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00
11				1133				657.98		1.40		1.36		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00		0.00
12				1142				645.29		0.92		0.00		0.00	    0.00	    0.00	    0.00	    0.00    	0.00	    0.00    	0.00	    0.00	    0.00
*/
