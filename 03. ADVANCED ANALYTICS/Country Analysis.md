# 📊 Advanced Analytics: Country Market Summary (2016–2018)

## 🎯 Purpose

This document contains the SQL query that produces a **market summary by country** from the `gold` layer of the data warehouse.  
The goal is to provide **key metrics** — customers, sellers, products, orders, revenue, market profile, and cross-border indicators — useful for **business and operational decision-making**.

## 📌 Assumptions

- **Reference period**: full timeframe from 2016 to 2018  
- **Excluded orders**: canceled and unavailable orders are not counted (this may cause differences compared to the silver/gold layer analyses in the DWH)  
- **Total customers** = 96095  
- **Total sellers** = 3095  
- **Total products** = 32951, but in the query result there are 33,597 because a product can have multiple sellers and thus appear in multiple regions  
- **Total orders** = 98212 (the query excludes orders with `order_status` in (`'canceled','unavailable'`)  
- **Total revenue** = 15739885,59 (the query excludes orders with `order_status` in (`'canceled','unavailable'`)

---

## 🗂️ Table Mapping

- `gold.dim_geolocation` — geographic/postal information (zip_code → country) 
- `gold.dim_customers` — customer master data (customer_id, customer_unique_id, customer_zip_code)   
- `gold.dim_sellers` — seller master data (seller_id, seller_zip_code)   
- `gold.fact_order_items` — order line items (order_id, seller_id, product_id, quantity, price...)   
- `gold.dim_products` — product master data (product_id, category...)   
- `gold.fact_orders` — order header (order_id, customer_id, order_status, order_purchase_timestamp...)  
- `gold.fact_payments` — order payments (order_id, payment_type, total...)   

---

## 📝 Complete Output:

| country | total_sellers | total_customer | total_products | total_orders | total_revenue | avg_revenue_per_order | market_segment | revenue_order_profile | max_orders_by_single_customer | average_spent_by_customer | percent_customer_above_average | domestic_orders_with_percent | foreign_orders_with_percent |
|---------|---------------|----------------|----------------|--------------|---------------|-----------------------|----------------|-----------------------|------------------------------|---------------------------|--------------------------------|------------------------------|-----------------------------|
| SP      | 1816          | 40290          | 22750          | 41123        | 5879410       | 142,97                | Large Market   | Low Value             | 16                           | 145.93€                   | 29,62 %                        | 31.079 &#124; 75,58%        | 10.044 &#124; 24,42%        |
| RJ      | 176           | 12379          | 1555           | 12699        | 2115884       | 166,62                | Large Market   | Low Value             | 6                            | 170.93€                   | 29,00 %                        | 1.021 &#124; 8,04%          | 11.678 &#124; 91,96%        |
| MG      | 250           | 11256          | 2824           | 11501        | 1843982       | 160,33                | Large Market   | Low Value             | 7                            | 163.82€                   | 29,44 %                        | 1.597 &#124; 13,89%         | 9.904 &#124; 86,11%         |
| RS      | 132           | 5276           | 789            | 5417         | 877825        | 162,05                | Medium Market  | Low Value             | 4                            | 166.38€                   | 28,81 %                        | 292 &#124; 5,39%            | 5.125 &#124; 94,61%         |
| PR      | 360           | 4881           | 3042           | 4985         | 795036        | 159,49                | Medium Market  | Low Value             | 6                            | 162.88€                   | 28,15 %                        | 739 &#124; 14,82%           | 4.246 &#124; 85,18%         |
| SC      | 197           | 3529           | 1491           | 3598         | 607518        | 168,85                | Medium Market  | Low Value             | 4                            | 172.15€                   | 28,56 %                        | 274 &#124; 7,62%            | 3.324 &#124; 92,38%         |

### Columns 1-8

| country | total_sellers | total_customer | total_products | total_orders | total_revenue | avg_revenue_<br>per_order | market_segment | ... |
|---------|---------------|----------------|----------------|--------------|---------------|-----------------------|----------------|---------|
| SP      | 1816          | 40290          | 22750          | 41123        | 5879410       | 142,97                | Large Market   | ... |
| RJ      | 176           | 12379          | 1555           | 12699        | 2115884       | 166,62                | Large Market   | ... |
| MG      | 250           | 11256          | 2824           | 11501        | 1843982       | 160,33                | Large Market   | ... |
| RS      | 132           | 5276           | 789            | 5417         | 877825        | 162,05                | Medium Market  | ... |
| PR      | 360           | 4881           | 3042           | 4985         | 795036        | 159,49                | Medium Market  | ... |
| SC      | 197           | 3529           | 1491           | 3598         | 607518        | 168,85                | Medium Market  | ... |


### Columns 9-14

| country | ... | revenue_order_<br>profile | max_orders_by_<br>single_customer | average_spent_<br>by_customer | percent_customer_<br>above_average | domestic_orders_<br>with_percent | foreign_orders_<br>with_percent |
|---------|-----|-----------------------|------------------------------|---------------------------|--------------------------------|------------------------------|-----------------------------|
| SP      | ... | Low Value             | 16                           | 145.93€                   | 29,62 %                        | 31.079 &#124; 75,58%        | 10.044 &#124; 24,42%        |
| RJ      | ... | Low Value             | 6                            | 170.93€                   | 29,00 %                        | 1.021 &#124; 8,04%          | 11.678 &#124; 91,96%        |
| MG      | ... | Low Value             | 7                            | 163.82€                   | 29,44 %                        | 1.597 &#124; 13,89%         | 9.904 &#124; 86,11%         |
| RS      | ... | Low Value             | 4                            | 166.38€                   | 28,81 %                        | 292 &#124; 5,39%            | 5.125 &#124; 94,61%         |
| PR      | ... | Low Value             | 6                            | 162.88€                   | 28,15 %                        | 739 &#124; 14,82%           | 4.246 &#124; 85,18%         |
| SC      | ... | Low Value             | 4                            | 172.15€                   | 28,56 %                        | 274 &#124; 7,62%            | 3.324 &#124; 92,38%         |


---

## 💻 The Query

```sql
WITH customer_seller_product_stats AS (
    -- Calculate total unique customers, sellers, and products by country
    SELECT dg.country,
           COUNT(DISTINCT dc.customer_unique_id) AS total_customers,
           COUNT(DISTINCT ds.seller_id) AS total_sellers,
           COUNT(DISTINCT dp.product_id) AS total_products
    FROM gold.dim_geolocation dg
    LEFT JOIN gold.dim_customers dc 
        ON dg.zip_code = dc.customer_zip_code
    LEFT JOIN gold.dim_sellers ds 
        ON dg.zip_code = ds.seller_zip_code
    LEFT JOIN gold.fact_order_items foi 
        ON foi.seller_id = ds.seller_id
    LEFT JOIN gold.dim_products dp 
        ON dp.product_id = foi.product_id
    GROUP BY dg.country
),

order_revenue_stats AS (
    -- Calculate total orders and total revenue by country
    -- Excluding canceled and unavailable orders
    SELECT dg.country,
           COUNT(DISTINCT fo.order_id) AS total_orders,
           SUM(fp.total) AS total_revenue
    FROM gold.fact_orders fo
    LEFT JOIN gold.fact_payments fp 
        ON fo.order_id = fp.order_id
    LEFT JOIN gold.dim_customers dc 
        ON dc.customer_id = fo.customer_id
    LEFT JOIN gold.dim_geolocation dg 
        ON dg.zip_code = dc.customer_zip_code
    WHERE fo.order_status NOT IN ('canceled','unavailable')
    GROUP BY dg.country
),

max_orders_per_customer AS (
    -- Find the maximum number of orders placed by a single customer per country
    SELECT DISTINCT country,
           max_orders_by_single_customer
    FROM (
        SELECT dg.country,
               dc.customer_unique_id,
               COUNT(DISTINCT fo.order_id) AS num_orders,
               MAX(COUNT(DISTINCT fo.order_id)) OVER (PARTITION BY dg.country) 
                   AS max_orders_by_single_customer
        FROM gold.fact_orders fo
        LEFT JOIN gold.dim_customers dc 
            ON fo.customer_id = dc.customer_id
        LEFT JOIN gold.dim_geolocation dg 
            ON dg.zip_code = dc.customer_zip_code
        WHERE fo.order_status NOT IN ('canceled', 'unavailable')
        GROUP BY dg.country, dc.customer_unique_id
    ) AS sub
    WHERE num_orders = max_orders_by_single_customer
),

customer_spending AS (
    -- Calculate spending per customer and the average spending by country
    SELECT dg.country,
           dc.customer_unique_id,
           SUM(fp.total) AS customer_spending,
           AVG(SUM(fp.total)) OVER (PARTITION BY dg.country) AS avg_country_spending
    FROM gold.fact_orders fo
    LEFT JOIN gold.fact_payments fp 
        ON fo.order_id = fp.order_id
    LEFT JOIN gold.dim_customers dc 
        ON dc.customer_id = fo.customer_id
    LEFT JOIN gold.dim_geolocation dg 
        ON dg.zip_code = dc.customer_zip_code
    WHERE fo.order_status NOT IN ('canceled','unavailable')
    GROUP BY dg.country, dc.customer_unique_id
),

above_avg_customers AS (
    -- Count how many customers spend more than the average in their country
    SELECT country,
           COUNT(DISTINCT customer_unique_id) AS customers_above_avg_spending
    FROM customer_spending
    WHERE customer_spending > avg_country_spending
    GROUP BY country
),

domestic_foreign_orders AS (
    -- Calculate orders by country distinguishing between domestic and foreign sellers
    SELECT gc.country AS customer_country,
           CASE 
               WHEN gc.country = gs.country THEN 'domestic'
               ELSE 'foreign'
           END AS order_type,
           COUNT(DISTINCT fo.order_id) AS order_count
    FROM gold.fact_orders fo
    JOIN gold.dim_customers dc 
        ON fo.customer_id = dc.customer_id
    JOIN gold.dim_geolocation gc 
        ON dc.customer_zip_code = gc.zip_code
    JOIN gold.fact_order_items foi 
        ON foi.order_id = fo.order_id
    JOIN gold.dim_sellers ds 
        ON foi.seller_id = ds.seller_id
    JOIN gold.dim_geolocation gs 
        ON ds.seller_zip_code = gs.zip_code
    WHERE fo.order_status NOT IN ('canceled','unavailable')
    GROUP BY gc.country,
             CASE 
                WHEN gc.country = gs.country THEN 'domestic'
                ELSE 'foreign'
             END
),

domestic_foreign_summary AS (
    -- Summarize domestic vs foreign orders by country
    SELECT customer_country AS country,
           SUM(CASE WHEN order_type = 'domestic' THEN order_count ELSE 0 END) AS domestic_orders,
           SUM(CASE WHEN order_type = 'foreign' THEN order_count ELSE 0 END) AS foreign_orders
    FROM domestic_foreign_orders
    GROUP BY customer_country
)

-- Final aggregation and classification
SELECT stat.country AS country,
       stat.total_sellers,
       stat.total_customers,
       stat.total_products,
       revenue.total_orders,
       ROUND(revenue.total_revenue,0) AS total_revenue,
       ROUND(revenue.total_revenue * 1.0 / revenue.total_orders, 2) AS avg_revenue_per_order,

       -- Market segmentation based on size (orders and revenue thresholds)
       CASE
           WHEN revenue.total_orders > 10000 AND revenue.total_revenue > 1000000 THEN 'Large Market'
           WHEN revenue.total_orders BETWEEN 1000 AND 10000 
                AND revenue.total_revenue BETWEEN 200000 AND 1000000 THEN 'Medium Market'
           ELSE 'Small Market'
       END AS market_segment,

       -- Order value profile based on avg revenue per order (198 as benchmark)
       CASE
           WHEN ROUND(revenue.total_revenue * 1.0 / revenue.total_orders, 2) >= 198 THEN 'High Value'
           WHEN ROUND(revenue.total_revenue * 1.0 / revenue.total_orders, 2) BETWEEN 180 AND 197 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS revenue_order_profile,

       max_cust.max_orders_by_single_customer,
       CAST(ROUND(revenue.total_revenue / stat.total_customers, 2) AS varchar) + '€' 
           AS average_spent_by_customer,

       FORMAT(CAST(above.customers_above_avg_spending AS FLOAT) / stat.total_customers * 100, 'N2') + ' %' 
           AS percent_customer_above_average,

       FORMAT(domestic_foreign.domestic_orders, 'N0') + ' | ' + 
       FORMAT(100.0 * domestic_foreign.domestic_orders / revenue.total_orders, 'N2') + '%' 
           AS domestic_orders_with_percent,

       FORMAT(revenue.total_orders - domestic_foreign.domestic_orders, 'N0') + ' | ' +
       FORMAT(100.0 - (100.0 * domestic_foreign.domestic_orders / revenue.total_orders), 'N2') + '%' 
           AS foreign_orders_with_percent

FROM customer_seller_product_stats stat
JOIN order_revenue_stats revenue 
    ON stat.country = revenue.country
JOIN max_orders_per_customer max_cust 
    ON stat.country = max_cust.country
JOIN above_avg_customers above 
    ON stat.country = above.country
JOIN domestic_foreign_summary domestic_foreign 
    ON stat.country = domestic_foreign.country
ORDER BY total_revenue DESC;
```

---
## Main Key Metrics Explained
| Metric                                          | Thresholds / Calculation                                                                                                                     | Description                                                                                                                                         |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Market Segment**                              | **Large**: orders > 10000 & revenue > 1000000 <br> **Medium**: orders 1000–10000 & revenue 200000–1000000 <br> **Small**: all others | Classifies country markets by size |
| **Revenue per Order Profile**                   | **High**: ≥198 <br> **Medium**: 180–197 <br> **Low**: <198                                                                                   | Categorizes countries by average order value                                     |
| **Max Orders by Single Customer**               | `MAX(COUNT(DISTINCT order_id)) OVER (PARTITION BY country)`                                                                                  | Identifies outliers or very active customers                              |
| **Average Spent per Customer**                  | `total_revenue / total_customers`                                                                                                            | Shows how much a typical customer spends in each country                                       |
| **Percent of Customers Above Average Spending** | `(customers_above_avg_spending / total_customers) * 100`                                                                                     | Indicates the share of high-value customers                                                        |
| **Domestic vs. Foreign Orders**                 | Domestic: orders where customer\_country = seller\_country <br> Foreign: orders where customer\_country ≠ seller\_country                    | Measures cross-border activity                                                 |

---

## 💡 Why This Query Is Useful for the Business

1. **Market segmentation**: allows classification of markets (Large / Medium / Small) using simple thresholds based on orders and revenue; useful to prioritize commercial and operational investments (market expansion, marketing campaigns, seller onboarding).  
2. **Average order value**: identifies countries with high/low "order value" — a fundamental input for pricing, promotions, and discount policies.  
3. **Domestic vs. cross-border analysis**: helps understand the share of local vs. foreign demand; impacts logistics, customs, taxation, and shipping policies.  
4. **Customer spending distribution**: knowing how many customers spend above the average helps define retention and up-sell targets (e.g., loyalty programs, targeted campaigns).  
5. **Outlier identification**: detecting customers with unusually high order counts (max orders by single customer) is useful for account management or to investigate potential fraud / hidden B2B activity.  
6. **Inventory and assortment sizing**: by knowing the number of active products per country and the number of sellers, companies can optimize assortment and manage SKU investment.  

---
## 🚀 How to Leverage This Output for Further Analysis

The output of this query provides a **rich foundation of country-level metrics**, but it can be extended and integrated in several ways to generate deeper insights:

1. **Integration with Marketing Data**  
   - Combine with campaign performance data (click-through rates, conversions, promotions) to identify which market segments respond best to different strategies.  
   - Use `percent_customer_above_average` to target high-value customers with personalized offers or loyalty programs.

2. **Cross-Referencing with Product Analytics**  
   - Link `total_products` and `total_sellers` with product category or inventory data to understand which categories drive revenue in each country.  
   - Identify underperforming SKUs or markets where assortment expansion could increase sales.

3. **Advanced Customer Segmentation**  
   - Leverage `average_spent_by_customer` and `max_orders_by_single_customer` to classify customers into segments (high-value, repeat buyers, occasional buyers) for targeted retention strategies.  
   - Track cross-border activity (`domestic_orders_with_percent` vs `foreign_orders_with_percent`) to adjust international shipping policies or promotional campaigns.

4. **Visualization in BI Tools**  
   - Import the query output into Power BI, Tableau, or Looker to create **interactive dashboards**:  
     - Compare revenue vs order volume per country  
     - Visualize high-value markets geographically  
     - Track trends over time (when combined with timestamped data)  

5. **Scenario Analysis & Forecasting**  
   - Use historical market segmentation and revenue profiles to simulate the impact of marketing initiatives or new seller onboarding.  
   - Combine with external economic or demographic data to predict growth potential in each country.

6. **Cross-Layer Insights**  
   - Integrate this dataset with silver/gold layer analytics (e.g., detailed order items, payment types) to drill down from country-level insights to product- or customer-level actions.  
   - Monitor KPIs over time and feed into automated reporting pipelines for operational decision-making.

---

## ⚙️ Technical Details and Interesting SQL Techniques

- **CTEs (Common Table Expressions)**: the query is structured into logical, reusable blocks.  
  This makes the logic easier to read, debug, and test (each CTE can be run in isolation).

- **Aggregate → Derived → Window pattern**: when applying a window function (e.g., `AVG`, `MAX`) on top of already aggregated results (e.g., spending per customer), you need a two-step approach:  
  1. Aggregate at the customer level.  
  2. Apply the window function on the derived set.  
  This avoids errors and database limitations.

- **`COUNT(DISTINCT ...)` usage**: applied frequently to reduce the risk of double-counting caused by joins with transactional tables (`order_items`, `payments`).  
  ⚠️ Note: this operation is expensive on large datasets, so to consider alternative solutions on larger dataset.

- **Divide-by-zero handling**: use `NULLIF(..., 0)` or `CASE WHEN ... > 0 THEN ... ELSE 0 END` to prevent runtime errors or `INF` values.

- **`FORMAT(...)` for readability**: functions like `FORMAT(..., 'N2')` are handy for displaying results, but they can be slow in large-scale aggregations.  
  👉 Best practice: perform calculations numerically and handle formatting at the visualization layer (BI tool).

- **`LEFT JOIN` vs `INNER JOIN`**: in `customer_seller_product_stats`, `LEFT JOIN`s ensure countries with no customers or sellers are still included in the output.  
  👉 Use `INNER JOIN` to restrict the dataset to countries with complete information.

- **Robustness**: the use of `ISNULL/NULLIF` and `LEFT JOIN`s in the final select makes the query more tolerant of missing data.
