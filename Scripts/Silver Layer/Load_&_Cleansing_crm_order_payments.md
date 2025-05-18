# 🧹 Data Loading & Cleansing: `crm_order_payments` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.crm_order_payments`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

## Initial DDL Script to load `crm_order_payments` from broze layer (no structure changes)
```sql
IF OBJECT_ID('silver.crm_order_payments', 'U') IS NOT NULL
	DROP TABLE silver.crm_order_payments;
GO

CREATE TABLE silver.crm_order_payments (
    order_id NVARCHAR(50),
    payment_sequential INT,
    payment_type NVARCHAR(50),
    payment_installments INT,
    payment_value FLOAT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
    );
GO

INSERT INTO silver.crm_order_payments(
    order_id , payment_sequential,
    payment_type , payment_installments, payment_value 
)

SELECT 
    order_id ,
    payment_sequential,
    payment_type ,
    payment_installments,
    payment_value 
FROM bronze.crm_order_payments;
```
---

## ✅ Checks Summary

| Type                 | Category                | Check Description                                            |
|--------------------  |-------------------------|------------------------------------------------------------- |
| **DATA INTEGRITY**   | Duplicates Values       | Check for duplicates on (`order_id`, `payment_sequential`)    |
|                      | NULL Values             | Check for NULL or zero `payment_value`                       |
|                      | Distinct Values         | Check distinct values for `payment_type`                      |
|                      | Payment Value Range     | Ensure `payment_value` is valid (non-negative and non-null)   |
| **DATA CONSISTENCY** | Payment Sequence        | Ensure correct sequence of payments (`payment_sequential`)    |

---

## Check for Duplicates (`order_id`, `payment_sequential`)

```sql
SELECT order_id + '_' + CAST(payment_sequential AS nvarchar(5)) AS composite_key,
       COUNT(*)
FROM BRONZE.crm_order_payments
GROUP BY order_id + '_' + CAST(payment_sequential AS nvarchar(5))
HAVING COUNT(*) > 1;
-- No duplicates detected
```
---

## Check Distinct Payment Types

```sql
SELECT DISTINCT payment_type
FROM BRONZE.crm_order_payments;
-- No anomalies detected in payment types
```
---

## Check for Zero or NULL Payments
```sql
SELECT * 
FROM BRONZE.crm_order_payments
WHERE payment_value <= 0 OR payment_value IS NULL;
/* There are payments equal to zero where the transaction failed,
 these payments belong to the "not_defined" type and will be excluded */
```
---

## Check Payment Value Range
```sql
SELECT 
       MIN(payment_value) AS min_payment,
       MAX(payment_value) AS max_payment
FROM BRONZE.crm_order_payments;
-- Ensure all payments have a valid payment value
```
---
✅ Data cleaned!

## Final DDL script with the new changes for `crm_order_items`
No changes necessary to apply to structure, datatype and columns of this table. Initial DDL script unchanged.

