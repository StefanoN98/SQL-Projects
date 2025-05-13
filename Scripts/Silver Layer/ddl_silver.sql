/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist and adding also the metadata column dwh_create_date
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

/* ========================================================================
   DROP & CREATE crm Tables
===========================================================================*/

-- DROP & CREATE silver.crm_order_items
IF OBJECT_ID('silver.crm_order_items', 'U') IS NOT NULL
	DROP TABLE silver.crm_order_items;
GO
  
CREATE TABLE silver.crm_order_items (
    order_id NVARCHAR(50),
    order_item_id INT,
    product_id NVARCHAR(50),
    seller_id NVARCHAR(50),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    shipping_type NVARCHAR(50)
);
GO

-------------------------------------------------------------------------------

-- DROP & CREATE silver.crm_order_payment
IF OBJECT_ID('silver.crm_order_payment', 'U') IS NOT NULL
	DROP TABLE silver.crm_order_payment;
GO

CREATE TABLE silver.crm_order_payment (
    order_id  NVARCHAR(50),
    payment_sequence NVARCHAR(200),
    credit_card FLOAT,
    debit_card FLOAT,
    boleto FLOAT,
    voucher FLOAT,
    total FLOAT,
);
GO
