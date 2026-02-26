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
