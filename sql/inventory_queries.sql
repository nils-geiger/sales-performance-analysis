-- ============================================================
-- INVENTORY EXTENSION
-- ============================================================
-- Assumes analytics.inventory has columns:
-- store_id, product_id, stock_on_hand
--
-- Inventory is a point-in-time snapshot. Missing store-product
-- combinations are NOT automatically treated as zero stock.


-- 1. Inventory snapshot KPIs

SELECT
    SUM(i.stock_on_hand::numeric) AS stock_units,
    ROUND(
        SUM(
            i.stock_on_hand::numeric
            * TRIM(REPLACE(p.product_cost, '$', ''))::numeric
        ),
        2
    ) AS inventory_cost_value,
    ROUND(
        SUM(
            i.stock_on_hand::numeric
            * TRIM(REPLACE(p.product_price, '$', ''))::numeric
        ),
        2
    ) AS inventory_retail_value,
    COUNT(*) FILTER (WHERE i.stock_on_hand::numeric = 0) AS explicit_zero_stock_rows
FROM analytics.inventory AS i
JOIN analytics.products AS p
  ON i.product_id = p.product_id;


-- 2. Inventory-table completeness check

WITH expected AS (
    SELECT
        (SELECT COUNT(*) FROM analytics.stores)
        *
        (SELECT COUNT(*) FROM analytics.products) AS expected_pairs
),
actual AS (
    SELECT COUNT(*) AS actual_pairs
    FROM analytics.inventory
)
SELECT
    expected_pairs,
    actual_pairs,
    expected_pairs - actual_pairs AS missing_pairs
FROM expected
CROSS JOIN actual;


-- 3. Products with the most explicit zero-stock locations

SELECT
    p.product_name,
    COUNT(*) FILTER (WHERE i.stock_on_hand::numeric = 0) AS zero_stock_stores,
    SUM(i.stock_on_hand::numeric) AS stock_units
FROM analytics.inventory AS i
JOIN analytics.products AS p
  ON i.product_id = p.product_id
GROUP BY p.product_name
HAVING COUNT(*) FILTER (WHERE i.stock_on_hand::numeric = 0) > 0
ORDER BY zero_stock_stores DESC, p.product_name;


-- 4. Estimated days of cover using the final 30 days of sales

WITH bounds AS (
    SELECT MAX(sale_date) AS max_date
    FROM analytics.v_sales_analysis
),
sales_30d AS (
    SELECT
        s.store_id,
        s.product_id,
        SUM(s.units) AS units_last_30d
    FROM analytics.v_sales_analysis AS s
    CROSS JOIN bounds AS b
    WHERE s.sale_date BETWEEN b.max_date - INTERVAL '29 days'
                          AND b.max_date
    GROUP BY s.store_id, s.product_id
)
SELECT
    st.store_name,
    p.product_name,
    i.stock_on_hand::numeric AS stock_on_hand,
    COALESCE(s.units_last_30d, 0) AS units_last_30d,
    ROUND(COALESCE(s.units_last_30d, 0) / 30.0, 2) AS avg_daily_units,
    CASE
        WHEN COALESCE(s.units_last_30d, 0) > 0
        THEN ROUND(
            i.stock_on_hand::numeric
            / (s.units_last_30d / 30.0),
            1
        )
        ELSE NULL
    END AS days_of_cover
FROM analytics.inventory AS i
JOIN analytics.stores AS st
  ON i.store_id = st.store_id
JOIN analytics.products AS p
  ON i.product_id = p.product_id
LEFT JOIN sales_30d AS s
  ON i.store_id = s.store_id
 AND i.product_id = s.product_id
ORDER BY days_of_cover ASC NULLS LAST;
