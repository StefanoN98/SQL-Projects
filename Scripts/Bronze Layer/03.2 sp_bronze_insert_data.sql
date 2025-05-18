/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC sp_bronze_insert_data;
===============================================================================
*/

CREATE OR ALTER PROCEDURE sp_bronze_insert_data AS
BEGIN

	DECLARE @start_time DATETIME , @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME

	BEGIN TRY
	-- Setting start time for the batch
	SET @batch_start_time = GETDATE();
	-- PRINT MESSAGE FOR THE STORED PROCEDURE
		PRINT '=========================================';
		PRINT ' Loading Bronze Layer';
		PRINT '=========================================';

		PRINT '-----------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '-----------------------------------------';
		
		-- LOAD DATA INTO bronze.crm_order_items
		SET @start_time = GETDATE()
		PRINT '<< Truncating Table: bronze.crm_order_items';
		TRUNCATE TABLE bronze.crm_order_items
		PRINT '<< Inserting Table: bronze.crm_order_items';
		BULK INSERT bronze.crm_order_items
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\crm_order_items.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @END_time = GETDATE()
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> ---------------'

		-- LOAD DATA INTO bronze.crm_order_payments
		SET @start_time = GETDATE()
		PRINT '<< Truncating Table: bronze.crm_order_payments';
		TRUNCATE TABLE bronze.crm_order_payments
		PRINT '<< Inserting Table: bronze.crm_order_payments';
		BULK INSERT bronze.crm_order_payments
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\crm_order_payments.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @END_time = GETDATE()
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> ---------------'

		-- LOAD DATA INTO bronze.crm_order_reviews
		SET @start_time = GETDATE()
		PRINT '<< Truncating Table: bronze.crm_order_reviews';
		TRUNCATE TABLE bronze.crm_order_reviews
		PRINT '<< Inserting Table: bronze.crm_order_reviews';
		BULK INSERT bronze.crm_order_reviews
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\crm_order_reviews.csv'
		WITH(
			DATAFILETYPE = 'widechar',
    			CODEPAGE = '65001',
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @END_time = GETDATE()
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'


		-- LOAD DATA INTO bronze.crm_orders
		SET @start_time = GETDATE()
		PRINT '<< Truncating Table: bronze.crm_orders';
		TRUNCATE TABLE bronze.crm_orders
		PRINT '<< Inserting Table: bronze.crm_orders';
		BULK INSERT bronze.crm_orders
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\crm_orders.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @END_time = GETDATE()
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
		

		PRINT '-----------------------------------------';
		PRINT 'Loading ERP tables';
		PRINT '-----------------------------------------';

		-- LOAD DATA INTO bronze.erp_customers
		SET @start_time = GETDATE()
		PRINT '<< Truncating Table: bronze.erp_customers';
		TRUNCATE TABLE bronze.erp_customers
		PRINT '<< Inserting Table: bronze.erp_customers';
		BULK INSERT bronze.erp_customers
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_customers.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @END_time = GETDATE()
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> ---------------'

		-- LOAD DATA INTO bronze.erp_geolocation
		SET @start_time = GETDATE()
		PRINT '<< Truncating Table: bronze.erp_geolocation';
		TRUNCATE TABLE bronze.erp_geolocation
		PRINT '<< Inserting Table: bronze.erp_geolocation';
		BULK INSERT bronze.erp_geolocation
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_geolocation.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @END_time = GETDATE()
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> ---------------'

		-- LOAD DATA INTO bronze.erp_product_category_translation
		SET @start_time = GETDATE()
		PRINT '<< Truncating Table: bronze.erp_product_category_translation';
		TRUNCATE TABLE bronze.erp_product_category_translation
		PRINT '<< Inserting Table: bronze.erp_product_category_translation';
		BULK INSERT bronze.erp_product_category_translation
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_product_category_translation.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @END_time = GETDATE()
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> ---------------'

		-- LOAD DATA INTO bronze.erp_products
		SET @start_time = GETDATE()
		PRINT '<< Truncating Table:bronze.erp_products';
		TRUNCATE TABLE bronze.erp_products
		PRINT '<< Inserting Table: bronze.erp_products';
		BULK INSERT bronze.erp_products
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_products.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @END_time = GETDATE()
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> ---------------'

			-- LOAD DATA INTO  bronze.erp_sellers
		SET @start_time = GETDATE()
		PRINT '<< Truncating Table:  bronze.erp_sellers';
		TRUNCATE TABLE  bronze.erp_sellers
		PRINT '<< Inserting Table:  bronze.erp_sellers';
		BULK INSERT  bronze.erp_sellers
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\erp_sellers.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @END_time = GETDATE()
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
		
		-- Setting end time for the batch & print message
		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
	END TRY

	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH

END

EXEC dbo.sp_bronze_insert_data
