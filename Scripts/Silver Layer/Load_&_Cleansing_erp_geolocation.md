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
