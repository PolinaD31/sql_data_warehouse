/*
============================
DB exploration 
============================
Purpose:
		Explore the structure of the DB. Explore columns and metadata for tables.
*/

-- Explore DB Tables
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- Explore Table columns
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales';

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products';