# 🧹 Data Loading & Cleansing: `erp_customer` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.erp_customer`.  
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
|                    | Unwanted Characters     | Ensure `customer_city` contains no numeric or standard characters   |

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
---

## `customer_unique_id` cleaning
### 1) Check NULL values
```sql
SELECT customer_unique_id
FROM silver.erp_customers
WHERE customer_unique_id IS NULL
-- No NULL values
```

### 2) Check duplicates
```sql
SELECT customer_unique_id,
	   COUNT(customer_unique_id) AS counting_orders
FROM silver.erp_customers
GROUP BY customer_unique_id
HAVING COUNT(customer_unique_id) > 1
-- We have duplicates because the same customer can make more orders

| customer_unique_id                     | counting_orders |
|----------------------------------------|-----------------|
| 8d50f5eadf50201ccdcedfb9e2ac8455       | 17              |
| 3e43e6105506432c953e165fb2acf44c       | 9               |
| 6469f99c1f9dfae7733b25662e7f1782       | 7               |
| ca77025e7201e3b30c44b472ff346268       | 7               |
| 1b6c7548a2a1f9037c1fd3ddfed95f33       | 7               |

-- For Example for customer ca77025e7201e3b30c44b472ff346268 we have the following result:

| customer_id                         | customer_unique_id              | customer_zip_code_prefix | customer_city  | customer_state |
|------------------------------------|----------------------------------|--------------------------|----------------|----------------|
| dc7dc47999d1b3c4c2f6a085a1a76eef   | ca77025e7201e3b30c44b472ff346268 | 51021                    | recife         | PE             |
| 6ccedfba5919d72fcc8c51bfa982de62   | ca77025e7201e3b30c44b472ff346268 | 51021                    | recife         | PE             |
| c59e684f832f832056ceee2c310cfc7f   | ca77025e7201e3b30c44b472ff346268 | 51021                    | recife         | PE             |
| 852e5ea6e9d74416ddf88bdbdb3189b9   | ca77025e7201e3b30c44b472ff346268 | 51021                    | recife         | PE             |
| 71f39c371308d132d7633895477dd307   | ca77025e7201e3b30c44b472ff346268 | 51021                    | recife         | PE             |
| b145bff18e79ac4dfb3fb91e61906f38   | ca77025e7201e3b30c44b472ff346268 | 51021                    | recife         | PE             |
| fc709ab645b71acd6046aeb03b590aa5   | ca77025e7201e3b30c44b472ff346268 | 51021                    | recife         | PE             |

```

### 3) Check customer_unique_id lenght
```sql
SELECT LEN(customer_unique_id) AS lenght_customer_unique_id,
	   COUNT(*)
FROM silver.erp_customers
GROUP BY LEN(customer_unique_id)
ORDER BY LEN(customer_unique_id) DESC
-- All the customer_id has 32 characters
```
---

## `customer_zip_code_prefix` cleaning
### 1) Verify the zip code prefix lenght is 5
```sql
SELECT LEN(customer_zip_code_prefix) AS lenght_customer_zip_code_prefix,
	   COUNT(*)
FROM silver.erp_customers
GROUP BY LEN(customer_zip_code_prefix)
ORDER BY LEN(customer_zip_code_prefix) DESC
-- All the prefix have lenght 5
```
### 2) Verify each customer_unique_id has only 1 zip_code associated
```sql
SELECT 
    customer_unique_id,
    COUNT(DISTINCT customer_zip_code_prefix) AS zip_code_count
FROM silver.erp_customers
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT customer_zip_code_prefix) > 1;
-- There are 250 customers with anomalies, let explore 1 of them:

SELECT c.*, o.order_purchase_timestamp, o.order_delivered_customer_date
FROM silver.erp_customers c
JOIN silver.crm_orders o
ON c.customer_id=o.customer_id
where customer_unique_id='13abc50b97af7425b5066e405d7cd760'

| customer_id                         | customer_unique_id              | customer_zip_code_prefix | customer_city         | customer_state | order_purchase_timestamp | order_delivered_customer_date |
|------------------------------------|----------------------------------|--------------------------|-----------------------|----------------|--------------------------|-------------------------------|
| 43798f254097cd1ae79c084d3c697ee3   | 13abc50b97af7425b5066e405d7cd760 | 06533                    | santana de parnaiba   | SP             | 2017-05-01 10:30:43.000  | 2017-05-08 07:42:07.000       |
| 1bd05d9a0031e8461d15550893d9b85a   | 13abc50b97af7425b5066e405d7cd760 | 07793                    | cajamar               | SP             | 2017-05-07 20:47:31.000  | 2017-05-29 06:04:02.000       |

-- In this case there was a bug in the system who accidentally associate in the second order te wrong information about zip_code, city and state
-- To fix that we'll consider as correct location the one indicated in the first order

--UPDATE statement: assign zip_code related to first order for the anomalies
-- Step 1: associate customer, zip_code and purchase order date
WITH FirstZipByOrder AS (
    SELECT
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS rn
    FROM silver.erp_customers c
    JOIN silver.crm_orders o
        ON c.customer_id = o.customer_id
),
-- Step 2: select only the first zip_code (based on first date)
FixedZip AS (
    SELECT
        customer_unique_id,
        customer_zip_code_prefix AS fixed_zip,
        customer_city AS fixed_city,
        customer_state AS fixed_state
    FROM FirstZipByOrder
    WHERE rn = 1
),
-- Step 3: find only the customer with more zip_codes associated
MultipleZips AS (
    SELECT customer_unique_id
    FROM silver.erp_customers
    GROUP BY customer_unique_id
    HAVING COUNT(DISTINCT customer_zip_code_prefix) > 1
)

-- Step 4: update only the customer with more zip_code using the zip_code of the first order and related city and state
UPDATE c
SET c.customer_zip_code_prefix = f.fixed_zip,
    c.customer_city = f.fixed_city,
    c.customer_state = f.fixed_state
FROM silver.erp_customers c
JOIN FixedZip f
    ON c.customer_unique_id = f.customer_unique_id
JOIN MultipleZips m
    ON c.customer_unique_id = m.customer_unique_id;
-- Now all customer have an unique zip_code, city and state based on the data filled during the first order
```
---

## `customer_city` cleaning
### 1) Verify there are no city names with numbers
```sql
select DISTINCT customer_city
from silver.erp_customers
WHERE customer_city LIKE '%[0-9]%'
ORDER BY customer_city
-- 1 value found : 'quilometro 14 do mutum' --> it is correct becuase it represents a brasilian district name
```

### 2) Check if there are results with not standard characters
```sql
-- Check for non standard characters
SELECT *
FROM silver.erp_customers
WHERE customer_city COLLATE Latin1_General_BIN  LIKE '%[^a-zA-Z0-9 ]%' --empty spaces are allowed
ORDER BY customer_city
-- All the city names are correct

|customer_city        |
|---------------------|
|arraial d'ajuda      |
|bandeirantes d'oeste |
|biritiba-mirim       |
|cipo-guacu           |

--Replace double space with standard empty space
UPDATE silver.erp_customers
SET customer_city= REPLACE(customer_city, '  ', ' ')
WHERE customer_city LIKE '%  %';
```
---

## `customer_state` cleaning
### 1) Verify the customer_state lenght is 2
```sql
SELECT LEN(customer_state) AS lenght_customer_state,
	   COUNT(*)
FROM silver.erp_customers
GROUP BY LEN(customer_state)
ORDER BY LEN(customer_state) DESC
-- All the customer_state have lenght 2
```

### 2) Associate correct state using GetStatoFromZipPrefix Function
```sql
UPDATE silver.erp_customers
SET customer_state = dbo.GetStatoFromZipPrefix(LEFT(customer_zip_code_prefix, 3));
-- All customer_state are correctly settled based on the customer_zip_code_prefix
```

### 3) Verify that a zip and city belong to the same country
```sql
SELECT 
    customer_zip_code_prefix,
    customer_city
FROM silver.erp_customers
GROUP BY 
    customer_zip_code_prefix,
    customer_city
HAVING COUNT(DISTINCT customer_state) > 1;
-- no zip_code_prefix + city associated to more countries
```
---

## Referential check with `silver.crm_orders`
```sql
-- Verify all `customer_id` exist in the orders table
SELECT c.customer_id,
       o.order_id
FROM silver.erp_customers c
LEFT JOIN silver.crm_orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
/*
|customer_id	                    |order_id |
|-----------------------------------|---------|
|86dc2ffce2dfff336de2f386a786e574   |NULL     |

There is only 1 customer_id with no order_id because it is the order 'bfbd0f9bdef84302105ad712db648a6c'
that has been canceled from silver.crm_orders and silver.crm_order_items because it didn't have payments information
from the table silver.crm_order_payments.
So for this reason also this related customer_id we'll be canceled because in the database there are missing data about
this order_id*/

-- DELETE statement:
DELETE FROM silver.erp_customers
WHERE customer_id= '86dc2ffce2dfff336de2f386a786e574'
```

---
✅ Data cleaned!

## Final DDL script with the new changes for `erp_customers`
No changes necessary to apply to structure, datatype and columns of this table. Initial DDL script unchanged.

