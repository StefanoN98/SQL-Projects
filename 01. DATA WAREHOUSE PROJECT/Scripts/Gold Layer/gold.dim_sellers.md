# 🧱 Gold Layer – `dim_sellers`

> This script defines and validates the creation of the `gold.dim_sellers` dimension view from the Silver Layer.  
> The purpose is to establish a cleaned and standardized reference table for sellers.

---

## 🏗️ View Definition

```sql
IF OBJECT_ID('gold.dim_sellers', 'V') IS NOT NULL
    DROP VIEW gold.dim_sellers;
GO

CREATE VIEW gold.dim_sellers AS
SELECT 
    seller_id,
    seller_zip_code_prefix AS seller_zip_code
FROM silver.erp_sellers;
```

---

## 📊 Record Summary

```sql
SELECT *
FROM gold.dim_sellers;
-- 3095 unique sellers
```

---

## 🔍 Data Validations

### 1. Check that each `seller_id` has at least one associated `order_id`  
⚠️ _This will need to be repeated once the final Gold Layer fact tables are built._

```sql
SELECT s.seller_id,
       oi.order_id
FROM gold.dim_sellers s
LEFT JOIN silver.crm_order_items oi
ON s.seller_id = oi.seller_id
WHERE oi.order_id IS NULL;
-- ✅ All `seller_id`s have an associated `order_id`
```

---

### 2. Check that `seller_zip_code` exists in `dim_geolocation`

```sql
SELECT s.seller_id,
       s.seller_zip_code,
       g.city,
       g.country
FROM gold.dim_sellers s
LEFT JOIN gold.dim_geolocation g
ON s.seller_zip_code = g.zip_code
WHERE g.city IS NULL OR g.country IS NULL;
-- ✅ All seller locations are correctly mapped
```

---

> ⚠️ **Note**  
> This view is currently based on **Silver Layer** tables.  
> Once the **Gold Layer** fact tables are finalized, all logic and validations should be **reviewed and refactored** accordingly.

---

_Last updated: 2025-06-07_
