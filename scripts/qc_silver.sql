/*
==========================================================
Quality Checks
==========================================================
Script Purpose:
This script performs various quality checke for data consistency,
accuracy, and standardization accross the 'silver' schema. It includes
checks for:
	- Null or duplicate primary keys.
	- Unwanted spaces in string fields.
	- Data standardization and consistency.
	- Invalid Date ranges and orders.
	- Data consistency between related fields.

Usage Notes:
	- Run these checks after data loading silver layer.
	- Investigate and resolve any discrepancies found during the checks.
=================================================================================
*/
-- ---------------------------------------------------------------------------
-- ==============================================================================
/* Identifying quality issues*/
--crm_cust_info (bronze)
-- ==============================================================================

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
-- =======================================================================
/* Identifying quality issues*/
--crm_cust_info(silver)
-- ========================================================================
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

-- ================================================================

-- ----------------------------------------------------------------
-- ================================================================
--crm_prd_info (bronze)
/* Identifying quality issues*/
-- ===============================================================
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
-- ==============================================================
/* Identifying quality issues*/
--crm_prd_info---silver
-- =============================================================
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
-- --------------------------------------------------------------
-- ==============================================================
/* Identifying quality issues*/
--crm_sales_details
-- =============================================================
-->> Bronze layer
SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN  (SELECT prd_key FROM  silver.crm_prd_info);

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN  (SELECT sls_cust_id FROM  silver.crm_cust_info);

-- Check for invalid dates
-- negative numbers or zeroes can't be cast to a date
SELECT
NULLIF(sls_order_dt,0) as sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR
LEN(sls_order_dt)!= 8 OR 
sls_order_dt > 20500101 OR
sls_order_dt < 19000101;

SELECT
NULLIF(sls_ship_dt,0) as sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 OR
LEN(sls_ship_dt)!= 8 OR 
sls_ship_dt > 20500101 OR
sls_ship_dt < 19000101;

SELECT
NULLIF(sls_due_dt,0) as sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 OR
LEN(sls_due_dt)!= 8 OR 
sls_due_dt > 20500101 OR
sls_due_dt < 19000101;

-- order date must always be earlier than shipping date or due date
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

--Business rule check
-- Sales = Quantity * Price
-- Negative, Zeroes , Nulls not allowed
SELECT DISTINCT
sls_sales AS old_sls_price,
sls_quantity,
sls_price AS old_sls_price,

CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0 
	THEN sls_sales / NULLIF(sls_quantity,0)
	ELSE sls_price
END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
--Rules
-- if sales is negative, zero, or null, derive it using Quantity and Price
-- if price is zero or null, calculate it using sales and quantity
-- if price is negative, convert it to a positive value

-- ===================================================================
-->> Silver layer
--Quality check, silver layer
-- ==================================================================
SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN  (SELECT prd_key FROM  silver.crm_prd_info);

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN  (SELECT sls_cust_id FROM  silver.crm_cust_info);


-- order date must always be earlier than shipping date or due date
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

--Business rule check
-- Sales = Quantity * Price
-- Negative, Zeroes , Nulls not allowed
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

------------------------------------------------------------------
-- ===============================================================
-- ===============================================================
-->>>>> ERP Tables
-- ===============================================================

-- ===============================================================
--erp_cust_az12
-- ===============================================================

-- >>> bronze layer
SELECT
	
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END cid,
	bdate,
	gen
FROM bronze.erp_cust_az12
	
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END
NOT IN (SELECT DISTINCT cst_key FROM bronze.crm_cust_info);

--Invalid dates
SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();
--gen
SELECT DISTINCT
gen
FROM bronze.erp_cust_az12;

-- >>>Silver layer
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

SELECT DISTINCT
gen
FROM silver.erp_cust_az12;
-- ======================================================
--erp_loc_a101
-- ======================================================
-- checking valid  keys
SELECT DISTINCT
	cid
FROM bronze.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info)

SELECT DISTINCT
	REPLACE(cid,'-','') AS cid
FROM bronze.erp_loc_a101
WHERE REPLACE(cid,'-','') NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- Data Standardization and Consistency
SELECT DISTINCT
cntry
FROM bronze.erp_loc_a101;

-->>> Silver layer
SELECT DISTINCT
	cid
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info)

SELECT DISTINCT
	cntry
FROM
silver.erp_loc_a101;








