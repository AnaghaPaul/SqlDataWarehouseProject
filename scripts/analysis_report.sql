/* Analysis*/
/* The type of business is E-commerce , where  a visitor buys something from a web based retailer*/
-- Before we do any further analysis , let's look the objective or aim of the business - where should the business focus ? 
-- This can be identified by deciding the mode of E-commerce the company falls in.
-- This can be derived from the data, by looking at the annual re-purchase rate of this year compared to previous year.
-- The historical data of sales orders can be queried from silver layer from silver.crm_sales_details
--To find the distinct years
SELECT
  DISTINCT(YEAR(sls_order_dt)) 
  FROM silver.crm_sales_details; 
--Result : 2010, 2011, 2012, 2013, 2014
-- annual repurchase rate
