/*
=============================
Sales Trends Analysis
=============================
Purpose: 
		Analyze sales performance and customer trends over time 
		and calculate cumulative and moving average metrics.
*/

-- Changes over time (year)
SELECT 
	YEAR(order_date) AS order_year,
	SUM(sales) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM layer3.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Changes over time (month)
SELECT 
	MONTH(order_date) AS order_month,
	SUM(sales) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM layer3.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

-- Changes over time (year, month)
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_year_month,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers
FROM layer3.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');

-- Cumulative analysis

-- Total sales per month & running total over time (for each year)
SELECT
	order_year_month,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY order_year_month ORDER BY order_year_month) AS running_total,
	AVG(avg_price) OVER (PARTITION BY order_year_month ORDER BY order_year_month) AS moving_avg
FROM 
	(SELECT
		DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_year_month,
		SUM(sales) AS total_sales,
		AVG(price) AS avg_price
	FROM layer3.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)) t
