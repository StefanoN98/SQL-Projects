# 📊 Product Performance Summary

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

---

## 💻 The Query

```sql
WITH product_orders AS (
    -- Extract orders per product and seller, including unique customer ID and revenue
    SELECT 
        foi.product_id,
        foi.seller_id,
        fo.order_id,
        fo.customer_id,
        dc.customer_unique_id,               
        fo.order_purchase_timestamp,
        fo.order_status,
        foi.item_price AS item_price,             
        SUM(foi.total_order_payment) AS order_revenue  -- total revenue associated with the order
    FROM gold.fact_order_items foi
    JOIN gold.fact_orders fo ON foi.order_id = fo.order_id
    JOIN gold.dim_customers dc ON fo.customer_id = dc.customer_id  
    WHERE fo.order_status NOT IN ('canceled','unavailable') -- exclude canceled/unavailable orders
    GROUP BY 
        foi.product_id, foi.seller_id, fo.order_id, fo.customer_id, dc.customer_unique_id,
        fo.order_purchase_timestamp, fo.order_status, foi.item_price
),

product_rev_prc_pt1 AS (
   -- Calculate average price and revenue per product id
    SELECT 
        dp.product_id,
        dp.product_category_name,
        AVG(foi.item_price) AS avg_product_price,            -- average selling price of the product
        AVG(foi.total_order_payment) AS avg_revenue_per_order -- average order revenue (including shipping, fees, etc.)
    FROM gold.dim_products dp
    JOIN gold.fact_order_items foi ON foi.product_id = dp.product_id
    JOIN gold.fact_orders fo ON fo.order_id = foi.order_id
    WHERE fo.order_status NOT IN ('canceled','unavailable')
    GROUP BY dp.product_id, dp.product_category_name
),

product_rev_prc_pt2 AS(
   -- Use the previous cte  to apply window functions and get average  price and revenue per product category level
    SELECT
        product_id,
        product_category_name,
        ROUND(avg_product_price,2) AS avg_product_price,          
        ROUND(avg_revenue_per_order,2) AS avg_revenue_per_order,  
        AVG(avg_product_price) OVER (PARTITION BY product_category_name) AS avg_category_price,    -- average price within the category
        AVG(avg_revenue_per_order) OVER (PARTITION BY product_category_name) AS avg_category_revenue -- average revenue within the category
    FROM product_rev_prc_pt1
),

product_reviews AS (
   -- Aggregate reviews per product
    SELECT 
        dp.product_id,
        AVG(CAST(fr.review_score AS FLOAT)) AS avg_review_score,      -- average review score per product
        COUNT(fr.review_id) AS total_reviews,                         -- total number of reviews
        SUM(CASE WHEN fr.review_score = 5 THEN 1 ELSE 0 END) AS five_star_reviews, -- number of 5-star reviews
        SUM(CASE WHEN fr.review_score = 1 THEN 1 ELSE 0 END) AS one_star_reviews  -- number of 1-star reviews
    FROM gold.fact_reviews fr
    JOIN gold.fact_order_items foi ON foi.order_id=fr.order_id
    JOIN gold.dim_products dp ON dp.product_id=foi.product_id
    GROUP BY dp.product_id
),

product_stats AS (
   -- Calculate product-level aggregations
    SELECT 
        dp.product_id,
        dp.product_category_name,

        -- Supply & demand
        COUNT(DISTINCT po.seller_id) AS total_sellers,                -- number of unique sellers
        COUNT(DISTINCT po.customer_unique_id) AS total_customers,    -- number of unique customers
        COUNT(DISTINCT po.order_id) AS total_orders,                 -- unique orders containing the product
        ROUND(SUM(po.order_revenue),0) AS total_revenue,            -- total revenue for the product
       
        -- Reviews
        ROUND(AVG(pr.avg_review_score),2) AS avg_review_score,       -- average review score
        MAX(pr.total_reviews) AS total_reviews,                      -- using MAX to preserve actual count from origin cte
        MAX(pr.five_star_reviews) * 1.0 / NULLIF(MAX(pr.total_reviews),0) AS pct_five_star, -- percentage of 5-star reviews
        MAX(pr.one_star_reviews) * 1.0 / NULLIF(MAX(pr.total_reviews),0) AS pct_one_star,   -- percentage of 1-star reviews

        -- Temporal metrics
        CAST(MIN(po.order_purchase_timestamp) AS DATE) AS first_order_date,  -- date of first order
        CAST(MAX(po.order_purchase_timestamp) AS DATE) AS last_order_date,   -- date of last order
        DATEDIFF(DAY, MIN(po.order_purchase_timestamp), MAX(po.order_purchase_timestamp)) AS product_lifetime_days, -- product lifetime in days
        FORMAT(MAX(po.order_purchase_timestamp), 'yyyy-MM') AS peak_month,  -- peak month based on last order

        -- Customer loyalty / repeat purchases
        CASE 
          WHEN COUNT(DISTINCT po.customer_unique_id) > 0 
          THEN CAST(COUNT(DISTINCT po.order_id) AS FLOAT) / COUNT(DISTINCT po.customer_unique_id) -- average orders per customer
          ELSE NULL
        END AS avg_orders_per_customer

    FROM gold.dim_products dp
    JOIN product_orders po ON dp.product_id = po.product_id
    LEFT JOIN product_reviews pr ON dp.product_id = pr.product_id
    GROUP BY dp.product_id, dp.product_category_name
)

-- Final query joining product stats and price/revenue comparisons
SELECT 
    ps.product_id,
    ps.product_category_name,
    ps.total_sellers,
    ps.total_customers,                
    ps.total_orders,
    ps.total_revenue,

    -- Revenue segmentation based on percentiles
    CASE 
        WHEN ps.total_revenue > PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY ps.total_revenue) OVER() THEN 'Top 10% Revenue'
        WHEN ps.total_revenue > PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ps.total_revenue) OVER() THEN 'Top 25% Revenue'
        ELSE 'Long Tail'
    END AS revenue_segment,

    prp.avg_revenue_per_order,                  -- average revenue per order
    ROUND(avg_orders_per_customer,3) AS avg_orders_per_customer, -- average orders per customer
    prp.avg_product_price,                      -- average product price

    -- Price comparison with category
    ROUND(prp.avg_product_price - prp.avg_category_price,2) AS price_diff_vs_category, 
    CASE 
        WHEN prp.avg_product_price > prp.avg_category_price THEN 'Above Category Price'
        WHEN prp.avg_product_price < prp.avg_category_price THEN 'Below Category Price'
        ELSE 'At Category Price'
    END AS price_positioning,

    ps.total_reviews,
    ps.avg_review_score,
    FORMAT(ps.pct_five_star *100,'N2') + '%' AS pct_five_star, -- percentage of 5-star reviews
    FORMAT(ps.pct_one_star *100,'N2') + '%' AS pct_one_star,   -- percentage of 1-star reviews
    ps.first_order_date,
    ps.last_order_date,
    ps.product_lifetime_days,
    ps.peak_month

FROM product_stats ps
JOIN product_rev_prc_pt2 prp 
     ON ps.product_id = prp.product_id
ORDER BY product_id;
```
---

## 🔑 Main Key Metrics Explained
| Metric                      | Calculation / Threshold                                  | Description                                   |
| --------------------------- | -------------------------------------------------------- | --------------------------------------------- |
| **Revenue Segment**         | **Top 10%**: >90th percentile<br>**Top 25%**: 75th-90th percentile<br>**Long Tail**: <75th percentile             | Classifies products by revenue performance, Identifies star products vs. those needing attention  |
| **Avg Revenue per Order**   | Average revenue across all orders containing the product | Helps identify high-value products.           |
| **Avg Orders per Customer** | `total_orders / total_customers`                         | Measures repeat purchase behavior.            |
| **Price Positioning**       | Compares product price vs. category average: Above/Below/At Category Price                       | Compares product price with category average. |
| **Review Metrics**          | **5-star %**: `(five_star_reviews / total_reviews) * 100`<br>**1-star %**: `(one_star_reviews / total_reviews) * 100`                | Reflects customer satisfaction and product quality perception .               |
| **Temporal Metrics**        | First/Last order dates, lifetime in days, peak month     | Tracks product lifecycle and peak demand.     |

---

## 💡 Why This Query Is Useful for the Business

1.  **Product performance tracking**: This query allows monitoring of products at a granular level --- revenue, customer base, order volume, and reviews. It helps prioritize high-performing SKUs and identify underperforming ones.
2.  **Revenue segmentation**: By classifying products into `Top 10% Revenue`, `Top 25% Revenue`, or `Long Tail`, the business can focus on core revenue drivers while managing the long tail differently (e.g., assortment pruning or targeted marketing).
3.  **Price positioning**: The query compares a product's price to its category average, providing insight into whether a product is priced competitively,overpriced, or aligned with the category benchmark.
4.  **Customer loyalty analysis**: Metrics like `average orders per customer` show the degree of repeat purchases,useful for identifying products that build loyalty or attract one-time buyers.
5.  **Product lifecycle management**: By extracting first/last order dates and product lifetime days, the business can understand product maturity stages and plan replenishment, marketing pushes, or discontinuation strategies.
6.  **Review-driven insights**: Review distributions (5-star vs 1-star) highlight customer satisfaction and product quality, crucial for product improvement, supplier evaluation, and marketing claims.

------------------------------------------------------------------------

## 🚀 How to Leverage This Output for Further Analysis

1.  **Portfolio optimization**
    -   Identify SKUs in the long tail with low revenue and poor reviews for discontinuation.
    -   Focus marketing resources on top 10% products with high review scores.
2.  **Category management**
    -   Compare price positioning across categories to assess pricing strategies.
    -   Use `avg_category_price` and `avg_category_revenue` to benchmark performance.
3.  **Customer segmentation**
    -   Cross-analyze `avg_orders_per_customer` with review scores to detect loyal customers of high-quality products.
    -   Target retention campaigns on products with repeat buyers.
4.  **Time-series insights**
    -   Use `first_order_date`, `last_order_date`, and `peak_month` to track adoption curves and seasonality.
    -   Plan product launches and promotions based on seasonal peaks.
5.  **Quality assurance**
    -   Monitor share of 1-star reviews to detect products that may damage reputation.
    -   Feed back review insights to suppliers for corrective actions.

------------------------------------------------------------------------

## ⚙️ Technical Details and SQL Techniques

-   **Use of multiple CTEs**: The query is modular, splitting logic into product orders, revenue/price stats, reviews, and product-level aggregation for clarity and reusability.
-   **Window functions for benchmarking**:
    `AVG(...) OVER (PARTITION BY category)` enables intra-category comparisons without extra joins.
-   **Percentile-based segmentation**: `PERCENTILE_CONT` is applied for dynamic thresholds (`Top 10%`, `Top 25%`), avoiding static cutoffs.
-   **Review aggregation logic**: Counts of 5-star vs 1-star reviews provide polarity measures beyond simple averages.
-   **Lifecycle calculation**: `DATEDIFF` between first and last orders captures product longevity.
-   **Null and divide-by-zero handling**: `NULLIF` ensures stable calculations in cases of products with no reviews.
-   **Formatting for readability**: Output includes percentages (`pct_five_star`, `pct_one_star`) and month formatting, though final
    display is best handled in BI tools.
