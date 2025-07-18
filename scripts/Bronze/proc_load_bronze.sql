/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
USE DataWarehouse;
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '===================================';
        PRINT 'Loading Bronze Layer';
        PRINT '===================================';

        PRINT '===================================';
        PRINT 'Loading CRM tables';
        PRINT '===================================';

        SET @start_time = GETDATE();
        PRINT 'Truncating table: crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT 'Inserting data into table: crm_cust_info';
        BULK INSERT bronze.crm_cust_info 
        FROM 'D:\Trainings\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (

            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '===================================';

        SELECT COUNT(*) FROM bronze.crm_cust_info;

        PRINT 'Truncating table: crm_prd_info';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT 'Inserting data into table: crm_prd_info';
        BULK INSERT bronze.crm_prd_info 
        FROM 'D:\Trainings\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (

            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '===================================';

        SELECT COUNT(*) FROM bronze.crm_prd_info;


        PRINT 'Truncating table: crm_sales_details';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT 'Inserting data into table: crm_sales_details';
        BULK INSERT bronze.crm_sales_details 
        FROM 'D:\Trainings\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (

            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '===================================';

        SELECT COUNT(*) FROM bronze.crm_sales_details;

        PRINT '===================================';
        PRINT 'Loading ERP tables';
        PRINT '===================================';

        PRINT 'Truncating table: erp_loc_a101';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT 'Inserting data into table: erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101 
        FROM 'D:\Trainings\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH (

            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '===================================';

        SELECT COUNT(*) FROM bronze.erp_loc_a101;

        PRINT 'Truncating table: erp_cust_az12';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT 'Inserting data into table: erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12 
        FROM 'D:\Trainings\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        WITH (

            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '===================================';

        SELECT COUNT(*) FROM bronze.erp_cust_az12;


        PRINT 'Truncating table: erp_px_cat_g1v2';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT 'Inserting data into table: erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2 
        FROM 'D:\Trainings\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (

            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '===================================';

        SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;

        SET @batch_end_time = GETDATE();
        PRINT '===================================';
        PRINT 'Bronze Layer Loading is completed' 
        PRINT 'Total Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
        PRINT '===================================';


    END TRY
    BEGIN CATCH
        PRINT '===================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===================================';

    END CATCH
END;


EXEC bronze.load_bronze

