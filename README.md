# 🏬 Modern Retail & Order Management Data Warehouse  
**SQL Server | Dimensional Modeling | Medallion Architecture | Power BI**

---

## 📌 Project Overview

This project delivers a modern **Retail & Order Management Data Warehouse** supporting a company selling bicycles, sports clothing, and related components across international markets.

The solution integrates CRM and ERP systems into a structured, analytics-ready platform designed for:

- Sales performance reporting  
- Customer behavior analysis  
- Product and category insights  
- Order lifecycle tracking (order, shipping, due dates)  
- Regional and country-level comparisons  

The warehouse is built using:

- **Dimensional Modeling (Star Schema)**
- **Medallion Architecture (Bronze → Silver → Gold)**
- **SQL-based transformations**
- **Power BI integration**

The system balances performance, governance, scalability, and business usability.

---

# 🌍 Geographic Coverage

Customers operate across:

- Canada  
- United States  
- United Kingdom  
- Germany  
- France  
- Australia  

Supports multi-country reporting.

---

# 🗂️ Data Sources

## 1️⃣ CRM System

Provides customer master data:

- Customer identifiers  
- Personal attributes  
- Customer lifecycle details  

Supports:

- Customer profiling  
- Retention analysis  
- Segmentation modeling  

---

## 2️⃣ ERP System

Provides operational and transactional data.

### Product Master Data
- Product name  
- Cost  
- Product line  
- Category & subcategory  
- Lifecycle dates  

### Sales & Order Transactions
- Order numbers  
- Line-level transaction data  
- Order, shipping, and due dates  
- Sales amount, quantity, pricing  

### Demographics & Geography
- Birth date  
- Gender  
- Country  

![Integration Model](docs/integration_model.png)

---

# 🚀 Core Data Warehouse Features

---

## ⭐ 1. Dimensional Modeling – Star Schema

The analytical layer is implemented using a **Star Schema**, optimized for reporting and BI workloads.

### Structure

- Central fact table: `fact_sales`
- Conformed dimension tables:
  - `dim_customer`
  - `dim_product`
  - `dim_date` (role-playing: order date, shipping date, due date)

### Declared Grain

> One row represents one product purchased by one customer in a single order (order line item level).

This supports precise revenue tracking and customer-level analysis.

### Business & Technical Benefits

| Benefit | Impact |
|----------|--------|
| High Query Performance | Fewer joins and denormalized dimensions |
| Business Readability | Model aligns with stakeholder reporting needs |
| BI Tool Compatibility | Seamless Power BI integration |
| Scalability | New dimensions and metrics can be added easily |

Supports analysis such as:

- Revenue by category and region  
- Customer purchasing patterns  
- Seasonal sales trends  
- Order fulfillment cycle analysis  

![Star Schema Model](docs/data_model_starschema.png)

![Fact Table Structure](docs/fact_table_star_schema.png)

---

## 📊 2. Facts and Dimensions – Analytical Integrity

The design strictly separates measurable events from descriptive attributes.

### 🔹 Fact Table – `fact_sales`

Contains additive measures:

- `sales_amount`
- `quantity`
- `unit_price`

**Facts:**

- Participate in aggregations (SUM, AVG)
- Drive KPIs and executive metrics
- Enable time-series and trend analysis
- Represent numeric business events

---

### 🔹 Dimension Tables

Contain descriptive attributes such as:

- Product hierarchy (category, subcategory)
- Customer demographics
- Geographic attributes
- Calendar hierarchies

**Dimensions:**

- Used for filtering and grouping
- Enable drill-down analysis
- Define analytical constraints
- Support segmentation

### Modeling Discipline Applied

- No additive business metrics stored in dimension tables  
- Clear fact grain declaration  
- Surrogate key implementation  
- Controlled handling of non-additive attributes  

Prevents:

- Double counting  
- Aggregation ambiguity  
- Reporting inconsistencies  

---

## 🏗️ 3. Medallion Architecture (Bronze → Silver → Gold)

The warehouse follows a structured layered architecture.

![Data Architecture](docs/data_architecture.png)

---

### 🔹 Bronze Layer – Raw Ingestion

- Raw CSV ingestion from CRM and ERP  
- No transformations  
- Full source traceability  

**Benefit:** Preserves auditability and lineage.

---

### 🔹 Silver Layer – Cleansed & Conformed

- Data standardization  
- Deduplication  
- Data type normalization  
- Conformed reference data (including unified date dimension)  

**Benefit:** Ensures consistent business definitions across systems.

---

### 🔹 Gold Layer – Business-Ready Model

- Star schema implementation  
- Optimized fact and dimension tables  
- Designed for analytical performance  

**Benefits:**

- Clear separation between transformation and reporting logic  
- Scalable data design  
- Stable semantic layer for BI tools  

---

## 🔐 4. Gold Layer Views – Security & Access Management

The Gold layer exposes **SQL views** rather than direct table access.

### Purpose

- Restrict direct access to base tables  
- Enforce role-based security  
- Mask sensitive columns  
- Provide abstraction from physical schema  

### Governance Benefits

| Feature | Benefit |
|----------|---------|
| Role-based access | Controlled exposure of data |
| Column-level filtering | Protection of sensitive attributes |
| Schema abstraction | Safe structural evolution |
| Stable BI interface | Prevents dashboard disruption |

Views act as a governance boundary between storage and business consumption.

---

# 🔄 Data Flow

![Data Flow](docs/data_flow.png)

---

# ❄️ Snowflake Schema (Alternative Model)

A normalized dimensional version is available:

![Snowflake Model](data_warehouse_snowflake/docs/data_model.png)

This version:

- Separates hierarchical attributes  
- Reduces redundancy  
- Supports complex global hierarchies  

The Star Schema remains the primary analytical model.

---

# 📈 SQL-Based Data Analysis

The analysis workflow follows:

1. Explore  
2. Profile  
3. Clean  
4. Shape  
5. Analyze  

![Data Analysis Workflow](docs/data_analysis_workflow.png)

Focus areas:

- Customer behavior analysis  
- Product performance evaluation  
- Revenue and growth trends  
- Time-series and seasonal analysis  

---

# 📊 Power BI Integration

The Gold-layer Star Schema connects directly to Power BI, enabling:

- KPI dashboards  
- Interactive drill-down reports  
- Customer segmentation  
- Regional comparisons  
- Trend visualization  

**Outcome:** Decision-ready intelligence for pricing, promotions, and growth strategy.

---

# 📂 Repository Structure

---

# 🛠️ Tools & Technologies

- SQL Server Express  
- SQL Server Management Studio (SSMS)  
- Power BI  
- Draw.io  
- Git / GitHub  

---

# 🎯 What This Project Demonstrates

- Dimensional modeling expertise  
- Fact/dimension integrity enforcement  
- Enterprise-style layered architecture  
- Governance-aware warehouse design  
- BI-ready semantic modeling  
- Business-aligned analytical thinking  

This solution delivers a secure, scalable, and performance-optimized analytical foundation.

---

# 📜 License

This project is licensed under the MIT License.




