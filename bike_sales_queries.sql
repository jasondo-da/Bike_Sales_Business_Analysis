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
	p.product_name,
    ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_sales
FROM order_items ot
LEFT JOIN products p
	ON ot.product_id = p.product_id
LEFT JOIN brands b
	ON p.brand_id = b.brand_id
GROUP BY p.product_name
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

/* 	Which month is historically the most profitable month? */

/* 	Does the shipping time affect sales? */
