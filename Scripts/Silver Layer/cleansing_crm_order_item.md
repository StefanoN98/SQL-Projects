# 🧹 Data Cleansing: `crm_order_items` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `bronze.crm_order_items` table before promoting the data to the **Silver Layer**.  
> The goal is to ensure that all records are complete, clean, and logically consistent prior to transformation and standardization.

---
## Initial DDL Script to load `crm_order_items` from broze layer (no changes)
```sql
IF OBJECT_ID('silver.crm_order_items', 'U') IS NOT NULL
	DROP TABLE silver.crm_order_items;
  
CREATE TABLE silver.crm_order_items (
    order_id NVARCHAR(50),
    order_item_id INT,
    product_id NVARCHAR(50),
    seller_id NVARCHAR(50),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

INSERT INTO silver.crm_order_items (
    order_id, order_item_id, product_id, seller_id,
    shipping_limit_date, price, freight_value
)
SELECT 
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM bronze.crm_order_items;
```
---

## ✅ Checks Summary

| Type               | Category                | Check Description                                            |
|--------------------|-------------------------|------------------------------------------------------------- |
| **DATA INTEGRITY** | Duplicates Values       | Check for duplicates on (`order_id`, `order_item_id`)        |
|                    | NULL Values             | Check for NULL values                                        |
|                    | Empty Strings           | Detect empty string values in key fields                     |
|                    | Unwanted Spaces         | Remove unwanted spaces from text fields                      |
|                    | Check Length            | Validate that `order_id` has exactly 32 characters           |
|                    | Numeric Range           | Ensure `price` and `freight_value` are non-negative          |
|                    | Logical Consistency     | Detect `price = 0` with positive `freight_value`             |
|                    | Value Distribution      | Check value distribution in `order_item_id`                  |
| **DATA VALIDATION**| Date Validity           | Ensure `shipping_date` is within reasonable date range       |
| **BUSINESS RULES** | Check Sequence          | Ensure item numbers are sequential within each `order_id`    |
|                    | Derived Column          | Derive `shipping_type` from `freight_value`                  |


---


## Check duplicates composite key (`order_id`, `order_item_id`) 

```sql
SELECT order_id, order_item_id, COUNT(*) AS occurrences
FROM bronze.crm_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
-- No duplicates detected

```

---

## Check NULL values

```sql
SELECT *
FROM bronze.crm_order_items
WHERE order_id IS NULL OR 
      order_item_id IS NULL OR
      product_id IS NULL OR
      seller_id IS NULL OR
      shipping_limit_date IS NULL OR
      price IS NULL OR
      freight_value IS NULL;
-- No NULL values detected
```

---

## Check Empty Strings

```sql
SELECT *
FROM bronze.crm_order_items
WHERE order_id = '' OR product_id = '' OR seller_id = '';
--No empty strings detected
```

---

## Check Unwanted Spaces 

```sql
SELECT *
FROM bronze.crm_order_items
WHERE TRIM(order_id) != order_id OR
      TRIM(product_id) != product_id OR
      TRIM(seller_id) != seller_id;
-- No unwanted spaces detected
```

---

## Check Length  `order_id`

```sql
SELECT DISTINCT order_id,
       LEN(order_id) AS length
FROM bronze.crm_order_items
WHERE LEN(order_id) <> 32;
-- No anomalies detected, the lenght for all the strings is 32
```

---

## Numeric range on `price` & `freight_value` 

```sql

SELECT *
FROM bronze.crm_order_items
WHERE price < 0 OR freight_value < 0;
-- No negative values
```

---

## Logical Consistency between `price` & `freight_value` 
```sql

-- Zero price but positive freight
SELECT *
FROM bronze.crm_order_items
WHERE price = 0 AND freight_value > 0;
-- No issue detected
```

---


## Value Distribution on `order_item_id`

```sql
SELECT order_id, COUNT(*) AS item_count
FROM bronze.crm_order_items
GROUP BY order_id
ORDER BY item_count DESC;
```

---

## Date Validation on `shipping_limit_date`

```sql
SELECT MIN(shipping_limit_date) AS min_date,
       MAX(shipping_limit_date) AS max_date,
       DATEDIFF(YEAR, MIN(shipping_limit_date), MAX(shipping_limit_date)) AS interval_years,
       IIF(MAX(shipping_limit_date) > GETDATE(), 'Anomaly', 'No Anomaly') AS today_check
FROM bronze.crm_order_items;
```

---

## Check Sequence

```sql
WITH ranked_items AS (
  SELECT order_id, order_item_id,
         ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_item_id) AS rn
  FROM bronze.crm_order_items
)
SELECT *
FROM ranked_items
WHERE order_item_id <> rn
ORDER BY order_id;
```

---

## Shipping Type Derivation

```sql
SELECT *,
    CASE 
        WHEN freight_value > 0 THEN 'Standard Shipping'
        ELSE 'Free Shipping'
    END AS shipping_type
FROM bronze.crm_order_items;
```

---


✅ Ready to promote cleaned data to the **Silver Layer**!




## Final DDL script with the new changes for `crm_order_items`

```sql
IF OBJECT_ID('silver.crm_order_items', 'U') IS NOT NULL
	DROP TABLE silver.crm_order_items;
  
CREATE TABLE silver.crm_order_items (
    order_id NVARCHAR(50),
    order_item_id INT,
    product_id NVARCHAR(50),
    seller_id NVARCHAR(50),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    shipping_type NVARCHAR(50), --Added derived column
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

INSERT INTO silver.crm_order_items (
    order_id, order_item_id, product_id, seller_id,
    shipping_limit_date, price, freight_value, shipping_type
)
SELECT 
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    CASE 
        WHEN freight_value > 0 THEN 'Standard Shipping'
        ELSE 'Free Shipping'
    END AS shipping_type
FROM bronze.crm_order_items;
```

---
