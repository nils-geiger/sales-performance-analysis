sql
-- Monthly Revenue & Profit Margin

SELECT
    DATE_TRUNC('month', sale_date) AS month,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(
        100 * SUM(profit) / SUM(revenue),
        2
    ) AS profit_margin_pct
FROM analytics.v_sales_analysis
GROUP BY month
ORDER BY month;


-- Top 5 Products by Revenue

SELECT
    product_name,
    ROUND(SUM(revenue), 2) AS revenue
FROM analytics.v_sales_analysis
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 5;


-- Top 8 Stores by Revenue

SELECT
    store_name,
    ROUND(SUM(revenue), 2) AS revenue
FROM analytics.v_sales_analysis
GROUP BY store_name
ORDER BY revenue DESC
LIMIT 8;


-- Profit by Product Category

SELECT
    product_category,
    ROUND(SUM(profit), 2) AS profit
FROM analytics.v_sales_analysis
GROUP BY product_category
ORDER BY profit DESC;

