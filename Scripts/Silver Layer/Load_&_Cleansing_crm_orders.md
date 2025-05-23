# 🧹 Data Loading & Cleansing: `crm_orders` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.crm_orders`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

---
## Initial DDL Script to load `crm_orders` from broze layer (no structure changes)


```sql
IF OBJECT_ID('silver.crm_orders', 'U') IS NOT NULL
	DROP TABLE silver.crm_orders;
GO

CREATE TABLE silver.crm_orders (
    order_id NVARCHAR(50),
	customer_id NVARCHAR(50),
    order_status NVARCHAR(50),
	order_purchase_timestamp DATETIME,
	order_approved_at DATETIME,
	order_delivered_carrier_date DATETIME,
	order_delivered_customer_date DATETIME,
	order_estimated_delivery_date DATETIME,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
    );
GO


INSERT INTO silver.crm_orders(
	order_id , customer_id, order_status,
	order_purchase_timestamp,order_approved_at,
	order_delivered_carrier_date,order_delivered_customer_date,
	order_estimated_delivery_date
	)

SELECT order_id ,
	   customer_id,
	   order_status,
	   order_purchase_timestamp,
	   order_approved_at,
	   order_delivered_carrier_date,
	   order_delivered_customer_date,
	   order_estimated_delivery_date
FROM bronze.crm_orders
```
---

## `order_id` cleaning
### 1) Check order_id lenght
```sql
SELECT LEN(order_id) AS lenght_order_id,
	   COUNT(*) AS counting
FROM silver.crm_orders
GROUP BY LEN(order_id)
ORDER BY LEN(order_id) DESC
-- All the order_id has 32 characters
```

### 2) Check duplicates
```sql
SELECT order_id,
	   COUNT(*) AS counting
FROM silver.crm_orders
GROUP BY order_id
HAVING COUNT(*)>1
-- NO duplicates detected
```
---


## `customer_id` cleaning
### 1) Check customer_id lenght
```sql
SELECT LEN(customer_id) AS lenght_customer_id,
	   COUNT(*)
FROM silver.crm_orders
GROUP BY LEN(customer_id)
ORDER BY LEN(customer_id) DESC
-- All the customer_id has 32 characters
```
---


## `order_status` cleaning
### 1) Analyze distinct values
```sql
SELECT DISTINCT order_status
FROM silver.crm_orders
/*No anomalies values.
  We have the following results created -approved-  processing - invoiced - shipped- delivered - unavailable - canceled*/
```


### 2) Verify correcteness of order_status and dates
Verify when order is only **CREATED** `order_approved_at` , `order_delivered_carrier_date` and `order_delivered_customer_date` should be NULL
```sql
SELECT *
FROM silver.crm_orders
WHERE order_status = 'created'
  AND (order_approved_at IS NOT NULL OR
	   order_delivered_carrier_date IS NOT NULL OR 
	   order_delivered_customer_date IS NOT NULL);
	-- No anomalies
```

Verify when order is **PROCESSING, APPROVED OR INVOICED** `order_delivered_carrier_date` and `order_delivered_customer_date` should be NULL
```sql
SELECT *
FROM silver.crm_orders
WHERE order_status IN ( 'processing','approved', 'invoiced')
  AND (order_delivered_carrier_date IS NOT NULL OR 
	   order_delivered_customer_date IS NOT NULL);
	-- No anomalies
```

Verify when order is **SHIPPED** `order_delivered_customer_date` should be NULL
```sql
SELECT *
FROM silver.crm_orders
WHERE order_status = 'shipped'
  AND order_delivered_customer_date IS NOT NULL;
	-- No anomalies
```

Verify when order is **DELIVERED** `order_delivered_customer_date` should be NOT NULL
```sql
SELECT *
FROM silver.crm_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;
	-- 4 Anomalies detected, in this case the status is only shippe

-- UPDATE statement: fix `order_status` to 'shipped' when `order_delivered_customer_date` IS NULL
UPDATE silver.crm_orders
SET order_status = 'shipped'
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL
```


Verify when order is **UNAVAILABLE** `order_delivered_carrier_date` & `order_delivered_customer_date` should be  NULL
```sql
SELECT *
FROM silver.crm_orders
WHERE order_status = 'unavailable' AND order_delivered_carrier_date IS NOT NULL AND order_delivered_customer_date IS NOT NULL
	-- No anomalies
```

Verify when order is **CANCELED** `order_delivered_customer_date` should be  NULL
```sql
SELECT *
FROM silver.crm_orders
WHERE order_status = 'canceled' AND order_delivered_customer_date IS NOT NULL
-- we have 6 anomalies , so in this case the status should be delivered

-- UPDATE statement: fix `order_status` to 'delivered' when `order_delivered_customer_date` IS NOT NULL
UPDATE silver.crm_orders
SET order_status = 'delivered'
WHERE order_status = 'canceled' AND order_delivered_customer_date IS NOT NULL
```
---


```sql
/*======================
  order_purchase_timestamp cleaning
======================*/
--Check range
SELECT MIN(order_purchase_timestamp) AS min_date_purchase,
	   MAX(order_purchase_timestamp) AS max_date_purchase
FROM silver.crm_orders
-- From 04/09/2016 to 17/10/2018

----------------------------------------------------------------

/*======================
  order_purchase_timestamp,order_approved_at,
	   order_delivered_carrier_date,order_delivered_customer_date,
	   order_estimated_delivery_date cleaning
======================*/
-- Check range
SELECT 
	   MIN(order_purchase_timestamp) AS min_date_purchase,
	   MAX(order_purchase_timestamp) AS max_date_purchase,
	   MIN(order_approved_at) AS min_date_approved_purchase,
	   MAX(order_approved_at) AS max_date_approved_purchase,
	   MIN(order_delivered_carrier_date) AS min_date_delivered_carrier,
	   MAX(order_delivered_carrier_date) AS max_date_delivered_carrier,
	   MIN(order_delivered_customer_date) AS min_date_delivered_customer,
	   MAX(order_delivered_customer_date) AS max_date_delivered_customer,
	   MIN(order_estimated_delivery_date) AS min_date_estimated_delivery,
	   MAX(order_estimated_delivery_date) AS max_date_estimated_delivery
FROM silver.crm_orders
/*
Date order purchase --> from 04/09/2016 to 17/10/2018
Date approved purchase --> from 15/09/2016 to 03/09/2018
Date delivered carrier --> from 08/10/2016 to 11/09/2018
Date delivered customer --> from 11/10/2016 to 17/10/2018
date estimatd delivery --> from 30/09/2016 to 12/11/2018
*/

-- Verify correctness of date sequence
SELECT order_id,
       customer_id,
       order_status,
       order_purchase_timestamp,
       order_approved_at,
       order_delivered_carrier_date,
       order_delivered_customer_date,
       order_estimated_delivery_date,
       CASE WHEN order_approved_at < order_purchase_timestamp THEN 1 ELSE 0 END AS approved_before_purchase,
       CASE WHEN order_delivered_carrier_date < order_approved_at THEN 1 ELSE 0 END AS delivered_carrier_before_approved,
       CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END AS delivered_customer_before_carrier
FROM silver.crm_orders
WHERE (order_approved_at < order_purchase_timestamp)
   OR (order_delivered_carrier_date < order_approved_at)
   OR (order_delivered_customer_date < order_delivered_carrier_date)

ORDER BY order_id;
-- no issue with approved_before_purchase
-- 1382 rows with issue about delivered_carrier_before_approved &  delivered_customer_before_carrier
-- In these cases the CRM inverted the 2 dates, so to fix it it is necessary to replace inverting dates

-- Fix when order_approved_at > order_delivered_carrier_date add 1 day because it will be sent the day after (BUSINESS RULE)
-- this rule works only when the crm make this kind of inversion
UPDATE silver.crm_orders
SET order_delivered_carrier_date = DATEADD(DAY, 1, order_approved_at)
WHERE  order_approved_at > order_delivered_carrier_date ;

-- Same fix when order_delivered_carrier_date > order_delivered_customer_date
UPDATE silver.crm_orders
SET order_delivered_customer_date = DATEADD(DAY, 1, order_delivered_carrier_date)
WHERE  order_delivered_carrier_date > order_delivered_customer_date ;
```





