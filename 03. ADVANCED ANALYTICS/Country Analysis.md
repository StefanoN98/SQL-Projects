# 📊 Advanced Analytics: Country Market Summary (2016–2018)

## 🎯 Purpose

This document contains the SQL query that produces a **market summary by country** from the `gold` layer of the data warehouse.  
The goal is to provide **key metrics** — customers, sellers, products, orders, revenue, market profile, and cross-border indicators — useful for **business and operational decision-making**.

## 📌 Assumptions

- **Reference period**: full timeframe from 2016 to 2018  
- **Excluded orders**: canceled and unavailable orders are not counted (this may cause differences compared to the silver/gold layer analyses in the DWH)  
- **Total customers** = 96,095  
- **Total sellers** = 3,095  
- **Total products** = 32,951, but in the query result there are 33,597 because a product can have multiple sellers and thus appear in multiple regions  
- **Total orders** = 98,212 (the query excludes orders with `order_status` in (`'canceled','unavailable'`)  
- **Total revenue** = 15,739,885.59 (the query excludes orders with `order_status` in (`'canceled','unavailable'`)

---

## 🗂️ Table Mapping (short overview)

- `gold.dim_geolocation` — geographic/postal information (zip_code → country) 
- `gold.dim_customers` — customer master data (customer_id, customer_unique_id, customer_zip_code)   
- `gold.dim_sellers` — seller master data (seller_id, seller_zip_code)   
- `gold.fact_order_items` — order line items (order_id, seller_id, product_id, quantity, price...)   
- `gold.dim_products` — product master data (product_id, category...)   
- `gold.fact_orders` — order header (order_id, customer_id, order_status, order_purchase_timestamp...)  
- `gold.fact_payments` — order payments (order_id, payment_type, total...)   

---

## Complete Output:

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

## The Query

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

## Perché questa query è utile al business

1. **Segmentazione mercato**: permette di classificare i mercati (Large / Medium / Small) utilizzando soglie semplici basate su ordini e revenue; utile per prioritizzare investimenti commerciali e operativi (market expansion, campagne marketing, onboarding seller).
2. **Valore medio degli ordini**: identifica paesi con "order value" alto/basso — input fondamentale per pricing, promozioni e politiche di sconto.
3. **Analisi domestico vs cross-border**: capisci la porzione di domanda locale vs estera; impatta logistica, dogane, tasse e politiche di spedizione.
4. **Distribuzione della spesa tra clienti**: sapere quanti clienti spendono sopra la media aiuta a definire target per retention e up-sell (es. loyalty program, campagne mirate).
5. **Identificazione outlier**: trovare clienti con molti ordini (max orders by single customer) è utile per account management o per investigare casi di frode / B2B nascosto.
6. **Dimensionamento inventario e assortimento**: conoscendo numero di prodotti attivi per paese e numero di seller, si può ottimizzare assortimento e gestire investimenti in SKU.

---

## Dettagli tecnici e tecniche SQL interessanti utilizzate

- **CTE (Common Table Expressions)**: struttura la logica in blocchi leggibili e riutilizzabili; facilita debug e testing (puoi eseguire singoli CTE isolati).
- **Pattern aggregate → derived → window**: quando si vuole applicare una funzione window (es. AVG/ MAX) su risultati già aggregati (es. spesa per customer), è necessario: aggregare per customer in un primo step, poi usare una window function nel passo successivo. Questo evita errori/limitazioni del DB.
- **COUNT(DISTINCT ...)**: usato spesso per ridurre il rischio di double counting causato da join a tabelle di atto (order_items, payments). Nota: è costoso su dataset grandi.
- **Gestione divide-by-zero**: uso di `NULLIF(..., 0)` oppure `CASE WHEN ... > 0 THEN ... ELSE 0 END` per evitare errori o valori `INF`.
- **FORMAT / formattazione**: `FORMAT(..., 'N2')` è comoda per visualizzazione ma può essere lenta in aggregazioni massicce; preferire calcoli numerici e formattare a livello di layer di visualizzazione (BI) quando possibile.
- **LEFT JOIN vs INNER JOIN**: i LEFT JOIN nella fase di conteggio (cte1) consentono di mostrare paesi anche privi di clienti/seller in alcuni casi. Usare INNER JOIN se si vuole restringere il dataset solo a paesi con dati completi.
- **Performance considerations**:
  - `COUNT(DISTINCT ...)` e `SUM(fp.total)` con join su payments possono essere molto costosi: valutare materialized view / pre-aggregazioni nel silver layer.
  - index raccomandati: `fact_orders(order_id, customer_id, order_status, order_purchase_timestamp)`, `fact_payments(order_id)`, `fact_order_items(order_id, seller_id, product_id)`, `dim_geolocation(zip_code)`.
  - considerare `approx_count_distinct()` (o equivalent) se si lavora su engine big-data per migliorare prestazioni.
  - in presenza di più pagamenti per ordine, normalizzare total per `order_id` (es. calcolare `revenue_per_order` in un CTE che prende SUM(fp.total) per order_id) per evitare sovrastime.
- **Robustezza**: l'uso di `ISNULL/NULLIF` e LEFT JOIN nel final select rende la query più tollerante a dati mancanti.
