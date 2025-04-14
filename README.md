# Bike Sales Business Analysis

![image](https://github.com/user-attachments/assets/c0fc832a-510d-4c92-b1fe-7f806ebf3d50)

## Table of Contents

- [Project Introduction](#project-introduction)
    - [Bike Sales Business Analysis SQL Queries](#bike-sales-business-analysis-sql-queries)
    - [Bike Sales Business Analysis Dataset](#bike-sales-business-analysis-dataset)
- [Analysis Outline](#analysis-outline)

## Project Introduction

In this descriptive analysis, I will identify trends and relationships within the current and historical data and evaluate the financial performance of this company using MySQL. During the analysis process, I want to see if I can help optimize their business opportunities by answering key business-related questions. This analysis will be split into three parts: geographic performance, product performance, and seasonal performance.

### Bike Sales Business Analysis SQL Queries
All SQL queries on GitHub.

Link: [Bike Sales Business Analysis](https://github.com/jasondo-da/Bike_Sales_Financial_Analysis/blob/main/bike_sales_queries.sql)

### Bike Sales Business Analysis Dataset (In Process)

The Bike Store Relational Database | SQL is a Kaggle-based dataset that samples the database from sqlservertutorial.net. This dataset provides a detailed overview of consumer purchasing behaviors, shipping data, order details, transaction data, and store inventory data. 

Link: [Original Kaggle Dataset](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database)


## Analysis Outline

-- Geographic Performance --

/* What are the total historical sales by state? */
```sql
SELECT 
  c.state,
  ROUND(SUM(ot.quantity * ot.list_price), 2) total_order_price
FROM customers c
LEFT JOIN orders o
  ON c.customer_id = o.customer_id
LEFT JOIN order_items ot
  ON o.order_id = ot.order_id
GROUP BY c.state
```

/* 	Which areas contain the largest addressable market? */


/* 	Which cities generate the most revenue? */


/* 	Which stores are historical sales leaders and losers? */


-- Product Performance --

/* 	Which category are the best sellers? */

/* 	Which sellers generate the most sales? */

/* 	Which items are the best sellers? */

/* 	Which products are the most profitable? */

/* 	Do discounts affect total sales? */

-- Seasonal Performance --

/* 	Which months historically move the most volume?  Most Sales? */

/* 	Which month is historically the most profitable month? */

/* 	Does the shipping time affect sales? */
