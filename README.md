# Modern Retail & Order Management Data Warehouse using SQL Server

---

## 📌 Project Overview

This project delivers a modern **Retail & Order Management Data Warehouse** for a company selling bicycles, sports clothing, and related components across multiple international markets.

The business operates in a retail / e-commerce model, managing:

- Customer orders  
- Product catalogs  
- Pricing and quantities  
- Fulfillment timelines  

The data warehouse supports:

- Sales performance analysis  
- Customer behavior and segmentation  
- Product and category-level reporting  
- Order lifecycle tracking (order, shipping, due dates)  

The primary analytical model is implemented as a **Star Schema** with a role-playing Date dimension.  
An alternative **Snowflake Schema** version is included separately for hierarchical normalization and global modeling scenarios.

---

# 🗂️ Data Sources

The warehouse integrates enterprise-style CRM and ERP systems.

## 1️⃣ CRM (Customer Relationship Management)

Provides customer master data:

- Customer identifiers and business keys  
- Personal attributes (name, gender, marital status)  
- Customer creation and lifecycle details  

Supports:

- Customer profiling  
- Segmentation  
- Retention analysis  

---

## 2️⃣ ERP (Enterprise Resource Planning)

Provides operational and transactional data.

### Product Master Data
- Product name  
- Cost  
- Product line  
- Category and subcategory  
- Lifecycle dates  

### Sales & Order Transactions
- Order numbers  
- Line-level sales data  
- Order, shipping, and due dates  
- Sales amounts, quantities, pricing  

### Customer Demographics & Geography
- Birth date  
- Gender  
- Country and location  

Enables full order-to-delivery lifecycle analysis.

---

# 🌍 Geographic Coverage

Customers operate across:

- Canada  
- United States  
- United Kingdom  
- Germany  
- France  
- Australia  

Supports regional and country-level reporting.

---

# 🏗️ Stage 1 – Data Warehouse (Medallion Architecture)

The warehouse follows a structured **Bronze → Silver → Gold** architecture.

## Architecture Diagram

![Data Architecture](docs/data_architecture.png)

---

## 🔹 Bronze Layer
- Raw CSV ingestion from CRM and ERP  
- No transformations  
- Preserves source fidelity and traceability  

## 🔹 Silver Layer
- Data cleansing  
- Standardization  
- Deduplication  
- Conformed reference data (including unified date dimension)  

## 🔹 Gold Layer
- Business-ready star schema  
- Fact and conformed dimension tables  
- Optimized for analytical queries and Power BI  

**Benefit:**  
Incremental data quality improvement, simplified maintenance, and scalable analytics.

---

# ⭐ Dimensional Design Process

The dimensional model follows Kimball’s structured four-step approach.

---

## 1️⃣ Select Business Process

Retail sales and order management — covering:

- Order placement  
- Fulfillment  
- Delivery timelines  

---

## 2️⃣ Declare Grain

**Fact Table Grain:**

> One row represents one product purchased by one customer within a single sales order (order line item level).

This supports:

- Product-level analysis  
- Customer purchasing behavior  
- Transaction-level revenue tracking  

---

## 3️⃣ Identify Dimensions

### 🟢 Product Dimension
Derived from ERP:

- Product name  
- Product line  
- Category & subcategory  
- Lifecycle dates  

### 🟢 Customer Dimension
Derived from CRM & ERP:

- Customer identifiers  
- Demographics  
- Country  

### 🟢 Date Dimension (Role-Playing)

A single conformed `dim_date` reused as:

- Order Date  
- Shipping Date  
- Due Date  

Ensures consistent time intelligence without duplication.

---

## 4️⃣ Identify Facts

The central `fact_sales` table includes:

- Sales amount  
- Quantity sold  
- Unit price  

Enables:

- Revenue analysis  
- Product performance  
- Sales trends over time  

---

## 📊 Star Schema Model

![Data Model](docs/data_model_starschema.png)

---

## 📋 Fact Table Structure

![Fact Table](docs/fact_table_star_schema.png)

---

## 🔄 Data Flow

![Data Flow](docs/data_flow.png)

---

# ❄️ Snowflake Schema (Alternative Model)

A normalized dimensional version is available under:

![Data Flow](data_warehouse_snowflake/docs/data_model.png)
