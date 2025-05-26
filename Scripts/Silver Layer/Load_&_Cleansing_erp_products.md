# 🧹 Data Loading & Cleansing: `erp_customer` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.erp_products`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

---
## Initial DDL Script to load `erp_products` from broze layer (no structure changes)
```sql
IF OBJECT_ID('silver.erp_products', 'U') IS NOT NULL
	DROP TABLE silver.erp_products;
GO

CREATE TABLE silver.erp_products (
	product_id NVARCHAR(50),
	product_category_name NVARCHAR(100),
	product_name_length INT,
	product_description_length INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);
GO

INSERT INTO silver.erp_products(
	product_id, product_category_name,
	product_name_length, product_description_length,
	product_photos_qty, product_weight_g,
	product_length_cm, product_height_cm,
	product_width_cm
	)

SELECT  product_id,
        product_category_name,
        product_name_length,
        product_description_length,
	product_photos_qty,
	product_weight_g,
	product_length_cm,
	product_height_cm,
	product_width_cm
FROM bronze.erp_products
```
| product_id                          | product_category_name | product_name_length | product_description_length | product_photos_qty | product_weight_g | product_length_cm | product_height_cm | product_width_cm |
|------------------------------------|------------------------|---------------------|----------------------------|--------------------|------------------|-------------------|-------------------|------------------|
| 078faa63eb55a5055713e141f098624c   | automotivo             | 57                  | 597                        | 2                  | 1100             | 60                | 8                 | 33               |
| 55279b0710ffb17d56db631cb318c47a   | moveis_decoracao       | 56                  | 603                        | 1                  | 2400             | 40                | 35                | 35               |
| 0ebe8f2e60fadb8f9ebf63a5841f34f1   | cama_mesa_banho        | 49                  | 282                        | 1                  | 2783             | 65                | 14                | 46               |

---

## ✅ Checks Summary

| Type               | Category                  | Check Description                                                                 |
|--------------------|---------------------------|------------------------------------------------------------------------------------|
| **DATA INTEGRITY** | NULL Values               | Ensure `product_id` is not NULL                                                    |
|                    | Duplicates                | Check for duplicate `product_id`                                                   |
|                    | Length Validation         | Ensure `product_id` has 32 characters                                              |
|                    | NULL Values               | Identify and handle NULLs in `product_category_name`                               |
|                    | NULL Values               | Set `product_name_length`, `product_description_length`, `product_photos_qty` to 0 if NULL |
|                    | NULL Values               | Set weight/dimension columns to 0 if product info is not available                |
|                    | NULL Values               | Manually impute missing values for a specific product with similar data            |
| **DATA VALIDATION**| Category Completeness     | Replace NULL `product_category_name` with 'product_name_not_available'            |
|                    | Value Completeness        | Check maximum values of `product_name_length`, `product_description_length`, `product_photos_qty` |
| **BUSINESS RULES** | Imputation Strategy       | For missing dimensions, reuse known values from similar products                   |

---

## `product_id` cleaning
### 1) Check NULL values
```sql
SELECT product_id
FROM silver.erp_products
WHERE product_id IS NULL
-- No NULL values
```

### 2) Check duplicates
```sql
SELECT product_id,
	   COUNT(*) AS counting
FROM silver.erp_products
GROUP BY product_id
HAVING COUNT(*) > 1
-- No duplicates detected
```

### 3) Check lenght
```sql
SELECT LEN(product_id) AS lenght_product_id,
	   COUNT(*)
FROM silver.erp_products
GROUP BY LEN(product_id)
ORDER BY LEN(product_id) DESC
-- All the product_id has 32 characters
```
---

## `product_category_name` cleaning
### 1) Check distinct values
```sql
 SELECT DISTINCT product_category_name
 FROM silver.erp_products
 ORDER BY product_category_name
 -- There are NULL values
```

### 2) Check NULL values
```sql
 SELECT *
 FROM silver.erp_products
 WHERE product_category_name IS NULL
 -- 610 product_id have NULL values as product_category_name

 --UPDATE statement: NULL product_category_name will be replaced with the string 'product name not available'
 UPDATE silver.erp_products
 SET product_category_name = 'product_name_not_available'
 WHERE product_category_name IS NULL
```
---

## `product_name_length` , `product_description_length` , `product_photos_qty` cleaning
### 1) Check NULL values
```sql
SELECT product_id, 
       product_category_name,
       product_name_length ,
       product_description_length ,
       product_photos_qty
FROM silver.erp_products
WHERE  product_name_length IS NULL OR
       product_description_length IS NULL OR
       product_photos_qty IS NULL 
-- As for product_category_name we have exactly the same 610 rows where there are no info
	
--UPDATE statement: in this case we set lenght to 0 because no name, description and photos are available
UPDATE silver.erp_products
SET 	product_name_length = 0,
	product_description_length = 0,
	product_photos_qty = 0
WHERE product_category_name = 'product_name_not_available'
```


### 2) Check max lenght for each field
```sql
SELECT MAX(product_name_length) AS max_product_name_lenght ,
       MAX(product_description_length) AS max_product_description_length,
       MAX(product_photos_qty) AS max_product_photos_qty
FROM silver.erp_products
```
---

## `product_weight_g`, `product_length_cm`, `product_height_cm`, `product_width_cm` cleaning
### 1) Check NULL values
```sql
SELECT product_id,
       product_category_name,
       product_weight_g,
       product_length_cm,
       product_height_cm,
       product_width_cm
FROM silver.erp_products
WHERE  product_weight_g IS NULL OR
       product_length_cm IS NULL OR
       product_height_cm IS NULL OR
       product_width_cm IS NULL
/*2 rows detected:
 the first where product_category_name is 'product name not available',
 the second where product_category_name is 'bebes' and its product_id is 09ff539a621711667c43eba6a3bd8466*/

 --UPDATE statement: for the first case we set all the values to zero
 UPDATE silver.erp_products
SET   product_weight_g = 0,
      product_length_cm = 0,
      product_height_cm = 0,
      product_width_cm = 0
WHERE product_category_name ='product_name_not_available' AND
      (product_weight_g IS NULL OR
       product_length_cm IS NULL OR
       product_height_cm IS NULL OR
       product_width_cm IS NULL )


-- For the second case we can assign values from a random bebes product that has a similar product_id
 SELECT DISTINCT product_id,
		 product_category_name,
	    	 product_weight_g,
	   	 product_length_cm,
	   	 product_height_cm,
	   	 product_width_cm
 FROM silver.erp_products
 WHERE product_category_name = 'bebes' AND LEFT(product_id, 2) = '09'
 -- We choose the same dimensions as for the product_id = 09dbbe2c4f26cad4d560aea043f9632c

 --UPDATE statement: assign values from similar product_id
UPDATE silver.erp_products
SET 
	product_weight_g = (SELECT product_weight_g FROM silver.erp_products WHERE product_id = '09dbbe2c4f26cad4d560aea043f9632c'),
	product_length_cm = (SELECT product_length_cm FROM silver.erp_products WHERE product_id = '09dbbe2c4f26cad4d560aea043f9632c'),
	product_height_cm = (SELECT product_height_cm FROM silver.erp_products WHERE product_id = '09dbbe2c4f26cad4d560aea043f9632c'),
	product_width_cm = (SELECT product_width_cm FROM silver.erp_products WHERE product_id = '09dbbe2c4f26cad4d560aea043f9632c')
WHERE product_id = '09ff539a621711667c43eba6a3bd8466';
```
---
✅ Data cleaned!

## Final DDL script with the new changes for `erp_products`
No changes necessary to apply to structure, datatype and columns of this table. Initial DDL script unchanged.


