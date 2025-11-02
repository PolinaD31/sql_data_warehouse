/*
=============================
Basic Analysis
=============================
Purpose: 
		This script performs initial exploratory analysis 
		on the Layer 3 views. It provides an overview 
		of key business metrics and dimensional insights.		
*/

-- Unique countries
SELECT DISTINCT country
FROM layer3.dim_customers;

-- Unique categories
SELECT DISTINCT category
FROM layer3.dim_products;

-- Explore dates
SELECT 
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS range_years
FROM layer3.fact_sales;

-- Youngest and oldes customers
SELECT 
DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS oldest,
DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS youngest
FROM layer3.dim_customers;

-- Average age 
SELECT 
AVG(DATEDIFF(YEAR, birth_date, GETDATE())) AS average_age
FROM layer3.dim_customers;

-- Total sales
SELECT SUM(sales) AS total_sales
FROM layer3.fact_sales;

-- Total sold items
SELECT SUM(quantity) AS total_items_sold
FROM layer3.fact_sales;

-- Average selling price
SELECT AVG(price) AS avg_price
FROM layer3.fact_sales;

-- Total Order count
SELECT COUNT(order_number) AS total_orders
FROM layer3.fact_sales;

SELECT COUNT(DISTINCT order_number) AS total_orders
FROM layer3.fact_sales;

-- Total number of products
SELECT COUNT(product_id) AS total_products
FROM layer3.dim_products;

SELECT COUNT(DISTINCT product_id) AS total_products
FROM layer3.dim_products;

-- Total number of customers
SELECT COUNT(customer_id) AS total_products
FROM layer3.dim_customers;

SELECT COUNT(DISTINCT customer_id) AS total_products
FROM layer3.dim_customers;

-- Total customers that have placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customer_order
FROM layer3.fact_sales;

-- Key metrics generation
SELECT 'Total Sales' AS measure_name, SUM(sales) AS measure_value FROM layer3.fact_sales
UNION ALL
SELECT 'Total Items Sold' AS measure_name, SUM(quantity) AS measure_value FROM layer3.fact_sales 
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value FROM layer3.fact_sales
UNION ALL
SELECT 'Average Customer Age' AS measure_name, 
AVG(DATEDIFF(YEAR, birth_date, GETDATE())) AS measure_value FROM layer3.dim_customers
UNION ALL
SELECT 'Total Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM layer3.fact_sales
UNION ALL
SELECT 'Total Products' AS measure_name, COUNT(DISTINCT product_id) AS measure_value FROM layer3.dim_products
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(DISTINCT customer_id) AS measure_value FROM layer3.dim_customers
UNION ALL 
SELECT 'Total Customers that Placed an Order' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM layer3.fact_sales;

------------------------------------------
-- Measures by dimensions
------------------------------------------

-- Total customers by countries
SELECT country, COUNT(customer_id) AS customer_count
FROM layer3.dim_customers 
GROUP BY country
ORDER BY COUNT(customer_id) DESC;

-- Total customers by gender
SELECT gender, COUNT(customer_id) AS customer_count
FROM layer3.dim_customers 
GROUP BY gender
ORDER BY COUNT(customer_id) DESC;

-- Total products by category
SELECT category, COUNT(DISTINCT product_id) AS product_count
FROM layer3.dim_products
GROUP BY category
ORDER BY COUNT(product_id) DESC;

-- Average cost by category
SELECT category, AVG(cost) AS average_cost
FROM layer3.dim_products
GROUP BY category
ORDER BY AVG(cost) DESC;

-- Total revenue by category
SELECT p.category, 
CASE WHEN SUM(sales) IS NULL THEN 0
	ELSE SUM(sales)
END AS total_sales
FROM layer3.fact_sales AS sls
RIGHT JOIN layer3.dim_products AS p
	ON sls.product_key = p.product_key
GROUP BY category
ORDER BY total_sales DESC;

-- Total revenue by customer
SELECT cst.customer_key, 
cst.firstname,
cst.lastname,
SUM(sls.sales) AS total_sales
FROM layer3.dim_customers AS cst
JOIN layer3.fact_sales AS sls
	ON cst.customer_key = sls.customer_key
GROUP BY 
cst.customer_key,
cst.firstname,
cst.lastname
ORDER BY total_sales DESC;

-- Total items sold by country
SELECT cst.country, SUM(sls.quantity) AS items_sold
FROM layer3.fact_sales AS sls
LEFT JOIN layer3.dim_customers AS cst
	ON cst.customer_key = sls.customer_key
GROUP BY cst.country
ORDER BY items_sold DESC;

-- Total items sold by category
SELECT p.category, 
CASE WHEN SUM(quantity) IS NULL THEN 0
	ELSE SUM(quantity)
END AS total_items_sold
FROM layer3.fact_sales AS sls
RIGHT JOIN layer3.dim_products AS p
	ON sls.product_key = p.product_key
GROUP BY category
ORDER BY total_items_sold DESC;

-- Average age by country
SELECT country, AVG(DATEDIFF(YEAR, birth_date, GETDATE())) AS average_age
FROM layer3.dim_customers
GROUP BY country
ORDER BY average_age;

-- Customers by marital status
SELECT marital_status, COUNT(customer_id) AS customer_count
FROM layer3.dim_customers
GROUP BY marital_status
ORDER BY customer_count DESC;

------------------------------------------
-- Ranking analysis
------------------------------------------

-- 7 products with highest total sales
SELECT TOP 7
p.product_key, 
p.product_name, 
SUM(sls.sales) AS total_sales
FROM layer3.fact_sales AS sls
LEFT JOIN layer3.dim_products AS p
	ON sls.product_key = p.product_key
GROUP BY 
p.product_key, 
p.product_name
ORDER BY total_sales DESC;

-- 7 products with lowest total sales (excluding products that did not sell at all)
SELECT TOP 7
p.product_key, 
p.product_name,
SUM(sls.sales) AS total_sales
FROM layer3.fact_sales AS sls
LEFT JOIN layer3.dim_products AS p
	ON sls.product_key = p.product_key
GROUP BY 
p.product_key, 
p.product_name
ORDER BY total_sales;

-- 7 subcategories with highest total sales
SELECT TOP 7
p.subcategory, 
SUM(sales) AS total_sales
FROM layer3.fact_sales AS sls
LEFT JOIN layer3.dim_products AS p
	ON sls.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY total_sales DESC;

-- 7 customers that have generated highest revenue
SELECT TOP 7
c.customer_key, 
SUM(sales) AS total_sales
FROM layer3.fact_sales AS sls
LEFT JOIN layer3.dim_customers AS c
	ON sls.customer_key = c.customer_key
GROUP BY c.customer_key
ORDER BY total_sales DESC;

-- 5 customer with most orders placed
SELECT TOP 5
c.customer_key,
c.firstname, 
c.lastname,
COUNT(DISTINCT order_number) AS total_orders
FROM layer3.fact_sales AS sls
LEFT JOIN layer3.dim_customers AS c
	ON sls.customer_key = c.customer_key
GROUP BY 
c.customer_key,
c.firstname, 
c.lastname
ORDER BY total_orders DESC;

-- 5 customer with least orders placed
SELECT TOP 5
c.customer_key,
c.firstname, 
c.lastname,
COUNT(DISTINCT order_number) AS total_orders
FROM layer3.fact_sales AS sls
LEFT JOIN layer3.dim_customers AS c
	ON sls.customer_key = c.customer_key
GROUP BY 
c.customer_key,
c.firstname, 
c.lastname
ORDER BY total_orders;

-- 3 Country with highest total sales
SELECT TOP 3
cst.country,
SUM(sls.sales) AS total_sales
FROM layer3.fact_sales AS sls
JOIN layer3.dim_customers AS cst
    ON sls.customer_key = cst.customer_key
GROUP BY cst.country
ORDER BY total_sales DESC;