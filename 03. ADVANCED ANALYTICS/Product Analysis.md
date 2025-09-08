# 📊 📊 Advanced Analytics: Product Performance Summary

## 🎯 Purpose

> This document contains the SQL query that produces a **product-level performance summary** from the `gold` layer of the data warehouse.
The goal is to provide key metrics — revenue, orders, sellers, customers, reviews, price positioning, and temporal dynamics — useful for product management, marketing, and operational decision-making.

---

## 📑 Table of Contents

1. [Assumptions](#-assumptions)  
2. [Table Mapping](#-table-mapping)  
3. [Output](#-output)  
   - [Columns 1-7](#columns-1-7)  
   - [Columns 8-20](#columns-8-20)  
4. [The Query](#-the-query)  
5. [Main Key Metrics Explained](#-main-key-metrics-explained)  
6. [Why This Query Is Useful for the Business](#-why-this-query-is-useful-for-the-business)  
7. [How to Leverage This Output for Further Analysis](#-how-to-leverage-this-output-for-further-analysis)
8. [Technical Details and SQL Techniques](#-technical-details-and-sql-techniques) 

---

## 📌 Assumptions


- **Excluded orders**: canceled or unavailable orders are ignored.
- **Revenue per product**: includes total order payments (item price + shipping), that's why `avg_revenue_per_order` is higher than `avg_product_price`.
- **Customer count**: uses customer_unique_id to avoid double-counting repeat customers.
- **Product prices**: may vary over time; averages are computed across all order events.
  
---

## 🗂️ Table Mapping
- `gold.dim_products` — product master data (product_id, product_category_name)
- `gold.dim_customers` — customer master data (customer_id, customer_unique_id)
- `gold.fact_order_items` — order line items (product_id, seller_id, item_price, total_order_payment)
- `gold.fact_orders` — order header (order_id, customer_id, order_status, order_purchase_timestamp)
- `gold.fact_reviews` — reviews (order_id, review_score)

---
## 📝 Output:

| product_id                         | product_category_name | total_sellers | total_customers | total_orders | total_revenue | revenue_segment    | avg_revenue_per_order | avg_orders_per_customer | avg_product_price | price_diff_vs_category | price_positioning     | total_reviews | avg_review_score | pct_five_star | pct_one_star | first_order_date | last_order_date | product_lifetime_days | peak_month |
|-----------------------------------|---------------------|---------------|----------------|--------------|---------------|------------------|---------------------|------------------------|-----------------|----------------------|---------------------|---------------|----------------|---------------|--------------|-----------------|----------------|----------------------|------------|
| 001b72dfd63e9833e8c02742adf472e3 | furniture_decor     | 1             | 12             | 12           | 665           | Top 25% Revenue  | 47,47               | 1                      | 34,99           | -68,48               | Below Category Price | 14            | 3,5            | 50,00%        | 28,57%       | 2017-02-15      | 2017-12-15     | 303                  | 2017-12    |
| 001c5d71ac6ad696d22315953758fa04 | bed_bath_table      | 1             | 1              | 1            | 101           | Long Tail        | 100,64              | 1                      | 79,9            | -27,65               | Below Category Price | 1             | 5              | 100,00%       | 0,00%        | 2017-01-25      | 2017-01-25     | 0                    | 2017-01    |
| 00210e41887c2a8ef9f791ebc780cc36 | health_beauty       | 1             | 5              | 5            | 319           | Long Tail        | 45,59               | 1                      | 33,41           | -113,6               | Below Category Price | 7             | 4,43           | 85,71%        | 14,29%       | 2017-05-22      | 2017-06-26     | 35                   | 2017-06    |
| 002159fe700ed3521f46cfcf6e941c76 | fashion_shoes       | 1             | 7              | 8            | 1851          | Top 10% Revenue  | 231,33              | 1,143                  | 202,33          | 117,85               | Above Category Price | 7             | 3,43           | 28,57%        | 28,57%       | 2017-04-15      | 2018-08-07     | 479                  | 2018-08    |
| 05fa3b5ecdf7f54e97fe25127db0ee7c | sports_leisure      | 1             | 3              | 4            | 808           | Top 25% Revenue  | 201,95              | 1,333                  | 181             | 46,2                 | Above Category Price | 4             | 3,75           | 50,00%        | 0,00%        | 2017-08-03      | 2018-02-23     | 204                  | 2018-02    |


### Columns 1-7
| product_id                         | product_<br>category_name | total_sellers | total_<br>customers | total_orders | total_<br>revenue | revenue_<br>segment    | ... |
|-----------------------------------|---------------------|---------------|----------------|--------------|---------------|------------------|-----|
| 001b72dfd63e9833e8c02742adf472e3 | furniture_decor     | 1             | 12             | 12           | 665           | Top 25% Revenue  | ... |
| 001c5d71ac6ad696d22315953758fa04 | bed_bath_table      | 1             | 1              | 1            | 101           | Long Tail        | ... |
| 00210e41887c2a8ef9f791ebc780cc36 | health_beauty       | 1             | 5              | 5            | 319           | Long Tail        | ... |
| 002159fe700ed3521f46cfcf6e941c76 | fashion_shoes       | 1             | 7              | 8            | 1851          | Top 10% Revenue  | ... |
| 05fa3b5ecdf7f54e97fe25127db0ee7c | sports_leisure      | 1             | 3              | 4            | 808           | Top 25% Revenue  | ... |

### Columns 8-20
| product_id                         | ... | avg_revenue<br>_per_order | avg_orders_<br>per_customer | avg_product_<br>price | price_diff_<br>vs_category | price_positioning     | total_reviews | avg_review_<br>score | pct_five_<br>star | pct_one_<br>star | first_<br>order_date | last_<br>order_date | product_<br>lifetime_days | peak_month |
|-----------------------------------|-----|---------------------|------------------------|-----------------|----------------------|---------------------|---------------|----------------|---------------|--------------|-----------------|----------------|----------------------|------------|
| 001b72dfd63e9833e8c02742adf472e3 | ... | 47,47               | 1                      | 34,99           | -68,48               | Below Category Price | 14            | 3,5            | 50,00%        | 28,57%       | 2017-02-15      | 2017-12-15     | 303                  | 2017-12    |
| 001c5d71ac6ad696d22315953758fa04 | ... | 100,64              | 1                      | 79,9            | -27,65               | Below Category Price | 1             | 5              | 100,00%       | 0,00%        | 2017-01-25      | 2017-01-25     | 0                    | 2017-01    |
| 00210e41887c2a8ef9f791ebc780cc36 | ... | 45,59               | 1                      | 33,41           | -113,6               | Below Category Price | 7             | 4,43           | 85,71%        | 14,29%       | 2017-05-22      | 2017-06-26     | 35                   | 2017-06    |
| 002159fe700ed3521f46cfcf6e941c76 | ... | 231,33              | 1,143                  | 202,33          | 117,85               | Above Category Price | 7             | 3,43           | 28,57%        | 28,57%       | 2017-04-15      | 2018-08-07     | 479                  | 2018-08    |
| 05fa3b5ecdf7f54e97fe25127db0ee7c | ... | 201,95              | 1,333                  | 181             | 46,2                 | Above Category Price | 4             | 3,75           | 50,00%        | 0,00%        | 2017-08-03      | 2018-02-23     | 204                  | 2018-02    |

