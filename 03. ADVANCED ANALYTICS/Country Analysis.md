# Advanced Analytics: Country Market Summary (2016–2018)

**Scopo**

Questo documento contiene la query SQL (commentata riga-per-riga) che produce un riassunto di mercato per *country* a partire dal layer `gold` del data warehouse. L'obiettivo è fornire metriche chiave — clienti, seller, prodotti, ordini, revenue, profilo di mercato e indicatori di cross-border — utili per decisioni commerciali e operative.

**Periodo di riferimento**: completo dal 2016 al 2018 (assunto nella query).\
**Nota**: la query esclude gli ordini con `order_status` in (`'canceled','unavailable'`).

---

## Mappatura tabelle (breve)

- `gold.dim_geolocation` — informazioni geografico/postali (zip_code → country)
- `gold.dim_customers` — anagrafica clienti (customer_id, customer_unique_id, customer_zip_code)
- `gold.dim_sellers` — anagrafica venditori (seller_id, seller_zip_code)
- `gold.fact_order_items` — righe di ordine (order_id, seller_id, product_id, quantity, price...)
- `gold.dim_products` — anagrafica prodotti (product_id, category...)
- `gold.fact_orders` — header ordine (order_id, customer_id, order_status, order_purchase_timestamp...)
- `gold.fact_payments` — pagamenti per ordine (order_id, payment_type, total...)

---

| country | total_sellers | total_customer | total_products | total_orders | total_revenue | avg_revenue_per_order | market_segment | revenue_order_profile | max_orders_by_single_customer | average_spent_by_customer | percent_customer_above_average | domestic_orders_with_percent | foreign_orders_with_percent |
|---------|---------------|----------------|----------------|--------------|---------------|-----------------------|----------------|-----------------------|------------------------------|---------------------------|--------------------------------|------------------------------|-----------------------------|
| SP      | 1816          | 40290          | 22750          | 41123        | 5879410       | 142,97                | Large Market   | Low Value             | 16                           | 145.93€                   | 29,62 %                        | 31.079 &#124; 75,58%        | 10.044 &#124; 24,42%        |
| RJ      | 176           | 12379          | 1555           | 12699        | 2115884       | 166,62                | Large Market   | Low Value             | 6                            | 170.93€                   | 29,00 %                        | 1.021 &#124; 8,04%          | 11.678 &#124; 91,96%        |
| MG      | 250           | 11256          | 2824           | 11501        | 1843982       | 160,33                | Large Market   | Low Value             | 7                            | 163.82€                   | 29,44 %                        | 1.597 &#124; 13,89%         | 9.904 &#124; 86,11%         |
| RS      | 132           | 5276           | 789            | 5417         | 877825        | 162,05                | Medium Market  | Low Value             | 4                            | 166.38€                   | 28,81 %                        | 292 &#124; 5,39%            | 5.125 &#124; 94,61%         |
| PR      | 360           | 4881           | 3042           | 4985         | 795036        | 159,49                | Medium Market  | Low Value             | 6                            | 162.88€                   | 28,15 %                        | 739 &#124; 14,82%           | 4.246 &#124; 85,18%         |
| SC      | 197           | 3529           | 1491           | 3598         | 607518        | 168,85                | Medium Market  | Low Value             | 4                            | 172.15€                   | 28,56 %                        | 274 &#124; 7,62%            | 3.324 &#124; 92,38%         |


---

## Query completa (commentata riga-per-riga)

```sql
/*
  Query: Country Market Summary
  Dialetto: SQL Server (FORMAT, CONCAT con '+', CAST ... come nell'esempio originale).
  Note generali:
  - Uso di CTE per modularità e per evitare ripetizioni.
  - Alcune aggregazioni vengono calcolate in step intermedi per abilitare l'uso di window function
    su risultati già aggregati (pattern: aggregate -> derived -> window).
  - Attenzione a eventuali duplicazioni dovute ai join (per questo si usano COUNT(DISTINCT ...)).
*/

WITH

-- CTE1: conteggi di base per country (clienti unici, seller unici, prodotti distinti)
cte1 AS (
    SELECT
        dg.country,
        -- numero di clienti distinti associati a questa geolocalizzazione
        COUNT(DISTINCT dc.customer_unique_id) AS total_customers,
        -- numero di seller distinti nella stessa geolocalizzazione
        COUNT(DISTINCT ds.seller_id) AS total_sellers,
        -- numero di prodotti distinti che compaiono negli order_items associati ai seller
        -- (attenzione: un prodotto può avere più seller, quindi può essere contato in più country)
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

-- CTE2: ordini e revenue per country (escludendo order_status cancellati / unavailable)
cte2 AS (
    SELECT
        dg.country,
        -- numero ordini validi (DISTINCT per evitare duplicazioni dovute a più righe per order in altri join)
        COUNT(DISTINCT fo.order_id) AS total_orders,
        -- somma totale dei pagamenti associati agli ordini (attenzione: se un ordine ha più pagamenti, fp.total verrà sommato più volte)
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

-- CTE3: massimo numero di ordini effettuati da un singolo cliente per country, cioè il numero massimo di ordini che è stato fatto da un cliente per paese
-- Pattern: prima calcolo num_orders per customer (aggregate), poi prendo il MAX per country
cte3_customer_orders AS (
    SELECT
        dg.country,
        dc.customer_unique_id,
        COUNT(DISTINCT fo.order_id) AS num_orders
    FROM gold.fact_orders fo
    LEFT JOIN gold.dim_customers dc
        ON fo.customer_id = dc.customer_id
    LEFT JOIN gold.dim_geolocation dg
        ON dg.zip_code = dc.customer_zip_code
    WHERE fo.order_status NOT IN ('canceled','unavailable')
    GROUP BY dg.country, dc.customer_unique_id
),
cte3 AS (
    -- qui prendo il valore massimo (numero di ordini del top customer) per country
    SELECT
        country,
        MAX(num_orders) AS max_orders_by_single_customer
    FROM cte3_customer_orders
    GROUP BY country
),

/* della cte3 c'era anche questa variante più snella:
    SELECT DISTINCT
        dg.country,
        MAX(COUNT(DISTINCT fo.order_id)) OVER (PARTITION BY dg.country) AS max_orders_by_single_customer
    FROM gold.fact_orders fo
    LEFT JOIN gold.dim_customers dc ON fo.customer_id = dc.customer_id
    LEFT JOIN gold.dim_geolocation dg ON dg.zip_code = dc.customer_zip_code
    WHERE fo.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY dg.country, dc.customer_unique_id
*/

-- CTE4: spesa per singolo customer e media di spesa per country
-- Step 1: calcolo spesa per customer
cte4a_base AS (
    SELECT
        dg.country,
        dc.customer_unique_id,
        SUM(fp.total) AS customer_spending
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
-- Step 2: calcolo la media di spesa per country usando una window function sul risultato aggregato
cte4a AS (
    SELECT
        country,
        customer_unique_id,
        customer_spending,
        AVG(customer_spending) OVER (PARTITION BY country) AS avg_country_spending
    FROM cte4a_base
),
-- CTE4b: numero di clienti che hanno speso più della media del proprio country
cte4b AS (
    SELECT
        country,
        COUNT(1) AS customers_above_avg_spending
    FROM cte4a
    WHERE customer_spending > avg_country_spending
    GROUP BY country
),

-- CTE5: ordini domestici vs esteri (considerando country del customer vs country del seller)
-- -- qui calcoliamo in base alla country del customer, Quanti ordini sono stati fatti verso seller della stessa country e quanti ordini sono stati fatti verso seller di altre country.
cte5a AS (
    SELECT
        gc.country AS customer_country,
        CASE WHEN gc.country = gs.country THEN 'domestic' ELSE 'foreign' END AS order_type,
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
    GROUP BY gc.country, CASE WHEN gc.country = gs.country THEN 'domestic' ELSE 'foreign' END
),
cte5b AS (
    SELECT
        customer_country AS country,
        SUM(CASE WHEN order_type = 'domestic' THEN order_count ELSE 0 END) AS domestic_orders,
        SUM(CASE WHEN order_type = 'foreign' THEN order_count ELSE 0 END) AS foreign_orders
    FROM cte5a
    GROUP BY customer_country
)

-- Final select: aggrego i risultati e calcolo metriche derivate
SELECT
    cte1.country AS country,
    cte1.total_sellers AS total_sellers,
    cte1.total_customers AS total_customers,
    cte1.total_products AS total_products,
    cte2.total_orders AS total_orders,
    -- arrotondo revenue totale a 0 decimali per leggibilità
    ROUND(cte2.total_revenue, 0) AS total_revenue,
    -- media revenue per order (uso divisione sicura per evitare divide-by-zero)
    CASE WHEN cte2.total_orders > 0 THEN ROUND(cte2.total_revenue * 1.0 / cte2.total_orders, 2) ELSE 0 END AS avg_revenue_per_order,

    -- segmento di mercato (semplice regola business)
    CASE
        WHEN cte2.total_orders > 10000 AND cte2.total_revenue > 1000000 THEN 'Large Market'
        WHEN cte2.total_orders BETWEEN 1000 AND 10000 AND cte2.total_revenue BETWEEN 200000 AND 1000000 THEN 'Medium Market'
        ELSE 'Small Market'
    END AS market_segment,

    -- profilo basato su revenue media per ordine (198 come riferimento di revenue media è la media compelssiva di avg_revenue_per_order)
    CASE
        WHEN CASE WHEN cte2.total_orders > 0 THEN ROUND(cte2.total_revenue * 1.0 / cte2.total_orders, 2) ELSE 0 END >= 198 THEN 'High Value'
        WHEN CASE WHEN cte2.total_orders > 0 THEN ROUND(cte2.total_revenue * 1.0 / cte2.total_orders, 2) ELSE 0 END BETWEEN 180 AND 197 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS revenue_order_profile,

    cte3.max_orders_by_single_customer AS max_orders_by_single_customer,

    -- spesa media per customer (safe division + formattazione con simbolo €)
    CAST(ROUND(cte2.total_revenue * 1.0 / NULLIF(cte1.total_customers, 0), 2) AS varchar) + '€' AS average_spent_by_customer,

    -- percentuale di clienti che spendono più della media del proprio country
    FORMAT(CAST(ISNULL(cte4b.customers_above_avg_spending, 0) AS FLOAT) / NULLIF(cte1.total_customers, 0) * 100, 'N2') + ' %' AS percent_customer_above_average,

    -- ordini domestici: count | percentuale rispetto al totale ordini del paese
    FORMAT(ISNULL(cte5b.domestic_orders, 0), 'N0') + ' | ' +
    FORMAT(CASE WHEN cte2.total_orders > 0 THEN 100.0 * ISNULL(cte5b.domestic_orders, 0) / cte2.total_orders ELSE 0 END, 'N2') + '%' AS domestic_orders_with_percent,

    -- ordini esteri: count | percentuale
    FORMAT(ISNULL(cte2.total_orders - ISNULL(cte5b.domestic_orders, 0), 0), 'N0') + ' | ' +
    FORMAT(CASE WHEN cte2.total_orders > 0 THEN 100.0 - (100.0 * ISNULL(cte5b.domestic_orders, 0) / cte2.total_orders) ELSE 0 END, 'N2') + '%' AS foreign_orders_with_percent

FROM cte1
JOIN cte2 ON cte1.country = cte2.country
LEFT JOIN cte3 ON cte1.country = cte3.country
LEFT JOIN cte4b ON cte1.country = cte4b.country
LEFT JOIN cte5b ON cte1.country = cte5b.country
ORDER BY cte2.total_revenue DESC;
```
## Assunzioni:
-periodo di riferimento completo da 2016 a 2018
-tolti dal conteggio gli ordjni cancellati e non disponibili (motivo per cui potrebbe differire il nuemro dalle analisi del silver/gold layer in dwh)
-total_customer = 96095
-total_sellers = 3095
-total_products = 32951, ma nella query ne ho 33597 poichè un prodotto può avere più seller, e quindi essere presente in più regioni
-total_orders = 98212 (esclusi i cancellati e unavailable)
-total_revenue = 15739885,59 (esclusi i cancellati e unavailable)

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

---

## Miglioramenti suggeriti / passi successivi

- Normalizzare `fact_payments` per avere una riga per `order_id` con `order_total` (pre-aggregazione) per rimuovere ambiguità sul calcolo di revenue.
- Aggiungere dimensione temporale (es. month / quarter) per trasformare l'analisi in serie storica e osservare trend.
- Calcolare metriche RFM e CLV (Customer Lifetime Value) per approfondire il segmento "High Value".
- Aggiungere metriche per seller (seller revenue share, conversion rate per seller) per ottimizzare onboarding e retention seller.
- Rendere la query parametrica (es. `@date_from`, `@date_to`) per riusabilità.
- Esportare i risultati in una tabella materializzata nightly per velocizzare le dashboard.
