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

| **Type**         | **Category**              | **Check Description**                                                                 |
|------------------|---------------------------|----------------------------------------------------------------------------------------|
| **DATA INTEGRITY** | Review ID Length          | Validate that `review_id` has exactly 32 alphanumeric characters                      |
|                  | Special Characters in ID   | Remove `review_id` with invalid or non-alphanumeric characters                         |
|                  | Empty / NULL `review_id`   | Delete rows where `review_id` is empty or NULL                                        |
|                  | Duplicates                 | Remove duplicate records based on `review_id` using `ROW_NUMBER()`                   |
|                  | Order ID Cleanup           | Remove extraneous quotes from `order_id` and enforce 32-char alphanumeric rule        |
| **DATA VALIDATION** | Score Validity            | Ensure `review_score` contains valid values only                                      |
|                  | Title & Message Quality    | Replace meaningless values (e.g., only numbers, too short, special chars)             |
|                  | Title/Message Normalization| Replace NULLs or invalid with `'No title'`, `'No comment'`, or `'no sense'`           |
| **FORMAT & TYPE**  | Whitespace Cleanup         | Remove double quotes and unwanted characters from text fields                         |
|                  | Timestamp Format           | Validate and convert date strings to proper `DATETIME` (length = 19)                 |
| **LOGICAL CHECKS** | Date Sequence Validation   | Ensure `review_creation_date` < `review_answer_timestamp`                             |
| **PERFORMANCE**    | Column Type Optimization   | Use `ALTER TABLE` to shrink column types and improve storage & indexing              |

---

## review_id cleaning
review_id has 32 alfanumeric characters. The rows with the following things will be eliminates:
  - review_id with only special characters
  - empty string
  - NULL strings
  - cleaned review_id with different lenght

### 1) Analyze & fix review_id lenght
```sql
SELECT  LEN(review_id) as lenght_review_id, count(*)
	FROM silver.crm_order_reviews
	GROUP BY LEN(review_id)
	ORDER by count(*) DESC
	/*The correct lenght is 32. All the other lenghts are incorrect or not valid.
	In particular where we have 33 there is an additional " at the beginning*/


--Replace " character at the beginning of review_id
	SELECT CASE 
		WHEN LEFT(review_id, 1) = '"' THEN SUBSTRING(review_id, 2, LEN(review_id))
		ELSE review_id
		END as review_id
	FROM silver.crm_order_reviews

--UPDATE statement: replacing " at the beginning
	UPDATE silver.crm_order_reviews
	SET review_id = 
		CASE 
		 WHEN LEFT(review_id, 1) = '"' THEN SUBSTRING(review_id, 2, LEN(review_id))
		 ELSE review_id
		END
	WHERE LEFT(review_id, 1) = '"';
	--20629 rows interested
```


