# 📚 SQL Server Data Warehouse Naming Convention

## **Table of Contents**

1. [General Principles](#general-principles)
2. [Layer-Specific Naming Rules](#layer-specific-naming-rules)
3. [Table Naming Convention](#table-naming-convention)
4. [Column & Key Naming Convention](#column--key-naming-convention)
5. [Stored Procedure Naming Convention](#stored-procedure-naming-convention)
6. [Trigger Naming Convention](#trigger-naming-convention)
7. [View Naming Convention](#view-naming-convention)
8. [Index Naming Convention](#index-naming-convention)
9. [Summary](#summary)

---

# 📚 SQL Server Data Warehouse Naming Convention

> This document defines the **naming standards** used in this project, aligned with the **Medallion Architecture** (Bronze → Silver → Gold). It ensures consistency, clarity, and maintainability across all layers and ETL processes.

---

## General Principles

| Rule                      | Description                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| **Naming Format**         | Use `snake_case`, all lowercase, with underscores `_` separating words      |
| **Language**              | Use **English** for all names                                               |
| **Reserved Words**        | Avoid SQL Server reserved words for object names (e.g., `user`, `order`)    |
| **Consistency**           | Always name entities consistently across layers                             |

---

## Layer-Specific Naming Rules

### 🥉 **Bronze Rules**
- All table names must **start with the source system name** (e.g., `erp_raw_orders`, `crm_raw_contacts`).
- Table names must **exactly match the original structure and naming** in the source system — **no renaming**.
- Schema: `bronze`

### 🥈 **Silver Rules**
- Table names must **still retain the source system reference** (e.g., `erp_stg_orders`).
- Tables may include **basic business-standard column names**, but structural mapping must remain close to source.
- Schema: `silver`

### 🥇 **Gold Rules**
- All table names must be **business-aligned and human-readable**, with no system-level abbreviations.
- Use standard prefixes: `dim_`, `fact_`, or `report_` depending on purpose.
- Schema: `gold`



---

## Table Naming Convention
For **bronze** and **silver** layer will be kept the original name of the tables.

While all the tables in the **gold** layer follow the pattern:

```
<schema>.<prefix>_<entity_name>
```

| Prefix     | Type             | Example               |
|------------|------------------|------------------------|
| `dim_`     | Dimension table   | `gold.dim_product`     |
| `fact_`    | Fact table        | `gold.fact_sales`      |
| `report_`  | Report table      | `gold.report_sales`    |

---

## Column & Key Naming Convention

| Type              | Convention             | Example            |
|-------------------|------------------------|---------------------|
| Primary Key       | `<entity>_key`         | `customer_key`      |
| Surrogate Key     | `sk_<entity>`          | `sk_customer`       |
| Foreign Key       | `<entity>_fk`          | `customer_fk`       |
| Timestamps        | `created_at`, `updated_at` |                   |
| Standard Columns  | Use `snake_case`       | `order_amount`, `first_name` |

**Example Table: `gold.fact_sales`**

| Column Name       | Description                          |
|-------------------|--------------------------------------|
| `fact_sales_key`  | Primary key                          |
| `customer_fk`     | Foreign key to `dim_customer`        |
| `product_fk`      | Foreign key to `dim_product`         |
| `sales_date`      | Date of sale                         |
| `quantity`        | Quantity sold                        |
| `total_amount`    | Total sale amount                    |
| `created_at`      | Timestamp of record creation         |

---

## Stored Procedure Naming Convention

Stored procedures follow the format:

```
sp_<layer>_<action>_<entity>
```

| Example                          | Description                            |
|----------------------------------|----------------------------------------|
| `sp_bronze_load_orders`          | Loads raw data into `bronze.orders`|
| `sp_silver_clean_orders`         | Cleans and transforms orders           |
| `sp_gold_load_fact_sales`        | Loads data into fact table             |
| `sp_gold_report_sales_summary`   | Generates a business report            |

---

## Trigger Naming Convention

```
trg_<table>_<action>
```

| Action Example                   | Description                            |
|----------------------------------|----------------------------------------|
| `trg_fact_sales_insert`          | Trigger on insert into `fact_sales`    |
| `trg_dim_customer_update`        | Trigger on update on `dim_customer`    |

---

## View Naming Convention

```
vw_<entity or business_purpose>
```

| Example                        | Description                                |
|--------------------------------|--------------------------------------------|
| `vw_fact_sales_summary`        | Aggregated sales view                      |
| `vw_monthly_revenue_by_region` | Business-specific reporting view           |

> All views should be created in the **`gold`** layer unless otherwise justified.

---

## Index Naming Convention

| Index Type       | Convention                          | Example                         |
|------------------|-------------------------------------|---------------------------------|
| Primary Key      | `pk_<table>`                        | `pk_dim_customer`               |
| Foreign Key      | `fk_<child>_<parent>`               | `fk_fact_sales_dim_customer`    |
| Unique           | `ux_<table>_<column>`               | `ux_dim_customer_email`         |
| Non-clustered    | `ix_<table>_<column>`               | `ix_fact_sales_order_date`      |
| Composite Index  | `ix_<table>_<col1>_<col2>`          | `ix_fact_sales_customer_product`|

---

## 📘 Summary

| Object           | Prefix/Format                  | Example                          |
|------------------|--------------------------------|----------------------------------|
| Dimension Table  | `dim_`                         | `gold.dim_product`               |
| Fact Table       | `fact_`                        | `gold.fact_sales`                |
| View             | `vw_`                          | `vw_fact_sales_summary`          |
| Stored Procedure | `sp_<layer>_<action>`          | `sp_gold_load_fact_sales`        |
| Trigger          | `trg_<table>_<action>`         | `trg_fact_sales_insert`          |
| Index (PK)       | `pk_`                          | `pk_dim_product`                 |
| Index (FK)       | `fk_<child>_<parent>`          | `fk_fact_sales_dim_product`      |
| Index (Unique)   | `ux_<table>_<column>`          | `ux_dim_customer_email`          |
| Index (Generic)  | `ix_<table>_<column>`          | `ix_fact_sales_order_date`       |
