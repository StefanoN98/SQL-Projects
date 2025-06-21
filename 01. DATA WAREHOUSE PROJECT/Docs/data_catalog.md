# Data Catalog for Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics.

---

## 🛒 `gold.fact_orders`

| Column                          | Data Type      | Description                                                      |
|---------------------------------|----------------|------------------------------------------------------------------|
| order_id                        | NVARCHAR(50)   | Unique ID of the order                                           |
| customer_id                     | NVARCHAR(50)   | Key to the customer dataset. Each order has a unique customer_id |
| order_status                    | NVARCHAR(50)   | Reference to the order status (delivered, shipped, etc)          |
| order_purchase_timestamp        | DATETIME       | Date and time when the order was placed                          |
| order_approved_at               | DATETIME       | Timestamp of payment approval                                    |
| order_delivered_carrier_date    | DATETIME       | When the order was handed over to the logistics partner          |
| order_delivered_customer_date   | DATETIME       | When the order was delivered to the customer                     |
| order_estimated_delivery_date   | DATETIME       | Estimated delivery date given at the time of purchase            |

---



