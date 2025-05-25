# 🧹 Data Loading & Cleansing: `erp_geolocation` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.erp_geolocation`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

---
## Initial DDL Script to load `erp_geolocation` from broze layer (no structure changes)
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

SELECT geolocation_zip_code_prefix,
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
| **Data Integrity**    | `geolocation_zip_code_prefix`| All values must have exactly 5 characters                                        |
|                       | `geolocation_zip_code_prefix`| Ensure it covers all zip codes present in customers and sellers tables           |
| **Standardization**   | `geolocation_city`           | Remove diacritic/special characters and lowercase standardization                |
|                       | `geolocation_city`           | Remove symbols such as `*`, `.`, `º`, `%`, `£`, `³`, and replace `-` with space  |
| **Data Integrity**    | `geolocation_state`          | Ensure all values have 2 characters only (remove trailing semicolons)            |
| **Referential Check** | `zip_code` mapping           | Verify completeness against `erp_customers` and `erp_sellers` for shared prefixes|

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
-- There are 106 distinct values with special characters in particular the majority use - that will be replaced with an empty space
-- While we'll remove the following *.º%³£

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

