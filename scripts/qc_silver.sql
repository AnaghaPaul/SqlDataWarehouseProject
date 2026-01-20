/* Identifying quality issues*/
--crm_cust_info (bronze)
-- Check for Nulls or Duplicates in Primary Key
-- Expectation : No Result
SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL;

/* Check unwanted spaces in string values */
-- Expectation : No Results
SELECT 
cst_firstname
FROM
bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

/* Data Standardisation or Consistency*/
SELECT DISTINCT(cst_gndr)
FROM
bronze.crm_cust_info;

SELECT DISTINCT(cst_marital_status)
FROM
bronze.crm_cust_info;
------------------------------------------

/* Identifying quality issues*/
--crm_cust_info(silver)
-- Check for Nulls or Duplicates in Primary Key
-- Expectation : No Result
SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL;

/* Check unwanted spaces in string values */
-- Expectation : No Results
SELECT 
cst_firstname
FROM
silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

/* Data Standardisation or Consistency*/
SELECT DISTINCT(cst_gndr)
FROM
silver.crm_cust_info;

SELECT DISTINCT(cst_marital_status)
FROM
silver.crm_cust_info;



----------------------------------------
--crm_prd_info (bronze)
/* Identifying quality issues*/
-- Check for Nulls or Duplicates in Primary Key
-- Expectation : No Result

SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL;

/* Check unwanted spaces in string values */
-- Expectation : No Results
SELECT 
prd_name
FROM
bronze.crm_prd_info
WHERE prd_name != TRIM(prd_name);

/* Check for Nulls or Negative numbers*/
--Expectation : No Results
SELECT * 
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

/* Data Standardisation or Consistency*/

SELECT DISTINCT(prd_line)
FROM
bronze.crm_prd_info;

/* Check for Invalid Date Orders*/
SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt;
-----------------------------------------------------
--crm_prd_info---silver
/* Identifying quality issues*/
-- Check for Nulls or Duplicates in Primary Key
-- Expectation : No Result

SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL;

/* Check unwanted spaces in string values */
-- Expectation : No Results
SELECT 
prd_name
FROM
silver.crm_prd_info
WHERE prd_name != TRIM(prd_name);

/* Check for Nulls or Negative numbers*/
--Expectation : No Results
SELECT * 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

/* Data Standardisation or Consistency*/

SELECT DISTINCT(prd_line)
FROM
silver.crm_prd_info;

/* Check for Invalid Date Orders*/
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;
---------------------------------------------
