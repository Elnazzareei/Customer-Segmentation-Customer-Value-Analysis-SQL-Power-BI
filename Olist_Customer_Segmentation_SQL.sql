-- Check database and source table
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;


SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
    'olist_customers_dataset',
    'olist_orders_dataset',
    'olist_order_items_dataset',
    'olist_order_payments_dataset'
  )
ORDER BY table_name, ordinal_position;


-- Check data quality
SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM public.olist_customers_dataset
UNION ALL
SELECT 'orders', COUNT(*) FROM public.olist_orders_dataset
UNION ALL
SELECT 'order_items', COUNT(*) FROM public.olist_order_items_dataset
UNION ALL
SELECT 'payments', COUNT(*) FROM public.olist_order_payments_dataset;

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_not_null,
    COUNT(customer_id) AS customer_id_not_null,
    COUNT(order_status) AS status_not_null,
    COUNT(order_purchase_timestamp) AS purchase_timestamp_not_null
FROM public.olist_orders_dataset;

SELECT customer_id, COUNT(*) AS occurrences
FROM public.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id, order_item_id, COUNT(*) AS occurrences
FROM public.olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT order_status, COUNT(*) AS number_of_orders
FROM public.olist_orders_dataset
GROUP BY order_status
ORDER BY number_of_orders DESC;


-- Clean orders
DROP TABLE IF EXISTS public.orders_clean;

CREATE TABLE public.orders_clean AS
SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    NULLIF(TRIM(customer_id), '') AS customer_id,
    NULLIF(TRIM(order_status), '') AS order_status,
    TO_TIMESTAMP(NULLIF(TRIM(order_purchase_timestamp), ''), 'MM/DD/YYYY HH24:MI')
        AS order_purchase_timestamp,
    TO_TIMESTAMP(NULLIF(TRIM(order_approved_at), ''), 'MM/DD/YYYY HH24:MI')
        AS order_approved_at,
    TO_TIMESTAMP(NULLIF(TRIM(order_delivered_carrier_date), ''), 'MM/DD/YYYY HH24:MI')
        AS order_delivered_carrier_date,
    TO_TIMESTAMP(NULLIF(TRIM(order_delivered_customer_date), ''), 'MM/DD/YYYY HH24:MI')
        AS order_delivered_customer_date,
    TO_TIMESTAMP(NULLIF(TRIM(order_estimated_delivery_date), ''), 'MM/DD/YYYY HH24:MI')
        AS order_estimated_delivery_date
FROM public.olist_orders_dataset;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(*) - COUNT(order_purchase_timestamp) AS missing_purchase_timestamps
FROM public.orders_clean;



-- Clean customers
DROP TABLE IF EXISTS public.customers_clean;

CREATE TABLE public.customers_clean AS
SELECT
    NULLIF(TRIM(customer_id), '') AS customer_id,
    NULLIF(TRIM(customer_unique_id), '') AS customer_unique_id,
    customer_zip_code_prefix,
    NULLIF(TRIM(customer_city), '') AS customer_city,
    NULLIF(TRIM(customer_state), '') AS customer_state
FROM public.olist_customers_dataset;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(customer_unique_id) AS customer_unique_id_not_null
FROM public.customers_clean;


-- Clean order items
DROP TABLE IF EXISTS public.order_items_clean;

CREATE TABLE public.order_items_clean AS
SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    order_item_id,
    NULLIF(TRIM(product_id), '') AS product_id,
    NULLIF(TRIM(seller_id), '') AS seller_id,
    TO_TIMESTAMP(NULLIF(TRIM(shipping_limit_date), ''), 'MM/DD/YYYY HH24:MI')
        AS shipping_limit_date,
    price,
    freight_value
FROM public.olist_order_items_dataset;


SELECT COUNT(*) AS unmatched_order_items
FROM public.order_items_clean oi
LEFT JOIN public.orders_clean o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;



-- Clean payments
DROP TABLE IF EXISTS public.payments_clean;

CREATE TABLE public.payments_clean AS
SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    payment_sequential,
    NULLIF(TRIM(payment_type), '') AS payment_type,
    payment_installments,
    payment_value
FROM public.olist_order_payments_dataset;

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_not_null,
    COUNT(payment_value) AS payment_value_not_null
FROM public.payments_clean;


-- Aggregate order items and payments
DROP TABLE IF EXISTS public.order_items_summary;

CREATE TABLE public.order_items_summary AS
SELECT
    order_id,
    COUNT(*) AS total_items,
    COUNT(DISTINCT product_id) AS unique_products,
    SUM(price) AS total_product_price,
    SUM(freight_value) AS total_freight
FROM public.order_items_clean
GROUP BY order_id;

DROP TABLE IF EXISTS public.payments_summary;

CREATE TABLE public.payments_summary AS
SELECT
    order_id,
    SUM(payment_value) AS total_payment_value,
    COUNT(*) AS payment_count,
    MAX(payment_installments) AS max_installments
FROM public.payments_clean
GROUP BY order_id;


-- Build the order-level master table
DROP TABLE IF EXISTS public.orders_master;

CREATE TABLE public.orders_master AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    COALESCE(i.total_items, 0) AS total_items,
    COALESCE(i.unique_products, 0) AS unique_products,
    COALESCE(i.total_product_price, 0) AS total_product_price,
    COALESCE(i.total_freight, 0) AS total_freight,
    COALESCE(p.total_payment_value, 0) AS total_payment_value,
    COALESCE(p.payment_count, 0) AS payment_count,
    COALESCE(p.max_installments, 0) AS max_installments
FROM public.orders_clean o
LEFT JOIN public.order_items_summary i ON o.order_id = i.order_id
LEFT JOIN public.payments_summary p ON o.order_id = p.order_id;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(total_payment_value) AS total_payment_value
FROM public.orders_master;



-- Join orders and customer identities
DROP TABLE IF EXISTS public.orders_customer;

CREATE TABLE public.orders_customer AS
SELECT
    o.*,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state
FROM public.orders_master o
LEFT JOIN public.customers_clean c ON o.customer_id = c.customer_id;

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(customer_unique_id) AS orders_with_customer,
    COUNT(*) - COUNT(customer_unique_id) AS orders_without_customer
FROM public.orders_customer;


-- Filter delivered orders
DROP TABLE IF EXISTS public.delivered_orders;

CREATE TABLE public.delivered_orders AS
SELECT *
FROM public.orders_customer
WHERE order_status = 'delivered';

SELECT
    COUNT(*) AS delivered_order_rows,
    COUNT(DISTINCT order_id) AS unique_delivered_orders,
    COUNT(DISTINCT customer_unique_id) AS delivered_customers,
    ROUND(SUM(total_payment_value)::numeric, 2) AS delivered_order_payment_value,
    SUM(total_items) AS delivered_items
FROM public.delivered_orders;


-- Calculate customer-level value and behavior
DROP TABLE IF EXISTS public.customer_value;

CREATE TABLE public.customer_value AS
SELECT
    customer_unique_id,
    MIN(order_purchase_timestamp) AS first_purchase_date,
    MAX(order_purchase_timestamp) AS last_purchase_date,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_items) AS total_items,
    SUM(total_payment_value) AS total_spent,
    AVG(total_payment_value) AS average_order_value,
    SUM(total_freight) AS total_freight
FROM public.delivered_orders
WHERE customer_unique_id IS NOT NULL
GROUP BY customer_unique_id;

SELECT
    COUNT(*) AS customer_rows,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    SUM(total_orders) AS delivered_orders,
    ROUND(SUM(total_spent)::numeric, 2) AS total_customer_value
FROM public.customer_value;


-- Prepare the RFM dataset
DROP TABLE IF EXISTS public.customer_rfm;

CREATE TABLE public.customer_rfm AS
SELECT
    customer_unique_id,
    DATE '2018-08-30' - DATE(last_purchase_date) AS recency,
    total_orders AS frequency,
    ROUND(total_spent::numeric, 2) AS monetary,
    first_purchase_date,
    last_purchase_date,
    total_items,
    average_order_value,
    total_freight
FROM public.customer_value;

SELECT *
FROM public.customer_rfm
ORDER BY monetary DESC
LIMIT 10;


-- Calculate the RFM score
DROP TABLE IF EXISTS public.customer_rfm_scored;

CREATE TABLE public.customer_rfm_scored AS
SELECT
    *,
    6 - NTILE(5) OVER (ORDER BY recency) AS recency_score,
    CASE
        WHEN frequency = 1 THEN 1
        WHEN frequency = 2 THEN 2
        WHEN frequency = 3 THEN 3
        WHEN frequency = 4 THEN 4
        WHEN frequency >= 5 THEN 5
    END AS frequency_score,
    NTILE(5) OVER (ORDER BY monetary) AS monetary_score
FROM public.customer_rfm;

DROP TABLE IF EXISTS public.customer_rfm_final;

CREATE TABLE public.customer_rfm_final AS
SELECT
    *,
    recency_score + frequency_score + monetary_score AS rfm_score
FROM public.customer_rfm_scored;

SELECT rfm_score, COUNT(*) AS customers
FROM public.customer_rfm_final
GROUP BY rfm_score
ORDER BY rfm_score;


-- Assign final customer segment
DROP TABLE IF EXISTS public.customer_segments_v2;

CREATE TABLE public.customer_segments_v2 AS
SELECT
    *,
    CASE
        WHEN recency_score >= 4 AND monetary_score >= 4
            THEN 'High-Value Recent Customers'
        WHEN recency_score >= 4 AND frequency_score = 1
            THEN 'Recent One-Time Customers'
        WHEN recency_score >= 3
             AND frequency_score >= 2
             AND monetary_score >= 3
            THEN 'Loyal Customers'
        WHEN recency_score <= 2 AND monetary_score <= 2
            THEN 'Low-Value Inactive'
        WHEN recency_score <= 2
            THEN 'Needs Attention'
        ELSE 'Developing Customers'
    END AS customer_segment
FROM public.customer_rfm_final;


-- Analyze customer segments
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(recency_days)::numeric, 2) AS avg_recency_days,
    ROUND(AVG(delivered_orders)::numeric, 2) AS avg_orders,
    ROUND(AVG(total_customer_value)::numeric, 2) AS avg_customer_value,
    ROUND(SUM(total_customer_value)::numeric, 2) AS total_customer_value
FROM public.customer_segments_powerbi
GROUP BY customer_segment
ORDER BY customer_segment;


-- Create power BI dataset
DROP TABLE IF EXISTS public.customer_segments_powerbi;

CREATE TABLE public.customer_segments_powerbi AS
SELECT
    customer_unique_id,
    customer_segment,
    recency AS recency_days,
    frequency AS delivered_orders,
    monetary AS total_customer_value,
    recency_score,
    frequency_score,
    monetary_score,
    rfm_score,
    first_purchase_date,
    last_purchase_date
FROM public.customer_segments_v2;


-- Validate final results
SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    ROUND(SUM(total_customer_value)::numeric, 2) AS total_customer_value
FROM public.customer_segments_powerbi;

SELECT
    (SELECT ROUND(SUM(total_payment_value)::numeric, 2)
     FROM public.delivered_orders) AS delivered_orders_payment_value,
    (SELECT ROUND(SUM(total_customer_value)::numeric, 2)
     FROM public.customer_segments_powerbi) AS customer_value_total;

SELECT
    customer_segment,
    COUNT(*) AS customers
FROM public.customer_segments_powerbi
GROUP BY customer_segment
ORDER BY customers DESC;









