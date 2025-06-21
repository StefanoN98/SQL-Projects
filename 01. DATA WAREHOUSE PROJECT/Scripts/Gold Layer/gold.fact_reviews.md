# 🏗️ Dimension View Creation & Validation: `fact_reviews` (Silver ➝ Gold Layer)

> This script creates and validates the `gold.fact_reviews` fact view.  
> The purpose is to establish a cleaned and standardized reference table for reviews.

---

## Gold Layer View Creation for `fact_reviews`
```sql
IF OBJECT_ID('gold.fact_reviews', 'V') IS NOT NULL
    DROP VIEW gold.fact_reviews;
GO

CREATE VIEW gold.fact_reviews AS
SELECT review_id,
	   order_id,
	   review_score,
	   review_comment_title,
	   review_comment_message,
	   review_creation_date,
	   review_answer_timestamp
FROM silver.crm_order_reviews
```

| review_id                           | order_id                           | review_score | review_comment_title | review_comment_message                                                                 | review_creation_date   | review_answer_timestamp     |
|------------------------------------|------------------------------------|--------------|-----------------------|----------------------------------------------------------------------------------------|-------------------------|-----------------------------|
| 7509021b9e9ee54c57408792e0a91d5b   | fb085529373f03634a84fa2358deedcd   | 5            | No title              | No comment                                                                             | 2018-07-05 00:00:00.000 | 2018-10-05 07:37:59.000     |
| bce71f23ce115a0ae6d292ffed50b0fc   | bea8e045e01a9594d652427ef4ae7236   | 5            | No title              | No comment                                                                             | 2017-06-09 00:00:00.000 | 2017-08-09 10:58:48.000     |
| 55e8dbe55085ca8c565f00d87dc07777   | 7b5004a23c4918b7c96c9d0cfd6107b6   | 5            | No title              | No comment                                                                             | NULL                    | NULL                        |
| d6c0b888949f0c3f236d67f588913930   | 4cd9478b63edacb631dcf780b036b157   | 4            | recomendo             | trabalho com profissionalismo das lojas lannister. indico com certeza                 | 2018-01-07 00:00:00.000 | 2018-03-07 22:47:44.000     |

---

## 🔍 Data Validation & Exploratory Analysis

### 1. Overview Data
```sql
SELECT 'review_counting' AS '_metric', COUNT(DISTINCT review_id) AS '_value' FROM gold.fact_reviews
UNION ALL
SELECT 'orders_counting' AS '_metric', COUNT(DISTINCT order_id) AS '_value' FROM gold.fact_reviews

| _metric         | _value |
|-----------------|--------|
| review_counting | 97372  |
| orders_counting | 97372  |
```

---

### 2. Referential Check
```sql
SELECT fr.review_id,
	   fr.order_id,
	   fo.order_id
FROM gold.fact_reviews fr
LEFT JOIN gold.fact_orders fo
ON fr.order_id=fo.order_id
WHERE fo.order_id IS NULL
-- ✅ All the review_id have at least one order related in the gold.fact_orders table
```

---
📌 **Ready to be used as a review fact in the Gold Layer and for BI analysis**!
