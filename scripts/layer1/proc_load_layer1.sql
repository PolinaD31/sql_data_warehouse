/*
======
Bulk data insertion
======
Purpose:
	This script loads data from files into the tables.

Caution!
	In case the location of your data changes, update the filepath.
*/
CREATE OR ALTER PROCEDURE layer1.load_layer1 AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_batch DATETIME, @end_time_batch DATETIME;
	BEGIN TRY
		SET @start_time_batch = GETDATE();
		SET @start_time = GETDATE();
		TRUNCATE TABLE layer1.crm_cust_info
		BULK INSERT layer1.crm_cust_info
		-- Change to your own path 
		FROM 'C:\_GitRepos\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW  = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		SET @start_time = GETDATE();
		TRUNCATE TABLE layer1.crm_prd_info
		BULK INSERT layer1.crm_prd_info
		-- Change to your own path 
		FROM 'C:\_GitRepos\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW  = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		SET @start_time = GETDATE();
		TRUNCATE TABLE layer1.crm_sales_details
		BULK INSERT layer1.crm_sales_details
		-- Change to your own path 
		FROM 'C:\_GitRepos\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW  = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @start_time = GETDATE();
		TRUNCATE TABLE layer1.erp_CUST_AZ12
		BULK INSERT layer1.erp_CUST_AZ12
		-- Change to your own path 
		FROM 'C:\_GitRepos\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW  = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		SET @start_time = GETDATE();
		TRUNCATE TABLE layer1.erp_LOC_A101
		BULK INSERT layer1.erp_LOC_A101
		-- Change to your own path 
		FROM 'C:\_GitRepos\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW  = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		SET @start_time = GETDATE();
		TRUNCATE TABLE layer1.erp_PX_CAT_G1V2
		BULK INSERT layer1.erp_PX_CAT_G1V2
		-- Change to your own path 
		FROM 'C:\_GitRepos\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW  = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		SET @end_time_batch = GETDATE();
		PRINT '=================================='
		PRINT 'Layer 1 load complete'
		PRINT 'Load duration: ' + CAST(DATEDIFF(second, @start_time_batch, @end_time_batch) AS NVARCHAR) + ' seconds';
		PRINT '=================================='
	END TRY
	BEGIN CATCH
		PRINT '==================================='
		PRINT 'ERROR DURING LOADING OF LAYER 1'
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT '==================================='
	END CATCH
END