# Bike Sales Business Analysis

![image](https://github.com/user-attachments/assets/c0fc832a-510d-4c92-b1fe-7f806ebf3d50)

## Table of Contents

- [Project Introduction](#project-introduction)
	- [Bike Sales Business Analysis SQL Queries](#bike-sales-business-analysis-sql-queries)
	- [Bike Sales Business Analysis Dataset](#bike-sales-business-analysis-dataset)
- [Analysis Outline](#analysis-outline)

## Project Introduction

In this descriptive analysis, I will identify trends and relationships within the current and historical data and evaluate the financial performance of this company using MySQL. During the analysis process, I want to see if I can help optimize their business opportunities by answering key business-related questions.

## Bike Sales Business Analysis SQL Queries
All SQL queries on GitHub.

Link: [Bike Sales Business Analysis](https://github.com/jasondo-da/Bike_Sales_Financial_Analysis/blob/main/bike_sales_queries.sql)

## Bike Sales Business Analysis Dataset

The Bike Store Relational Database | SQL is a Kaggle-based dataset that samples the database from sqlservertutorial.net. This dataset provides a detailed overview of consumer purchasing behaviors, shipping data, order details, transaction data, and store inventory data. 

Link: [Original Kaggle Dataset](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database)

Database Diagram:

![Screenshot 2025-04-22 182641](https://github.com/user-attachments/assets/ed61363d-65b3-49de-af5c-8f2d7d4ae2ec)



## Analysis Outline

``` sql
/* Which brands generate the most sales? */
SELECT
	b.brand_name,
	ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_sales,
	RANK() OVER(ORDER BY ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) DESC) brand_sales_rank
FROM order_items ot
LEFT JOIN products p
	ON ot.product_id = p.product_id
LEFT JOIN brands b
	ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY total_sales DESC
LIMIT 5
```

``` sql
/* Which category are the best sellers? */
SELECT 
	c.category_name,
	ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_sales,
	RANK() OVER(ORDER BY ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) DESC) category_sales_rank
FROM order_items ot
LEFT JOIN products p
	ON ot.product_id = p.product_id
LEFT JOIN categories c
	ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_sales DESC
```

``` sql
/* Which items are the best sellers? */
SELECT
	p.product_id,
	p.product_name,
	ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_sales,
	RANK() OVER(ORDER BY ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) DESC) product_sales_rank
FROM order_items ot
LEFT JOIN products p
	ON ot.product_id = p.product_id
LEFT JOIN brands b
	ON p.brand_id = b.brand_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC
LIMIT 10
```

``` sql
/* Do discounts affect total sales? */
SELECT 
	ROUND(SUM(ot.quantity * ot.list_price), 2) total_sales,
	ROUND(SUM(ot.discount), 2) total_discounts,
	1 - ((SUM(ot.quantity * ot.list_price) - SUM(ot.discount))) / (SUM(ot.quantity * ot.list_price)) percentage_of_sales
FROM order_items ot
```

``` sql
/* Which months historically move the most volume?  Most Sales? */
SELECT 
	MONTHNAME(o.order_date) month,
	COUNT(o.order_id) total_orders,
	ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) net_sales,
	ROUND(((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)) / COUNT(o.order_id)), 2) avg_order_total,
	RANK() OVER(ORDER BY ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) DESC) monthly_sales_rank
FROM orders o
LEFT JOIN order_items ot
	ON o.order_id = ot.order_id
GROUP BY month
```

``` sql
/* Does the shipping time affect sales? */
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
```

``` sql
/* Which stores have the most rejected sales? */
SELECT 
	s.store_id,
	COUNT(*) total_rejected_orders,
	RANK() OVER(ORDER BY COUNT(*) DESC) store_rank
FROM orders o
LEFT JOIN stores s
	ON o.store_id = s.store_id
WHERE o.order_status = 3
GROUP BY s.store_id
```

``` sql
/* What are the total historical sales by state? */
SELECT 
	c.state,
	ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_state_sales,
	RANK() OVER(ORDER BY ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) DESC) state_rank
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
LEFT JOIN order_items ot
	ON o.order_id = ot.order_id
GROUP BY c.state
```

``` sql
/* Which areas contain the largest addressable market? */
SELECT 
	c.state,
	COUNT(DISTINCT c.customer_id) total_customers,
	COUNT(o.order_id) total_orders,
	ROUND((COUNT(o.order_id) / COUNT(DISTINCT c.customer_id)), 2) avg_orders_per_customer,
	ROUND(((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)) / COUNT(c.customer_id)), 2) avg_sale_per_customer
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
LEFT JOIN order_items ot
	ON o.order_id = ot.order_id
GROUP BY c.state
ORDER BY total_customers DESC
```

``` sql
/* Which cities generate the most revenue? */
SELECT 
	c.city,
	c.state,
	COUNT(DISTINCT c.customer_id) total_customers,
	ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) total_sales,
	ROUND(((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)) / COUNT(c.customer_id)), 2) avg_sale_per_customer,
	RANK() OVER(ORDER BY ROUND((SUM(ot.quantity * ot.list_price) - SUM(ot.discount)), 2) DESC) city_sales_rank
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
LEFT JOIN order_items ot
	ON o.order_id = ot.order_id
GROUP BY c.city, c.state
ORDER BY total_sales DESC
LIMIT 10
```

``` sql
/* Which stores are historical sales leaders and losers? */
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
```
