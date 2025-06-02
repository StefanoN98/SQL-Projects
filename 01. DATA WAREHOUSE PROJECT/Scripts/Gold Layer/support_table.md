
IF OBJECT_ID('support_table_prefix_state_mapping', 'U') IS NOT NULL
	DROP TABLE support_table_prefix_state_mapping;
GO

CREATE TABLE support_table_prefix_state_mapping(
_3digits_prefix NVARCHAR(3),
country NVARCHAR(2)
)

-- LOAD DATA INTO bronze.crm_order_items

		TRUNCATE TABLE support_table_prefix_state_mapping
		BULK INSERT support_table_prefix_state_mapping
		FROM 'C:\Users\Stefano\Desktop\SQL\PROGETTI\Brazilian E-Commerce Public Dataset by Olist\Data\support_table_prefix_state_mapping.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK
		)

|_3digits_prefix |	country|
|----------------|---------|
|288	           |    RJ   |
|289	           |    RJ   |
|290	           |    ES   |
|291	           |    ES   |
