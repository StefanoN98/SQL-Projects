
# 🏗️ Fact View Creation & Validation: `fact_order_items` (Silver ➝ Gold Layer)

> This script defines and validates the creation of the `gold.fact_order_items` fact view from the Silver Layer.  
> The purpose is to establish a cleaned and standardized reference table for order items details

---

## Gold Layer View Creation for `fact_order_items`
```sql
IF OBJECT_ID('gold.fact_order_items', 'V') IS NOT NULL
    DROP VIEW gold.fact_order_items;
GO

CREATE VIEW gold.fact_order_items AS

WITH payments AS (
    SELECT order_id, SUM(total) AS total_payment
    FROM gold.fact_payments
    GROUP BY order_id
),
order_summaries AS (
    SELECT oi.order_id,
           SUM(oi.total_order_payment) AS total_order_payment,
           p.total_payment
    FROM silver.crm_order_items oi
    LEFT JOIN payments p
    ON oi.order_id = p.order_id
    GROUP BY oi.order_id, p.total_payment
),
delta_calc AS (
    SELECT order_id,
           total_order_payment,
           total_payment,
           CASE 
               WHEN ABS(total_order_payment - total_payment) <= 0.01 THEN 'no delta'
               WHEN total_payment > total_order_payment THEN 'Additional customs fees'
               WHEN total_payment < total_order_payment THEN 'Discount Code'
           END AS delta,
           CASE 
               WHEN ABS(total_order_payment - total_payment) <= 0.01 THEN 0
               ELSE ROUND(total_payment - total_order_payment,2)
           END AS delta_amount
    FROM order_summaries
)

SELECT 
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.shipping_limit_date,
    oi.price AS item_price,
    oi.freight_value AS item_freight_value,
    oi.total_order_payment,
    oi.shipping_type,
    dc.delta,
    dc.delta_amount
FROM silver.crm_order_items oi
LEFT JOIN delta_calc dc
ON oi.order_id = dc.order_id;
```
 
| order_id                         | order_item_id | product_id                        | seller_id                        | shipping_limit_date   | item_price | item_freight_value | total_order_payment | shipping_type     | delta                   | delta_amount |
|----------------------------------|---------------|-----------------------------------|----------------------------------|-----------------------|------------|--------------------|---------------------|-------------------|-------------------------|--------------|
| 00756576f4e494406945ac21cb82cfe0 | 1             | bfc0d01be79d9038c7720f983bf954e0  | 634964b17796e64304cadf1ad3050fb7 | 2018-02-06 02:53:55   | 137        | 15,71              | 152,71              | Standard Shipping | no delta                | 0            |
| 00772b2af35643653f108fdac1155ee3 | 1             | 85b8a24337b4e2571f8fee38f4253a06  | c3867b4666c7d76867627c2f7fb22e21 | 2017-05-02 11:05:19   | 37         | 10,96              | 47,96               | Standard Shipping | no delta                | 0            |
| 00789ce015e7e5791c7914f32bb4fad4 | 1             | f9d774a1820f792952eea079a40a7c6b  | 2709af9587499e95e803a6498a5a56e9 | 2017-07-04 23:43:34   | 154        | 14,83              | 168,83              | Standard Shipping | Additional customs fees | 21,98        |
| 0078a358a14592b887eb140ef515f5ab | 1             | 722f84416177a451c3be217ef8ffa082  | cca3071e3e9bb7d12640c9fbe2301306 | 2017-11-10 15:55:43   | 253,52     | 82,86              | 336,38              | Standard Shipping | no delta                | 0            |
| 00a870c6c06346e85335524935c600c0 | 1             | aca2eb7d00ea1a7b8ebd4e68314663af  | 955fee9216a65b617aa5c0531780ce60 | 2018-05-14 00:14:29   | 69,9       | 0                  | 69,9                | Free Shipping     | no delta                | 0            |

---

## 🔍 Data Validation & Exploratory Analysis

### 1. Overview Data
```sql
-- Let's see counting for order_id, product_id and selelr_id
SELECT 'orders_counting' AS '_metric', COUNT(DISTINCT order_id) AS '_value' FROM gold.fact_order_items 
UNION ALL
SELECT 'products_counting' AS '_metric', COUNT(DISTINCT product_id) AS '_value' FROM gold.fact_order_items 
UNION ALL
SELECT 'sellers_counting' AS '_metric', COUNT(DISTINCT seller_id) AS '_value' FROM gold.fact_order_items

| _metric          | _value |
|------------------|--------|
| orders_counting  | 98665  |
| products_counting| 32951  |
| sellers_counting | 3095   |

```

---

### 2. Referential Check
```sql
-- verify all order_id has an order_status in fact_orders
SELECT DISTINCT oi.order_id,
	   o.order_status
FROM gold.fact_order_items oi
LEFT JOIN gold.fact_orders o
ON oi.order_id=o.order_id
WHERE order_status IS NULL
-- ✅ All the order_id have a related order_status
```

---

📌 **Ready to be used as a order items fact in the Gold Layer and for BI analysis**!
