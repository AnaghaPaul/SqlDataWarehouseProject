-- ======================================================================================
  -- Create roleplaying views of Dimension Date
  -- =======================================================================================


-- -------------------------------------------------------------------------------------------
-- dim_order_date
-- -------------------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_order_date','V') IS NOT NULL
    DROP VIEW gold.dim_order_date;
GO
  CREATE VIEW gold.dim_order_date AS
  SELECT
  	date_key AS order_date_key, 
    date AS order_date,
    full_date AS order_full_date,-- Date in MM-dd-yyyy format
    day_of_month AS order_day_of_month, -- Field will hold day number of Month
    day_suffix AS order_day_suffix, -- Apply suffix as 1st, 2nd ,3rd etc
    day_name AS order_day_name, -- Contains name of the day, Sunday, Monday 
    day_of_week AS order_day_of_week,-- First Day Sunday=1 and Saturday=7
    day_of_week_in_month AS order_day_of_week_in_month, --1st Monday or 2nd Monday in Month
    day_of_week_in_year AS order_day_of_week_in_year,
    day_of_quarter AS order_day_of_quarter, 
    day_of_year AS order_day_of_year,
    week_of_month AS order_week_of_month,-- Week Number of Month 
    week_of_quarter AS order_week_of_quarter, --Week Number of the Quarter
    week_of_year AS order_week_of_year,--Week Number of the Year
    month AS order_month, --Number of the Month 1 to 12
    month_name AS order_month_name,--January, February etc
    month_of_quarter AS order_month_of_quarter,-- Month Number belongs to Quarter
    quarter AS order_quarter,
    quarter_name AS order_quarter_name,--First,Second..
    year AS order_year,-- Year value of Date stored in Row
    year_name AS order_year_name, --CY 2012,CY 2013
    month_year AS order_month_year, --Jan-2013,Feb-2013
    mmyyyy AS order_mmyyyy,
    first_day_of_month AS order_first_day_of_month,
    last_day_of_month AS order_last_day_of_month,
    first_day_of_quarter AS order_first_day_of_quarter,
    last_day_of_quarter AS order_last_day_of_quarter,
    first_day_of_year AS order_first_day_of_year,
    last_day_of_year AS order_last_day_of_year,
	season AS order_season,
	is_holiday AS order_is_holiday,
    is_weekday AS order_is_weekday,-- 0=Week End ,1=Week Day
	holiday_name AS order_holiday_name,
	fiscal_day_of_year AS order_fiscal_day_of_year,
	fiscal_week_of_year AS order_fiscal_week_of_year,
	fiscal_month AS order_fiscal_month,
	fiscal_quarter AS order_fiscal_quarter,
	fiscal_quarter_name AS order_fiscal_quarter_name,
	fiscal_year AS order_fiscal_year,
	fiscal_year_name AS order_fiscal_year_name,
	fiscal_month_year AS order_fiscal_month_year,
	fiscal_mmyyyy AS order_fiscal_mmyyyy,
	fiscal_first_day_of_month AS order_fiscal_first_day_of_month,
	fiscal_last_day_of_month AS order_fiscal_last_day_of_month,
	fiscal_first_day_of_quarter AS order_fiscal_first_day_of_quarter,
	fiscal_last_day_of_quarter AS order_fiscal_last_day_of_quarter,
	fiscal_first_day_of_year AS order_fiscal_first_day_of_year,
	fiscal_last_day_of_year AS order_fiscal_last_day_of_year
	
  FROM gold.dim_date

-- ------------------------------------------------------------------------------------------------
-- dim_shipping_date
-- -------------------------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_shipping_date','V') IS NOT NULL
    DROP VIEW gold.dim_shipping_date;
GO
  CREATE VIEW gold.dim_shipping_date AS
  SELECT
  	date_key AS shipping_date_key, 
    date AS shipping_date,
    full_date AS shipping_full_date,-- Date in MM-dd-yyyy format
    day_of_month AS shipping_day_of_month, -- Field will hold day number of Month
    day_suffix AS shipping_day_suffix, -- Apply suffix as 1st, 2nd ,3rd etc
    day_name AS shipping_day_name, -- Contains name of the day, Sunday, Monday 
    day_of_week AS shipping_day_of_week,-- First Day Sunday=1 and Saturday=7
    day_of_week_in_month AS shipping_day_of_week_in_month, --1st Monday or 2nd Monday in Month
    day_of_week_in_year AS shipping_day_of_week_in_year,
    day_of_quarter AS shipping_day_of_quarter, 
    day_of_year AS shipping_day_of_year,
    week_of_month AS shipping_week_of_month,-- Week Number of Month 
    week_of_quarter AS shipping_week_of_quarter, --Week Number of the Quarter
    week_of_year AS shipping_week_of_year,--Week Number of the Year
    month AS shipping_month, --Number of the Month 1 to 12
    month_name AS shipping_month_name,--January, February etc
    month_of_quarter AS shipping_month_of_quarter,-- Month Number belongs to Quarter
    quarter AS shipping_quarter,
    quarter_name AS shipping_quarter_name,--First,Second..
    year AS shipping_year,-- Year value of Date stored in Row
    year_name AS shipping_year_name, --CY 2012,CY 2013
    month_year AS shipping_month_year, --Jan-2013,Feb-2013
    mmyyyy AS shipping_mmyyyy,
    first_day_of_month AS shipping_first_day_of_month,
    last_day_of_month AS shipping_last_day_of_month,
    first_day_of_quarter AS shipping_first_day_of_quarter,
    last_day_of_quarter AS shipping_last_day_of_quarter,
    first_day_of_year AS shipping_first_day_of_year,
    last_day_of_year AS shipping_last_day_of_year,
    season AS shipping_season,
	is_holiday AS shipping_is_holiday,
    is_weekday AS shipping_is_weekday,-- 0=Week End ,1=Week Day
	holiday_name AS shipping_holiday_name,
	fiscal_day_of_year AS shipping_fiscal_day_of_year,
	fiscal_week_of_year AS shipping_fiscal_week_of_year,
	fiscal_month AS shipping_fiscal_month,
	fiscal_quarter AS shipping_fiscal_quarter,
	fiscal_quarter_name AS shipping_fiscal_quarter_name,
	fiscal_year AS shipping_fiscal_year,
	fiscal_year_name AS shipping_fiscal_year_name,
	fiscal_month_year AS shipping_fiscal_month_year,
	fiscal_mmyyyy AS shipping_fiscal_mmyyyy,
	fiscal_first_day_of_month AS shipping_fiscal_first_day_of_month,
	fiscal_last_day_of_month AS shipping_fiscal_last_day_of_month,
	fiscal_first_day_of_quarter AS shipping_fiscal_first_day_of_quarter,
	fiscal_last_day_of_quarter AS shipping_fiscal_last_day_of_quarter,
	fiscal_first_day_of_year AS shipping_fiscal_first_day_of_year,
	fiscal_last_day_of_year AS shipping_fiscal_last_day_of_year
	
  FROM gold.dim_date
-- ---------------------------------------------------------------------------------------------------------------------------------
-- dim_due_date
-- ---------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_due_date','V') IS NOT NULL
    DROP VIEW gold.dim_due_date;
GO
  CREATE VIEW gold.dim_due_date AS
  SELECT
  	date_key AS due_date_key, 
    date AS due_date,
    full_date AS due_full_date,-- Date in MM-dd-yyyy format
    day_of_month AS due_day_of_month, -- Field will hold day number of Month
    day_suffix AS due_day_suffix, -- Apply suffix as 1st, 2nd ,3rd etc
    day_name AS due_day_name, -- Contains name of the day, Sunday, Monday 
    day_of_week AS due_day_of_week,-- First Day Sunday=1 and Saturday=7
    day_of_week_in_month AS due_day_of_week_in_month, --1st Monday or 2nd Monday in Month
    day_of_week_in_year AS due_day_of_week_in_year,
    day_of_quarter AS due_day_of_quarter, 
    day_of_year AS due_day_of_year,
    week_of_month AS due_week_of_month,-- Week Number of Month 
    week_of_quarter AS due_week_of_quarter, --Week Number of the Quarter
    week_of_year AS due_week_of_year,--Week Number of the Year
    month AS due_month, --Number of the Month 1 to 12
    month_name AS due_month_name,--January, February etc
    month_of_quarter AS due_month_of_quarter,-- Month Number belongs to Quarter
    quarter AS due_quarter,
    quarter_name AS due_quarter_name,--First,Second..
    year AS due_year,-- Year value of Date stored in Row
    year_name AS due_year_name, --CY 2012,CY 2013
    month_year AS due_month_year, --Jan-2013,Feb-2013
    mmyyyy AS due_mmyyyy,
    first_day_of_month AS due_first_day_of_month,
    last_day_of_month AS due_last_day_of_month,
    first_day_of_quarter AS due_first_day_of_quarter,
    last_day_of_quarter AS due_last_day_of_quarter,
    first_day_of_year AS due_first_day_of_year,
    last_day_of_year AS due_last_day_of_year,
    season AS due_season,
	is_holiday AS due_is_holiday,
    is_weekday AS due_is_weekday,-- 0=Week End ,1=Week Day
	holiday_name AS due_holiday_name,
	fiscal_day_of_year AS due_fiscal_day_of_year,
	fiscal_week_of_year AS due_fiscal_week_of_year,
	fiscal_month AS due_fiscal_month,
	fiscal_quarter AS due_fiscal_quarter,
	fiscal_quarter_name AS due_fiscal_quarter_name,
	fiscal_year AS due_fiscal_year,
	fiscal_year_name AS due_fiscal_year_name,
	fiscal_month_year AS due_fiscal_month_year,
	fiscal_mmyyyy AS due_fiscal_mmyyyy,
	fiscal_first_day_of_month AS due_fiscal_first_day_of_month,
	fiscal_last_day_of_month AS due_fiscal_last_day_of_month,
	fiscal_first_day_of_quarter AS due_fiscal_first_day_of_quarter,
	fiscal_last_day_of_quarter AS due_fiscal_last_day_of_quarter,
	fiscal_first_day_of_year AS due_fiscal_first_day_of_year,
	fiscal_last_day_of_year AS due_fiscal_last_day_of_year
	
  FROM gold.dim_date
