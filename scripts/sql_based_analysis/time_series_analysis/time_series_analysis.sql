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


