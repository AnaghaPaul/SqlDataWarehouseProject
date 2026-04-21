-- ==============================================================================================================================================
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Analysis>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.>
-- ----------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Trend Analysis>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- --------------------------------------------------------------------------------------------------------------------------------------
-- Sales Trend (Revenue)
-- (MoM)
SELECT
o.order_fiscal_year,
o.order_fiscal_month,
o.order_fiscal_mmyyyy AS fiscal_mmyyyy,
SUM(f.sales_amount) As total_sales
FROM
gold.fact_sales AS f
JOIN
gold.dim_order_date AS o
ON f.order_date_key = o.order_date_key
WHERE f.order_date_key != -1
GROUP BY o.order_fiscal_year,o.order_fiscal_month,o.order_fiscal_mmyyyy
ORDER BY o.order_fiscal_year,o.order_fiscal_month;
-- Sales Growth Trend
-- MoM
WITH monthly_sales AS (
    SELECT
        o.order_fiscal_year,
        o.order_fiscal_month,
        o.order_fiscal_mmyyyy AS fiscal_mmyyyy,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    JOIN gold.dim_order_date AS o
        ON f.order_date_key = o.order_date_key
    WHERE f.order_date_key != -1
    GROUP BY 
        o.order_fiscal_year,
        o.order_fiscal_month,
        o.order_fiscal_mmyyyy
),
previous_sales_details AS (
    SELECT
        order_fiscal_year,
        order_fiscal_month,
        fiscal_mmyyyy,
        total_sales AS current_total_sales,
        LAG(total_sales) OVER (
            ORDER BY order_fiscal_year, order_fiscal_month
        ) AS previous_sales
    FROM monthly_sales
)
SELECT
    order_fiscal_year,
    order_fiscal_month,
    fiscal_mmyyyy,
    current_total_sales,
    previous_sales,
    CASE 
        WHEN previous_sales IS NULL OR previous_sales = 0 THEN NULL
        ELSE ((current_total_sales - previous_sales) * 100.0 / previous_sales)
    END AS sales_growth_rate
FROM previous_sales_details
ORDER BY order_fiscal_year, order_fiscal_month;

-- Sales Trend (YoY)
SELECT
o.order_fiscal_year AS fiscal_year,
SUM(f.sales_amount) As total_sales
FROM
gold.fact_sales AS f
JOIN
gold.dim_order_date AS o
ON f.order_date_key = o.order_date_key
WHERE f.order_date_key != -1
GROUP BY o.order_fiscal_year
ORDER BY o.order_fiscal_year;

-- Sales Growth Trend YoY
WITH yearly_sales AS (
    SELECT
        o.order_fiscal_year,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    JOIN gold.dim_order_date AS o
        ON f.order_date_key = o.order_date_key
    WHERE f.order_date_key != -1
    GROUP BY o.order_fiscal_year
),
previous_sales_details AS (
    SELECT
        order_fiscal_year,
        total_sales AS current_total_sales,
        LAG(total_sales) OVER (
            ORDER BY order_fiscal_year
        ) AS previous_sales
    FROM yearly_sales
)
SELECT
    order_fiscal_year AS fiscal_year,
    current_total_sales,
    previous_sales,
    CASE 
        WHEN previous_sales IS NULL OR previous_sales = 0 THEN NULL
        ELSE CAST(
            ((current_total_sales - previous_sales) * 100.0 / previous_sales)
            AS DECIMAL(7,2)
        )
    END AS sales_growth_rate
FROM previous_sales_details
ORDER BY order_fiscal_year;

-- gross profit
-- gross profit = Revenue - cost of goods
-- cost of goods = quantity * cost

SELECT 
s.order_number,
s.product_key,
s.sales_amount,
s.quantity,
p.cost,
s.sales_amount - (p.cost * s.quantity) AS gross_profit 
FROM 
gold.fact_sales s
JOIN
gold.dim_products p
ON p.product_key=s.product_key
-- YoY profit trend
WITH gross_profit_info AS (
SELECT 
s.order_number,
s.product_key,
s.sales_amount,
s.quantity,
p.cost,
o.order_fiscal_year,
o.order_fiscal_month,
o.order_fiscal_mmyyyy,
s.sales_amount - (COALESCE(p.cost, 0) * COALESCE(s.quantity, 0)) AS gross_profit
FROM 
gold.dim_products p
JOIN
gold.fact_sales s
ON p.product_key = s.product_key
JOIN
gold.dim_order_date o
ON s.order_date_key = o.order_date_key
WHERE s.order_date_key != -1)
SELECT
order_fiscal_year,
SUM(gross_profit) AS total_gross_profit
FROM
gross_profit_info
GROUP BY order_fiscal_year
ORDER BY order_fiscal_year

--MoM profit trend
WITH gross_profit_info AS (
SELECT 
s.order_number,
s.product_key,
s.sales_amount,
s.quantity,
p.cost,
o.order_fiscal_year,
o.order_fiscal_month,
o.order_fiscal_mmyyyy,
s.sales_amount - (COALESCE(p.cost, 0) * COALESCE(s.quantity, 0)) AS gross_profit
FROM 
gold.dim_products p
JOIN
gold.fact_sales s
ON p.product_key = s.product_key
JOIN
gold.dim_order_date o
ON s.order_date_key = o.order_date_key
WHERE s.order_date_key != -1)
SELECT
order_fiscal_mmyyyy,
SUM(gross_profit) AS total_gross_profit
FROM
gross_profit_info
GROUP BY  order_fiscal_year, order_fiscal_month,order_fiscal_mmyyyy
ORDER BY order_fiscal_year, order_fiscal_month

-- YoY profit trend
WITH gross_profit_info AS (
SELECT 
s.order_number,
s.product_key,
s.sales_amount,
s.quantity,
p.cost,
o.order_fiscal_year,
o.order_fiscal_month,
o.order_fiscal_mmyyyy,
s.sales_amount - (COALESCE(p.cost, 0) * COALESCE(s.quantity, 0)) AS gross_profit
FROM 
gold.dim_products p
JOIN
gold.fact_sales s
ON p.product_key = s.product_key
JOIN
gold.dim_order_date o
ON s.order_date_key = o.order_date_key
WHERE s.order_date_key != -1)
SELECT
order_fiscal_year,
SUM(gross_profit) AS total_gross_profit
FROM
gross_profit_info
GROUP BY  order_fiscal_year
ORDER BY order_fiscal_year;
-- YoY Profit Growth Rate
WITH yearly_gross_profit AS
(
SELECT 
o.order_fiscal_year,
SUM(s.sales_amount - (COALESCE(p.cost, 0) * COALESCE(s.quantity, 0))) AS gross_profit
FROM
gold.dim_products p
JOIN
gold.fact_sales s
ON p.product_key = s.product_key
JOIN
gold.dim_order_date o
ON s.order_date_key = o.order_date_key
WHERE o.order_date_key != -1
GROUP BY o.order_fiscal_year),
previous_profit_info AS 
(
SELECT
order_fiscal_year,
gross_profit AS current_year_gross_profit,
LAG(gross_profit) OVER (ORDER BY order_fiscal_year) AS previous_year_gross_profit
FROM
yearly_gross_profit)
SELECT
order_fiscal_year,
CASE 
WHEN previous_year_gross_profit IS NULL or previous_year_gross_profit = 0 THEN NULL
ELSE CAST(((current_year_gross_profit-previous_year_gross_profit)*100.00/previous_year_gross_profit)AS DECIMAL(7,2)) END AS profit_growth_rate
FROM
previous_profit_info


