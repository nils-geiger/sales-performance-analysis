-- ============================================================
-- SALES PERFORMANCE ANALYSIS
-- ============================================================

-- 1. Monthly revenue, profit and margin

SELECT
    DATE_TRUNC('month', sale_date)::date AS month,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    SUM(units) AS units,
    ROUND(
        100 * SUM(profit) / NULLIF(SUM(revenue), 0),
        2
    ) AS profit_margin_pct
FROM analytics.v_sales_analysis
GROUP BY 1
ORDER BY 1;


-- 2. Like-for-like year-over-year comparison:
--    Jan-Sep 2022 vs Jan-Sep 2023

WITH period AS (
    SELECT
        EXTRACT(YEAR FROM sale_date)::int AS year,
        SUM(revenue) AS revenue,
        SUM(profit) AS profit,
        SUM(units) AS units
    FROM analytics.v_sales_analysis
    WHERE sale_date BETWEEN DATE '2022-01-01' AND DATE '2022-09-30'
       OR sale_date BETWEEN DATE '2023-01-01' AND DATE '2023-09-30'
    GROUP BY 1
),
pivoted AS (
    SELECT
        MAX(revenue) FILTER (WHERE year = 2022) AS revenue_2022,
        MAX(revenue) FILTER (WHERE year = 2023) AS revenue_2023,
        MAX(profit) FILTER (WHERE year = 2022) AS profit_2022,
        MAX(profit) FILTER (WHERE year = 2023) AS profit_2023,
        MAX(units) FILTER (WHERE year = 2022) AS units_2022,
        MAX(units) FILTER (WHERE year = 2023) AS units_2023
    FROM period
)
SELECT
    ROUND(revenue_2022, 2) AS revenue_2022_jan_sep,
    ROUND(revenue_2023, 2) AS revenue_2023_jan_sep,
    ROUND(100 * (revenue_2023 / NULLIF(revenue_2022, 0) - 1), 2) AS revenue_growth_pct,
    ROUND(profit_2022, 2) AS profit_2022_jan_sep,
    ROUND(profit_2023, 2) AS profit_2023_jan_sep,
    ROUND(100 * (profit_2023 / NULLIF(profit_2022, 0) - 1), 2) AS profit_growth_pct,
    units_2022 AS units_2022_jan_sep,
    units_2023 AS units_2023_jan_sep,
    ROUND(100 * (units_2023 / NULLIF(units_2022, 0) - 1), 2) AS units_growth_pct,
    ROUND(100 * profit_2022 / NULLIF(revenue_2022, 0), 2) AS margin_2022_pct,
    ROUND(100 * profit_2023 / NULLIF(revenue_2023, 0), 2) AS margin_2023_pct,
    ROUND(
        100 * profit_2023 / NULLIF(revenue_2023, 0)
        - 100 * profit_2022 / NULLIF(revenue_2022, 0),
        2
    ) AS margin_change_pp
FROM pivoted;


-- 3. Top 5 products by revenue + share of total revenue

WITH product_revenue AS (
    SELECT
        product_name,
        SUM(revenue) AS revenue,
        SUM(profit) AS profit,
        SUM(units) AS units
    FROM analytics.v_sales_analysis
    GROUP BY product_name
),
ranked AS (
    SELECT
        product_name,
        revenue,
        profit,
        units,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS revenue_rank,
        SUM(revenue) OVER () AS total_revenue
    FROM product_revenue
)
SELECT
    product_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(profit, 2) AS profit,
    units,
    ROUND(100 * revenue / NULLIF(total_revenue, 0), 2) AS revenue_share_pct
FROM ranked
WHERE revenue_rank <= 5
ORDER BY revenue_rank;


-- 4. Top-5 revenue concentration as one KPI
--    Current dataset result: 46.81%

WITH product_revenue AS (
    SELECT
        product_name,
        SUM(revenue) AS revenue
    FROM analytics.v_sales_analysis
    GROUP BY product_name
),
ranked AS (
    SELECT
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS revenue_rank,
        SUM(revenue) OVER () AS total_revenue
    FROM product_revenue
)
SELECT
    ROUND(
        100 * SUM(revenue) FILTER (WHERE revenue_rank <= 5)
        / MAX(total_revenue),
        2
    ) AS top5_revenue_share_pct
FROM ranked;


-- 5. Product profitability:
--    separates revenue leadership from profit leadership

SELECT
    product_name,
    product_category,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    SUM(units) AS units,
    ROUND(
        100 * SUM(profit) / NULLIF(SUM(revenue), 0),
        2
    ) AS profit_margin_pct
FROM analytics.v_sales_analysis
GROUP BY product_name, product_category
ORDER BY profit DESC;


-- 6. Product-category performance

SELECT
    product_category,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    SUM(units) AS units,
    ROUND(
        100 * SUM(profit) / NULLIF(SUM(revenue), 0),
        2
    ) AS profit_margin_pct
FROM analytics.v_sales_analysis
GROUP BY product_category
ORDER BY profit DESC;


-- 7. Top stores by revenue

SELECT
    store_name,
    store_city,
    store_location,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    SUM(units) AS units,
    ROUND(
        100 * SUM(profit) / NULLIF(SUM(revenue), 0),
        2
    ) AS profit_margin_pct
FROM analytics.v_sales_analysis
GROUP BY store_name, store_city, store_location
ORDER BY revenue DESC
LIMIT 10;


-- 8. Store-location performance normalized by number of stores

WITH store_performance AS (
    SELECT
        store_id,
        store_location,
        SUM(revenue) AS revenue,
        SUM(profit) AS profit,
        SUM(units) AS units
    FROM analytics.v_sales_analysis
    GROUP BY store_id, store_location
)
SELECT
    store_location,
    COUNT(*) AS store_count,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_store,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(profit), 2) AS avg_profit_per_store,
    ROUND(
        100 * SUM(profit) / NULLIF(SUM(revenue), 0),
        2
    ) AS profit_margin_pct
FROM store_performance
GROUP BY store_location
ORDER BY avg_revenue_per_store DESC;


-- 9. Highest-revenue days:
--    useful for detecting seasonal/event-driven spikes

SELECT
    sale_date,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    SUM(units) AS units,
    COUNT(*) AS transactions
FROM analytics.v_sales_analysis
GROUP BY sale_date
ORDER BY revenue DESC
LIMIT 10;
