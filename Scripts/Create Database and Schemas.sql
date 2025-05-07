
/*
==================================================
Create Database and Schemas
==================================================

Script Purpose:
This script creates a new database named 'ECommerceDatawarehouse' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally in a similar way, the script sets up three schemas
(after checking if they don't exist) within the database: 'bronze', 'silver', and 'gold'.

WARNING:
Running this script will drop the entire 'ECommerceDatawarehouse' database if it exists.
All data in the database will be permanently deleted. Proceed with caution
and ensure you have proper backups before running this script.
*/
-----------------------------------------------------------------------------------------------------------------------------

-- CREATE DATABASE
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ECommerceDatawarehouse')
BEGIN
	ALTER DATABASE ECommerceDatawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ECommerceDatawarehouse;
END;
GO

CREATE DATABASE ECommerceDatawarehouse;

USE ECommerceDatawarehouse;

-- CREATE SCHEMAS FOR THE 3 LAYERS (if not exist)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
	EXEC('CREATE SCHEMA bronze');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
	EXEC('CREATE SCHEMA silver');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
	EXEC('CREATE SCHEMA gold');
GO
