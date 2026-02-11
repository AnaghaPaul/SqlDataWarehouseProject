/*
=====================================================================================================
DDL Script: Create Silver Tables
=====================================================================================================
Purpose : This script creates 7 empty tables in silver layer and drop the tables if they already exists. 
This is the step before 'Full load' of data into the silver layer. There are 6 tables that are derived
from the source systems and one calendar table(dwh_calendar_table) that is generated in the datawarehouse
so as to make time series analysis easier
Warning : The existing tables and data in it would be deleted when the script is executed.*/


USE DataWarehouse;
GO

--Creating Empty Tables


--CRM

--crm customer info table
IF OBJECT_ID ('silver.crm_cust_info','U') IS  NOT NULL
	DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info(--naming convention - <source><name>
	cst_id INT,
	cst_key NVARCHAR (50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);


-- crm product info table
IF OBJECT_ID ('silver.crm_prd_info','U') IS  NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_name NVARCHAR (50),
	prd_cost INT,
	prd_line NVARCHAR (50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


-- crm sales details table
IF OBJECT_ID ('silver.crm_sales_details','U') IS  NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,--Is in form <YEAR><MONTH><DAY> without space
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


--ERP

-- CUST_AZ12
IF OBJECT_ID ('silver.erp_cust_az12','U') IS  NOT NULL
	DROP TABLE silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);


-- LOC_A101
IF OBJECT_ID ('silver.erp_loc_a101','U') IS  NOT NULL
	DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);


--PX_CAT_G1V2
IF OBJECT_ID ('silver.erp_px_cat_g1v2','U') IS  NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);


-- Calendar table (generated in datawarehouse, not derived from source data)
IF OBJECT_ID('silver.dwh_dim_date', 'U') IS NOT NULL
    DROP TABLE silver.dwh_dim_date

CREATE TABLE silver.dwh_dim_date
(
    date_key INT primary key, 
    date DATETIME,
    full_date CHAR(10),-- Date in MM-dd-yyyy format
    day_of_month VARCHAR(2), -- Field will hold day number of Month
    day_suffix VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
    day_name VARCHAR(9), -- Contains name of the day, Sunday, Monday 
    day_of_week CHAR(1),-- First Day Sunday=1 and Saturday=7
    day_of_week_in_month VARCHAR(2), --1st Monday or 2nd Monday in Month
    day_of_week_in_year VARCHAR(2),
    day_of_quarter VARCHAR(3), 
    day_of_year VARCHAR(3),
    week_of_month VARCHAR(1),-- Week Number of Month 
    week_of_quarter VARCHAR(2), --Week Number of the Quarter
    week_of_year VARCHAR(2),--Week Number of the Year
    month VARCHAR(2), --Number of the Month 1 to 12
    month_name VARCHAR(9),--January, February etc
    month_of_quarter VARCHAR(2),-- Month Number belongs to Quarter
    quarter CHAR(1),
    quarter_name VARCHAR(9),--First,Second..
    year CHAR(4),-- Year value of Date stored in Row
    year_name CHAR(7), --CY 2012,CY 2013
    month_year CHAR(10), --Jan-2013,Feb-2013
    mmyyyy CHAR(6),
    first_day_of_month DATE,
    last_day_of_month DATE,
    first_day_of_quarter DATE,
    last_day_of_quarter DATE,
    first_day_of_year DATE,
    last_day_of_year DATE,
    is_weekday BIT,-- 0=Week End ,1=Week Day
);
-- -----------------------------------------------------------------------------------------------------------------------------
-- Supplementary Calendar Dimension(generated in datawarehouse)
-- Stores geography-specific calendar attributes (holidays, holiday type, seasons).
-- Designed to extend the core Date dimension without duplicating it.
-- Joined contextually using date_key and customer country.

IF OBJECT_ID('silver.dwh_dim_supplementary_calendar', 'U') IS NOT NULL
    DROP TABLE silver.dwh_dim_supplementary_calendar

CREATE TABLE silver.dwh_dim_supplementary_calendar(
date_key INT NOT NULL,
country CHAR(10) NOT NULL,
holiday_flag BIT NOT NULL,
religious_holiday_flag BIT NOT NULL,
holiday_name VARCHAR(100) NULL,
season VARCHAR(20) NOT NULL
	CONSTRAINT pk_dim_supplementary_calendar
		PRIMARY KEY (date_key, country),
	CONSTRAINT fk_calendar_date
		FOREIGN KEY (date_key)
		REFERENCES silver.dwh_dim_date(date_key)
);
