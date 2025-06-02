# 🧹 Data Loading & Cleansing: `erp_geolocation` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.erp_geolocation`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

---
## Initial DDL Script to load `erp_geolocation` from bronze layer (no structure changes)
```sql
IF OBJECT_ID('silver.erp_geolocation', 'U') IS NOT NULL
	DROP TABLE silver.erp_geolocation;
GO

CREATE TABLE silver.erp_geolocation (
	geolocation_zip_code_prefix NVARCHAR(10),
	geolocation_lat DECIMAL(18,15),
	geolocation_lng DECIMAL(18,15),
	geolocation_city NVARCHAR(50),
	geolocation_state NVARCHAR(10)
	);
GO

INSERT INTO silver.erp_geolocation (
	geolocation_zip_code_prefix, geolocation_lat,
	geolocation_lng, geolocation_city, geolocation_state
    )

SELECT  geolocation_zip_code_prefix,
	geolocation_lat,
	geolocation_lng,
	geolocation_city, 
	geolocation_state
FROM bronze.erp_geolocation
```
| geolocation_zip_code_prefix | geolocation_lat       | geolocation_lng       | geolocation_city       | geolocation_state |
|-----------------------------|-----------------------|-----------------------|------------------------|-------------------|
| 12954                       | -23.030732479548483   | -46.529689370159346   | atibaia                | SP                |
| 38779                       | -16.999281839040204   | -46.012807624452900   | brasilândia de minas   | MG                |
| 12980                       | -22.931105671093974   | -46.275134516010920   | joanopolis             | SP                |
| 01035                       | -23.541577961711493   | -46.641607223296130   | sao paulo              | SP                |
| 01012                       | -23.547762303364266   | -46.635360537884480   | são paulo              | SP                |

---

## ✅ Checks Summary
| Type                  | Column                       | Check Description                                                                |
|-----------------------|------------------------------|----------------------------------------------------------------------------------|
| **Data Integrity**    | Check Lenght                 | All `geolocation_zip_code_prefix` must have exactly 5 characters                 |
|                       | `geolocation_zip_code_prefix`| Ensure it covers all zip codes present in customers and sellers tables           |
|                       | Unwanted Characters          | Remove diacritic/special characters on `geolocation_city`                        |
|                       | Unwanted Characters          | Remove and replace symbols on `geolocation_city`                                 |
|                       | Check Lenght                 | Ensure all values have 2 characters on `geolocation_state`                       |
| **DATA CONSISTENCY**  | Referential Check            | Verify completeness against `erp_customers` and `erp_sellers` for shared prefixes|

---

## `geolocation_zip_code_prefix` cleaning
### 1) Check lenght
```sql
SELECT LEN(geolocation_zip_code_prefix) AS lenght_geolocation_zip_code_prefix,
	   COUNT(*) AS counting
FROM silver.erp_geolocation
GROUP BY LEN(geolocation_zip_code_prefix)
ORDER BY LEN(geolocation_zip_code_prefix) DESC
-- All the geolocation_zip_code_prefix has 5 characters
```

## `geolocation_city` cleaning
### 1) Check if there are results with not standard characters (foreign characters)
```sql
SELECT *
FROM silver.erp_geolocation
WHERE geolocation_city COLLATE Latin1_General_BIN  LIKE '%[^a-zA-Z0-9 ]%' --empty spaces are allowed
ORDER BY geolocation_city
-- there are a lot of rows where the name of the city is written with foreign and special characters

| geolocation_city |
|------------------|
| abadiânia        |
| abaeté           |
| açailândia       |
| acarà            |

--Let see how to standardize foreign characters with TRANSLATE
SELECT 
    geolocation_city AS original_city,
    LOWER(
		TRANSLATE(
			geolocation_city,
			'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñ',
			'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuCcNn'
			 ) 
		)AS normalized_city
FROM silver.erp_geolocation
WHERE geolocation_city COLLATE Latin1_General_BIN LIKE '%[^a-zA-Z ]%';

-- UPDATE statement: replace all the foreign characters with the alfabetic standard
UPDATE silver.erp_geolocation
SET geolocation_city = LOWER(
    TRANSLATE(
        geolocation_city,
        'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñ',
        'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuCcNn'
    )
)
WHERE geolocation_city COLLATE Latin1_General_BIN LIKE '%[^a-zA-Z ]%';
-- 76796 rows involved
```

### 2) Check if there are results with not standard characters (special characters)
```sql
SELECT DISTINCT geolocation_city
FROM silver.erp_geolocation
WHERE geolocation_city COLLATE Latin1_General_BIN  LIKE '%[^a-zA-Z0-9 ]%' --empty spaces are allowed
ORDER BY geolocation_city
-- There are 106 distinct values with special characters
-- in particular the majority use - that will be replaced with an empty space
-- While we'll remove the following *.º%³£

| geolocation_city                |
|---------------------------------|
| são joão do pau d%26apos%3balho |
| sa£o paulo                      |
| lambari d%26apos%3boeste        |
| ...arraial do cabo              |
| * cidade                        |

-- UPDATE statement:remove the following characters -->  *.º%³£
UPDATE silver.erp_geolocation
SET geolocation_city = REPLACE(
	REPLACE(
	REPLACE(
    REPLACE(
    REPLACE(
    REPLACE(
    REPLACE(geolocation_city, '-', ' '),
    '*', ''),
    '.', ''),
    'º', ''),
    '%', ''),
    '£', ''),
    '³', '')
WHERE geolocation_city COLLATE Latin1_General_BIN  LIKE '%[^a-zA-Z0-9 ]%'
```
---

## `geolocation_state` cleaning
### 1) Check lenght
```sql
SELECT LEN(geolocation_state) AS lenght_geolocation_state,
	   COUNT(*) AS counting
FROM silver.erp_geolocation
GROUP BY LEN(geolocation_state)
ORDER BY LEN(geolocation_state) DESC
-- Everything has 3 characters because there is an additional ; at the end

|geolocation_state|
|-----------------|
| SP;             |
| MG;             |
| PA;             |

--UPDATE statement: remove ; at the end
UPDATE silver.erp_geolocation
SET geolocation_state = TRIM(';' FROM geolocation_state)
WHERE geolocation_state LIKE '%;%';
```

--2) Associate correct state using GetStatoFromZipPrefix Function
```sql
UPDATE silver.erp_geolocation
SET geolocation_state = dbo.GetStatoFromZipPrefix(LEFT(geolocation_zip_code_prefix, 3));
-- All geolocation_state are correctly settled based on the geolocation_zip_code_prefix
```
---

## Referential check on `geolocation_zip_code_prefix`
### Verify that geolocation table has all the `geolocation_zip_code_prefix` compared to customers and sellers tables
In the gold layer we'll create an unique dim table with the zip, city and state information,so now we just check if there are missing values from erp_geolocation table that will represent the base table
```sql
-- Check on customers table
SELECT DISTINCT
    	c.customer_zip_code_prefix,
	c.customer_city,
	c.customer_state
FROM silver.erp_customers c
LEFT JOIN silver.erp_geolocation g
ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL
ORDER BY c.customer_zip_code_prefix;
-- 157 zip_code to add


-- Check on sellers table
SELECT DISTINCT
    	s.seller_zip_code_prefix,
	s.seller_city,
	s.seller_state
FROM bronze.erp_sellers s
LEFT JOIN silver.erp_geolocation g
ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL
ORDER BY s.seller_zip_code_prefix;
-- 7 zip_code to add

-- we'll integrate those values in an unique dim table in the gold layer
```
---
✅ Data cleaned!

## Final DDL script with the new changes for `erp_geolocation`
No changes necessary to apply to structure, datatype and columns of this table. Initial DDL script unchanged.
