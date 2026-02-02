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
-- -------------------------------------------------------------------------------------------------------------------------------------------------
