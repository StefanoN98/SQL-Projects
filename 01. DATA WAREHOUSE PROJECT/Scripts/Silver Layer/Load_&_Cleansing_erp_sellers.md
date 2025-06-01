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
### 1) Check if there are results with not standard characters or names
```sql
SELECT *
FROM silver.erp_sellers
WHERE seller_city COLLATE Latin1_General_BIN  LIKE '%[^a-zA-Z0-9 ]%' --empty spaces are allowed
ORDER BY seller_city
-- Detected the following anomalies

/*
| seller_zip_code_prefix | seller_city                     | solution                         |
|-----------------------|--------------------------------|------------------------------------|
| 22790                 | 04482255                       | replace with rio de janeiro        |
| 86385                 | andira-pr                      | take off text after -              |
| 23943                 | angra dos reis rj              | remove last 3 characters           |
| 15350                 | auriflama/sp                   | take off text after /              |
| 29142                 | cariacica / es                 | take off text after /              |
| 12306                 | jacarei / sao paulo            | take off text after /              |
| 88501                 | lages - sc                     | take off text after -              |
| 08717                 | mogi das cruzes / sp           | take off text after /              |
| 20081                 | rio de janeiro / rio de janeiro| take off text after /              |
| 22050                 | rio de janeiro \rio de janeiro | take off text after \              |
| 04557                 | são paulo                      | replace with sao paulo             |
| 04007                 | sao paulo - sp                 | take off text after -              |
| 03407                 | sao paulo / sao paulo          | take off text after /              |
| 03581                 | sao paulop                     | replace with sao paulo             |
| 02051                 | sao pauo                       | replace with sao paulo             |
| 13790                 | sao sebastiao da grama/sp      | take off text after /              |
| 09726                 | sbc/sp                         | replace with sao bernardo do campo |
| 03363                 | sp / sp                        | replace with sao paulo             |
| 87025                 | vendas@creditparts.com.br      | replace with maringa               |
*/


-- UPDATE statement:
--	\/- will be eliminated the text after this characters (them included)
UPDATE silver.erp_sellers
SET seller_city = LEFT(seller_city, CHARINDEX('/', seller_city + '/') - 1)
WHERE seller_city LIKE '%/%';

UPDATE silver.erp_sellers
SET seller_city = LEFT(seller_city, CHARINDEX('-', seller_city + '-') - 1)
WHERE seller_city LIKE '%-%';

UPDATE silver.erp_sellers
SET seller_city = LEFT(seller_city, CHARINDEX('\', seller_city + '\') - 1)
WHERE seller_city LIKE '%\%';

-- Fix name city '04482255
UPDATE silver.erp_sellers
SET seller_city = 'rio de janeiro'
WHERE seller_zip_code_prefix = 22790;

-- Fix name city 'angra dos reis rj'
UPDATE silver.erp_sellers
SET seller_city = LEFT(seller_city, LEN(seller_city) - 3)
WHERE seller_zip_code_prefix = 23943;

-- Fix name city 'sbc/sp'
UPDATE silver.erp_sellers
SET seller_city = 'sao bernardo do campo'
WHERE seller_zip_code_prefix = 09726;

-- Fix name city 'vendas@creditparts.com.br'
UPDATE silver.erp_sellers
SET seller_city = 'maringa'
WHERE seller_zip_code_prefix = 87025;

--Replace with sao paulo
UPDATE silver.erp_sellers
SET seller_city = 'sao paulo'
WHERE seller_zip_code_prefix IN(04557 , 03581 ,  02051 , 03363, 05303);

/*Other issues detected:

| seller_zip_code_prefix | seller_city                  | solution                     |
|------------------------|------------------------------|------------------------------|
| 09687                  | ao bernardo do campo         | sao bernardo do campo        |
| 71906                  | brasilia df                  | brasilia                     |
| 15014                  | s jose do rio preto          | sao jose do rio preto        |
| 13456                  | santa barbara d oeste        | santa barbara d´oeste        |
| 05303                  | sao  paulo                   | sao paulo (extra space)      |
| 09861                  | sbc                          | sao bernardo do campo        |
| 04776                  | sp                           | sao paulo                    |
| 05141                  | sp                           | sao paulo                    |
| 12903                  | sp                           | sao paulo                    |
| 16021                  | sp                           | sao paulo                    |*/

-- Fix name city 'ao bernardo do campo ' & 'sbc'
UPDATE silver.erp_sellers
SET seller_city = 'sao bernardo do campo'
WHERE seller_zip_code_prefix IN (09687,09861)

-- Fix name city 'brasilia df'
UPDATE silver.erp_sellers
SET seller_city = 'brasilia df'
WHERE seller_zip_code_prefix = 71906

-- Fix name city 's jose do rio preto'
UPDATE silver.erp_sellers
SET seller_city = 'sao jose do rio preto'
WHERE seller_zip_code_prefix = 15014

-- Fix name city 'santa barbara d oeste'
UPDATE silver.erp_sellers
SET seller_city = 'santa barbara d´oeste'
WHERE seller_zip_code_prefix = 13456

-- Fix replacing sao paulo
UPDATE silver.erp_sellers
SET seller_city = 'sao paulo'
WHERE seller_zip_code_prefix IN (04776,05141, 12903, 16021,01207,08050)     

-- Fix with correct name city
UPDATE silver.erp_sellers
SET seller_city = 'osasco'
WHERE seller_zip_code_prefix = 06280

-- Fix with correct name city
UPDATE silver.erp_sellers
SET seller_city = 'taboao da serra'
WHERE seller_zip_code_prefix IN ( 06760, 06764)

-- Fix with correct name city
UPDATE silver.erp_sellers
SET seller_city = 'guarulhos'
WHERE seller_city = 'garulhos'

-- Fix with correct name city
UPDATE silver.erp_sellers
SET seller_city = 'aruja'
WHERE seller_zip_code_prefix = 07411

-- Fix with correct name city
UPDATE silver.erp_sellers
SET seller_city = 'santo andre'
WHERE seller_zip_code_prefix =  09190

-- Fix with correct name city
UPDATE silver.erp_sellers
SET seller_city = 'sao bernardo do campo'
WHERE seller_zip_code_prefix =  09721
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

### 2) Verify that a zip and city belong to the same country
```sql
SELECT 
    seller_zip_code_prefix,
    seller_city
FROM silver.erp_sellers
GROUP BY 
    seller_zip_code_prefix,
    seller_city
HAVING COUNT(DISTINCT seller_state) > 1;
-- 15 rows found

-- Display the result
WITH zip_city_duplicates AS (
    SELECT 
        seller_zip_code_prefix,
        seller_city
    FROM silver.erp_sellers
    GROUP BY 
        seller_zip_code_prefix,
        seller_city
    HAVING COUNT(DISTINCT seller_state) > 1
)
SELECT s.seller_zip_code_prefix,
	   s.seller_city,
	   s.seller_state
FROM silver.erp_sellers s
JOIN zip_city_duplicates d
  ON s.seller_zip_code_prefix = d.seller_zip_code_prefix
 AND s.seller_city = d.seller_city
ORDER BY s.seller_zip_code_prefix, s.seller_city;

| seller_zip_code_prefix | seller_city    | seller_state |
|------------------------|----------------|---------------|
| 21210                  | rio de janeiro | RN            |
| 21210                  | rio de janeiro | RJ            |
| 22783                  | rio de janeiro | RJ            |
| 22783                  | rio de janeiro | SP            |


--UPDATE statement: fix with the correct seller_state
-- Fix country  RJ'
UPDATE silver.erp_sellers
SET seller_state = 'RJ'
WHERE seller_zip_code_prefix IN ('21210' , '22783')

-- Fix country  'MG'
UPDATE silver.erp_sellers
SET seller_state = 'MG'
WHERE seller_zip_code_prefix  IN ('31160' , '36010' , '37795','83321','85960')

-- Fix country 'BA'
UPDATE silver.erp_sellers
SET seller_state = 'BA'
WHERE seller_zip_code_prefix  = '44600'

-- Fix country 'PR'
UPDATE silver.erp_sellers
SET seller_state = 'PR'
WHERE seller_zip_code_prefix  IN ('80240' , '81020','81560','83020')

-- Fix country 'SC'
UPDATE silver.erp_sellers
SET seller_state = 'SC'
WHERE seller_zip_code_prefix  IN ('88301', '89052')

-- Fix country 'RS'
UPDATE silver.erp_sellers
SET seller_state = 'RS'
WHERE seller_zip_code_prefix  = '95076'
```
---
✅ Data cleaned!

## Final DDL script with the new changes for `erp_sellers`
No changes necessary to apply to structure, datatype and columns of this table. Initial DDL script unchanged.
