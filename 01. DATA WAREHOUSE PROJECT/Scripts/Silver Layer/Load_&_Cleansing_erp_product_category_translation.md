# 🧹 Data Loading & Cleansing: `erp_product_category_translation` (Bronze ➝ Silver Layer)


> This script performs data quality checks and cleansing operations on the `silver.erp_product_category_translation`.  
> The goal is to ensure that all records are complete, clean, and logically consistent.

---
## Initial DDL Script to load `erp_product_category_translation` from bronze layer (no structure changes)
```sql
IF OBJECT_ID('silver.erp_product_category_translation', 'U') IS NOT NULL
	DROP TABLE silver.erp_product_category_translation;
GO

CREATE TABLE silver.erp_product_category_translation (
	product_category_name NVARCHAR(100),
	product_category_name_english NVARCHAR(100)
	);
GO

INSERT INTO silver.erp_product_category_translation(
	 product_category_name,
	 product_category_name_english
 )

SELECT product_category_name,
       product_category_name_english
FROM bronze.erp_product_category_translation
```
| product_category_name | product_category_name_english |
|-----------------------|-------------------------------|
| beleza_saude          | health_beauty                 |
| informatica_acessorios| computers_accessories         |
| automotivo            | auto                          |
| cama_mesa_banho       | bed_bath_table                |
| moveis_decoracao      | furniture_decor               |
| esporte_lazer         | sports_leisure                |
| perfumaria            | perfumery                     |

---

## ✅ Checks Summary


| Type                  | Category                  | Check Description                                                                   |
|-----------------------|---------------------------|-------------------------------------------------------------------------------------|
| **DATA INTEGRITY**    | NULL / Missing Values     | Check for missing `product_category_name_english` in translation table              |
| **REFERENTIAL**       | Cross-table Consistency   | Ensure all `product_category_name` in `erp_products` have corresponding translation |
| **DATA COMPLETENESS** | Manual Enrichment         | Add missing translations for uncovered categories (`pc_gamer`, etc.)                |


---

## 1) Verify completeness with erp_products table
```sql
SELECT DISTINCT p.product_category_name,
	   pt.product_category_name_english
FROM silver.erp_products p
LEFT JOIN silver.erp_product_category_translation pt
ON p.product_category_name= pt.product_category_name
WHERE product_category_name_english IS NULL
-- There are 3 rows without the corresponding translation:

|p.product_category_name                         |pt.product_category_name_english|
|---------------------------------------------------------------------------------|
|pc_gamer	                                 |NULL                            |
|portateis_cozinha_e_preparadores_de_alimentos   |NULL                            |
|product_name_not_available	                 |NULL                            |

--INSERT INTO statement: add the missingvalues and the translation
INSERT INTO silver.erp_product_category_translation (
	   product_category_name,
	   product_category_name_english
	   )
VALUES
  ('pc_gamer', 'pc_gamer'),
  ('portateis_cozinha_e_preparadores_de_alimentos','kitchen_portables_and_food_processors'),
  ('product_name_not_available', 'product_name_not_available');
```
---
✅ Data cleaned!

## Final DDL script with the new changes for `erp_product_category_translation`
No changes necessary to apply to structure, datatype and columns of this table. Initial DDL script unchanged.

