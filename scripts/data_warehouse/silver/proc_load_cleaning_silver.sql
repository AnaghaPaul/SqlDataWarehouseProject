/*Stored Procedure: Load Silver Layer (Bronze -> Silver)
==============================================================================
Purpose: This stored procedure performs the ETL (Extract, Transform, Load) process 
to  populate the 'silver' schema tables from 'bronze' schema.
Actions performed: 
-Truncates Silver tables.
-Inserts transformed and cleansed data from Bronze into silver tables.
-Populate dim_date table
Warning : The script will truncate any existing data in the table, so execute with precaution.
===============================================================================
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
===============================================================================*/

CREATE OR ALTER PROCEDURE silver.load_silver AS --stored procedure
	BEGIN
		DECLARE @start_load_time DATETIME, @end_load_time DATETIME, @batch_start_time DATETIME , @batch_end_time DATETIME; -- start_load_time, end_load time, batch_start time, batch_end_time
	    BEGIN TRY
			SET @batch_start_time = GETDATE();
	
			PRINT '=================================================================================================';
			PRINT 'Loading Silver Layer';
			PRINT '=================================================================================================';
			PRINT 'Loading Source Derived Tables - Customer Relationship Management and Enterprise Resource Planning';
			PRINT '==================================================================================================';
			PRINT '--------------------------------------------------------------------------------------------------';
			PRINT 'Loading CRM Tables';
			PRINT '-------------------------------------------------------------------------------------------------';
-- ==========================================================================
-- Truncating and Inserting Data into silver.crm_cust_info
			PRINT '>>Preparing to truncate and load silver.crm_cust_info';
	
			SET @start_load_time = GETDATE();
-- Truncate	
			PRINT'>> Truncating Table : silver.crm_cust_info';
			TRUNCATE TABLE silver.crm_cust_info;
			PRINT'>> Inserting Data Into : silver.crm_cust_info';
-- Insert
			INSERT INTO silver.crm_cust_info (
						cst_id, 
						cst_key, 
						cst_firstname, 
						cst_lastname, 
						cst_marital_status, 
						cst_gndr,
						cst_create_date
					)
			SELECT
			cst_id,
						cst_key,
						TRIM(cst_firstname) AS cst_firstname,
						TRIM(cst_lastname) AS cst_lastname,
						CASE 
							WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
							WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
							ELSE 'n/a'
						END AS cst_marital_status, -- Normalize marital status values to readable format
						CASE 
							WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
							WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
							ELSE 'n/a'
						END AS cst_gndr, -- Normalize gender values to readable format
						cst_create_date
					FROM (
						SELECT
							*,
							ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
						FROM bronze.crm_cust_info
						WHERE cst_id IS NOT NULL
					) t
					WHERE flag_last = 1; -- Select the most recent record per customer
	
			SET @end_load_time = GETDATE();
			PRINT '>>Loading to silver.crm_cust_info completed successfully';
			PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
			PRINT '-------------------------------------------------------------------------------------------------';
-- Loding completed for silver.crm_cust_info
-- ===================================================================================================================
-- Truncating and Inserting Data into silver.crm_prd_info
			PRINT '>>Preparing to truncate and load silver.crm_prd_info';
			
			-- crm_prd_info
			SET @start_load_time = GETDATE();
-- Truncate				
			PRINT'>> Truncating Table : silver.crm_prd_info';
			TRUNCATE TABLE silver.crm_prd_info;
			PRINT'>> Inserting Data Into : silver.crm_prd_info';
-- Insert					
			INSERT INTO silver.crm_prd_info (
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
						REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID
						SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Extract product key
						prd_name,
						ISNULL(prd_cost, 0) AS prd_cost,
						CASE 
							WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
							WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
							WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
							WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
							ELSE 'n/a'
						END AS prd_line, -- Map product line codes to descriptive values
						CAST(prd_start_dt AS DATE) AS prd_start_dt,
						CAST(
							DATEADD(DAY, -1,LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) 
							AS DATE
						) AS prd_end_dt -- Calculate end date as one day before the next start date
					FROM bronze.crm_prd_info;
	
	
			SET @end_load_time = GETDATE();
			PRINT '>>Loading to silver.crm_prod_info completed successfully';
			PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
			PRINT '-------------------------------------------------------------------------------------------------';
-- ---------------------------------------------------------------------------------------------------------------------
			
			--crm_sales_details
			PRINT '>>Preparing to truncate and load silver.crm_sales';
	
			SET @start_load_time = GETDATE();
-- Truncate
			PRINT'>> Truncating Table : silver.crm_sales_details';
			TRUNCATE TABLE silver.crm_sales_details;
			PRINT'>> Inserting Data Into : silver.crm_sales_details';
-- Insert			
			INSERT INTO silver.crm_sales_details (
						sls_ord_num,
						sls_prd_key,
						sls_cust_id,
						sls_order_dt,
						sls_ship_dt,
						sls_due_dt,
						sls_sales,
						sls_quantity,
						sls_price
			)
			
			SELECT
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
				END AS sls_order_dt,
			
				CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
				END AS sls_ship_dt,
			
				CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
				END AS sls_due_dt,
			
				CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
					THEN sls_quantity * ABS(sls_price)
					ELSE sls_sales
				END AS sls_sales,
			
				sls_quantity,
			
				CASE WHEN sls_price IS NULL OR sls_price <= 0 
					THEN sls_sales / NULLIF(sls_quantity,0)
					ELSE sls_price
				END AS sls_price
			
			FROM bronze.crm_sales_details;
	
			SET @end_load_time = GETDATE();
			PRINT '>>Loading to silver.crm_sales_details completed successfully';
			PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
			PRINT '-------------------------------------------------------------------------------------------------';
	
			PRINT '>> CRM Tables loaded successfully.';
			PRINT '=================================================================================================';

-- =========================================================================================================================
			--ERP Tables
			PRINT '------------------------------------------';
			PRINT 'Loading ERP Tables';
			PRINT '------------------------------------------';
			
			
			--erp_cust_az12
			PRINT '>>Preparing to truncate and load silver.erp_cust_az12';
			SET @start_load_time = GETDATE();
-- Truncate
			PRINT'>> Truncating Table : silver.erp_cust_az12';
			TRUNCATE TABLE silver.erp_cust_az12;
			
-- Insert	
			PRINT'>> Inserting Data Into : silver.erp_cust_az12';
			INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
				SELECT 
				
				CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
					 ELSE cid
				END AS cid,
				
				CASE WHEN bdate > GETDATE() THEN NULL
					 ELSE bdate
				END AS bdate,
				
				CASE WHEN UPPER(TRIM(gen)) IN ('F' , 'FEMALE') THEN 'Female'
					 WHEN UPPER(TRIM(gen)) IN ('M' , 'MALE') THEN 'Male'
					 ELSE 'n/a'
				END AS gen
			FROM bronze.erp_cust_az12;

			SET @end_load_time = GETDATE();
			PRINT '>>Loading to silver.erp_cust_az12 completed successfully';
			PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
			PRINT '-------------------------------------------------------------------------------------------------';
-- ---------------------------------------------------------------------------------------------------------------------------				
			--erp_loc_a101
			PRINT '>>Preparing to truncate and load silver.erp_loc_a101';
			SET @start_load_time = GETDATE();
-- Truncate
			PRINT'>> Truncating Table : silver.erp_loc_a101';
			TRUNCATE TABLE silver.erp_loc_a101;
-- Insert
			PRINT'>> Inserting Data Into : silver.erp_loc_a101';
			
			INSERT INTO silver.erp_loc_a101(cid,cntry)
			
				SELECT
					REPLACE(cid,'-','') AS cid,
					CASE WHEN TRIM(cntry) ='DE' THEN 'Germany'
						WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
						WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
						ELSE TRIM(cntry)
				END AS cntry
			FROM bronze.erp_loc_a101;
	
			SET @end_load_time = GETDATE();
			PRINT '>>Loading to silver.erp_loc_a101 completed successfully';
			PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
			PRINT '-------------------------------------------------------------------------------------------------';
-- ----------------------------------------------------------------------------------------------------------------------
			
			--erp_px_cat_g1v2
			PRINT '>>Preparing to truncate and load silver.erp_px_cat_g1v2';
			SET @start_load_time = GETDATE();
	-- Truncate
			PRINT'>> Truncating Table : silver.erp_px_cat_g1v2';
			TRUNCATE TABLE silver.erp_px_cat_g1v2;
			PRINT'>> Inserting Data Into : silver.erp_px_cat_g1v2';
	-- Insert		
			INSERT INTO silver.erp_px_cat_g1v2(
				id,
				cat,
				subcat,
				maintenance
				)
			
			SELECT
			id,
			cat,
			subcat,
			maintenance
			FROM bronze.erp_px_cat_g1v2;
	
			SET @end_load_time = GETDATE();
			PRINT '>>Loading to silver.erp_px_cat_g1v2 completed successfully';
			PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
			PRINT '-------------------------------------------------------------------------------------------------';
			PRINT '>>ERP tables truncated and loaded successfully.';
			PRINT '=================================================================================================';
			PRINT '>> All source derived tables are truncated and loaded successfully.';
			PRINT '=================================================================================================';

			
-- ----------------------------------------------------------------------------------------------------------------------------
-- Truncating and Populating dwh_dim_date
/*  Rebuild Date Dimension (dwh_dim_date)

   - Truncates and reloads the Date dimension with standardized calendar
     attributes.
   - Acts as a conformed dimension reused across multiple business dates
     (order, shipping, due).

   Benefits:
   - Consistent time intelligence across the warehouse
   - Simplified joins and faster analytical queries
   - Centralized date logic for reporting and BI consumption */
-- calendar table added - updated on 02-06-2026
			PRINT'>>Preparing to truncate and populate dwh_dim_date.'

--dwh_dim_date
			-- SET NOCOUNT ON stops SQL Server from sending the message 
			-- indicating the number of rows affected by T-SQL statements.
			SET NOCOUNT ON;
			PRINT'>>NOCOUNT set On'
				
			SET @start_load_time = GETDATE();
-- Truncate
	
			PRINT'>> Truncating Table : silver.dwh_dim_date';
			TRUNCATE TABLE silver.dwh_dim_date;
			PRINT'>> Inserting Data Into : silver.dwh_dim_date';
			-- Populating date dimension table
			-- =======================================================================================
			--Specify Start Date and End date here
			--Value of Start Date Must be Less than Your End Date 
			--=========================================================================================

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			DECLARE @start_date DATETIME = '12/29/2014' --Starting value of Date Range
			DECLARE @end_date DATETIME = '01/01/2100' --End Value of Date Range
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			PRINT '>> The dwh_dim_date will be populated from ' + CAST(@start_date AS NVARCHAR(30))  + ' to ' + CAST(@end_date AS NVARCHAR(30)) + '.';

			--Temporary Variables To Hold the Values During Processing of Each Date of Year
			DECLARE
				@day_of_week_in_month INT,
				@day_of_week_in_year INT,
				@day_of_quarter INT,
				@week_of_month INT,
				@current_year INT,
				@current_month INT,
				@current_quarter INT

			/*Table Data type to store the day of week count for the month and year*/
			DECLARE @day_of_week TABLE
			(
				dow INT,
				month_count INT,
				quarter_count INT,
				year_count INT
			)

			INSERT INTO @day_of_week VALUES (1, 0, 0, 0)
			INSERT INTO @day_of_week VALUES (2, 0, 0, 0)
			INSERT INTO @day_of_week VALUES (3, 0, 0, 0)
			INSERT INTO @day_of_week VALUES (4, 0, 0, 0)
			INSERT INTO @day_of_week VALUES (5, 0, 0, 0)
			INSERT INTO @day_of_week VALUES (6, 0, 0, 0)
			INSERT INTO @day_of_week VALUES (7, 0, 0, 0)

			--Extract and assign various parts of Values from Current Date to Variable

			DECLARE @current_date AS DATETIME = @start_date
			SET @current_month = DATEPART(MM, @current_date)
			SET @current_year = DATEPART(YY, @current_date)
			SET @current_quarter = DATEPART(QQ, @current_date)

			/********************************************************************************************/
			--Proceed only if Start Date(Current date) is less than End date you specified above

			WHILE @current_date < @end_date
			/*Begin day of week logic*/
			BEGIN
				/*Check for Change in Month of the Current date if Month changed then 
				Change variable value*/
				IF @current_month != DATEPART(MM, @current_date) 
				BEGIN
					UPDATE @day_of_week
					SET [month_count] = 0
					SET @current_month = DATEPART(MM, @current_date)
				END

				/* Check for Change in Quarter of the Current date if Quarter changed then change 
					Variable value*/
				IF @current_quarter != DATEPART(QQ, @current_date)
				BEGIN
					UPDATE @day_of_week
					SET [quarter_count] = 0
					SET @current_quarter = DATEPART(QQ, @current_date)
				END

				/* Check for Change in Year of the Current date if Year changed then change 
					Variable value*/
				IF @current_year != DATEPART(YY, @current_date)
				BEGIN
					UPDATE @day_of_week
					SET year_count = 0
					SET @current_year = DATEPART(YY, @current_date)
				END

				-- Set values in table data type created above from variables
				UPDATE @day_of_week
				SET 
					month_count = month_count + 1,
					quarter_count = quarter_count + 1,
					year_count = year_count + 1
				WHERE dow = DATEPART(DW, @current_date)

				SELECT
					@day_of_week_in_month = month_count,
					@day_of_quarter = quarter_count,
					@day_of_week_in_year = year_count
				FROM @day_of_week
				WHERE dow = DATEPART(DW, @current_date)
    
			/*End day of week logic*/


			/* Populate Your Dimension Table with values*/
    
				INSERT INTO silver.dwh_dim_date

				SELECT
        
					CONVERT (char(8),@current_date,112) as 'date_key',
					@current_date AS 'date',
					CONVERT (char(10),@current_date,101) as 'full_date',
					DATEPART(DD, @current_date) AS 'day_of_month',
					--Apply Suffix values like 1st, 2nd 3rd etc..
					CASE 
						WHEN DATEPART(DD,@current_date) IN (11,12,13) THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'th'
						WHEN RIGHT(DATEPART(DD,@current_date),1) = 1 THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'st'
						WHEN RIGHT(DATEPART(DD,@current_date),1) = 2 THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'nd'
						WHEN RIGHT(DATEPART(DD,@current_date),1) = 3 THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'rd'
						ELSE CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'th' 
					END AS 'day_suffix',
        
					DATENAME(DW, @current_date) AS 'day_name',
					DATEPART(DW, @current_date) AS 'day_of_week',
					@day_of_week_in_month AS 'day_of_week_in_month',
					@day_of_week_in_year AS 'day_of_week_in_year',
					@day_of_quarter AS 'day_of_quarter',
					DATEPART(DY, @current_date) AS 'day_of_year',
					DATEPART(WW, @current_date) + 1 - DATEPART(WW, CONVERT(VARCHAR, DATEPART(MM, @current_date)) + '/1/' + CONVERT(VARCHAR, DATEPART(YY, @current_date))) AS 'week_of_month',
					(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @current_date), 0), @current_date) / 7) + 1 AS 'week_of_quarter',
					DATEPART(WW, @current_date) AS 'week_of_year',
					DATEPART(MM, @current_date) AS 'month',
					DATENAME(MM, @current_date) AS 'month_name',
					CASE
						WHEN DATEPART(MM, @current_date) IN (1, 4, 7, 10) THEN 1
						WHEN DATEPART(MM, @current_date) IN (2, 5, 8, 11) THEN 2
						WHEN DATEPART(MM, @current_date) IN (3, 6, 9, 12) THEN 3
					END AS 'month_of_quarter',
					DATEPART(QQ, @current_date) AS 'quarter',
					CASE DATEPART(QQ, @current_date)
						WHEN 1 THEN 'First'
						WHEN 2 THEN 'Second'
						WHEN 3 THEN 'Third'
						WHEN 4 THEN 'Fourth'
					END AS 'quarter_name',
					DATEPART(YEAR, @current_date) AS 'year',
					'CY ' + CONVERT(VARCHAR, DATEPART(YEAR, @current_date)) AS 'year_name',
					LEFT(DATENAME(MM, @current_date), 3) + '-' + CONVERT(VARCHAR, DATEPART(YY, @current_date)) AS 'month_year',
					RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @current_date)),2) + CONVERT(VARCHAR, DATEPART(YY, @current_date)) AS 'mmyyy',
					CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, @current_date) - 1), @current_date))) AS 'first_day_of_month',
					CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, (DATEADD(MM, 1, @current_date)))), DATEADD(MM, 1, @current_date)))) AS 'last_day_of_month',
					DATEADD(QQ, DATEDIFF(QQ, 0, @current_date), 0) AS 'first_day_of_quarter',
					DATEADD(QQ, DATEDIFF(QQ, -1, @current_date), -1) AS 'last_day_of_quarter',
					CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, @current_date))) AS 'first_day_of_year',
					CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, @current_date))) AS 'last_day_of_year',
					CASE DATEPART(DW, @current_date)
						WHEN 1 THEN 0
						WHEN 2 THEN 1
						WHEN 3 THEN 1
						WHEN 4 THEN 1
						WHEN 5 THEN 1
						WHEN 6 THEN 1
						WHEN 7 THEN 0
					END AS 'is_weekday'

				SET @current_date = DATEADD(DD, 1, @current_date)
				END
	
			SET @end_load_time = GETDATE();
			PRINT '>>dwh_dim_date populated successfully'

			PRINT '>>Load Duration:' +CAST(DATEDIFF(second,@start_load_time,@end_load_time) AS NVARCHAR)+ ' seconds';
			PRINT '---------------------------------------------------------------------------------------------------------------'
	
			SET @batch_end_time=GETDATE();
			PRINT '---------------------------------------------------------------------------------------------------------------'
			PRINT '>>Loading silver layer is completed'
			PRINT '---------------------------------------------------------------------------------------------------------------'
	
			PRINT '>>Total Load Duration for silver layer:' +CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR)+ ' seconds';
			PRINT '---------------------------------------------------------------------------------------------------------------'

		END TRY
		BEGIN CATCH
			 PRINT '==============================================='
			 PRINT 'ERROR OCCURED WHILE LOADING THE SILVER LAYER'
			 PRINT ' ERROR MESSAGE ' + ERROR_MESSAGE();
			 PRINT ' ERROR MESSAGE ' +CAST(ERROR_NUMBER() AS NVARCHAR);
			 PRINT ' ERROR MESSAGE ' +CAST(ERROR_STATE() AS NVARCHAR);
			 PRINT '==============================================='
		END CATCH			
	END
