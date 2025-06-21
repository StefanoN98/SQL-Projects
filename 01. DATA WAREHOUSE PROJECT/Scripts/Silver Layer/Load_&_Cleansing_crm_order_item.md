# 🧹 Data Loading & Cleansing: `crm_order_items` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.crm_order_items`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

---
## Initial DDL Script to load `crm_order_items` from broze layer (no structure changes)
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
| order_id                             | order_item_id | product_id                         | seller_id                          | shipping_limit_date     | price | freight_value | dwh_create_date             |
|-------------------------------------|---------------|------------------------------------|------------------------------------|--------------------------|-------|----------------|-----------------------------|
| 9bd837f7b2734bea1bb928fefebb8c91    | 1             | dfec64aac9b864b2807a7be33222b75f   | 1e8b33f18b4f7598d87f5cbee2282cc2   | 2018-05-13 21:15:37.000 | 84,9  | 8,95           | 2025-05-18 16:06:04.5466667 |
| 9bd8962db91a783af70ff3eb36fbeea8    | 1             | eff955ba97941dc6837a770367d66944   | 1554a68530182680ad5c8b042c3ab563   | 2017-06-29 02:23:05.000 | 43,9  | 17,6           | 2025-05-18 16:06:04.5466667 |
| 9bd8962db91a783af70ff3eb36fbeea8    | 2             | eff955ba97941dc6837a770367d66944   | 1554a68530182680ad5c8b042c3ab563   | 2017-06-29 02:23:05.000 | 43,9  | 17,6           | 2025-05-18 16:06:04.5466667 |
| 9bd90698ab1e822ca4cb1e2a0de42fd4    | 1             | 53b36df67ebb7c41585e8d54d6772e08   | 7d13fca15225358621be4086e1eb0964   | 2018-05-04 16:11:17.000 | 99,9  | 0              | 2025-05-18 16:06:04.5466667 |

---

## ✅ Checks Summary

| Type                 | Category                | Check Description                                            |
|----------------------|-------------------------|------------------------------------------------------------- |
| **DATA INTEGRITY**   | Duplicates Values       | Check for duplicates on (`order_id`, `order_item_id`)        |
|                      | NULL Values             | Check for NULL values                                        |
|                      | Empty Strings           | Detect empty string values in key fields                     |
|                      | Unwanted Spaces         | Remove unwanted spaces from text fields                      |
|                      | Check Length            | Validate that `order_id` has exactly 32 characters           |
|                      | Numeric Range           | Ensure `price` and `freight_value` are non-negative          |
|                      | Logical Consistency     | Detect `price = 0` with positive `freight_value`             |
|                      | Value Distribution      | Check value distribution in `order_item_id`                  |
| **DATA VALIDATION**  | Date Validity           | Ensure `shipping_date` is within reasonable date range       |
| **DATA CONSISTENCY** | Check Sequence          | Ensure item numbers are sequential within each `order_id`    |
| **BUSINESS RULES**   | Derived Column          | Derive `shipping_type` from `freight_value`                  |
|                      | Derived Column          | Derive `total_order_payment` as `price` + `freight_value`    |

---


## Check duplicates composite key (`order_id`, `order_item_id`) 

```sql
SELECT order_id, order_item_id, COUNT(*) AS occurrences
FROM silver.crm_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
-- No duplicates detected

```

---

## Check NULL values (`order_id`, `order_item_id`, `product_id`,`seller_id`,`shipping_limit_date`,`price`,`freight_value`) 

```sql
SELECT *
FROM silver.crm_order_items
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

## Check Empty Strings (`order_id`, `product_id `, `seller_id `)

```sql
SELECT *
FROM silver.crm_order_items
WHERE order_id = '' OR product_id = '' OR seller_id = '';
--No empty strings detected
```

---

## Check Unwanted Spaces  (`order_id`, `product_id `, `seller_id `)

```sql
SELECT *
FROM silver.crm_order_items
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
FROM silver.crm_order_items
WHERE LEN(order_id) <> 32;
-- No anomalies detected, the lenght for all the strings is 32
```

---

## Numeric range on `price` & `freight_value` 

```sql

SELECT *
FROM silver.crm_order_items
WHERE price < 0 OR freight_value < 0;
-- No negative values
```

---

## Logical Consistency between `price` & `freight_value` 
```sql

-- Zero price but positive freight
SELECT *
FROM silver.crm_order_items
WHERE price = 0 AND freight_value > 0;
-- No issue detected
```

---


## Value Distribution on `order_item_id`

```sql
SELECT order_id, COUNT(*) AS item_count
FROM silver.crm_order_items
GROUP BY order_id
ORDER BY item_count DESC;
-- 21 is th maximum number of items purchased in an unique order 
```

---

## Date Validation on `shipping_limit_date`

```sql
SELECT MIN(shipping_limit_date) AS min_date,
       MAX(shipping_limit_date) AS max_date,
       DATEDIFF(YEAR, MIN(shipping_limit_date), MAX(shipping_limit_date)) AS interval_years,
       IIF(MAX(shipping_limit_date) > GETDATE(), 'Anomaly', 'No Anomaly') AS today_check
FROM silver.crm_order_items;
-- Shipping data from 2016 to 2020

| min_date                | max_date                | interval_years | today_check |
|-------------------------|-------------------------|----------------|-------------|
| 2016-09-19 00:15:34.000 | 2020-04-09 22:35:08.000 | 4              | No Anomaly  |

```

---

## Check Sequence `order_item_id`

```sql
WITH ranked_items AS (
  SELECT order_id, order_item_id,
         ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_item_id) AS rn
  FROM silver.crm_order_items
)
SELECT *
FROM ranked_items
WHERE order_item_id <> rn
ORDER BY order_id;
-- Each following item has the correct senquence number

| order_id                          | order_item_id | rn |
|-----------------------------------|---------------|----|
| 0019c29108428acffd089c36103c9440  | 1             | 1  |
| 001ab0a7578dd66cd4b0a71f5b6e1e41  | 1             | 1  |
| 001ab0a7578dd66cd4b0a71f5b6e1e41  | 2             | 2  |
| 001ab0a7578dd66cd4b0a71f5b6e1e41  | 3             | 3  |
| 001ac194d4a326a6fa99b581e9a3d963  | 1             | 1  |

```

---

## Shipping Type Derivation `shipping_type`

```sql
SELECT *,
    CASE 
        WHEN freight_value > 0 THEN 'Standard Shipping'
        ELSE 'Free Shipping'
    END AS shipping_type
FROM silver.crm_order_items;

| price  | freight_value  | shipping_type     |
|--------|----------------|-------------------|
| 85     | 17.03          | Standard Shipping |
| 229    | 9.80           | Standard Shipping |
| 99.9   | 0.00           | Free Shipping     |
```

---

## Total Order Payment Derivation
```sql
  SELECT *,
	price + freight_value AS total_order_payment
FROM bronze.crm_order_items

| price  | freight_value  | total_order_payment |
|--------|----------------|---------------------|
| 58.90  | 13.29          | 72.19               |
| 239.90 | 19.93          | 259.83              |
| 199.00 | 17.87          | 216.87              |
```

### Verify that all the total_order_payment have the same transactional payments value
```sql
WITH order_payment AS (
    SELECT 
        order_id,
        SUM(total_order_payment) AS total_order_payment
    FROM silver.crm_order_items
    GROUP BY order_id
),
transact_payment AS (
    SELECT 
        order_id,
        SUM(payment_value) AS total_payment_value
    FROM silver.crm_order_payments
    GROUP BY order_id
)

SELECT 
    op.order_id,
    op.total_order_payment,
    tp.total_payment_value
FROM order_payment op
LEFT JOIN transact_payment tp
    ON op.order_id = tp.order_id
WHERE ABS(op.total_order_payment - tp.total_payment_value) > 0.01 --to verify detect also small differences
-- 380 rows detected

| order_id                           | total_order_payment  | total_payment_value        |
|------------------------------------|----------------------|----------------------------|
| 03b218d39c422c250f389120c531b61f   | 50,24                | 58,03                      |
| 04993613aee4046caf92ea17b316dcfb   | 524,32               | 524,28                     |
| 09ec142bfa34576d3914bdf8c19927c2   | 70,75                | 70,76                      |
| 10a6730b0b333e2b017dd139a0530f19   | 126,99               | 143,53                     |


/* In these cases sometimes the customer paid more or less compared to the theoretical order price
   There are 2 situations:
   - order payment > actual transaction payment --> it means the customer used a coupon to reduce price
   - order payment < actual transaction payment --> it means the customer paid something more at the customs /*
-- For these cases we'll add in the gold layer 2 new columns: one that expalain in which situation we are and the difference amount
```

### Referential Check with `silver.crm_order_payments`
```sql
SELECT DISTINCT(fo.order_id) AS order_id_orders_table,
	   op.order_id AS order_id_payments_table
FROM silver.crm_order_items fo
LEFT JOIN silver.crm_order_payments op
ON fo.order_id= op.order_id
WHERE op.order_id IS NULL 
-- There is one order_id not present in the silver.crm_order_payments table
-- The rows for this order_id will be eliminated

--DELETE statement: remove rows for the order_id not present in payments table
DELETE FROM silver.crm_order_items
WHERE order_id ='bfbd0f9bdef84302105ad712db648a6c'
```
---


✅ Data cleaned!




## Final DDL script with the new changes for `crm_order_items`
Added the derived column `shipping_type`

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
    total_order_payment FLOAT, --Added derived column
    shipping_type NVARCHAR(50), --Added derived column
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

INSERT INTO silver.crm_order_items (
    order_id, order_item_id, product_id, seller_id,
    shipping_limit_date, price, freight_value,
    total_order_payment, shipping_type
)
SELECT 
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    price + freight_value AS total_order_payment,
    CASE 
        WHEN freight_value > 0 THEN 'Standard Shipping'
        ELSE 'Free Shipping'
    END AS shipping_type
FROM bronze.crm_order_items;
```

| order_id                           | order_item_id | product_id                          | seller_id                           | shipping_limit_date    | price  | freight_value | total_order_payment | shipping_type     | dwh_create_date               |
|------------------------------------|----------------|--------------------------------------|--------------------------------------|--------------------------|--------|----------------|---------------------|--------------------|-------------------------------|
| 00010242fe8c5a6d1ba2dd792cb16214   | 1              | 4244733e06e7ecb4970a6e2683c13e61     | 48436dade18ac8b2bce089ec2a041202     | 2017-09-19 09:45:35.000 | 58.90  | 13.29          | 72.19               | Standard Shipping  | 2025-05-31 12:02:21.0600000   |
| 00018f77f2f0320c557190d7a144bdd3   | 1              | e5f2d52b802189ee658865ca93d83a8f     | dd7ddc04e1b6c2c614352b383efe2d36     | 2017-05-03 11:05:13.000 | 239.90 | 19.93          | 259.83              | Standard Shipping  | 2025-05-31 12:02:21.0600000   |
| 000229ec398224ef6ca0657da4fc703e   | 1              | c777355d18b72b67abbeef9df44fd0fd     | 5b51032eddd242adc84c38acab88f23d     | 2018-01-18 14:48:30.000 | 199.00 | 17.87          | 216.87              | Standard Shipping  | 2025-05-31 12:02:21.0600000   |


---
