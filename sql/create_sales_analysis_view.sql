-- Reusable transaction-level analytical view for sales reporting.
-- Assumes the original Maven CSV tables have been loaded into the analytics schema.

CREATE OR REPLACE VIEW analytics.v_sales_analysis AS

WITH base AS (
    SELECT
        s.sale_id,
        s.date::date AS sale_date,

        st.store_id,
        st.store_name,
        st.store_city,
        st.store_location,

        p.product_id,
        p.product_name,
        p.product_category,

        s.units::numeric AS units,

        TRIM(REPLACE(p.product_cost, '$', ''))::numeric AS product_cost,
        TRIM(REPLACE(p.product_price, '$', ''))::numeric AS product_price

    FROM analytics.sales AS s

    LEFT JOIN analytics.stores AS st
           ON s.store_id = st.store_id

    LEFT JOIN analytics.products AS p
           ON s.product_id = p.product_id
)

SELECT
    sale_id,
    sale_date,
    store_id,
    store_name,
    store_city,
    store_location,
    product_id,
    product_name,
    product_category,
    units,
    product_cost,
    product_price,
    units * product_price AS revenue,
    units * product_cost AS cost,
    units * (product_price - product_cost) AS profit
FROM base;
