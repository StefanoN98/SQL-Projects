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
| review_id                         | order_id                         | review_score | review_comment_title | review_comment_message                                                                                                                                                      | review_creation_date   | review_answer_timestamp   |
|------------------------------------|-----------------------------------|----------------|-----------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------|-----------------------------|
| 0a044c92844616a59bf4d1ea68bf75ac" | e977b374d773afa133c09a9215ed08c2 | 1            | NULL                | NULL                                                                                                                                                                         | 2017-12-20 00:00:00   | 2017-12-20 09:04:44";;;;;;       |
| ""7122dc3d9094676b780465db6b226600" | "334fe6d31dfa8c49583196dda4b260e6 | 5            | *****                | NULL                                                                                                                                                                         | 2018-05-04 00:00:00   | 2018-05-05 02:35:37       |
| "fb2e6c662f767b55033f5583b5bf77fd" | 6d9cc2a706027666e20ffb8e008de464" | 4           | embalagem em excesso | 16656526 | Muito plástico e papelão. Cade a preocupação com a sustentabilidade?"                                             | 2018-06-20 00:00:00   | "2018-06-21 12:30:16"       |
| d06e693cf25b87851321187dc9fb7bdd | 2d0805e3e830d6d2d694ee7a3aa58502 | 1            | so good               | Ainda não recebi. Não sei porque tanto atraso. Sempre compro na lannister nunca tive problemas..                                                                            | 2018-01-13 00:00:00   | 2018-01-18 09:29:13       |

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

## `review_id` cleaning
`review_id` has 32 alfanumeric characters. The rows with the following things will be eliminates:
  - review_id with only special characters
  - empty string
  - NULL strings
  - cleaned review_id with different lenght

### 1) Analyze & fix review_id lenght
```sql
SELECT  LEN(review_id) as lenght_review_id, count(*) AS counting
	FROM silver.crm_order_reviews
	GROUP BY LEN(review_id)
	ORDER by count(*) DESC
	--The correct lenght is 32. All the other lenghts are incorrect or not valid.
	
	| lenght_review_id | counting |
	|------------------|----------|
	| 32               | 77982    |
	| 33               | 20465    |
	| 34               | 256      |
	| 1                | 120      |
	| 9                | 25       |
	| 16               | 13       |
	| 19               | 12       |

	-- In particular where we have 33 there is an additional " at the beginning
	| review_id                         |
	|-----------------------------------|
	| "7122dc3d9094676b780465db6b226600 |
        | "0a044c92844616a59bf4d1ea68bf75ac |


--Replace " character at the beginning of review_id
	SELECT CASE 
		WHEN LEFT(review_id, 1) = '"' THEN SUBSTRING(review_id, 2, LEN(review_id))
		ELSE review_id
		END as review_id
	FROM silver.crm_order_reviews

	| review_id                         |
	|-----------------------------------|
	| 7122dc3d9094676b780465db6b226600  |
        | 0a044c92844616a59bf4d1ea68bf75ac  |

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


### 2) Analyze & delete review_id with a different lenght,with special characters or NULL
```sql
SELECT review_id
FROM silver.crm_order_reviews
WHERE LEN(review_id)<>32
          OR review_id COLLATE Latin1_General_BIN  LIKE '%[^a-zA-Z0-9]%'
          OR review_id IS NULL
/*
| review_id            |
|----------------------|
| "                    |
| ;;;;;;               |
| GT. KEYLA            |
| Recomendo a Loja     |
| SEM NENHUM CONTATO"  |
| ;;;;;;               |
| E aii???"            |*/

-- DELETE statement: remove rows with different lenght, special characters or NULL
DELETE FROM silver.crm_order_reviews
WHERE LEN(review_id) <> 32
	  OR review_id COLLATE Latin1_General_BIN LIKE '%[^a-zA-Z0-9]%'
          OR review_id IS NULL;
--786 rows deleted
```

### 3) Remove duplicates on cleaned `review_id`
```sql
SELECT review_id, COUNT(*) AS occurrences
FROM silver.crm_order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;


--DELETE statement, remove duplicates
WITH duplicates as(
	SELECT review_id, 
	ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY review_id) as occurences
	FROM silver.crm_order_reviews
	)
DELETE FROM duplicates
WHERE occurences > 1
--802 rows deleted
```
## però meglio questa query in teoria:
```sql
WITH duplicates AS (
    SELECT review_id, 
    ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY review_id) as occurences
    FROM silver.crm_order_reviews
)
DELETE FROM silver.crm_order_reviews
WHERE review_id IN (SELECT review_id FROM duplicates WHERE occurences > 1);
```
---

## `order_id` cleaning
  `order_id` has 32 alfanumeric characters. No special characters are allowed.
### 1 )Analyze lenght of a order_id
```sql
	SELECT  LEN(order_id) as lenght_order_id, count(*) AS counting
	FROM silver.crm_order_reviews
	GROUP BY LEN(order_id)
	ORDER by count(*) DESC
	--The correct lenght is 32, while all the orders are incorrect.

	| lenght_order_id | counting |
	|-----------------|----------|
	| 32              | 77981    |
	| 36              | 20716    |

	--In particular where we have 36 there are additional " characters at the beginning and at the end

	-- Replace " characters
	SELECT  REPLACE(order_id,'"','') as order_id
	FROM silver.crm_order_reviews

	--UPDATE statement: replace " characters
	UPDATE silver.crm_order_reviews
	SET order_id= REPLACE(order_id,'"','')
	-- Now all the order_id lenght is 32
```
---

## `review_score` cleaning
### 1) Analyze DISTINCT values
 ```sql
	SELECT DISTINCT review_score
	FROM silver.crm_order_reviews
	-- No score anomalies detected
	| review_score |
	|--------------|
	| 1            |
	| 2            |
	| 3            |
	| 4            |
	| 5            |

```
---
## `review_comment_title` & `review_comment_message` cleaning
In this case we'll not consider title or comment when we have:
  - Only numbers
  - Only special charaters
  - Less than 3 characters --> no sense title/comment

| review_comment_title | review_comment_message                 |
|----------------------|----------------------------------------|
| NULL                 | NULL                                   |
| Bm                  | "Vou ver se o produto                  |
| 1565                 | Satisfeito;;;;                         |
| NULL                 | **''                                   |


### Standardize and fix values in `review_comment_title` & `review_comment_message`
```sql
SELECT 
   CASE
      WHEN review_comment_title IS NULL OR --Check NULL values
           review_comment_title NOT LIKE '%[^0-9]%' OR  --Check only numbers
           review_comment_title NOT LIKE '%[0-9A-Za-z]%' --Check only special characters
      THEN 'No title'
      ELSE 
         CASE
            WHEN LEN(REPLACE(REPLACE(REPLACE(review_comment_title, ';', ' '), '?', ' '), '"', ' ')) < 3 THEN 'no sense' --Check too short values
            ELSE TRIM(REPLACE(REPLACE(REPLACE(review_comment_title, ';', ' '), '?', ' '), '"', ' '))
         END
   END AS review_comment_title,
   
   CASE
      WHEN review_comment_message IS NULL OR --Check NULL values
           review_comment_message NOT LIKE '%[^0-9]%' OR --Check only numbers
           review_comment_message NOT LIKE '%[0-9A-Za-z]%' --Check only special characters
      THEN 'No comment'
      ELSE 
         CASE
            WHEN LEN(REPLACE(REPLACE(REPLACE(review_comment_message, ';', ' '), '?', ' '), '"', ' ')) < 3 THEN 'no sense' --Check too short values
            ELSE TRIM(REPLACE(REPLACE(REPLACE(review_comment_message, ';', ' '), '?', ' '), '"', ' '))
         END
   END AS review_comment_message
FROM silver.crm_order_reviews;


--UPDATE statement: replace invalid titles and comment
UPDATE silver.crm_order_reviews
SET 
    review_comment_title = 
        CASE
            WHEN review_comment_title IS NULL OR
                 review_comment_title NOT LIKE '%[^0-9]%' OR
                 review_comment_title NOT LIKE '%[0-9A-Za-z]%'
            THEN 'No title'
            ELSE 
                CASE
                    WHEN LEN(REPLACE(REPLACE(REPLACE(review_comment_title, ';', ' '), '?', ' '), '"', ' ')) < 3 THEN 'no sense'
                    ELSE LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(review_comment_title, ';', ' '), '?', ' '), '"', ' ')))
                END
        END,
        
    review_comment_message = 
        CASE
            WHEN review_comment_message IS NULL OR
                 review_comment_message NOT LIKE '%[^0-9]%' OR
                 review_comment_message NOT LIKE '%[0-9A-Za-z]%'
            THEN 'No comment'
            ELSE 
                CASE
                    WHEN LEN(REPLACE(REPLACE(REPLACE(review_comment_message, ';', ' '), '?', ' '), '"', ' ')) < 3 THEN 'no sense'
                    ELSE LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(review_comment_message, ';', ' '), '?', ' '), '"', ' ')))
                END
        END;
```
---

## `review_creation_date` & `review_answer_timestamp` cleaning
Only datetime values are accepted (lenght 19), all the other results will be displayed as NULL

| review_creation_date              | review_answer_timestamp                        |
|---------------------------------|-----------------------------------------------|
| 2018-06-20 00:00:00             | 2018-06-21 12:30:16";;;;;;                     |
| Não sei porque tanto atraso      | sempre compro na lannister nunca tive problemas.."" |
| 2017-11-08 00:00:00             | 2017-11-08 15:42:33";;;;;;                     |
| produto ainda não chegou""       | 2018-03-07 00:00:00,2018-03-07 12:24:06";;;;;; |

### 1 ) Fix invalid datetime and replace them with NULL values
```sql
SELECT  CASE
		 WHEN ISDATE(LEFT(review_creation_date,19))=1 THEN LEFT(review_creation_date,19)
		 ELSE NULL
		 END AS review_creation_date,
		CASE
		 WHEN ISDATE(LEFT(review_answer_timestamp,19))=1 THEN LEFT(review_answer_timestamp,19)
		 ELSE NULL
		 END AS review_answer_timestamp
		
FROM silver.crm_order_reviews

--UPDATE statement: replace invalid datetime
UPDATE silver.crm_order_reviews
SET 
    review_creation_date = 
        CASE 
            WHEN ISDATE(LEFT(review_creation_date, 19)) = 1 THEN LEFT(review_creation_date, 19)
            ELSE NULL
        END,
        
    review_answer_timestamp = 
        CASE 
            WHEN ISDATE(LEFT(review_answer_timestamp, 19)) = 1 THEN LEFT(review_answer_timestamp, 19)
            ELSE NULL
        END;
```
### 2 ) Verify review_creation_date are earlier than review_answer_timestamp
``` sql
SELECT  
    review_creation_date,
    review_answer_timestamp,
    IIF(review_creation_date > review_answer_timestamp, 'Anomaly', 'OK') AS check_date_sequence
FROM silver.crm_order_reviews
WHERE review_creation_date > review_answer_timestamp;
--No anomalies detected
```
---
✅ Data cleaned!
## Final DDL script with the new changes for `crm_order_reviews`
Alter the initial DDL script with the new changes to optimize memory & performance
``` sql
--Change lenght review_id
ALTER TABLE silver.crm_order_reviews
ALTER COLUMN review_id NVARCHAR(50)

--Change lenght order_id
ALTER TABLE silver.crm_order_reviews
ALTER COLUMN order_id NVARCHAR(50)

--Change review_score datatype
ALTER TABLE silver.crm_order_reviews
ALTER COLUMN review_score INT

--Change lenght review_comment_title
ALTER TABLE silver.crm_order_reviews
ALTER COLUMN review_comment_title NVARCHAR(80)

--Change lenght review_comment_title
ALTER TABLE silver.crm_order_reviews
ALTER COLUMN review_comment_message NVARCHAR(500)

--Change review_score datatype
ALTER TABLE silver.crm_order_reviews
ALTER COLUMN review_creation_date DATETIME

--Change review_answer_timestamp datatype
ALTER TABLE silver.crm_order_reviews
ALTER COLUMN review_answer_timestamp DATETIME

--The updated dll script appears in this way:
CREATE TABLE silver.crm_order_reviews (
		review_id NVARCHAR(50),
		order_id NVARCHAR(50),
		review_score INT,
		review_comment_title NVARCHAR(80),
		review_comment_message NVARCHAR(500),
		review_creation_date DATETIME,
		review_answer_timestamp DATETIME,
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);
```
| review_id                          | order_id                          | review_score | review_comment_title | review_comment_message                                            | review_creation_date       | review_answer_timestamp    | dwh_create_date           |
|----------------------------------|---------------------------------|--------------|----------------------|------------------------------------------------------------------|---------------------------|----------------------------|--------------------------|
| 55e8dbe55085ca8c565f00d87dc07777 | 7b5004a23c4918b7c96c9d0cfd6107b6 | 5            | No title             | No comment                                                       | NULL                      | NULL                       | 2025-05-18 12:34:52.5966667 |
| d6c0b888949f0c3f236d67f588913930 | 4cd9478b63edacb631dcf780b036b157 | 4            | recomendo            | trabalho com profissionalismo das lojas lannister. indico com certeza | 2018-01-07 00:00:00.000   | 2018-03-07 22:47:44.000    | 2025-05-18 12:34:52.5966667 |
| 89ce1bf13facec183ff6e592ff4e305d | ada32b6f0cb6b0a58d13dc20a423f2fa | 5            | No title             | No comment                                                       | NULL                      | NULL                       | 2025-05-18 12:34:52.5966667 |

