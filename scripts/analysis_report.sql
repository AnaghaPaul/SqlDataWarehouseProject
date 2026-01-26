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
WITH yearly_customers AS (
    SELECT DISTINCT
        sls_cust_id,
        YEAR(sls_order_dt) AS order_year
    FROM silver.crm_sales_details
    WHERE YEAR(sls_order_dt) IN (2013, 2014)
)
SELECT
    100.0 *
    COUNT(DISTINCT CASE 
        WHEN y2013.sls_cust_id IS NOT NULL 
         AND y2014.sls_cust_id IS NOT NULL 
        THEN y2013.sls_cust_id 
    END)
    /
    NULLIF(COUNT(DISTINCT y2013.sls_cust_id), 0) 
    AS annual_repurchase_rate
FROM yearly_customers y2013
  
LEFT JOIN yearly_customers y2014
    ON y2013.sls_cust_id = y2014.sls_cust_id
   AND y2014.order_year = 2014
WHERE y2013.order_year = 2013;

/*result : 1.88% < 40% --> E-Commerce type is aquisition mode, the buyers of this business usually do not repurchase the product,
this may be due to the business selling one-time purchase products and customer does not need to up-grade soon.
Loyalty programs are not good long-term investments, instead the company need to focus on acquiring new customers*/



