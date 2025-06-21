# 🗂️ Data Catalog for Gold Layer

This document provides a comprehensive data catalog for the Gold Layer. It details each table’s columns, their corresponding data types, and clear descriptions of their purpose and business meaning.

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

## 💰 `gold.fact_payments`

| Column              | Data Type      | Description                                                       |
|---------------------|----------------|-------------------------------------------------------------------|
| order_id            | NVARCHAR(50)   | ID of the order                                                   |
| payment_sequential  | NVARCHAR(4000) | Sequence number for multiple payments for the same order          |
| credit_card         | FLOAT          | Value of transaction paid using a credit card as payment type     |
| debit_card          | FLOAT          | Value of transaction paid using a debit card as payment type      |
| boleto              | FLOAT          | Value of transaction paid using a boleto as payment type          |
| voucher             | FLOAT          | Value of transaction paid using a voucher as payment type         |
| total               | FLOAT          | Sum of the transaction values                                     |


---

## 📦 `gold.fact_order_items`
| Column               | Data Type      | Description                                                                                                                         |
|----------------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------|
| order_id             | NVARCHAR(50)   | ID of the order                                                                                                                     |
| order_item_id        | INT            | Sequential number identifying number of items included in the same order                                                            |
| product_id           | NVARCHAR(50)   | ID of the product                                                                                                                   |
| seller_id            | NVARCHAR(50)   | ID of the seller for that product                                                                                                   |
| shipping_limit_date  | DATETIME       | Deadline for the seller to ship the product                                                                                         |
| price                | FLOAT          | Price paid for the product                                                                                                          |
| freight_value        | FLOAT          | Shipping cost charged                                                                                                               |
| total_order_payment  | FLOAT          | Sum of the transaction values                                                                                                       |
| shipping_type        | NVARCHAR(50)   | Reference to shipping type (standard, free)                                                                                         |
| delta                | VARCHAR(23)    | Indicates if the customer use a discount code (Discount Code), paid more duty taxes (Additional customs fees) or nothing (no delta) |
| delta amount         | FLOAT          | Difference between sum of the transaction values and freigh_value + price                                                           |

---

## ⭐ `gold.fact_reviews`
| Column                 | Data Type      | Description                                                      |
|------------------------|----------------|------------------------------------------------------------------|
| review_id              | NVARCHAR(50)   | Unique ID for the review                                         |
| order_id               | NVARCHAR(50)   | Associated order ID                                              |
| review_score           | INT            | Score from 1 to 5                                                |
| review_comment_title   | NVARCHAR(80)   | Title of the review (optional)                                   |
| review_comment_message | NVARCHAR(500)  | Message of the review (optional)                                 |
| review_creation_date   | DATETIME       | Date the review was created by the customer                      |
| review_answer_timestamp| DATETIME       | Timestamp when the customer service answered the review          |

---

## 🧩 `gold.dim_products`
| Column                 | Data Type      | Description                                       |
|------------------------|----------------|---------------------------------------------------|
| product_id             | NVARCHAR(50)   | Unique ID of the product                          |
| product_category_name  | NVARCHAR(100)  | Name of the product category (in english)         |
| product_weight_g       | INT            | Weight of the product in grams                    |
| product_length_cm      | INT            | Length of the product in cm                       |
| product_height_cm      | INT            | Height of the product in cm                       |
| product_width_cm       | INT            | Width of the product in cm                        |

---

## 🧑‍💼 `gold.dim_sellers`
| Column           | Data Type      | Description                             |
|------------------|----------------|-----------------------------------------|
| seller_id        | NVARCHAR(50)   | Unique ID of the seller                 |
| seller_zip_code  | NVARCHAR(10)   | First 5 digits of the seller's ZIP code |

---

## 👤 `gold.dim_customers`
| Column               | Data Type      | Description                                                      |
|----------------------|----------------|------------------------------------------------------------------|
| customer_id          | NVARCHAR(50)   | Key to the orders dataset. Each order has a unique customer_id.  |
| customer_unique_id   | NVARCHAR(50)   | Permanent customer ID (same person, multiple orders)             |
| customer_zip_code    | NVARCHAR(10)   | First 5 digits of the customer’s ZIP code                        |

---

## 📍 `gold.dim_geolocation`
| Column    | Data Type      | Description                       |
|-----------|----------------|---------------------------------|
| zip_code  | NVARCHAR(10)   | ZIP code prefix (first 5 digits)|
| city      | NVARCHAR(50)   | City of the ZIP code            |
| country   | NVARCHAR(10)   | State of the ZIP code           |





