# 🏗️ Dimension View Creation & Validation: `dim_products` (Silver ➝ Gold Layer)

> This script defines and validates the creation of the `gold.dim_products` dimension view from the Silver Layer.  
> The purpose is to establish a cleaned and standardized reference table for products.

---

## Gold Layer View Creation for `dim_products`
```sql
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT p.product_id,
	   pct.product_category_name_english as product_category_name,
	   p.product_weight_g AS product_weight,
	   p.product_length_cm AS product_lenght,
	   p.product_height_cm AS product_height,
	   p.product_width_cm AS product_width
FROM silver.erp_products p
LEFT JOIN silver.erp_product_category_translation pct
ON p.product_category_name=pct.product_category_name
```
| product_id                         | product_category_name        | product_weight | product_lenght | product_height | product_width |
|------------------------------------|------------------------------|----------------|----------------|----------------|---------------|
| 0ebe8f2e60fadb8f9ebf63a5841f34f1   | bed_bath_table               | 2783           | 65             | 14             | 46            |
| c1b1fa3428453960653af124b17ab165   | agro_industry_and_commerce   | 1000           | 28             | 9              | 26            |
| f06796447de379a26dde5fcac6a1a2f7   | furniture_decor              | 11400          | 52             | 6              | 52            |
| 10244e4307f7a1575e022f248b51402a   | bed_bath_table               | 1400           | 30             | 10             | 20            |
| a91c0e7e93a72403880b5f4238764471   | auto                         | 400            | 26             | 16             | 16            |

---

## 🔍 Data Validation & Exploratory Analysis

### 1. Overview Data
```sql
SELECT 'Product' AS _group, 'product_id_counting' AS _metric, COUNT(DISTINCT product_id) AS _value FROM gold.dim_products
UNION ALL
SELECT 'Product', 'product_category_name_counting', COUNT(DISTINCT product_category_name) FROM gold.dim_products
UNION ALL
SELECT 'Weight','min_weight', MIN(product_weight) FROM gold.dim_products
UNION ALL
SELECT 'Weight','max_weight', MAX(product_weight) FROM gold.dim_products
UNION ALL
SELECT 'Lenght','min_lenght', MIN(product_lenght) FROM gold.dim_products
UNION ALL
SELECT 'Lenght','max_lenght', MAX(product_lenght) FROM gold.dim_products
UNION ALL
SELECT 'Height','min_height', MIN(product_height) FROM gold.dim_products
UNION ALL
SELECT 'Height','max_height', MAX(product_height) FROM gold.dim_products
UNION ALL
SELECT 'Width','min_width', MIN(product_width) FROM gold.dim_products
UNION ALL
SELECT 'Width','max_width', MAX(product_width) FROM gold.dim_products;

| _group   | _metric                          | _value |
|----------|----------------------------------|--------|
| Product  | product_id_counting              | 32951  |
| Product  | product_category_name_counting   | 74     |
| Weight   | min_weight                       | 0      |
| Weight   | max_weight                       | 40425  |
| Lenght   | min_lenght                       | 0      |
| Lenght   | max_lenght                       | 105    |
| Height   | min_height                       | 0      |
| Height   | max_height                       | 105    |
| Width    | min_width                        | 0      |
| Width    | max_width                        | 118    |

```

### 2. Referential Check
```sql
-- Verify all product_id have at least 1 order_id
SELECT p.product_id,
	   COUNT(oi.order_id) AS orders_counting
FROM gold.dim_products p
LEFT JOIN gold.fact_order_items oi
ON p.product_id=oi.product_id
GROUP BY p.product_id
HAVING COUNT(oi.order_id)<1
-- ✅ All the product_id have at least one order related
```
---

📌 **Ready to be used as a products dimension in the Gold Layer and for BI analysis**!
