# 📊 SQL-Project-E-Commerce-Case

## 📝 **Overview**

This repository presents a complete **SQL-based Data Analytics Pipeline**, progressing from **Data Warehousing** to **Exploratory Data Analysis (EDA)** and finally to **Advanced Analytics**. The goal is to create a structured, efficient, and insightful SQL-driven analytical workflow.

**Dataset used:** `Brazilian E-Commerce Public Dataset by Olist` ➝ [Kaggle Link](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

![SQL Server](https://img.shields.io/badge/Microsoft_SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Draw.io](https://img.shields.io/badge/Draw.io-FF9900?style=for-the-badge&logo=diagramsdotnet&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![PowerPoint](https://img.shields.io/badge/PowerPoint-B7472A?style=for-the-badge&logo=microsoftpowerpoint&logoColor=white)

---

## **Project Workflow**

### 1️⃣ **Data Warehouse (DWH) & ETL** 📂

**🟢 Objective:** Build a **Data Warehouse** using **SQL Server**, implementing **ETL processes**.

**🛠 Approach:** Leverages the **Medallion Architecture** (**Bronze, Silver, and Gold layers**) to store and transform raw data into business-ready insights.

#### 📌 **Key Steps:**
- 🏛 **Data Architecture:** Bronze Layer for raw data ingestion and storage, Silver Layer for cleaned, validated, and standardized data. Gold Layer for business-ready, aggregated data optimized for analytics.
- ⚙ **ETL Pipelines:** Batch processing strategies for data ingestion and transformation.
- 📊 **Final Output:** Clean, structured data stored in the **Gold Layer** using **Star Schema** with fact and dimension views ready for analytics.

#### **💼 Business Value:**
- A Data Warehouse serves as the **single source**  that consolidates disparate data sources into a unified, consistent format. This enables businesses to perform cross-functional analysis, identify trends that span multiple departments, and generate insights.
- The structured approach demonstrated in this project - with bronze, silver, and gold layers - reflects how enterprises manage data quality and accessibility at scale and shows the technical infrastructure required.

🔗 **Reference:**   [DWH Project](https://github.com/StefanoN98/SQL-Project-E-Commerce-Case/tree/bd9bb231a220b417fb088afec177e58012c02b1a/01.%20DATA%20WAREHOUSE%20PROJECT)

---

### 2️⃣ **Exploratory Data Analysis (EDA)** 🔍

**🟢 Objective**: Investigate the dataset to discover patterns, spot anomalies, make statistic analysis and **extract meaningful insights**.

**🛠 Approach**: Use the Gold Layer from the DWH to perform the analysis exploring **5 strategic analytical dimensions**.

#### 📌 **Key Objects:**
- 🗄️**Database Profiling:** Understanding data structure, quality, and storage patterns.
- 📆**Temporal Analysis:** Uncovering time-based trends, seasonality, and customer lifecycles.
- 🔢**Key metrics Exploration:** Identifying distributions, outliers and segmentation.
- ⚖️**Magnitude Analysis:** Quantifying business entity performance across multiple metrics.
- 🏆**Rank Analysis:** Identify top/bottom-performing entities and establish competitive benchmarks.

#### **💼 Business Value:**
- Exploratory Data Analysis serves as the analytical **bridge** between data infrastructure and business intelligence. Through systematic investigation across those multiple dimensions organizations can identify hidden opportunities, detect emerging risks, and understand the underlying drivers of their business performance.
- This project shows how it is possible to systematically explore business datasets by **focusing on distinct analytical areas** rather than conducting random exploratory queries

🔗 **Reference:** [EDA Project](https://github.com/StefanoN98/SQL-Projects/tree/aeb630b85d62458d96b5fb171dea25894c6885e5/02.%20EDA%20PROJECT)

---

### 3️⃣ **Advanced Analytics** 📈

### 🔜 Next Step

---

## 🔧 **Technologies Used**

- 🗄 **SQL Server**: Data processing & querying.
- 📂 **CSV Datasets**: Source files for ETL processes.
- 📊 **SSMS**: SQL Server Management Studio for database interaction.
- 🖼 **DrawIO & Power Point**: Data architecture visualization.
- 🐙 **GitHub**: Version control & collaboration.

---

## 📜 **License**

This project is licensed under the **MIT License**.
