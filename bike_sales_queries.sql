---------------
-- Query SQL --
---------------

-- Geographic Performance --

/* What are the total historical sales by state? */
SELECT 
	c.state,
    ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_state_sales
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
LEFT JOIN order_items ot
	ON o.order_id = ot.order_id
GROUP BY c.state

/* 	Which areas contain the largest addressable market? */
SELECT 
	c.state,
	COUNT(DISTINCT c.customer_id) total_customers,
    ROUND(((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)) / COUNT(c.customer_id)), 2) avg_sale_per_customer
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
LEFT JOIN order_items ot
	ON o.order_id = ot.order_id
GROUP BY c.state
ORDER BY total_customers DESC

/* 	Which cities generate the most revenue? */
SELECT 
	c.city,
    c.state,
	COUNT(DISTINCT c.customer_id) total_customers,
    ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_sales,
    ROUND(((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)) / COUNT(c.customer_id)), 2) avg_sale_per_customer
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
LEFT JOIN order_items ot
	ON o.order_id = ot.order_id
GROUP BY c.city, c.state
ORDER BY total_sales DESC
LIMIT 10

/* 	Which stores are historical sales leaders and losers? */
SELECT 
	s.store_id,
    s.store_name,
    s.state,
	COUNT(DISTINCT o.customer_id) total_customers,
    ROUND(SUM(ot.quantity * ot.list_price), 2) total_sales,
    ROUND((SUM(ot.quantity * ot.list_price) / COUNT(o.customer_id)), 2) store_avg_sale_per_customer
FROM stores s
LEFT JOIN orders o
	ON s.store_id = o.store_id
LEFT JOIN order_items ot
	ON o.order_id = ot.order_id
GROUP BY s.store_id, s.store_name, s.state
ORDER BY total_sales DESC





-- Product Performance --

/* 	Which brands generate the most sales? */
SELECT 
    b.brand_name,
    ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_sales
FROM order_items ot
LEFT JOIN products p
	ON ot.product_id = p.product_id
LEFT JOIN brands b
	ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY total_sales DESC
LIMIT 5

/* 	Which category are the best sellers? */
SELECT 
	c.category_name,
    ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_sales
FROM order_items ot
LEFT JOIN products p
	ON ot.product_id = p.product_id
LEFT JOIN categories c
	ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_sales DESC

/* 	Which items are the best sellers? */
SELECT
	p.product_id,
	p.product_name,
    ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_sales
FROM order_items ot
LEFT JOIN products p
	ON ot.product_id = p.product_id
LEFT JOIN brands b
	ON p.brand_id = b.brand_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC
LIMIT 10

/* 	Do discounts affect total sales? */
SELECT 
	ROUND(SUM(ot.quantity * ot.list_price), 2) total_sales,
    ROUND(SUM(ot.discount), 2) total_discounts,
	1 - ((SUM(ot.quantity * ot.list_price) - SUM(ot.discount))) / (SUM(ot.quantity * ot.list_price)) percentage_of_sales
FROM order_items ot






-- Seasonal Performance --

/* 	Which months historically move the most volume?  Most Sales? */
SELECT 
	MONTH(o.order_date),
    COUNT(o.order_id) total_orders,
    ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) net_sales,
    ROUND(((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)) / COUNT(o.order_id)), 2) avg_order_total
FROM orders o
LEFT JOIN order_items ot
	ON o.order_id = ot.order_id
GROUP BY MONTH(o.order_date)

/* 	Does the shipping time affect sales? */
WITH late_orders AS (
	SELECT 
		COUNT(o.order_id) total_late_orders,
		ROUND(((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)) / (COUNT(o.order_id))), 2) avg_total_per_late_order
	FROM orders o
	LEFT JOIN order_items ot
		ON o.order_id = ot.order_id
	WHERE o.shipped_date > o.required_date),
total_orders AS (
	SELECT 
		COUNT(o.order_id) total_orders,
		ROUND(((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)) / (COUNT(o.order_id))), 2) avg_total_per_order
	FROM orders o
	LEFT JOIN order_items ot
		ON o.order_id = ot.order_id)

SELECT 
	total_orders,
    avg_total_per_order,
    total_late_orders,
    avg_total_per_late_order,
    ROUND(((total_late_orders / total_orders) * 100), 2) percentage_late_orders,
    ROUND((avg_total_per_order - avg_total_per_late_order), 2) net_sales_change
FROM total_orders, late_orders

/* Which stores have the most rejected sales? */
SELECT 
	s.store_id,
	COUNT(*)
FROM orders o
LEFT JOIN stores s
	ON o.store_id = s.store_id
WHERE o.order_status = 3
GROUP BY s.store_id
