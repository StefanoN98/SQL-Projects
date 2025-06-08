# 🏗️ Dimension View Creation & Validation: `fact_payments` (Silver ➝ Gold Layer)

> This script defines and validates the creation of the `gold.fact_payments` fact view from the Silver Layer.  
> The purpose is to establish a cleaned and standardized reference table for payments.

---

## Gold Layer View Creation for `fact_payments`
```sql
IF OBJECT_ID('gold.fact_payments', 'V') IS NOT NULL
    DROP VIEW gold.fact_payments;
GO

CREATE VIEW gold.fact_payments AS

WITH payments_cte AS (
    SELECT 
        order_id,
        payment_type,
        payment_value
    FROM silver.crm_order_payments
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
        STRING_AGG(payment_type, N' → ') WITHIN GROUP (ORDER BY payment_sequential) AS payment_sequence
    FROM silver.crm_order_payments
    GROUP BY order_id
)

-- Final result: pivot + sequence column
SELECT 
    p.order_id, s.payment_sequence,
    p.credit_card, p.debit_card, p.boleto, p.voucher, p.total
FROM pivoted p
JOIN payment_sequence s ON p.order_id = s.order_id;
```

| order_id                         | payment_sequence         | credit_card | debit_card | boleto | voucher | total  |
|----------------------------------|--------------------------|-------------|------------|--------|---------|--------|
| 00276d5c3491fbf55305e26891040df9 | credit_card              | 68,12       | 0          | 0      | 0       | 68,12  |
| 002f19a65a2ddd70a090297872e6d64e | voucher → voucher        | 0           | 0          | 0      | 77,29   | 77,29  |
| 0016dfedd97fc2950e388d2971d718c7 | credit_card → voucher    | 52,63       | 0          | 0      | 17,92   | 70,55  |
| 0020a222f55eb79a372d0efee3cca688 | credit_card              | 45,09       | 0          | 0      | 0       | 45,09  |
| 00335b686d693c7d72deeb12f8e89227 | boleto                   | 0           | 0          | 80,79  | 0       | 80,79  |

---

## 🔍 Data Validation & Exploratory Analysis

### 1. Overview Data
```sql
SELECT 'orders_counting' AS _metric, CAST(COUNT(DISTINCT order_id) AS varchar)+' total orders' AS _value FROM gold.fact_payments
UNION ALL
SELECT 'min_payment' AS _metric, CAST(MIN(total) AS varchar)+' €'  AS _value FROM gold.fact_payments
UNION ALL
SELECT 'avg_payment' AS _metric, CAST(ROUND(AVG(total),2) AS varchar)+' €' AS _value FROM gold.fact_payments
UNION ALL
SELECT 'max_payment' AS _metric, CAST(MAX(total) AS varchar)+' €' AS _value FROM gold.fact_payments

| _metric         | _value              |
|-----------------|---------------------|
| orders_counting | 99,440 total orders |
| min_payment     | 0 €                 |
| avg_payment     | 160.99 €            |
| max_payment     | 13,664.10 €         |
```

### 2. Referential Check
```sql
-- Verify every order_id has associated an order_status with the fact_orders table
SELECT fp.order_id,
	     co.order_status
FROM gold.fact_payments fp
LEFT JOIN silver.crm_orders co --da rifare con tabella gold
ON fp.order_id=co.order_id
WHERE co.order_status IS NULL
-- ✅ All the payments are associated to an order status


-- Verify all order_id with a payment are present in order_items fact table
SELECT fp.order_id,
	   fp.total,
	   co.order_status
FROM gold.fact_payments fp
LEFT JOIN silver.crm_orders co -- da rifare con tabella gold
ON fp.order_id=co.order_id
WHERE fp.order_id NOT IN (
		SELECT order_id
		FROM silver.crm_order_items -- da rifare con tabella gold
		)
-- There are 775 orders with no order_items associated, because the order_status was unavailable or canceled

| order_id                         | total   | order_status  |
|----------------------------------|---------|---------------|
| b91dd40b68675f4dc29339562895ca26 | 42,9    | unavailable   |
| d49363a0cc2a1915a5a11f85ea08ea48 | 102,66  | unavailable   |
| ef3b75eae01e343f3d7c05e88a9cc496 | 33,01   | unavailable   |
| 1e9cdb2ee26ee17ecb5f050a180cf8ff | 147,48  | unavailable   |

-- ✅ So all the others are correct and with at least one item associated
```

### 3. Data Correcteness
```sql
-- Check for duplicates in pivoted table
SELECT order_id, COUNT(*) AS occurrences
FROM gold.fact_payments
GROUP BY order_id
HAVING COUNT(*) > 1;
-- ✅ No duplicates detected
```

---

📌 **Ready to be used as a products dimension in the Gold Layer and for BI analysis**!
