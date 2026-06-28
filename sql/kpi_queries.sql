```sql
SELECT
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / SUM(revenue), 2) AS profit_margin_pct,
    COUNT(*) AS sales_transactions,
    COUNT(DISTINCT sale_date) AS trading_days,
    COUNT(DISTINCT store_id) AS stores,
    COUNT(DISTINCT product_id) AS products,
    COUNT(DISTINCT product_category) AS product_categories
FROM analytics.v_sales_analysis;
```
