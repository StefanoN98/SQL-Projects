# 🏗️ Dimension View Creation & Validation: `dim_sellers` (Silver ➝ Gold Layer)

> This script defines and validates the creation of the `gold.dim_sellers` dimension view from the Silver Layer.  
> The purpose is to establish a cleaned and standardized reference table for sellers.

---

## Gold Layer View Creation for `dim_sellers`

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

| seller_id                             | seller_zip_code |
|---------------------------------------|-----------------|
| d1b65fc7debc3361ea86b5f14c68d2e2      | 13844           |
| ce3ad9de960102d0677a81f5d0bb7b2d      | 20031           |
| c0f3eea2e14555b6faeea3dd58c1b1c3      | 04195           |
| 51a04a8a6bdcb23deccc82b0b80742cf      | 12914           |

---

## 🔍 Data Validation & Exploratory Analysis

### 1. Overview Data
```sql
SELECT COUNT(DISTINCT seller_id) AS seller_counting,
	   COUNT(DISTINCT seller_zip_code) AS seller_zip_counting
FROM gold.dim_sellers

| seller_counting | seller_zip_counting |
|-----------------|---------------------|
| 3095            | 2246                |

```

### 2. Referential Check
⚠️ _This will need to be repeated once the final Gold Layer fact tables are built._

```sql
-- Verify that each `seller_id` has at least one associated `order_id`  
SELECT s.seller_id,
       oi.order_id
FROM gold.dim_sellers s
LEFT JOIN silver.crm_order_items oi
ON s.seller_id = oi.seller_id
WHERE oi.order_id IS NULL;
-- ✅ All `seller_id`s have an associated `order_id`

-- Verifythat `seller_zip_code` exists in `dim_geolocation`
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
