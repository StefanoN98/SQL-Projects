# 🏗️ Dimension View Creation & Validation: `dim_geolocation` (Silver ➝ Gold Layer)

> This script creates and validates the `gold.dim_geolocation` dimension view.  
> The goal is to unify and deduplicate geolocation data coming from `erp_geolocation`, `erp_customers`, and `erp_sellers`.

---

## Gold Layer View Creation for `dim_geolocation`

```sql
IF OBJECT_ID('gold.dim_geolocation', 'V') IS NOT NULL
    DROP VIEW gold.dim_geolocation;
GO

CREATE VIEW gold.dim_geolocation AS
WITH append_table AS (
    SELECT DISTINCT 
        geolocation_zip_code_prefix AS zip_code,
        TRIM(geolocation_city) AS city,
        geolocation_state AS country,
        CONCAT(geolocation_zip_code_prefix, '_', TRIM(geolocation_city), '_', geolocation_state) AS location_key
    FROM silver.erp_geolocation

    UNION ALL

    SELECT DISTINCT
        c.customer_zip_code_prefix AS zip_code,
        TRIM(c.customer_city) AS city,
        c.customer_state AS country,
        CONCAT(c.customer_zip_code_prefix, '_', TRIM(c.customer_city), '_', c.customer_state) AS location_key
    FROM silver.erp_customers c

    UNION ALL

    SELECT DISTINCT
        s.seller_zip_code_prefix AS zip_code,
        TRIM(s.seller_city) AS city,
        s.seller_state AS country,
        CONCAT(s.seller_zip_code_prefix, '_', TRIM(s.seller_city), '_', s.seller_state) AS location_key
    FROM silver.erp_sellers s
),

-- Step 1: most frequent city for each zip_code
city_rank AS (
    SELECT 
        zip_code,
        TRIM(city) AS city,
        COUNT(*) AS city_freq,
        ROW_NUMBER() OVER (PARTITION BY zip_code ORDER BY COUNT(*) DESC) AS rn_city
    FROM append_table
    GROUP BY zip_code, city
)

SELECT DISTINCT
       a.zip_code,
       TRIM(c.city) AS city,
       a.country
FROM append_table a
LEFT JOIN city_rank c
ON a.zip_code = c.zip_code
WHERE c.rn_city = 1;
```

| zip_code | city                   | country |
|----------|------------------------|---------|
| 40327    | salvador               | BA      |
| 95125    | fazenda souza          | RS      |
| 95400    | sao francisco de paula | RS      |
| 20541    | rio de janeiro         | RJ      |
| 23082    | rio de janeiro         | RJ      |
| 26276    | nova iguacu            | RJ      |
---

## ✅ Checks Summary

| Type               | Category                | Check Description                                                                 |
|--------------------|-------------------------|------------------------------------------------------------------------------------|
| **DATA INTEGRITY** | View Creation           | Created with UNION from `geolocation`, `customers`, and `sellers` tables           |
| **DEDUPLICATION**  | Zip Code Aggregation    | Ensures one city per `zip_code`, based on most frequent occurrence                 |
| **REFERENTIAL**    | Customers Zip Coverage  | Verifies all `customer_zip_code_prefix` exist in `dim_geolocation`                |
|                    | Sellers Zip Coverage    | Verifies all `seller_zip_code_prefix` exist in `dim_geolocation`                  |
| **DATA VALIDITY**  | City-Country Consistency| Checks that cities belong to a single state/country; exceptions are documented     |

---

## 🔍 Data Validation & Exploratory Analysis

### 1. Overview Data
```sql
SELECT COUNT(DISTINCT zip_code) AS zip_code_counting,
       COUNT(DISTINCT city) AS city_counting,
       COUNT(DISTINCT country) AS country_counting
FROM GOLD.dim_geolocation
-- Let's see unique zip_code, city and country

| zip_code_counting | city_counting | country_counting |
|-------------------|---------------|------------------|
| 19177             | 5813          | 27               |
```

### 2. Referential Checks --> QUESTA DA FAR CONFRONTARE CON LE RELATIVE TABELLE GOLD NON SILVER

```sql
-- Check if all customer ZIP codes are covered
SELECT customer_zip_code_prefix
FROM silver.erp_customers
WHERE customer_zip_code_prefix NOT IN (
    SELECT zip_code FROM gold.dim_geolocation
);
-- ✅ All customer locations are covered

-- Check if all seller ZIP codes are covered
SELECT seller_zip_code_prefix
FROM silver.erp_sellers
WHERE seller_zip_code_prefix NOT IN (
    SELECT zip_code FROM gold.dim_geolocation
);
-- ✅ All seller locations are covered
```

---

### 3. Multiple States with Same City Name

```sql
SELECT 
    zip_code, city, country, COUNT(*) AS frequency
FROM gold.dim_geolocation
WHERE city IN (
    SELECT city
    FROM gold.dim_geolocation
    GROUP BY city
    HAVING COUNT(DISTINCT country) > 1
)
GROUP BY zip_code, city, country
ORDER BY city, frequency DESC;
```


| zip_code | city        | country | frequency |
|----------|-------------|---------|-----------|
| 39790    | agua boa    | MG      | 1         |
| 78635    | agua boa    | MT      | 1         |
| 57490    | agua branca | AL      | 1         |
| 58748    | agua branca | PB      | 1         |
| 64460    | agua branca | PI      | 1         |
| 63360    | aurora      | CE      | 1         |
| 89186    | aurora      | SC      | 1         |

✅ These duplicates are **expected** due to common city names across different Brazilian states.

---

📌 **Ready to be used as a gelocationc dimension in the Gold Layer and for BI analysis**!

