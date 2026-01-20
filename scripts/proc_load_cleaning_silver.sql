INSERT INTO silver.crm_cust_info(
	cst_id,cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)
SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 ELSE 'n/a'
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 ELSE 'n/a'
	END cst_gndr,
cst_create_date
FROM
(SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1;

SELECT TOP(20) * 
FROM silver.crm_cust_info;
SELECT TOP(20) * 
FROM bronze.crm_cust_info;


---crm_prd_info
INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_name,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)

SELECT 
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
prd_name,
ISNULL(prd_cost,0) as prd_cost,
 CASE UPPER(TRIM(prd_line)) 
      WHEN 'M' THEN 'Mountain'
	  WHEN 'R' THEN 'Road'
	  WHEN 'S' THEN 'Other Sales'
	  WHEN 'T' THEN 'Touring'
	  ELSE 'n/a'
 END AS prd_line,
 CAST(prd_start_dt AS DATE) as prd_start_dt,
--LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test,--does not work on sql server
CAST(DATEADD(DAY,-1,LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
FROM
bronze.crm_prd_info;
