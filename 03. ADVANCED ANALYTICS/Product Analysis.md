# 📊 📊 Advanced Analytics: Product Performance Summary

## 🎯 Purpose

> This document contains the SQL query that produces a **product-level performance summary** from the `gold` layer of the data warehouse.
The goal is to provide key metrics — revenue, orders, sellers, customers, reviews, price positioning, and temporal dynamics — useful for product management, marketing, and operational decision-making.

---

## 📑 Table of Contents

1. [Assumptions](#-assumptions)  
2. [Table Mapping](#-table-mapping)  
3. [Output](#-output)  
   - [Columns 1-8](#columns-1-8)  
   - [Columns 9-14](#columns-9-14)  
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
