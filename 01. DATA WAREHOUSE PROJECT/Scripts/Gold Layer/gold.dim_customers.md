
# 🏗️ Dimension View Creation & Validation: `dim_customers` (Silver ➝ Gold Layer)

> ⚠️ **Note**: This view is currently based on the **Silver Layer** tables.
> Once the final **Gold Layer** dimension and fact tables are complete, the logic and validations should be reviewed and refactored accordingly.

---

## Gold Layer View Creation for `dim_customers`

```sql
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix AS customer_zip_code
FROM silver.erp_customers;
```

| customer_id                        | customer_unique_id             | customer_zip_code |
|------------------------------------|--------------------------------|-------------------|
| d73698c8fc11e06d4e414969c84a7d3f | b1bfd7e518ac86fd5e44b796273c4f5c | 59460             |
| b59b9200abefa3aef8728bddb76a9d8c | 8ca1816f6c1a91aa2788ee471b85ab19 | 99840             |
| f2b88194d68ac45551d759ed2afee2bb | 2ae6a803cd4bcfe303b032afb1c9b89a | 03033             |
| 1336c066de955f70e1508ce21670b72e | 482100e419953116ee03dca7416277e0 | 19940             |
| ae447e76e331a2d1fb37473deb2ccae0 | 4412ff92330051eb18b7aa95d9d172e7 | 08790             |

---

## 🔍 Data Validation & Exploratory Analysis

### 1. Overview Data
```sql
SELECT 
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    COUNT(DISTINCT customer_id) AS total_customer_orders
FROM gold.dim_customers;
-- Let's see unique customers and the related orders

| total_customers | total_customer_orders |
|-----------------|-----------------------|
| 96096           | 99441                 |

```

---

### 2. Referential Check
```sql
-- Verify all `customer_id` exist in the orders table (⚠️ Silver for now)
SELECT f.customer_id,
       o.order_id
FROM gold.dim_customers f
LEFT JOIN silver.crm_orders o
ON f.customer_id = o.customer_id
WHERE o.order_id IS NULL;
-- ✅ Every customer_id has an associated order_id
```

---

### 3. Data Correcteness Check
Verify all customer_id have not more than 1 order_id associated (sarà da fare con quella gold) 
perchè ad ogni order_id è associato un customer_id 
```sql
-- Check that `customer_id` is not duplicated across multiple orders (⚠️ Silver for now)
SELECT f.customer_id,
       COUNT(o.order_id)
FROM gold.dim_customers f
LEFT JOIN silver.crm_orders o
ON f.customer_id = o.customer_id
GROUP BY f.customer_id
HAVING COUNT(o.order_id) > 1;
-- ✅ No anomalies


-- Verify all customer_zip_code have related city and state in dim_geolocation
SELECT c.customer_unique_id,
       c.customer_zip_code,
       g.city,
       g.country
FROM gold.dim_customers c
LEFT JOIN  gold.dim_geolocation g
ON c.customer_zip_code=g.zip_code
WHERE g.city IS NULL OR g.country IS NULL
-- All the information are available for each customer
```

---

📌 **Ready to be used as a customers dimension in the Gold Layer and for BI analysis**!
