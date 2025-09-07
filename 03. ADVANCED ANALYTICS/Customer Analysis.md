# 📊 Customer Segmentation & RFM Analysis

## 🎯 Purpose

> This document contains a **customer-level segmentation** SQL workflow built on the `gold` layer of the data warehouse. The pipeline computes order totals, per-customer statistics (recency, frequency, monetary), spending quartiles, RFM quartiles and final segments that are actionable for marketing, retention and product teams.

---

## 📑 Table of Contents

1. [Assumptions](#-assumptions)
2. [Table Mapping](#-table-mapping)
3. [Output](#-output)
   - [Columns 1-7](#columns-1-7)  
   - [Columns 8-13](#columns-8-13)  
5. [The Query](#-the-query)
6. [Key Metrics Explained](#-key-metrics-explained)
7. [Why This Is Useful for the Business](#-why-this-is-useful-for-the-business)
8. [How the End User Can Leverage The Output](#-how-the-end-user-can-leverage-the-output)
9. [Technical Details & SQL Techniques](#-technical-details--sql-techniques)
10. [Performance & Productionization Notes](#-performance--productionization-notes)
11. [Next Steps / Reproducibility](#-next-steps--reproducibility)

---

## 📌 Assumptions

- **Reference data**: entire dataset available in `gold` (no date filter is applied by default). If you need a specific time window, add `WHERE order_purchase_timestamp BETWEEN @from AND @to` in `order_totals`.
- **Excluded orders**: orders with `order_status` in (`'canceled','unavailable'`) are excluded.
- **Customer identity**: all aggregations use `customer_unique_id` (logical customer identifier) to avoid counting multiple internal `customer_id` values as separate customers.
- **Multiple payments per order**: the query sums `fact_payments.total` per `order_id` to normalize multi-payment orders.
- **Simplified CLV / Avg monthly value**: computed as `total_spent / active_months` (proxy). If you prefer true CLV, integrate churn/retention modeling and margins.

---

## 🗂️ Table Mapping

- `gold.fact_orders` — order headers (order_id, customer_id, order_status, order_purchase_timestamp)
- `gold.fact_payments` — payments per order (order_id, payment_type, total)
- `gold.dim_customers` — customer master (customer_id, customer_unique_id)

---

## 📝 Output

| customer_unique_id | first_order | last_order | recency_days | total_orders | active_months | avg_days_between_orders | total_spent | avg_order_value | order_value_stddev | avg_monthly_value | customer_segment_base | customer_segment_RFM |
|--------------------|-------------|------------|--------------:|-------------:|--------------:|-----------------------:|------------:|---------------:|-------------------:|------------------:|----------------------|---------------------:|
| 8d50f5eadf50201ccdcedfb9e2ac8455 | 2017-05 | 2018-08 | 14  | 16 | 10 | 30 | 902.04  | 56.38 | 39.76 | 58.57  | High Value | Low Value |
| 3e43e6105506432c953e165fb2acf44c | 2017-09 | 2018-02 | 188 | 9  | 4  | 20 | 1172.66 | 130.30 | 91.72 | 217.16 | High Value | Low Value |
| 1b6c7548a2a1f9037c1fd3ddfed95f33 | 2017-11 | 2018-02 | 201 | 7  | 4  | 15 | 959.01  | 137.00 | 80.70 | 309.36 | High Value | Low Value |
| 6469f99c1f9dfae7733b25662e7f1782 | 2017-09 | 2018-06 | 67  | 7  | 6  | 47 | 758.83  | 108.40 | 77.63 | 80.73  | High Value | Low Value |
| ca77025e7201e3b30c44b472ff346268 | 2017-10 | 2018-06 | 94  | 7  | 6  | 39 | 1122.72 | 160.39 | 77.07 | 143.33 | High Value | Low Value |
| 47c1a3033b8b77b3ab6e109eb4d5fdf3 | 2017-08 | 2018-01 | 222 | 6  | 4  | 34 | 944.21  | 157.37 | 134.56| 166.63 | High Value | Low Value |

### Columns 1-7

| customer_unique_id               |  first_order | last_order | recency_days | total_orders | active_months | avg_days_<br>between_orders | ... |
|----------------------------------|--------------|------------|-------------:|-------------:|--------------:|------------------------:|----:|
| 8d50f5eadf50201ccdcedfb9e2ac8455 | 2017-05      | 2018-08    | 14           |  16          | 10            | 30                      | ... |
| 3e43e6105506432c953e165fb2acf44c | 2017-09      | 2018-02    | 188          | 9            | 4             | 20                      | ... |
| 1b6c7548a2a1f9037c1fd3ddfed95f33 | 2017-11      | 2018-02    | 201          | 7            | 4             | 15                      | ... | 
| 6469f99c1f9dfae7733b25662e7f1782 | 2017-09      | 2018-06    | 67           | 7            | 6             | 47                      | ... | 
| ca77025e7201e3b30c44b472ff346268 | 2017-10      | 2018-06    | 94           | 7            | 6             | 39                      | ... |
| 47c1a3033b8b77b3ab6e109eb4d5fdf3 | 2017-08      | 2018-01    | 222          | 6            | 4             | 34                      | ... |


### Columns 8-13
| customer_unique_id               | ... | total_<br>spent | avg_order<br>_value | order_value_<br>stddev | avg_monthly_<br>value | customer_<br>segment_base | customer_<br>segment_RFM |
|----------------------------------|-----|----------------:|---------------------:|-----------------------:|----------------------:|--------------------------:|-------------------------:|
| 8d50f5eadf50201ccdcedfb9e2ac8455 | ... | 902.04          | 56.38                | 39.76                  | 58.57                 | High Value                | Low Value                |
| 3e43e6105506432c953e165fb2acf44c | ... | 1172.66         | 130.30               | 91.72                  | 217.16                | High Value                | Low Value                |
| 1b6c7548a2a1f9037c1fd3ddfed95f33 | ... | 959.01          | 137.00               | 80.70                  | 309.36                | High Value                | Low Value                |
| 6469f99c1f9dfae7733b25662e7f1782 | ... | 758.83          | 108.40               | 77.63                  | 80.73                 | High Value                | Low Value                |
| ca77025e7201e3b30c44b472ff346268 | ... | 1122.72         | 160.39               | 77.07                  | 143.33                | High Value                | Low Value                |
| 47c1a3033b8b77b3ab6e109eb4d5fdf3 | ... | 944.21          | 157.37               | 134.56                 | 166.63                | High Value                | Low Value                |

---

## 💻 The Query

```sql
WITH order_totals AS (
    -- Calculate total payment per order
    SELECT
        fo.order_id,
        fo.customer_id,
        fo.order_purchase_timestamp,
        SUM(fp.total) AS order_total  -- sum payments for each order
    FROM gold.fact_orders fo
    JOIN gold.fact_payments fp
        ON fo.order_id = fp.order_id
    WHERE fo.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY fo.order_id, fo.customer_id, fo.order_purchase_timestamp
),

customer_stats AS (
    -- Calculate customer statistics
    SELECT
        dc.customer_unique_id,
        MIN(ot.order_purchase_timestamp) AS first_order_date,  -- first purchase date
        MAX(ot.order_purchase_timestamp) AS last_order_date,   -- most recent purchase date
        COUNT(DISTINCT ot.order_id) AS total_orders,
        COUNT(DISTINCT FORMAT(ot.order_purchase_timestamp, 'yyyyMM')) AS active_months, -- Number of months in which the customer made purchases (proxy engagement)
        SUM(ot.order_total) AS total_spent,
        AVG(ot.order_total) AS avg_order_value,
        STDEV(ot.order_total) AS order_value_stddev,
        -- simplified monthly CLV proxy: total spent divided by months active
        SUM(ot.order_total) / NULLIF(DATEDIFF(DAY, MIN(ot.order_purchase_timestamp), MAX(ot.order_purchase_timestamp)) / 30.0, 0) AS avg_monthly_value
    FROM order_totals ot
    JOIN gold.dim_customers dc
        ON ot.customer_id = dc.customer_id
    GROUP BY dc.customer_unique_id
),

max_date AS (
    -- Single-row table with the dataset's last global order date (used for recency calculation),to understand if customers have come back
    SELECT MAX(order_purchase_timestamp) AS global_last_order_date
    FROM order_totals
),

spending_quartiles AS (
    -- Calculate quartiles (NTILE divides customers into 4 groups based on total_spent)
    SELECT
        cs.*,
        NTILE(4) OVER (ORDER BY cs.total_spent) AS spending_quartile
        -- 1 = low, 2 = medium-low 3 = medium-high 4 = high
    FROM customer_stats cs
),

rfm_quartiles AS (
    -- Calculate RFM quartiles. We reuse spending_quartile as monetary_quartile.
    SELECT
        sq.*,
        sq.spending_quartile AS monetary_quartile,
        NTILE(4) OVER (ORDER BY total_orders DESC) AS frequency_quartile,  -- Purchase frequence: higher orders -> higher quartile
        NTILE(4) OVER (ORDER BY DATEDIFF(DAY, last_order_date, md.global_last_order_date)) AS recency_quartile -- Days form last purchase: smaller days -> more recent
    FROM spending_quartiles sq
    CROSS JOIN max_date md
),


final_segments AS (
    -- Build segmentation based on spending and RFM
    SELECT *,
        -- Base segmentation
        CASE spending_quartile
            WHEN 4 THEN 'High Value'
            WHEN 3 THEN 'Upper Mid Value'
            WHEN 2 THEN 'Lower Mid Value'
            WHEN 1 THEN 'Low Value'
        END AS customer_segment_base,

        -- RFM segemntation combining  teh 3 parameters
        CASE
            WHEN monetary_quartile = 4 AND frequency_quartile = 4 AND recency_quartile = 1 THEN 'Top Champions'
            WHEN monetary_quartile >= 3 AND frequency_quartile >= 3 AND recency_quartile <= 2 THEN 'Loyal High Value'
            WHEN monetary_quartile >= 2 AND frequency_quartile >= 2 THEN 'Mid Value Regular'
            WHEN recency_quartile >= 3 THEN 'At Risk'
            ELSE 'Low Value'
        END AS customer_segment_RFM
    FROM rfm_quartiles
)

-- Final output & aggregation
SELECT
    customer_unique_id,
    FORMAT(first_order_date, 'yyyy-MM') AS first_order,
    FORMAT(last_order_date, 'yyyy-MM') AS last_order,
    DATEDIFF(DAY, last_order_date, (SELECT global_last_order_date FROM max_date)) AS recency_days,
    total_orders,
    active_months,
    CASE
        WHEN total_orders = 1 THEN '1 --> Unique Order' -- CUstomers with an unique order
        WHEN DATEDIFF(DAY, first_order_date, last_order_date) / (total_orders - 1) = 0 THEN '>1 --> More Orders the same day' -- More orders, but all the same day
        ELSE CAST(ROUND(DATEDIFF(DAY, first_order_date, last_order_date) / (total_orders - 1), 2) AS VARCHAR(20))
    END AS avg_days_between_orders,
    total_spent,
    ROUND(avg_order_value, 2) AS avg_order_value,
    ROUND(order_value_stddev, 2) AS order_value_stddev,
    ROUND(avg_monthly_value, 2) AS avg_monthly_value,
    customer_segment_base,
    customer_segment_RFM
FROM final_segments
ORDER BY total_orders DESC;
```

---

## 🔑 Key Metrics Explained

| Metric | Calculation / Notes | Purpose |
|---|---|---|
| **First / Last Order** | `MIN` / `MAX` of `order_purchase_timestamp` per customer | Establishes the customer's lifecycle window
| **Recency (days)** | Days between customer's last_order and dataset last order | Proxy for engagement; used in recency quartile
| **Total Orders** | `COUNT(DISTINCT order_id)` | Frequency measure used for RFM
| **Active Months** | Count distinct `yyyyMM` months with orders | Engagement depth: frequent monthly buyers vs burst buyers
| **Avg Days Between Orders** | `(last - first) / (orders - 1)` (special-case handling for single-day orders) | Measures pacing of repeat purchases
| **Total Spent** | Sum of order totals per customer | Monetary metric for segmentation
| **Avg Order Value** | `AVG(order_total)` | Typical basket size
| **Order Value StdDev** | `STDEV(order_total)` | Dispersion of order values
| **Avg Monthly Value** | `total_spent / active_months` (proxy CLV) | Simple proxy for recurring monthly revenue from the customer
| **Spending Quartile** | `NTILE(4)` on `total_spent` | Quick stratification into 4 equal groups
| **RFM quartiles** | `NTILE(4)` on recency, frequency, monetary | Classic segmentation building block
| **Customer segments** | rules combining quartiles → human-readable labels | Actionable groups for marketing/retention

---

## 💡 Why This Is Useful for the Business

- **Prioritize retention efforts**: identify "Top Champions" and "Loyal High Value" customers for VIP programs.  
- **Targeted reactivation**: focus "At Risk" customers with win-back campaigns.  
- **Promotions & offers**: tune promotions by segment (e.g., cross-sell to "Mid Value Regulars").  
- **Product & category insights**: correlate segments with SKU preferences to optimize assortment and merchandising.  
- **Operational planning**: forecast recurring revenue from avg_monthly_value and model impact of retention improvements.

---

## 🚀 How the End User Can Leverage The Output

1. **Import into BI dashboards** (Power BI / Tableau / Looker): create interactive filters by segment, heatmaps of recency vs frequency, and funnel visualizations.  
2. **Feed Marketing Automation**: export Top Champions and Loyal High Value customer lists to CRM / email platforms for personalized flows.  
3. **Churn detection & early warning**: monitor movement between RFM segments over time; customers sliding toward "At Risk" can be automatically flagged.  
4. **Cohort & retention analysis**: combine with first_order date to measure retention curves by cohort and segment.  
5. **A/B test offers**: run promotion experiments per segment and measure lift on average order value and repeat purchase rate.

---

## ⚙️ Technical Details & SQL Techniques

- **CTEs**: modular steps (normalization → customer aggregates → quartiles → segmentation) improve readability and testing.  
- **NTILE for quartiles**: partitions customers into approximately equal-sized buckets; sensitive to ties and distribution skew.  
- **Window functions**: used for quartiles and ranking without subqueries.  
- **Cross join for global scalar**: `CROSS JOIN max_date` attaches the dataset-level last_date to every customer row for recency calc.  
- **Null-safe division**: `NULLIF(...,0)` used to avoid division-by-zero when computing avg_monthly_value.  
- **Edge-case handling**: `avg_days_between_orders` checks `total_orders = 1` and same-day repeat orders.

---

## ⚠️ Performance & Productionization Notes

- `NTILE(4)` and `STDEV` on very large customer bases can be expensive. Consider:
  - Pre-aggregating `order_totals` in a materialized view / nightly batch.  
  - Using approximate quantiles (if supported) for very large datasets.  
- Index suggestions: `fact_orders(order_id, customer_id, order_purchase_timestamp)`, `fact_payments(order_id)`, `dim_customers(customer_id, customer_unique_id)`.  
- If `fact_payments` contains multiple rows per order (split payments), the `SUM(fp.total)` per `order_id` step avoids double-counting.  
- If you plan incremental runs, persist intermediate `order_totals` and `customer_stats` into a `mart` table with a timestamp partition.

---
