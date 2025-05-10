/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


/* ========================================================================
   DROP & CREATE crm Tables
===========================================================================*/

-- DROP & CREATE bronze.crm_order_items

IF OBJECT_ID('bronze.crm_order_items', 'U') IS NOT NULL
	DROP TABLE bronze.crm_order_items;
GO

CREATE TABLE bronze.crm_order_items (
    order_id NVARCHAR(50),
    order_item_id INT,
    product_id NVARCHAR(50),
    seller_id NVARCHAR(50),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
	ingested_at DATETIME DEFAULT GETDATE()
    );
GO
---------------------------------------------------------------------------

-- DROP & CREATE bronze.crm_order_payments

IF OBJECT_ID('bronze.crm_order_payments', 'U') IS NOT NULL
	DROP TABLE bronze.crm_order_payments;
GO

CREATE TABLE bronze.crm_order_payments (
    order_id NVARCHAR(50),
    payment_sequential INT,
    payment_type NVARCHAR(50),
    payment_installments INT,
    payment_value FLOAT,
	ingested_at DATETIME DEFAULT GETDATE()
    );
GO
---------------------------------------------------------------------------

-- DROP & CREATE bronze.crm_order_reviews

IF OBJECT_ID('bronze.crm_order_reviews', 'U') IS NOT NULL
	DROP TABLE bronze.crm_order_reviews;
GO

CREATE TABLE bronze.crm_order_reviews (
    review_id NVARCHAR(50),
    order_id NVARCHAR(50),
    review_score INT,
    review_comment_title NVARCHAR(255),
    review_comment_message NVARCHAR(MAX),
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
	ingested_at DATETIME DEFAULT GETDATE()
    );
GO
---------------------------------------------------------------------------

-- DROP & CREATE bronze.crm_orders

IF OBJECT_ID('bronze.crm_orders', 'U') IS NOT NULL
	DROP TABLE bronze.crm_orders;
GO

CREATE TABLE bronze.crm_orders (
    order_id NVARCHAR(50),
	customer_id NVARCHAR(50),
    order_status NVARCHAR(50),
	order_purchase_timestamp DATETIME,
	order_approved_at DATETIME,
	order_delivered_carrier_date DATETIME,
	order_delivered_customer_date DATETIME,
	order_estimated_delivery_date DATETIME,
	ingested_at DATETIME DEFAULT GETDATE()
    );
GO

/* ========================================================================
   DROP & CREATE erp Tables
===========================================================================*/

-- DROP & CREATE bronze.erp_customers

IF OBJECT_ID('bronze.erp_customers', 'U') IS NOT NULL
	DROP TABLE bronze.erp_customers;
GO

CREATE TABLE bronze.erp_customers (
    customer_id NVARCHAR(50),
	customer_unique_id NVARCHAR(50),
	customer_zip_code_prefix NVARCHAR(10),
	customer_city NVARCHAR(50),
	customer_state NVARCHAR(10),
	ingested_at DATETIME DEFAULT GETDATE()
	);
GO
---------------------------------------------------------------------------

-- DROP & CREATE bronze.erp_geolocation

IF OBJECT_ID('bronze.erp_geolocation', 'U') IS NOT NULL
	DROP TABLE bronze.erp_geolocation;
GO

CREATE TABLE bronze.erp_geolocation (
	geolocation_zip_code_prefix NVARCHAR(10),
	geolocation_lat DECIMAL(18,15),
	geolocation_lng DECIMAL(18,15),
	geolocation_city NVARCHAR(50),
	geolocation_state NVARCHAR(10),
	ingested_at DATETIME DEFAULT GETDATE()
	);
GO
---------------------------------------------------------------------------

-- DROP & CREATE bronze.erp_product_category_translation

IF OBJECT_ID('bronze.erp_product_category_translation', 'U') IS NOT NULL
	DROP TABLE bronze.erp_product_category_translation;
GO

CREATE TABLE bronze.erp_product_category_translation (
	product_category_name NVARCHAR(100),
	product_category_name_english NVARCHAR(100),
	ingested_at DATETIME DEFAULT GETDATE()
	);
GO
---------------------------------------------------------------------------

-- DROP & CREATE bronze.erp_products

IF OBJECT_ID('bronze.erp_products', 'U') IS NOT NULL
	DROP TABLE bronze.erp_products;
GO

CREATE TABLE bronze.erp_products (
	product_id NVARCHAR(50),
	product_category_name NVARCHAR(100),
	product_name_length INT,
	product_description_length NVARCHAR(MAX),
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT,
	ingested_at DATETIME DEFAULT GETDATE()
);
GO
---------------------------------------------------------------------------

-- DROP & CREATE bronze.erp_sellers

IF OBJECT_ID('bronze.erp_sellers', 'U') IS NOT NULL
	DROP TABLE bronze.erp_sellers;
GO

CREATE TABLE bronze.erp_sellers(
	seller_id NVARCHAR(50),
	seller_zip_code_prefix NVARCHAR(10),
	seller_city NVARCHAR(50),
	seller_state NVARCHAR(10),
	ingested_at DATETIME DEFAULT GETDATE()
);
GO
