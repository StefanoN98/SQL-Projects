# 🧹 Data Loading & Cleansing: `erp_sellers` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.erpsellers`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

---
## Initial DDL Script to load `erp_sellers` from broze layer (no structure changes)
```sql
IF OBJECT_ID('silver.erp_sellers', 'U') IS NOT NULL
	DROP TABLE silver.erp_sellers;
GO

CREATE TABLE silver.erp_sellers(
	seller_id NVARCHAR(50),
	seller_zip_code_prefix NVARCHAR(10),
	seller_city NVARCHAR(50),
	seller_state NVARCHAR(10)
);
GO

INSERT INTO silver.erp_sellers(
	seller_id, seller_zip_code_prefix,
	seller_city, seller_state
	)

SELECT seller_id,
       seller_zip_code_prefix,
       seller_city,
       seller_state
FROM bronze.erp_sellers
```
| seller_id                            | seller_zip_code_prefix | seller_city        | seller_state |
|--------------------------------------|------------------------|--------------------|--------------|
| 51a04a8a6bdcb23deccc82b0b80742cf     | 12914                  | braganca paulista  | SP           |
| c240c4061717ac1806ae6ee72be3533b     | 20920                  | rio de janeiro     | RJ           |
| e49c26c3edfa46d227d5121a6b6e4d37     | 55325                  | brejao             | PE           |
| 1b938a7ec6ac5061a66a3766e0e75f90     | 16304                  | penapolis          | SP           |

---

## ✅ Checks Summary

| Type               | Category             | Check Description                                                                  |
|--------------------|----------------------|------------------------------------------------------------------------------------|
| **DATA INTEGRITY** | NULL Values          | Ensure `seller_id` has no NULL values                                              |
|                    | Duplicates           | Check that `seller_id` is unique                                                   |
|                    | Length Validation    | Confirm `seller_id` has exactly 32 characters                                      |
|                    | Length Validation    | Ensure `seller_zip_code_prefix` is 5 characters                                    |
|                    | Length Validation    | Confirm `seller_state` is 2 characters only                                        |
| **DATA VALIDATION**| Character Cleaning   | Remove special characters (`/`, `-`, `\`) and trim values in `seller_city`         |
|                    | Unicode Normalization| Replace foreign characters like `âã` with standard letters in `seller_city`        |
| **STANDARDIZATION**| Value Formatting     | Truncate extra text after `/`, `-`, or `\` in `seller_city`                        |
|                    | Value Correction     | Convert `brasil,RS` → `RS` in `seller_state`                                       |


---

## `seller_id` cleaning
### 1) Check NULL values
```sql
SELECT seller_id
FROM silver.erp_sellers
WHERE seller_id IS NULL
-- No NULL values
```

### 2) Check duplicates
```sql
 SELECT seller_id,
	   COUNT(*) AS counting
FROM silver.erp_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1
-- No duplicates detected
```

### 3) Check lenght
```sql
SELECT LEN(seller_id) AS lenght_seller_id,
	   COUNT(*)
FROM silver.erp_sellers
GROUP BY LEN(seller_id)
ORDER BY LEN(seller_id) DESC
-- All the seller_id has 32 characters
```
---

##  `seller_zip_code_prefix` cleaning
### 1) Verify the zip code prefix lenght is 5
```sql
SELECT LEN(seller_zip_code_prefix) AS lenght_seller_zip_code_prefix,
	   COUNT(*)
FROM silver.erp_sellers
GROUP BY LEN(seller_zip_code_prefix)
ORDER BY LEN(seller_zip_code_prefix) DESC
-- All the prefix have lenght 5
```
---

##  `seller_city` cleaning
### 1) Check if there are results with not standard characters
```sql
SELECT *
FROM silver.erp_sellers
WHERE seller_city COLLATE Latin1_General_BIN  LIKE '%[^a-zA-Z0-9 ]%' --empty spaces are allowed
ORDER BY seller_city
-- Detected the following special characters /- and this foreign character âã

| seller_city               |
|---------------------------|
| andira-pr                 | 
| ribeirao preto / sao paulo|
| lages - sc                |
| são paulo                 |


-- UPDATE statement:
--	/ will be eliminated the text after this characters (/ included)
UPDATE silver.erp_sellers
SET seller_city = LEFT(seller_city, CHARINDEX('/', seller_city + '/') - 1)
WHERE seller_city LIKE '%/%';

-- - will be eliminated the text after this characters (- included)
UPDATE silver.erp_sellers
SET seller_city = LEFT(seller_city, CHARINDEX('-', seller_city + '-') - 1)
WHERE seller_city LIKE '%-%';

-- \ will be eliminated the text after this characters (\ included)
UPDATE silver.erp_sellers
SET seller_city = LEFT(seller_city, CHARINDEX('\', seller_city + '\') - 1)
WHERE seller_city LIKE '%\%';

-- âã will be replaced with a
UPDATE silver.erp_sellers
SET seller_city = REPLACE(
		  REPLACE(seller_city, 'ã','a'),
                  'â', 'a')
WHERE seller_city COLLATE Latin1_General_BIN  LIKE '%[^a-zA-Z0-9 ]%';
```
---

## `seller_state` cleaning
### 1) Check lenght
```sql
SELECT LEN(seller_state) AS lenght_seller_state,
	   COUNT(*) AS Counting
FROM silver.erp_sellers
GROUP BY LEN(seller_state)
ORDER BY LEN(seller_state) DESC
-- There are 2 values with lengh 10, in these cases there is also the state name

|seller_state|
|------------|
|brasil,RS   |
|brasil,RJ   |

-- UPDATE statement: keep only the last 2 characters
UPDATE silver.erp_sellers
SET seller_state= RIGHT(seller_state,2)
WHERE LEN(seller_state)> 2
```
---
✅ Data cleaned!

## Final DDL script with the new changes for `erp_sellers`
No changes necessary to apply to structure, datatype and columns of this table. Initial DDL script unchanged.
