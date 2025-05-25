/*
===============================================================================
DDL Script: Bulk Insert CSV Into Tables
===============================================================================
Script Purpose:
    This script insert records from cvs into the tables of the 'bronze' schema, truncating tables before,
	in order to not keep old data
	  Run this script to popolate the tables with new records.
===============================================================================
*/


		-- LOAD DATA INTO bronze.crm_order_items

		TRUNCATE TABLE bronze.crm_order_items
		BULK INSERT bronze.crm_order_items
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\crm_order_items.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)

		-- LOAD DATA INTO bronze.crm_order_payments
		TRUNCATE TABLE bronze.crm_order_payments
		BULK INSERT bronze.crm_order_payments
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\crm_order_payments.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)

		-- LOAD DATA INTO bronze.crm_order_reviews
		TRUNCATE TABLE bronze.crm_order_reviews
		BULK INSERT bronze.crm_order_reviews
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\crm_order_reviews.csv'
		WITH(
			FIRSTROW=2,
			DATAFILETYPE = 'widechar',  -- per Unicode UTF-16
			CODEPAGE = '65001', 
			FIELDTERMINATOR =',',
			TABLOCK
		)

		-- LOAD DATA INTO bronze.crm_orders
		TRUNCATE TABLE bronze.crm_orders
		BULK INSERT bronze.crm_orders
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\crm_orders.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)

		-- LOAD DATA INTO bronze.erp_customers
		TRUNCATE TABLE bronze.erp_customers
		BULK INSERT bronze.erp_customers
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_customers.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)

		-- LOAD DATA INTO bronze.erp_geolocation
		TRUNCATE TABLE bronze.erp_geolocation
		BULK INSERT bronze.erp_geolocation
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_geolocation.csv'
		WITH(
			FIRSTROW=2,
			DATAFILETYPE = 'widechar',  -- per Unicode UTF-16
			CODEPAGE = '65001',
			FIELDTERMINATOR =',',
			TABLOCK
		)

		-- LOAD DATA INTO bronze.erp_product_category_translation
		TRUNCATE TABLE bronze.erp_product_category_translation
		BULK INSERT bronze.erp_product_category_translation
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_product_category_translation.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)

		-- LOAD DATA INTO bronze.erp_products
		TRUNCATE TABLE bronze.erp_products
		BULK INSERT bronze.erp_products
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_products.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)

			-- LOAD DATA INTO  bronze.erp_sellers
		TRUNCATE TABLE  bronze.erp_sellers
		BULK INSERT  bronze.erp_sellers
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_sellers.csv'
		WITH(
			FIRSTROW=2,
			DATAFILETYPE = 'widechar',  -- per Unicode UTF-16
			CODEPAGE = '65001',
			FIELDTERMINATOR =',',
			TABLOCK
		)
