/*
=================
Load layer2
=================
Purpose:
    This stored procedure cleans and standardizes data from the layer 1. It then loads the clean data into the 
    layer 2 tables.Truncates the layer 2 tables tables before loading data.

This stored procedures does not take any parameters.
*/

CREATE OR ALTER PROCEDURE layer2.load_layer2 AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_batch DATETIME, @end_time_batch DATETIME;
	BEGIN TRY
		SET @start_time_batch = GETDATE();

		-- Cleaning and standardizing the data crm_cust_info
		SET @start_time = GETDATE();
		PRINT 'Truncation table layer2.crm_cust_info' 
		TRUNCATE TABLE layer2.crm_cust_info;
		PRINT 'Inserting data into the table layer2.crm_cust_info' 
		INSERT INTO layer2.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT 
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE UPPER(TRIM(cst_marital_status))
			WHEN 'M' THEN 'Married'
			WHEN 'S' THEN 'Single'
			ELSE 'n/a'
		END cst_marital_status,
		CASE UPPER(TRIM(cst_gndr))
			WHEN 'F' THEN 'Female'
			WHEN 'M' THEN 'Male'
			ELSE 'n/a'
		END cst_gndr,
		cst_create_date
		FROM (
		SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM layer1.crm_cust_info
		WHERE cst_id IS NOT NULL
		)t WHERE flag_last = 1
		SET @end_time = GETDATE();
		PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
		PRINT '---------------------------------'

		-- Cleaning and standardizing the data crm_prd_info
		SET @start_time = GETDATE();
		PRINT 'Truncation table layer2.crm_prd_info' 
		TRUNCATE TABLE layer2.crm_prd_info;
		PRINT 'Inserting data into the table layer2.crm_prd_info' 
		INSERT INTO layer2.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost, 0) AS prd_cost,
		CASE UPPER(TRIM(prd_line))
			 WHEN 'M'THEN 'Mountain'
			 WHEN 'R'THEN 'Road'
			 WHEN 'S'THEN 'Other Sales'
			 WHEN 'M'THEN 'Touring'
			 ELSE 'n\a'
		END AS prd_line,
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
		FROM layer1.crm_prd_info
		SET @end_time = GETDATE();
		PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
		PRINT '---------------------------------'

		-- Cleaning and standardizing the data crm_sales_details
		SET @start_time = GETDATE();
		PRINT 'Truncation table layer2.crm_sales_details' 
		TRUNCATE TABLE layer2.crm_sales_details;
		PRINT 'Inserting data into the table layer2.crm_sales_details' 
		INSERT INTO layer2.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_price,
		sls_quantity
		)
		SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE WHEN sls_sales IS NULL OR  sls_sales < 1 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
			 ELSE sls_sales
		END AS sls_sales,
		CASE WHEN sls_price < 1 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
			 ELSE sls_price
		END AS sls_price,
		sls_quantity
		FROM layer1.crm_sales_details
		SET @end_time = GETDATE();
		PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
		PRINT '---------------------------------'

		-- Cleaning and standardizing the data erp_CUST_AZ12
		SET @start_time = GETDATE();
		PRINT 'Truncation table layer2.erp_CUST_AZ12' 
		TRUNCATE TABLE layer2.erp_CUST_AZ12;
		PRINT 'Inserting data into the table layer2.erp_CUST_AZ12' 
		INSERT INTO layer2.erp_CUST_AZ12 (
		cid,
		bdate,
		gen
		)
		SELECT 
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid
		END AS cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END AS bdate,
		CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			ELSE 'n\a'
		END AS gen
		FROM layer1.erp_CUST_AZ12
		SET @end_time = GETDATE();
		PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
		PRINT '---------------------------------'

		-- Cleaning and standardizing the data in erp_LOC_A101
		SET @start_time = GETDATE();
		PRINT 'Truncation table layer2.erp_LOC_A101' 
		TRUNCATE TABLE layer2.erp_LOC_A101;
		PRINT 'Inserting data into the table layer2.erp_LOC_A101' 
		INSERT INTO layer2.erp_LOC_A101 (
		cid,
		cntry
		)
		SELECT 
		REPLACE(cid, '-', '') AS cid,
		CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
			WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
			WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n\a'
			ELSE TRIM(cntry)
		END AS cntry
		FROM layer1.erp_LOC_A101
		SET @end_time = GETDATE();
		PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
		PRINT '---------------------------------'

		-- Cleaning and standardizing the data in erp_PX_CAT_G1V2
		SET @start_time = GETDATE();
		PRINT 'Truncation table layer2.erp_PX_CAT_G1V2' 
		TRUNCATE TABLE layer2.erp_PX_CAT_G1V2;
		PRINT 'Inserting data into the table layer2.erp_PX_CAT_G1V2' 
		INSERT INTO layer2.erp_PX_CAT_G1V2 (
		id,
		cat,
		subcat,
		maintenance
		)
		SELECT 
		id,
		cat,
		subcat,
		maintenance
		FROM layer1.erp_PX_CAT_G1V2
		SET @end_time = GETDATE();
		PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
		SET @end_time_batch = GETDATE();
		PRINT '=================================='
		PRINT 'Layer 2 load complete'
		PRINT 'Load duration: ' + CAST(DATEDIFF(second, @start_time_batch, @end_time_batch) AS NVARCHAR) + ' seconds';
		PRINT '=================================='
	END TRY
	BEGIN CATCH
		PRINT '==================================='
		PRINT 'ERROR DURING LOADING OF LAYER 2'
		PRINT 'ERROR MESSAGE ' + ERROR_MESSAGE();
		PRINT 'ERROR CODE ' + ERROR_NUMBER();
		PRINT '==================================='
	END CATCH
END