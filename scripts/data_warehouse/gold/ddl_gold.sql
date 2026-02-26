-- gold.dim_customers
IF OBJECT_ID('gold.dim_customers','U') IS NOT NULL
	DROP TABLE gold.dim_customers;
GO
CREATE TABLE gold.dim_customers(
customer_key INT,
customer_id INT,
customer_number NVARCHAR(50),
first_name NVARCHAR(50),
last_name NVARCHAR(50),
country NVARCHAR(50),
marital_status VARCHAR(10),
gender VARCHAR(20),
birthdate DATE,
create_date DATE
);

-- gold.dim_products
IF OBJECT_ID('gold.dim_products','U') IS NOT NULL
	DROP TABLE gold.dim_products;
GO
CREATE TABLE gold.dim_products(
product_key INT,
product_id INT,
product_number NVARCHAR(50),
product_name NVARCHAR(50),
category_id NVARCHAR(50),
category VARCHAR(50),
subcategory VARCHAR(50),
maintenance VARCHAR(50),
cost INT,
product_line NVARCHAR(50),
start_date DATE
)

-- gold.dim_date
IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
	DROP TABLE gold.dim_date
GO
CREATE TABLE gold.dim_date
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
	season CHAR(15),
	is_holiday BIT,-- Flag 1=Global Holiday, 0-No Global Holiday
    is_weekday BIT,-- 0=Week End ,1=Week Day
	holiday_name VARCHAR(50),--Name of Global
	fiscal_day_of_year VARCHAR(3),
	fiscal_week_of_year VARCHAR(3),
	fiscal_month VARCHAR(2),
	fiscal_quarter CHAR(1),
	fiscal_quarter_name VARCHAR(9),
	fiscal_year CHAR(4),
	fiscal_year_name CHAR(7),
	fiscal_month_year CHAR(10),
	fiscal_mmyyyy CHAR(6),
	fiscal_first_day_of_month DATE,
	fiscal_last_day_of_month DATE,
	fiscal_first_day_of_quarter DATE,
	fiscal_last_day_of_quarter DATE,
	fiscal_first_day_of_year DATE,
	fiscal_last_day_of_year DATE,
);
