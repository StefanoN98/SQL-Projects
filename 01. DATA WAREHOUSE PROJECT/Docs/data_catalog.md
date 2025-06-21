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

## 📦 `order_items`
| Column                 | Description                                                                                                                         |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| order_id               | ID of the order                                                                                                                     |
| order_item_id          | Sequential number identifying number of items included in the same order                                                            |
| product_id             | ID of the product                                                                                                                   |
| seller_id              | ID of the seller for that product                                                                                                   |
| shipping_limit_date    | Deadline for the seller to ship the product                                                                                         |
| price                  | Price paid for the product                                                                                                          |
| freight_value          | Shipping cost charged                                                                                                               |
| total_order_payment    | Sum of the transaction values                                                                                                       |
| shipping_type          | Reference to shipping type (standard, free)                                                                                         |
| delta                  | Indicates if the customer use a discount code (Discount Code) , paid more duty taxes (Additional customs fees) or nothing (no delta)|  
| delta amount           | Difference between sum of the transaction values and freigh_value + price                                                           |



