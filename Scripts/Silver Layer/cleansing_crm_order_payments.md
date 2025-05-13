# 🧹 Data Cleansing: `crm_order_payments` (Bronze Layer)

> This script performs data quality checks and cleansing operations on the `bronze.crm_order_payments` table before promoting the data to the **Silver Layer**.  
> The goal is to ensure that all records are complete, clean, and logically consistent prior to transformation and standardization.

---

## ✅ Checks Summary

| Type               | Category                | Check Description                                            |
|--------------------|-------------------------|------------------------------------------------------------- |
| **DATA INTEGRITY** | Duplicates Values       | Check for duplicates on (`order_id`, `payment_sequential`)    |
|                    | NULL Values             | Check for NULL or zero `payment_value`                       |
|                    | Distinct Values         | Check distinct values for `payment_type`                      |
|                    | Payment Value Range     | Ensure `payment_value` is valid (non-negative and non-null)   |
|                    | Payment Sequence        | Ensure correct sequence of payments (`payment_sequential`)    |

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

## Pivot Tables
For each row there will be an unique order_id,
	the sequence in case of multiple payments, the payment value for each payment type
	and the total.
	
```sql
WITH payments_cte AS (
    SELECT 
        order_id,
        payment_type,
        payment_value
    FROM bronze.crm_order_payments
),
pivoted AS (
    SELECT 
        order_id,
        ISNULL([credit_card], 0) AS credit_card,
        ISNULL([debit_card], 0) AS debit_card,
        ISNULL([boleto], 0) AS boleto,
        ISNULL([voucher], 0) AS voucher,
        -- Total column (sum of all payment types)
        ISNULL([credit_card], 0) +
        ISNULL([debit_card], 0) +
        ISNULL([boleto], 0) +
        ISNULL([voucher], 0) AS total
    FROM payments_cte
    PIVOT (
        SUM(payment_value)
        FOR payment_type IN ([credit_card],[debit_card],[boleto],[voucher])
    ) AS p
),
payment_sequence AS (
    SELECT 
        order_id,
        STRING_AGG(payment_type, N' → ') WITHIN GROUP (ORDER BY payment_sequential) AS payment_sequence
    FROM bronze.crm_order_payments
    GROUP BY order_id
)

-- Final result: pivot + sequence column
SELECT 
    p.order_id, s.payment_sequence,
    p.credit_card, p.debit_card, p.boleto, p.voucher, p.total
FROM pivoted p
JOIN payment_sequence s ON p.order_id = s.order_id;
```
---

## Check for Duplicates in Pivot Table
```sql
WITH payments_cte AS (
    SELECT 
        order_id,
        payment_type,
        payment_value
    FROM bronze.crm_order_payments
),
pivoted AS (
    SELECT 
        order_id,
        ISNULL([credit_card], 0) AS credit_card,
        ISNULL([debit_card], 0) AS debit_card,
        ISNULL([boleto], 0) AS boleto,
        ISNULL([voucher], 0) AS voucher,
        -- Total column (sum of all payment types)
        ISNULL([credit_card], 0) +
        ISNULL([debit_card], 0) +
        ISNULL([boleto], 0) +
        ISNULL([voucher], 0) AS total
    FROM payments_cte
    PIVOT (
        SUM(payment_value)
        FOR payment_type IN ([credit_card],[debit_card],[boleto],[voucher])
    ) AS p
),
payment_sequence AS (
    SELECT 
        order_id,
        STRING_AGG(payment_type, N' → ') WITHIN GROUP (ORDER BY payment_sequential) AS payment_sequence
    FROM bronze.crm_order_payments
    GROUP BY order_id
),

pivot_result AS (
    -- Final result: pivot + sequence column
    SELECT 
        p.order_id, s.payment_sequence,
        p.credit_card, p.debit_card, p.boleto, p.voucher, p.total
    FROM pivoted p
    JOIN payment_sequence s ON p.order_id = s.order_id
)
-- Check for duplicates in pivoted table
SELECT order_id, COUNT(*) AS occurrences
FROM pivot_result
GROUP BY order_id
HAVING COUNT(*) > 1;
-- No duplicates detected
```
---

# DLL Script to load `crm_order_payments` in Silver Layer
```sql
CREATE TABLE silver.crm_order_payment (
    order_id  NVARCHAR(50),
    payment_sequence NVARCHAR(200),
    credit_card FLOAT,
    debit_card FLOAT,
    boleto FLOAT,
    voucher FLOAT,
    total FLOAT,
);

INSERT INTO silver.crm_order_payment(
   order_id, payment_sequence, credit_card,debit_card,
   boleto, voucher, total
)
WITH payments_cte AS (
    SELECT 
        order_id,
        payment_type,
        payment_value
    FROM bronze.crm_order_payments
),
pivoted AS (
    SELECT 
        order_id,
        ISNULL([credit_card], 0) AS credit_card,
        ISNULL([debit_card], 0) AS debit_card,
        ISNULL([boleto], 0) AS boleto,
        ISNULL([voucher], 0) AS voucher,
        ISNULL([credit_card], 0) +
        ISNULL([debit_card], 0) +
        ISNULL([boleto], 0) +
        ISNULL([voucher], 0) AS total
    FROM payments_cte
    PIVOT (
        SUM(payment_value)
        FOR payment_type IN ([credit_card],[debit_card],[boleto],[voucher])
    ) AS p
),
payment_sequence AS (
    SELECT 
        order_id,
        STRING_AGG(payment_type, N' → ') 
        WITHIN GROUP (ORDER BY payment_sequential) AS payment_sequence
    FROM bronze.crm_order_payments
    GROUP BY order_id
)
SELECT 
    p.order_id, s.payment_sequence,
    p.credit_card, p.debit_card, p.boleto, p.voucher, p.total
FROM pivoted p
JOIN payment_sequence s ON p.order_id = s.order_id;
```

---

