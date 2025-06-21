# 📊 SQL-Project-E-Commerce-Case (Data Analytics Pipeline)

## 📝 **Overview**

This repository presents a complete **SQL-based Data Analytics Pipeline**, progressing from **Data Warehousing** to **Exploratory Data Analysis (EDA)** and finally to **Advanced Analytics**. The goal is to create a structured, efficient, and insightful SQL-driven analytical workflow.

![SQL Server](https://img.shields.io/badge/Microsoft_SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Draw.io](https://img.shields.io/badge/Draw.io-FF9900?style=for-the-badge&logo=diagramsdotnet&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

---

## 🔄 **Project Workflow**

### 1️⃣ **Data Warehouse (DWH) & ETL** 📂

**🟢 Objective:** Build a **Data Warehouse** using **SQL Server**, implementing **ETL (Extract, Transform, Load) processes**.

**🛠 Approach:** Leverages the **Medallion Architecture** (**Bronze, Silver, and Gold layers**) to store and transform raw data into business-ready insights.

#### 📌 **Key Steps:**
- 🏛 **Data Architecture:** Designed using **Star Schema** with fact and dimension tables.
- ⚙ **ETL Pipelines:** Batch processing strategies for data ingestion and transformation.
- 📊 **Final Output:** Clean, structured data stored in the **Gold Layer** for analytics.

🔗 **Reference:** [Data Warehouse Project](https://github.com/StefanoN98/SQL-Project-E-Commerce-Case/blob/092bf920d01c9a3ef93815af693f47e0e7bf54e4/01.%20DATA%20WAREHOUSE%20PROJECT/01.%20DWH%20README.md)

---

### 2️⃣ **Exploratory Data Analysis (EDA)** 🔍

**🟢 Objective:** Uncover insights, trends, and anomalies in the dataset using SQL queries.

**🛠 Approach:** Uses the **Gold Layer** from the DWH to perform dimension and measure analysis.

#### 📌 **Key Steps:**
- 🏷 **Dimension Analysis:** Understanding segmentation (e.g., customer demographics, product categories).
- 📊 **Measure Exploration:** Computing key metrics (e.g., revenue, total sales, average price).
- 📈 **Ranking & Trend Analysis:** Identifying top/bottom-performing entities using SQL functions.

🔗 **Reference:** [EDA Project](https://github.com/StefanoN98/SQL-Projects/tree/main/02.%20EDA%20PROJECT)

---

### 3️⃣ **Advanced Analytics** 📈

**🟢 Objective:** Perform complex analytical operations to extract deeper business insights.

**🛠 Approach:** Uses advanced SQL techniques, including **trend analysis, cumulative metrics, segmentation, and performance evaluation**.

#### 📌 **Key Steps:**
- ⏳ **Time-Series Analysis:** Identifying changes over time using `GROUP BY`, `DATETRUNC`, and `LAG`.
- 📊 **Cumulative Metrics:** Running totals, moving averages, and YoY comparisons.
- 🏆 **Performance Analysis:** Ranking, category contribution analysis, and part-to-whole evaluations.
- 🔍 **Segmentation & Reporting:** Customer segmentation with `CASE WHEN`, product performance evaluation.

🔗 **Reference:** [Advanced Analytics Project](https://github.com/StefanoN98/SQL-Projects/tree/main/03.%20ADVANCED%20ANALYTICS%20PROJECT)

---

## 🔧 **Technologies Used**

- 🗄 **SQL Server**: Data processing & querying.
- 📂 **CSV Datasets**: Source files for ETL processes.
- 📊 **SSMS**: SQL Server Management Studio for database interaction.
- 🖼 **DrawIO**: Data architecture visualization.
- 🐙 **Git & GitHub**: Version control & collaboration.

---

## 📜 **License**

This project is licensed under the **MIT License**.
