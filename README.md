# 🏗️ SQL Data Warehouse Project

This project showcases the design and implementation of a **modern data warehouse** using **SQL Server**, including end-to-end **ETL processes**, **data modelling**, and **insightful analytics**. 

Designed as a portfolio project, it follows **industry best practices** in both data engineering and analytics.

---

## 📦 Project Overview

### 🛠️ Objective
To build a scalable and clean data warehouse that consolidates sales data from multiple sources, enabling robust analytical reporting and data-driven decision-making.

---

## 📁 Project Requirements

### 🔨 Data Engineering – Building the Data Warehouse
- **Data Sources**:  
  - Import structured data from two systems: **ERP** and **CRM**, provided as **CSV files**.
  
- **Data Quality**:  
  - Clean and resolve data quality issues (missing values, duplicates, format mismatches).
  
- **Integration**:  
  - Merge both data sources into a unified, user-friendly **star schema** optimized for analytical queries.
  
- **Scope**:  
  - Focus on the **latest dataset** only. (No historization required for this project.)
  
- **Documentation**:  
  - Provide detailed documentation of the **data model**, entity relationships, and transformation logic to assist both business users and technical analysts.

---

## Project Overview

This project involves the design and implementation of a scalable, modern data architecture using the Medallion architecture pattern. It encompasses the following key components:

### 1. Data Architecture

- **Medallion Architecture**: Implementation of Bronze, Silver, and Gold layers to structure raw, refined, and business-level data.
  - **Bronze Layer**: Ingests raw data from various source systems.
  - **Silver Layer**: Cleans and transforms data into standardized formats.
  - **Gold Layer**: Contains curated data models optimized for reporting and analytics.

### 2. ETL Pipelines

- **Data Ingestion**: Automated extraction of data from multiple source systems.
- **Transformation**: Data cleansing, normalization, and enrichment to ensure quality and usability.
- **Loading**: Efficient and scalable loading into respective layers of the data warehouse.

### 3. Data Modeling

- **Star Schema Design**: Development of fact and dimension tables tailored for analytical performance.
- **Optimization**: Ensures models are optimized for use in BI tools and analytical queries.

---

> This architecture enables a flexible and robust foundation for data analytics, ensuring clean lineage, high-quality data, and efficient data delivery to downstream consumers.

### 📊 Business Intelligence – Analytics & Reporting

#### 🎯 Objective
Develop SQL-based analytical queries to derive actionable insights in three key domains:

- 📈 **Sales Trends**:  
  Analyze performance over time, identify seasonality, and measure growth with running totals and moving averages.

- 🧑‍🤝‍🧑 **Customer Behavior**:  
  Segment customers by spend and tenure, identify VIPs and new customers, and compute KPIs such as recency and average order value.

- 🚲 **Product Performance**:  
  Identify high-performing products and categories, segment by revenue and cost, and assess contribution to total sales.

These insights empower stakeholders to make **strategic, data-informed decisions**.

## Tools Used

- **SQL Server Express** – Local database engine for developing and testing the data warehouse.
- **SQL Server Management Studio (SSMS)** – GUI for managing and querying SQL Server databases.
- **Git Repository** – Version control and collaboration on SQL scripts and documentation.
- **DrawIO** – Visual design of data architecture and data flow diagrams.
- **Notion** – Project documentation, planning, and note-taking.

#### 📊 Medallion Data Architecture Diagram

![Medallion Data Architecture](images/medallion_architecture.png)

**Medallion Architecture Overview:**

1. **Bronze Layer**: Stores raw data as-is from the source systems. In this project, data is ingested from CSV files into the SQL Server database.

2. **Silver Layer**: Performs data cleansing, standardization, and normalization. This layer prepares data for analytical use by refining the raw data into clean, queryable formats.

3. **Gold Layer**: Contains business-ready data modeled into a star schema. This layer supports reporting and analytics by organizing data into fact and dimension tables optimized for performance.


## 📜 License

This project is licensed under the **MIT License**.  
You are free to use, modify, and share this project with proper attribution.

---

## 👩‍💻 About Me

I'm a **Data Analyst** passionate about turning raw data into strategic insights.  
This project reflects my hands-on experience with SQL, data modeling, and business analytics, and I'm excited to share it with fellow data enthusiasts.

---

