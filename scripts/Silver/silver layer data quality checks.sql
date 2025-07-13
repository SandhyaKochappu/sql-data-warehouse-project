
---Check for duplicates in primary key
SELECT cst_id,
COUNT(*) count
FROM  silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 or cst_id IS NULL

SELECT * 
FROM(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_latest--window function
	FROM  silver.crm_cust_info
)t WHERE flag_latest != 1




-----Check for blank spaces in text columns
SELECT cst_firstname
FROM  silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
--No issues

SELECT cst_lastname
FROM  silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
--Np issues


SELECT cst_gndr
FROM  silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
--No issues

SELECT cst_marital_status
FROM  silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);
--No issues

SELECT cst_key
FROM  silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);
--No issues

--Check the cardinality of values in gender and marital status for consistency-
SELECT
DISTINCT(cst_gndr)
FROM  silver.crm_cust_info;
--three values 'Male,Female,n/a'

SELECT
DISTINCT(cst_marital_status)
FROM  silver.crm_cust_info;
--two values 'Single,Married'




SELECT TOP 10 *
FROM
silver.crm_cust_info;

----------------------------------------------------------------------
------------------Check for data issues in silver layer---------------
----------------------------------------------------------------------

---Check for duplicates in primary key
SELECT cst_id,
COUNT(*) count
FROM  silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 or cst_id IS NULL


-----Check for blank spaces in text columns
SELECT cst_firstname
FROM  silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
--No issues

SELECT cst_lastname
FROM  silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
--No issues


SELECT cst_gndr
FROM  silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
--No issues

SELECT cst_marital_status
FROM  silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);
--No issues

SELECT cst_key
FROM  silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);
--No issues

--Check the cardinality of values in gender and marital status for consistency-
SELECT
DISTINCT(cst_gndr)
FROM  silver.crm_cust_info;
--three values 'Male,Female,n/a'

SELECT
DISTINCT(cst_marital_status)
FROM  silver.crm_cust_info;
--two values 'Single,Married'

--------------------------------------------------------------------
-------------crm_prd_info table----
--------------------------------------------------------------------
SELECT prd_id,
COUNT(*) count
FROM  silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 or prd_id IS NULL
------No issues---




SELECT id
	FROM silver.erp_px_cat_g1v2
	WHERE id = 'CO_PE'




-----Check for blank spaces in text columns
SELECT prd_nm
FROM  silver.[crm_prd_info]
WHERE prd_nm != TRIM(prd_nm);
--No issues

-----Check for blank spaces in text columns
SELECT prd_cost
FROM  silver.[crm_prd_info]
WHERE prd_cost < 0 or prd_cost IS NULL;
--NULL issues




--Check the cardinality of values
SELECT
DISTINCT(prd_line)
FROM  silver.[crm_prd_info];
--three values 'Mountain,Road,Touring,Other Sales,n/a'



-----Checking for Invalid end_dates
SELECT *
FROM [DataWarehouse].silver.[crm_prd_info]
WHERE prd_end_dt < prd_start_dt;
--No issues



 
----------------------------------------------------------
-----------Data Quality checks for crm_prd_info table in silver layer
----------------------------------------------------------
SELECT prd_id,
COUNT(*) count
FROM  silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 or prd_id IS NULL
------No issues---

-----Check for blank spaces in text columns
SELECT prd_nm
FROM  silver.[crm_prd_info]
WHERE prd_nm != TRIM(prd_nm);
--No issues

-----Check for blank spaces in text columns
SELECT prd_cost
FROM  silver.[crm_prd_info]
WHERE prd_cost < 0 or prd_cost IS NULL;
--NULL issues


--Check the cardinality of values
SELECT
DISTINCT(prd_line)
FROM  silver.[crm_prd_info];
--No isssues


-----Checking for Invalid end_dates
SELECT *
FROM [DataWarehouse].silver.[crm_prd_info]
WHERE prd_end_dt < prd_start_dt;
--No isssues


----------------------------------------------------------
-----------Data Quality checks for [crm_sales_details] table in [Bronze] layer
----------------------------------------------------------


  SELECT *
  FROM [DataWarehouse].silver.[crm_sales_details]
  WHERE [sls_ord_num] != TRIM([sls_ord_num])
  --------No issues

  --------Checking for any missing products in [crm_prd_info] tables in silver layer
SELECT *
FROM [DataWarehouse].silver.[crm_sales_details]
WHERE [sls_prd_key] NOT IN (SELECT [prd_key]
FROM [DataWarehouse].silver.[crm_prd_info])
--------No issues


  --------Checking for any missing customers in [crm_cust_info] tables in silver layer
SELECT *
FROM [DataWarehouse].silver.[crm_sales_details]
WHERE [sls_cust_id] NOT IN (SELECT cst_id
FROM [DataWarehouse].silver.crm_cust_info)
--------No issues



  --------------Order date must be less than shipping and due date------
SELECT 
*
FROM [DataWarehouse].silver.[crm_sales_details]
WHERE sls_order_dt > sls_due_dt
OR sls_order_dt > sls_ship_dt
----------No issues

-----------Sales should be equal to quantity * price, Negative, zero and nulls are not allowed in sales---------
SELECT DISTINCT
		[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
  FROM [DataWarehouse].silver.[crm_sales_details]
  WHERE [sls_sales] != [sls_quantity] * [sls_price]
  OR [sls_sales] IS NULL OR [sls_quantity] IS NULL OR [sls_price] IS NULL
  OR [sls_sales] <= 0 OR [sls_quantity] <= 0 OR [sls_price] <= 0
  ORDER BY [sls_sales]
		  ,[sls_quantity]
		  ,[sls_price];




  ----------------------------------------------------------
-----------Data Quality checks for [crm_sales_details] table in [silver] layer
----------------------------------------------------------


SELECT [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
      ,[sls_order_dt]
      ,[sls_ship_dt]
      ,[sls_due_dt]
      ,[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
	  ,dwh_create_date
  FROM [DataWarehouse].silver.[crm_sales_details]


  SELECT *
  FROM [DataWarehouse].silver.[crm_sales_details]
  WHERE [sls_ord_num] != TRIM([sls_ord_num])
  --------No issues

  --------Checking for any missing products in [crm_prd_info] tables in silver layer
SELECT *
FROM [DataWarehouse].silver.[crm_sales_details]
WHERE [sls_prd_key] NOT IN (SELECT [prd_key]
FROM [DataWarehouse].silver.[crm_prd_info])
--------No issues


--------Checking for any missing customers in [crm_cust_info] tables in silver layer
SELECT *
FROM [DataWarehouse].silver.[crm_sales_details]
WHERE [sls_cust_id] NOT IN (SELECT cst_id
FROM [DataWarehouse].silver.crm_cust_info);
--------No issues


  --------------Order date must be less than shipping and due date------
SELECT 
*
FROM [DataWarehouse].silver.[crm_sales_details]
WHERE sls_order_dt > sls_due_dt
OR sls_order_dt > sls_ship_dt
----------No issues


-----------Sales should be equal to quantity * price, Negative, zero and nulls are not allowed in sales---------
SELECT DISTINCT
		[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
  FROM [DataWarehouse].silver.[crm_sales_details]
  WHERE [sls_sales] != [sls_quantity] * [sls_price]
  OR [sls_sales] IS NULL OR [sls_quantity] IS NULL OR [sls_price] IS NULL
  OR [sls_sales] <= 0 OR [sls_quantity] <= 0 OR [sls_price] <= 0
  ORDER BY [sls_sales]
		  ,[sls_quantity]
		  ,[sls_price];
----------No issues



--------------------------------------------------------------------
------------- erp_cust_az12 table---
--------------------------------------------------------------------


SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE SUBSTRING(cid,4, LEN(cid)) IN (SELECT 
cst_key 
FROM silver.crm_cust_info)


------Check for validity of birth dates--------
SELECT
	bdate
FROM silver.erp_cust_az12 WHERE bdate < '1924-01-01' OR bdate > GETDATE()

SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
		 ELSE cid
	END cid,
    CASE WHEN bdate > GETDATE() THEN NULL
		 ELSE bdate
    END bdate,
	gen
FROM silver.erp_cust_az12
WHERE  bdate > GETDATE();


----------Checking cardinality of gender column
SELECT DISTINCT gen
FROM silver.erp_cust_az12
--NULL,F ,Male, Female, M 




----------------Data Quality checks for silver.erp_cust_az12 table----------
-------------------------------------------------------------------------



------Check for validity of birth dates--------
SELECT
	bdate
FROM silver.erp_cust_az12 WHERE bdate < '1924-01-01' OR bdate > GETDATE()

SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
		 ELSE cid
	END cid,
    CASE WHEN bdate > GETDATE() THEN NULL
		 ELSE bdate
    END bdate,
	gen
FROM silver.erp_cust_az12
WHERE  bdate > GETDATE();


----------Checking cardinality of gender column
SELECT DISTINCT gen
FROM silver.erp_cust_az12
--NULL,F ,Male, Female, M 

--------------------------------------------------------
--------------silver.erp_loc_a101 table----
--------------------------------------------------------



SELECT
    REPLACE(cid,'-', '') cid,
    cntry
FROM silver.erp_loc_a101 
WHERE REPLACE(cid,'-', '') NOT IN (
SELECT 
	cst_key --AW00011000
FROM silver.crm_cust_info)

---------Check for Data Consistency in 'cntry' column--------
SELECT
   DISTINCT cntry
FROM silver.erp_loc_a101;
------Inconsistent values------------


SELECT
   DISTINCT cntry as old_cntry,
   CASE WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
	     WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
		 WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END cntry
FROM silver.erp_loc_a101;
------No issues--------


---------------Data Quality checks for silver.erp_loc_a101 table----------
-------------------------------------------------------------------------
SELECT
    cid
FROM silver.erp_loc_a101 
WHERE cid NOT IN (
SELECT 
	cst_key
FROM silver.crm_cust_info)
----------"No issues---------


SELECT
   DISTINCT cntry
FROM silver.erp_loc_a101;
----No issues------------


SELECT
    *
FROM silver.erp_loc_a101;




----'cat-id' in silver.crm_prd_info corresponds to 'id' in silver.erp_px_cat_g1v2 table
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM silver.erp_px_cat_g1v2;

---Check for unwanted spaces--------
SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);
----No issues---------


------------Check for data consistency--------
SELECT DISTINCT    
    cat
FROM silver.erp_px_cat_g1v2;
----No issues---------

SELECT DISTINCT    
    subcat
FROM silver.erp_px_cat_g1v2;
----No issues---------


SELECT DISTINCT    
    maintenance
FROM silver.erp_px_cat_g1v2;
----No issues---------


------------Check data quality in silver.erp_px_cat_g1v2 table---------
----------------------------------------------------------------------
SELECT 
*
FROM
silver.erp_px_cat_g1v2;


--------