-- Core project KPIs

SELECT
    MIN(sale_date) AS period_start,
    MAX(sale_date) AS period_end,
    COUNT(*) AS sales_transactions,
    SUM(units) AS units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(revenue), 0), 2) AS profit_margin_pct,
    COUNT(DISTINCT sale_date) AS trading_days,
    COUNT(DISTINCT store_id) AS stores,
    COUNT(DISTINCT store_city) AS cities,
    COUNT(DISTINCT product_id) AS products,
    COUNT(DISTINCT product_category) AS product_categories
FROM analytics.v_sales_analysis;
