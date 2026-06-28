sql
CREATE OR REPLACE VIEW analytics.v_sales_analysis AS

SELECT
    s.sale_id,
    c.date_clean AS sale_date,

    st.store_id,
    st.store_name,
    st.store_city,
    st.store_location,

    p.product_id,
    p.product_name,
    p.product_category,

    s.units,

    p.product_cost_num AS product_cost,
    p.product_price_num AS product_price,

    s.units::numeric * p.product_price_num AS revenue,
    s.units::numeric * p.product_cost_num AS cost,
    s.units::numeric * (p.product_price_num - p.product_cost_num) AS profit

FROM analytics.sales AS s

LEFT JOIN analytics.calendar AS c
       ON s.date = c.date_clean

LEFT JOIN analytics.stores AS st
       ON s.store_id = st.store_id

LEFT JOIN analytics.products AS p
       ON s.product_id = p.product_id;

