-- ==============================================================================================================================================
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Analysis>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.>
-- ----------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Trend Analysis>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- --------------------------------------------------------------------------------------------------------------------------------------
-- Sales Trend
-- YoY
SELECT 
	YEAR(shipping_date) AS sales_year,
	SUM(sales_amount) as total_sales
FROM
gold.fact_sales
GROUP BY YEAR(shipping_date)
ORDER BY YEAR(shipping_date);
-->>> Result :
-- The result can be visualized using line plots to identify patterns and trends.
/*
sales_year	total_sales
2011		6978386
2012		5800826
2013		16279963
2014		297075
*/	
-- ----------------------------------------------------------------------------------------------------------------------------------------
-- Sales Trend
-- MoM
SELECT
YEAR(shipping_date) AS sales_year,
CASE MONTH(shipping_date)
	WHEN 1 THEN 'january'
	WHEN 2 THEN 'february'
	WHEN 3 THEN 'march'
	WHEN 4 THEN 'april'
	WHEN 5 THEN 'may'
	WHEN 6 THEN 'june'
	WHEN 7 THEN 'july'
	WHEN 8 THEN 'august'
	WHEN 9 THEN 'september'
	WHEN 10 THEN 'october'
	WHEN 11 THEN 'november'
	WHEN 12 THEN 'december'
	END AS sales_month,
SUM(sales_amount) as total_sales
FROM
gold.fact_sales
GROUP BY YEAR(shipping_date), MONTH(shipping_date)
ORDER BY YEAR(shipping_date), MONTH(shipping_date) ;
-- >>> Result :
-- The result can be visualized using line plots to identify patterns and trends.
/*
sales_year	sales_month	total_sales
2011		january		406476
2011		february	461058
2011		march		492253
2011		april		498552
2011		may			557262
2011		june		689791
2011		july		643803
2011		august		586934
2011		september	632758
2011		october		624961
2011		november	738263
2011		december	646275
2012		january		534284
2012		february	497886
2012		march		404137
2012		april		395466
2012		may			347214
2012		june		536737
2012		july		463752
2012		august		538066
2012		september	429777
2012		october		545698
2012		november	518383
2012		december	589426
2013		january		840652
2013		february	777978
2013		march		1037653
2013		april		1010572
2013		may			1182485
2013		june		1621741
2013		july		1404303
2013		august		1545666
2013		september	1424867
2013		october		1596842
2013		november	1835728
2013		december	2001476
2014		january		289367
2014		february	7708
*/
-- ----------------------------------------------------------------------------------------------------------------------------------------------

--Sales Trend (YoY) - for visualization -line chart
-- For plotting keeping the number of variables to two is better for efficiency
SELECT
	DATEFROMPARTS(YEAR(shipping_date), MONTH(shipping_date), 1) AS month_start,
	SUM(sales_amount) as total_sales
FROM
gold.fact_sales
GROUP BY DATEFROMPARTS(YEAR(shipping_date), MONTH(shipping_date), 1)
ORDER BY DATEFROMPARTS(YEAR(shipping_date), MONTH(shipping_date), 1) ;
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- Result: (limited to 5 rows for convenience)
/*
month_start	total_sales
2011-01-01	406476
2011-02-01	461058
2011-03-01	492253
2011-04-01	498552
2011-05-01	557262
*/
-- -------------------------------------------------------------------------------------------------------------------------------------------------
-- Total Sales per category (YoY)
-- comparing components (total_sales per category)
SELECT 
	YEAR(s.shipping_date) AS sales_year,
	p.category,
	SUM(sales_amount) AS total_sales
FROM gold.dim_products AS p
JOIN
gold.fact_sales AS s
ON
p.product_key = s.product_key
WHERE category IN ('Accessories','Bikes','Clothing','Components') 
GROUP BY YEAR(s.shipping_date),p.category
ORDER BY YEAR(s.shipping_date),p.category;
-- !!!!!!!!! ATTENTION (DATA QUALITY ISSUE)-- suggestion for process improvement 
-- Note : category has Null values which have been omited at the moment by using WHERE clause.
-- While profile stage , it was found from detailed inspection of the null values that the products were pedals of somekind which can be classified as components.
-- This can be either corrected at ETL level, but after discussed with domain experts as to avoid assumption and to flag data quality issue.
-- If corrected in ETL, the where clause can be avoided entirely, which can save time and increase efficiency.
-- ================================================================================================================================================
-- Result :
-- ------------------------------------------------------------------------------------------------------------------------------------------------
/*
sales_year	category		total_sales
2011		Bikes			6978386
2012		Bikes			5800826
2013		Accessories		658115
2013		Bikes			15303477
2013		Clothing		318371
2014		Accessories		42147
2014		Bikes			233583
2014		Clothing		21345
*/
-- -------------------------------------------------------------------------------------------------------------------------------------------------
-- Total Sales per category (MoM)
-- comparing components (total_sales per category)
SELECT 
	YEAR(shipping_date) AS sales_year,
	CASE MONTH(shipping_date)
	WHEN 1 THEN 'january'
	WHEN 2 THEN 'february'
	WHEN 3 THEN 'march'
	WHEN 4 THEN 'april'
	WHEN 5 THEN 'may'
	WHEN 6 THEN 'june'
	WHEN 7 THEN 'july'
	WHEN 8 THEN 'august'
	WHEN 9 THEN 'september'
	WHEN 10 THEN 'october'
	WHEN 11 THEN 'november'
	WHEN 12 THEN 'december'
	END AS sales_month,
	p.category,
	SUM(sales_amount) AS total_sales
FROM gold.dim_products AS p
JOIN
gold.fact_sales AS s
ON
p.product_key = s.product_key
WHERE category IN ('Accessories','Bikes','Clothing','Components') 
GROUP BY YEAR(shipping_date),MONTH(s.shipping_date),p.category
ORDER BY YEAR(shipping_date),MONTH(s.shipping_date),p.category;
-- !!!!!!!!! ATTENTION (DATA QUALITY ISSUE)-- suggestion for process improvement 
-- Note : category has Null values which have been omited at the moment by using WHERE clause.
-- While profile stage , it was found from detailed inspection of the null values that the products were pedals of somekind which can be classified as components.
-- This can be either corrected at ETL level, but after discussed with domain experts as to avoid assumption and to flag data quality issue.
-- If corrected in ETL, the where clause can be avoided entirely, which can save time and increase efficiency.
-- ===========================================================================================================================================
-- Result :
-- Note : Result limited to 5 rows
-- --------------------------------------------------------------------------------------------------------------------------------------------
/*
sales_year	sales_month		category	total_sales
2011		january			Bikes		406476
2011		february		Bikes		461058
2011		march			Bikes		492253
2011		april			Bikes		498552
2011		may				Bikes		557262
*/

-- =============================================================================================================================================
-
