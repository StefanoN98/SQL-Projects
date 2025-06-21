# 🧹 Data Loading & Cleansing: `crm_order_payments` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.crm_order_payments`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

## Initial DDL Script to load `crm_order_payments` from bronze layer (no structure changes)
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
| order_id                             | payment_sequential  | payment_type | payment_installments | payment_value    | dwh_date                   |
|--------------------------------------|---------------------|--------------|----------------------|------------------|----------------------------|
| 0015ebb40fb17286bea51d4607c4733c     | 1                   | credit_card  | 1                    | 37    	      | 2025-05-18 16:05:38.573333 |
| 00169e31ef4b29deaae414f9a5e95929     | 1                   | boleto       | 1        		   | 55,11 	      | 2025-05-18 16:05:38.573333 |
| 0016dfedd97fc2950e388d2971d718c7     | 1                   | credit_card  | 5         	   | 52,63  	      | 2025-05-18 16:05:38.573333 |
| 0016dfedd97fc2950e388d2971d718c7     | 2                   | voucher      | 1       		   | 17,92            | 2025-05-18 16:05:38.573333 |

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

## Check Duplicates (`order_id`, `payment_sequential`)

```sql
SELECT order_id + '_' + CAST(payment_sequential AS nvarchar(5)) AS composite_key,
       COUNT(*)
FROM silver.crm_order_payments
GROUP BY order_id + '_' + CAST(payment_sequential AS nvarchar(5))
HAVING COUNT(*) > 1;
-- No duplicates detected
```
---

## Check Distinct Payment Types (`payment_type`)

```sql
SELECT DISTINCT payment_type
FROM silver.crm_order_payments;
-- No anomalies detected in payment types

| payment_type |
|--------------|
| credit_card  |
| boleto       |
| voucher      |
| debit_card   |
| not_defined  |
```
---

## `payment_value` cleaning
### 1) Check for Zero or NULL Payments
```sql
SELECT * 
FROM silver.crm_order_payments
WHERE payment_value <= 0 OR payment_value IS NULL;
/* There are payments equal to zero where the transaction failed,
these payments belong to the "not_defined" or "voucher" type.
They will be kept to understand and respect the payments sequence*/

| order_id                          | payment_sequential  | payment_type | payment_installments  | payment_value  |
|-----------------------------------|---------------------|--------------|-----------------------|----------------|
| 8bcbe01d44d147f901cd3192671144db  | 4                   | voucher      | 1                     | 0              |
| fa65dad1b0e818e3ccc5cb0e39231352  | 14                  | voucher      | 1                     | 0              |
| 6ccb433e00daae1283ccc956189c82ae  | 4                   | voucher      | 1                     | 0              |
| 4637ca194b6387e2d538dc89b124b0ee  | 1                   | not_defined  | 1                     | 0              |
| 00b1cb0320190ca0daa2c88b35206009  | 1                   | not_defined  | 1                     | 0              |
| 45ed6e85398a87c253db47c2d9f48216  | 3                   | voucher      | 1                     | 0              |
| fa65dad1b0e818e3ccc5cb0e39231352  | 13                  | voucher      | 1                     | 0              |
| c8c528189310eaa44a745b8d9d26908b  | 1                   | not_defined  | 1                     | 0              |
| b23878b3e8eb4d25a158f57d96331b18  | 4                   | voucher      | 1                     | 0              |

```
---

### 2) Check Payment Value Range
```sql
SELECT 
       MIN(payment_value) AS min_payment,
       MAX(payment_value) AS max_payment
FROM silver.crm_order_payments;
-- Ensure all payments have a valid payment value--> no negative payments
```
---
✅ Data cleaned!

## Final DDL script with the new changes for `crm_order_items`
No changes necessary to apply to structure, datatype and columns of this table. Initial DDL script unchanged.

