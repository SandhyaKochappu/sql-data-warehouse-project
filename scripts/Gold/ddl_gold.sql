/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views in the 'gold' schema, dropping existing tables 
    The gold layer represents the final dimension and fact tables(star schema)
    Each view performs transformation and combines data from the server layer 
	to produce a clean enriched and business ready data set.
Usage: 
	  These views can be queried directly for Analytics and reporting
===============================================================================

			Create dimension:gold.dim_customers 
====================================================================
*/
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW [Gold].[dim_customers] AS 
SELECT
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	cci.cst_id customer_id,
	cci.cst_key customer_number,
	cci.cst_firstname first_name,
	cci.cst_lastname last_name,
	cci.cst_marital_status marital_status,
	CASE WHEN cci.cst_gndr != 'n/a' then cci.cst_gndr
		ELSE COALESCE(eca.gen, 'n/a')--if eca.gen is NULL, use n/a
	END gender,
	eca.bdate birth_date,
	ela.cntry country,
	cci.cst_create_date create_date	
FROM silver.crm_cust_info cci
LEFT JOIN silver.erp_cust_az12 eca
ON cci.cst_key = eca.cid
LEFT JOIN silver.erp_loc_a101 ela
ON cci.cst_key = ela.cid;


-----------------Check for data quality------------------------
SELECT DISTINCT 
gender 
FROM [Gold].[dim_customers]
--No issues-----

====================================================================
---Create dimension:gold.dim_products  -----------
------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
CREATE VIEW [Gold].[dim_products] AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key,
    cpi.prd_id AS product_id,
    cpi.prd_key AS product_number,
    cpi.prd_nm AS product_name,
    cpi.prd_line AS product_line,       
    epcg.cat AS category,
    epcg.subcat AS subcategory,
    cpi.prd_cost AS cost, 
    epcg.maintenance, 
    cpi.prd_start_dt AS start_date
FROM [DataWarehouse].silver.[crm_prd_info] cpi
LEFT JOIN silver.erp_px_cat_g1v2 epcg
ON cpi.cat_id = epcg.id
WHERE cpi.prd_end_dt IS NULL;
---Filtering out all historical data-

SELECT * 
FROM [Gold].[dim_products]
--No issues-----


====================================================================
---Create fact:gold.fact_sales
-----------------As this view contains a lot of transactional data like keys, dates, and measures, this is a FACT view-----------
--Use the surrogate keys from corresponding dimensions to connect with with this fact
------------------------------------------------------------------------------
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
CREATE VIEW [Gold].[fact_sales] AS
SELECT 
       csd.[sls_ord_num] AS order_number
      ,dp.product_key 
      ,dc.customer_key
      ,csd.[sls_order_dt] AS order_date
      ,csd.[sls_ship_dt] Shipment_date
      ,csd.[sls_due_dt] due_date
      ,csd.[sls_sales] sales_amount
      ,csd.[sls_quantity] quantity
      ,csd.[sls_price] price
	  ,csd.dwh_create_date
  FROM silver.[crm_sales_details] csd
  LEFT JOIN [Gold].[dim_products] dp
  ON csd.[sls_prd_key] = dp.product_number
  LEFT JOIN [Gold].[dim_customers] dc
  ON csd.sls_cust_id = dc.customer_id 



  SELECT 
  * 
  FROM [Gold].[fact_sales];

--------------Check for Foreign key Integrity issues-----
---------------------------------------------------------
SELECT *
FROM [Gold].[fact_sales] f
LEFT JOIN [Gold].[dim_customers] c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL-----To check if there are any customers in sales that is not present in customer details
--------No rows--------


SELECT *
FROM [Gold].[fact_sales] f
LEFT JOIN [Gold].[dim_products] p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL -----To check if there are any products in sales that is not present in products details
--------No rows--------
