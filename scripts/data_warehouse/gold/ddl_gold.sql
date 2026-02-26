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
