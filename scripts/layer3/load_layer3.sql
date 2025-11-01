/*
===========================
Create Views for Layer 3
===========================
Purpose: 
		This script creates views for Layer 3, these views can be further used for anlytics. 
		Dimension ans fact tables are formed.
*/

-- Creating customer dimension view
DROP VIEW IF EXISTS layer3.dim_customers;
GO
CREATE VIEW layer3.dim_customers AS
SELECT
ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS firstname,
ci.cst_lastname AS lastname,
la.cntry AS country,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the priority source for gender
	ELSE ISNULL(ca.gen, 'n/a')
END AS gender,
ci.cst_marital_status AS marital_status,
ca.bdate AS birth_date,
ci.cst_create_date AS create_date
FROM layer2.crm_cust_info AS ci
LEFT JOIN layer2.erp_CUST_AZ12 AS ca 
	ON ci.cst_key = ca.cid 
LEFT JOIN layer2.erp_LOC_A101 AS la
	ON ci.cst_key = la.cid
GO

-- Creating product dimension view
DROP VIEW IF EXISTS layer3.dim_products;
GO
CREATE VIEW layer3.dim_products AS
SELECT 
ROW_NUMBER() OVER (ORDER BY pin.prd_start_dt, pin.prd_key) AS product_key,
pin.prd_id AS product_id,
pin.cat_id AS category_id,
pin.prd_key AS product_number,
pin.prd_nm AS product_name,
pin.prd_cost AS cost,
pin.prd_line AS product_line,
pin.prd_start_dt AS start_date,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance 
FROM layer2.crm_prd_info AS pin
LEFT JOIN layer2.erp_PX_CAT_G1V2 AS pc
	ON pin.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out the historical data
GO

-- Creating sales fact view
DROP VIEW IF EXISTS layer3.fact_sales;
GO
CREATE VIEW layer3.fact_sales AS
SELECT
s.sls_ord_num AS order_number,
p.product_key,
c.customer_key,
s.sls_order_dt AS order_date,
s.sls_ship_dt AS shipping_date,
s.sls_due_dt AS due_date,
s.sls_sales AS sales,
s.sls_price AS price,
s.sls_quantity AS quantity
FROM layer2.crm_sales_details s
LEFT JOIN layer3.dim_customers c
	ON s.sls_cust_id = c.customer_id
LEFT JOIN layer3.dim_products p
	ON s.sls_prd_key = p.product_number