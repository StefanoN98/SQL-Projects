# 🧹 Data Loading & Cleansing: `erp_customer` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.crm_order_items`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

---
## Initial DDL Script to load `erp_customer` from broze layer (no structure changes)
```sql
IF OBJECT_ID('silver.erp_customers', 'U') IS NOT NULL
	DROP TABLE silver.erp_customers;
GO

CREATE TABLE silver.erp_customers (
    customer_id NVARCHAR(50),
	customer_unique_id NVARCHAR(50),
	customer_zip_code_prefix NVARCHAR(10),
	customer_city NVARCHAR(50),
	customer_state NVARCHAR(10)
	);
GO

INSERT INTO silver.erp_customers(
	customer_id, customer_unique_id,
	customer_zip_code_prefix, customer_city,
	customer_state
	)

SELECT customer_id,
	   customer_unique_id,
	   customer_zip_code_prefix,
	   customer_city,
	   customer_state
FROM bronze.erp_customers;
```
| customer_id                        | customer_unique_id               | customer_zip_code_prefix | customer_city        | customer_state |
|------------------------------------|----------------------------------|--------------------------|----------------------|----------------|
| d73698c8fc11e06d4e414969c84a7d3f   | b1bfd7e518ac86fd5e44b796273c4f5c | 59460                    | sao paulo do potengi | RN             |
| b59b9200abefa3aef8728bddb76a9d8c   | 8ca1816f6c1a91aa2788ee471b85ab19 | 99840                    | sananduva            | RS             |
| f2b88194d68ac45551d759ed2afee2bb   | 2ae6a803cd4bcfe303b032afb1c9b89a | 03033                    | sao paulo            | SP             |
| 8d43602a38aad2e3712856431d9c2f69   | d2f86e7867ceb0f4054333653490ea33 | 31842                    | belo horizonte       | MG             |

---

## ✅ Checks Summary
| Type               | Category                 | Check Description                                                  |
|--------------------|--------------------------|--------------------------------------------------------------------|
| **DATA INTEGRITY** | NULL Values              | Ensure `customer_id`, `customer_unique_id` are not NULL            |
|                    | Duplicate Values         | Ensure no duplicate `customer_id` or `(customer_id, unique_id)`    |
|                    | Length Check             | Validate length of `customer_id` and `customer_unique_id` = 32     |
|                    | Length Check             | Validate `customer_zip_code_prefix` length = 5                     |
|                    | Length Check             | Validate `customer_state` length = 2                               |
| **DATA VALIDATION**| City Name Characters     | Ensure `customer_city` contains no numeric characters              |

---

## `customer_id` cleaning
### 1) Check NULL values
```sql
SELECT customer_id
FROM silver.erp_customers
WHERE customer_id IS NULL
-- No NULL values
```

### 2) Check duplicates
```sql
SELECT customer_id,
	   COUNT(*) AS counting
FROM silver.erp_customers
GROUP BY customer_id
HAVING COUNT(*) > 1
-- No duplicates detected
```

### 3) Check customer_id lenght
```sql
SELECT LEN(customer_id) AS lenght_customer_id,
	   COUNT(*)
FROM silver.erp_customers
GROUP BY LEN(customer_id)
ORDER BY LEN(customer_id) DESC
-- All the customer_id has 32 characters
```
