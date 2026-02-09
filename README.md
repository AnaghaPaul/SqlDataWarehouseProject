# Modern Retail & Order Management Data Warehouse using SQL Server
---
## Project Overview

This project focuses on building a modern Retail & Order Management Data Warehouse for a company selling bicycles, sports clothing, and related components across multiple international markets.
The business operates in a retail / e-commerce–style model, managing customer orders, product catalogs, pricing, quantities, and fulfillment timelines.

The data warehouse is designed to support:

- Sales performance analysis

- Customer behavior and segmentation

- Product and category-level reporting

- Order lifecycle tracking (order, shipping, and due dates)

A dimensional (star schema) model is implemented with clearly defined fact and dimension tables, including a role-playing Date dimension to enable time-based analytics across different business events.

## Datasource
The data warehouse integrates data from CRM and ERP source systems, reflecting common enterprise data flows.

:one:CRM (Customer Relationship Management)

The CRM system provides customer-related information used to build the Customer dimension, including:

- Customer identifiers and business keys

- Personal attributes (name, gender, marital status)

- Customer creation and lifecycle details

- This data supports customer profiling, segmentation, and retention analysis.

:two: ERP (Enterprise Resource Planning)

The ERP system supplies operational and transactional data, including:
- Product Master Data

Product details such as name, cost, product line, and lifecycle dates

Product categories and subcategories

- Sales & Order Transactions

Order numbers and line-level sales data

Order, shipping, and due dates

Sales amounts, quantities, and pricing

- Customer Demographics & Geography

Customer birth date and gender

Customer country and location information

These sources enable end-to-end analysis of the order-to-delivery process and provide a unified view of sales operations.

## Geographic coverage

Customers are located across multiple countries, including:

- Canada

- United States

- United Kingdom

- Germany

- France

- Australia

This allows for regional and country-level sales analysis.

The project is structured in **three key stages**:  

##  DataWarehouse Creation (Medallion Architecture)

This project implements a SQL Server–based Retail & Order Management Data Warehouse using the Medallion Architecture (Bronze, Silver, Gold). Data is ingested from multiple CRM and ERP source systems and processed through structured, iterative ETL pipelines to support evolving business and analytical requirements.

:one: **Bronze Layer**: Raw CRM and ERP data is ingested in its original format to preserve source fidelity and enable traceability.

:two: **Silver Layer**: Data is cleansed, standardized, deduplicated, and conformed across sources, including the creation of reusable reference data such as the calendar table.

:three: **Gold Layer**: Business-ready datasets are curated using a star schema, including fact tables and conformed dimensions (Customer, Product,and a role-playing Date dimension) optimized for analytical queries and Power BI reporting.

Benefit:
This layered, iterative approach incrementally improves data quality, simplifies maintenance, and supports scalable analytics. The star schema design enables efficient joins, fast query performance, and seamless integration with BI tools, ensuring reliable and performant business reporting.

## 2. SQL-Based Data Analysis (Explore → Profile → Clean → Shape → Analyze)
Curated data is explored, profiled, cleaned, and shaped using **SQL transformations** to derive actionable business insights. Key analytical focus areas include:  

- **Customer Behavior Analysis:**  
- **Product Performance Evaluation:**  
- **Revenue & Growth Dynamics:**

**Benefit:** Structured SQL analysis ensures **accurate, reproducible insights** and allows stakeholders to understand key operational drivers, optimize marketing strategies, and enhance customer engagement.  

## 3. Power BI Visualization
The analyzed datasets are visualized in **Power BI dashboards**, leveraging the **star-schema data model** to enable efficient slicing, dicing, and drill-down capabilities. Visualizations include interactive charts, KPIs, and trend analysis for products, sales, and customer segments.  

**Benefit:** Decision-makers gain a **clear, interactive view of business performance**, enabling data-driven strategy around pricing, promotions, customer acquisition, and investment allocation, ultimately supporting sustainable growth and profitability.


---
## Stage 1 - Data Warehouse
## 📖 Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
   
---
## 🚀 Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---
## Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
![Data Architecture](docs/DataArchitecture.png)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

## Dimensional Design Process
The dimensional model was designed using a structured, iterative four-step approach aligned with Kimball dimensional modeling best practices. The goal was to create a scalable and analytics-friendly model that supports retail and order management reporting.

 :one: *Select Business Process*
 
The selected business process is retail order management and sales transactions, representing the end-to-end lifecycle of a customer purchase.
This includes order placement, fulfillment, and delivery timelines, enabling analysis across ordering, shipping, and due dates.

:two: *Declare Grain*

The grain of the fact table is defined at the individual order line item level.

Each row in the fact table represents:

*One product*

*Purchased by one customer*

*Within a single sales order*

This granular design supports detailed analysis of:

*Customer purchasing behavior*

*Product-level performance*

*Transaction-level revenue and quantity metrics*

:three: *Identify the Dimensions*

*Product Dimension*

Derived from ERP product master data and enriched with product attributes such as:

- Product name

- Product line

- Category and subcategory

- Product lifecycle dates

*Customer Dimension*

Derived from CRM and ERP sources and includes:

- Customer identifiers and demographics

- Gender and birth date

- Geographic attributes such as country

*Date Dimension (Role-Playing)*
A single, conformed Date dimension created within the data warehouse and reused across multiple business roles:

- Order Date

- Shipping Date

- Due Date

This design enables consistent and flexible time-based analysis without duplicating date structures.
        
- **Identify the facts**

The central fact table captures sales measures at the declared grain, including:

- Sales amount
  
- Quantity sold

- Unit price
  
These measures enable analysis of revenue, order value, product performance, and sales trends over time.


![Fact_table](docs/fact_table.png)



![Data Flow](docs/DataFlow.png)
---

## 🛠️ Important Links & Tools:

- **[Datasets](datasets/):** Access to the project dataset (csv files).
- **[SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads):** Lightweight server for hosting your SQL database.
- **[SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16):** GUI for managing and interacting with databases.
- **[Git Repository](https://github.com/):** Set up a GitHub account and repository to manage, version, and collaborate on your code efficiently.
- **[DrawIO](https://www.drawio.com/):** Design data architecture, models, flows, and diagrams.
- **[Notion](https://www.notion.com/templates/sql-data-warehouse-project):** Get the Project Template from Notion.

---  

For more details, refer to [docs/requirements.md](docs/requirements.md).

## 📂 Repository Structure
```
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── etl.drawio                      # Draw.io file shows all different techniquies and methods of ETL
│   ├── data_architecture.drawio        # Draw.io file shows the project's architecture
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio                # Draw.io file for the data flow diagram
│   ├── data_models.drawio              # Draw.io file for data models (star schema)
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts 
|   ├──data_warehouse/                  # SQL scripts for ETL and transformation
│      ├── bronze/                         # Scripts for extracting and loading raw data
│      ├── silver/                         # Scripts for cleaning and transforming data
│      ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
└── requirements.txt                    # Dependencies and requirements for the project
```

---
## Satge 2- Queries and Analysis

The data analysis process is structured into five stages:
   - Explore
   - Profile
   - Clean
   - Shape
   - Analysis

![DataAnalysisWorkFlow](docs/DataAnalysisWorkFlow.png)

## SQL-Based Data Analysis (Explore → Profile → Clean → Shape → Analyze)

The data analysis process is structured into **five key stages**, building on the preliminary work already performed during the **data warehouse creation**. Each stage ensures that data is transformed from raw, operational form into high-quality, actionable insights:

1. **Explore**  
   - Initial examination of datasets to understand structure, data types, and relationships.  
   - Identify missing values, anomalies, and potential areas of interest for deeper analysis.  
   - **Benefit:** Provides a clear overview of the data landscape, allowing analysts to plan transformations and validate assumptions efficiently.  

2. **Profile**  
   - Generate descriptive statistics (counts, distributions, percentiles) and identify patterns or inconsistencies.  
   - Assess data quality metrics such as completeness, uniqueness, and consistency.  
   - **Benefit:** Highlights data quality issues early, ensuring that downstream analysis is reliable and robust.  

3. **Clean**  
   - Handle missing or inconsistent data, remove duplicates, and standardize formats.  
   - Correct errors and ensure that data adheres to business rules.  
   - **Benefit:** Produces accurate, trustworthy datasets that prevent errors in analysis and reporting.  

4. **Shape**  
   - Transform and model data into analytical-ready structures, including aggregations, calculated metrics, and key business dimensions.  
   - Leverage **star schema outputs from the data warehouse** for efficient querying and reporting.  
   - **Benefit:** Simplifies analytical operations, reduces computational overhead, and ensures seamless integration with visualization tools like Power BI.  

5. **Analyze**  
   - Perform detailed exploratory and descriptive analysis to uncover insights on **customer behavior, product performance, and sales trends**.  
   - Conduct **trend analysis** to identify seasonality, growth patterns, and revenue drivers over time.  
   - **Benefit:** Enables data-driven decisions around marketing strategy, inventory management, and growth initiatives, providing actionable intelligence to business stakeholders.  

**Note:** Many of these steps, such as data cleansing and shaping, are partially completed during the **data warehouse ETL process**, ensuring that the SQL analysis starts from a reliable, curated dataset. This integration reduces redundant work, improves efficiency, and allows analysts to focus on higher-value insights.

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.
