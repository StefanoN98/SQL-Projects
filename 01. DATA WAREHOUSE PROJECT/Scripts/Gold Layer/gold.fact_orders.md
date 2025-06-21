# 🏗️ Dimension View Creation & Validation: `fact_orders` (Silver ➝ Gold Layer)

> This script defines and validates the creation of the `gold.fact_orders` fact view from the Silver Layer.  
> The purpose is to establish a cleaned and standardized reference table for orders.

---

## Gold Layer View Creation for `fact_orders`
```sql
IF OBJECT_ID('gold.fact_orders', 'V') IS NOT NULL
    DROP VIEW gold.fact_orders;
GO

CREATE VIEW gold.fact_orders AS
SELECT order_id,
	   customer_id,
	   order_status,
	   order_purchase_timestamp,
	   order_approved_at,
	   order_delivered_carrier_date,
	   order_delivered_customer_date,
	   CAST(order_estimated_delivery_date AS date) AS order_estimated_delivery_date
FROM silver.crm_orders
```

| order_id                             | customer_id                     | order_status | order_purchase_timestamp  | order_approved_at         | order_delivered_carrier_date | order_delivered_customer_date | order_estimated_delivery_date |
|-------------------------------------|----------------------------------|--------------|---------------------------|---------------------------|------------------------------|-------------------------------|-------------------------------|
| bcbca462c055855afe0cb0df7b6a09f9    | 2ff3d530fd1c82961515acd088731097 | delivered    | 2018-03-12 17:26:02.000   | 2018-03-12 17:35:54.000   | 2018-03-13 23:12:23.000      | 2018-04-13 14:56:36.000       | 2018-04-03                    |
| 9da8ef7171b203799d1fac783097c70d    | 7186174ecd4121c35219e1874fc4eb48 | delivered    | 2018-06-04 20:07:58.000   | 2018-06-05 20:12:17.000   | 2018-06-06 14:41:00.000      | 2018-06-13 15:08:58.000       | 2018-07-11                    |
| 68ebbbf9a7236276c1c324a5c4abbcbf    | aa119c06a32aab3118de467432757566 | delivered    | 2017-10-16 01:53:47.000   | 2017-10-16 02:07:35.000   | 2017-10-16 21:13:04.000      | 2017-10-25 18:49:59.000       | 2017-11-03                    |
| c02a5571a92c4122218c6471c440567a    | 67de99df30be5012ce8bfd6501f3c8b4 | delivered    | 2017-07-26 08:58:54.000   | 2017-07-26 09:05:16.000   | 2017-07-26 14:32:55.000      | 2017-08-03 20:32:46.000       | 2017-08-17                    |

---

## 🔍 Data Validation & Exploratory Analysis

### 1. Overview Data
```sql
SELECT 'orders_counting' AS '_metric', COUNT(DISTINCT order_id) AS '_value' FROM gold.fact_orders
UNION ALL
SELECT 'customers_counting' AS '_metric', COUNT(DISTINCT customer_id) AS '_value' FROM gold.fact_orders
/*The result is expected because each line of this table represents an unique order.The 2 values match because
each order has associated an unique customer_id (that doesn't represent the customer but only the relation with
dim_customer view)*/

| _metric             | _value |
|---------------------|--------|
| orders_counting     | 99440  |
| customers_counting  | 99440  |

```
---

### 2. Referential Check
```sql
-- Verify all `order_id` have a related payment, order items
SELECT fo.order_id AS order_id_orders_table,
	   oi.order_id AS order_id_orders_itmes_table,
	   fp.order_id AS order_id_payment_table,
	   fo.order_status
FROM gold.fact_orders fo
LEFT JOIN gold.fact_order_items oi
ON fo.order_id= oi.order_id
LEFT JOIN gold.fact_payments fp
ON fo.order_id=fp.order_id
WHERE oi.order_id IS NULL OR fp.order_id IS NULL
ORDER BY fo.order_id;
/* ✅ There are 775 order_id not present in fact_order_items table, but it is correct since
the order_status in this case in unavailable or canceled*/
```
---


📌 **Ready to be used as a orders fact in the Gold Layer and for BI analysis**!



