# 🧹 Data Loading & Cleansing: `crm_order_reviews` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.crm_order_reviews`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

---
## Initial DDL Script to load `crm_order_reviews from broze layer (no structure changes)
```sql
IF OBJECT_ID('silver.crm_order_reviews', 'U') IS NOT NULL
		DROP TABLE silver.crm_order_reviews;
	GO

	CREATE TABLE silver.crm_order_reviews (
		review_id NVARCHAR(MAX),
		order_id NVARCHAR(MAX),
		review_score NVARCHAR(MAX),
		review_comment_title NVARCHAR(MAX),
		review_comment_message NVARCHAR(MAX),
		review_creation_date NVARCHAR(MAX),
		review_answer_timestamp NVARCHAR(MAX),
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);
	GO

⚠️ *Note:* This table was initially created with relaxed types to accommodate raw Bronze data.  
After cleaning, an `ALTER TABLE` will be used to align column types with the expected domain logic and improve performance.


	INSERT INTO silver.crm_order_reviews (
    review_id, order_id, review_score, review_comment_title, review_comment_message,
	review_creation_date, review_answer_timestamp
    )

	SELECT  review_id,
		order_id,
		review_score,
		review_comment_title,
		review_comment_message,
		review_creation_date,
		review_answer_timestamp,
	FROM bronze.crm_order_reviews;
	--Starting with 99225 rows
```
---

## ✅ Checks Summary
