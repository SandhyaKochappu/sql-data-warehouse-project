
---Check for duplicates in primary key
SELECT cst_id,
COUNT(*) count
FROM  bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 or cst_id IS NULL


-----Confirming data inconsistencies by checkomg individual values 
SELECT *
FROM  bronze.crm_cust_info
WHERE cst_id = '29466' 
---Three rows with three create date and updated values, rank the rows based on create_date and keep the one with latest create_date

--Use ROW_NUMBER() to assign a unique number to each row in a result set.
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_latest--window function
FROM  bronze.crm_cust_info
WHERE cst_id = '29466'

SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_latest--window function
FROM  bronze.crm_cust_info;

SELECT * 
FROM(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_latest--window function
	FROM  bronze.crm_cust_info
)t WHERE flag_latest != 1

----Selecting the latest records for each customer
SELECT * 
FROM(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_latest--window function
	FROM  bronze.crm_cust_info
)t WHERE flag_latest = 1 



-----Check for blank spaces in text columns
SELECT cst_firstname
FROM  bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
--has issues

SELECT cst_lastname
FROM  bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
--has issues


SELECT cst_gndr
FROM  bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
--No issues

SELECT cst_marital_status
FROM  bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);
--No issues

SELECT cst_key
FROM  bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key);
--No issues

--Check the cardinality of values in gender and marital status for consistency-
SELECT
DISTINCT(cst_gndr)
FROM  bronze.crm_cust_info;
--three values 'M,F,Null'

SELECT
DISTINCT(cst_marital_status)
FROM  bronze.crm_cust_info;
--three values 'S,M,Null'

------------Cleaning and standardising data-------
SELECT [cst_id]
      ,[cst_key]
      ,TRIM(cst_firstname) AS cst_firstname
      ,TRIM(cst_lastname) AS cst_lastname
	  ,CASE WHEN UPPER(TRIM([cst_marital_status])) = 'S' THEN 'Single'
			WHEN UPPER(TRIM([cst_marital_status])) = 'M' THEN 'Married'
			ELSE 'n/a'
		END [cst_marital_status]
      ,CASE WHEN UPPER(TRIM([cst_gndr])) = 'F' THEN 'Female'
			WHEN UPPER(TRIM([cst_gndr])) = 'M' THEN 'Male'
			ELSE 'n/a'
		END [cst_gndr]
      ,[cst_create_date]
  FROM 
  (
	SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_latest--window function
	FROM  bronze.crm_cust_info
	WHERE cst_id IS NOT NULL 
)t WHERE flag_latest = 1 


INSERT INTO silver.crm_cust_info (
	cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date )
SELECT [cst_id]
      ,[cst_key]
      ,TRIM(cst_firstname) AS cst_firstname
      ,TRIM(cst_lastname) AS cst_lastname
	  ,CASE WHEN UPPER(TRIM([cst_marital_status])) = 'S' THEN 'Single'
			WHEN UPPER(TRIM([cst_marital_status])) = 'M' THEN 'Married'
			ELSE 'n/a'
		END [cst_marital_status]
      ,CASE WHEN UPPER(TRIM([cst_gndr])) = 'F' THEN 'Female'
			WHEN UPPER(TRIM([cst_gndr])) = 'M' THEN 'Male'
			ELSE 'n/a'
		END [cst_gndr]
      ,[cst_create_date]
  FROM 
  (
	SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_latest--window function
	FROM  bronze.crm_cust_info
	WHERE cst_id IS NOT NULL 
)t WHERE flag_latest = 1 


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


-----Confirming data inconsistencies by checkomg individual values 
SELECT *
FROM  silver.crm_cust_info
WHERE cst_id = '29466' 
---Three rows with three create date and updated values, rank the rows based on create_date and keep the one with latest create_date

-----Check for blank spaces in text columns
SELECT cst_firstname
FROM  silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
--has issues

SELECT cst_lastname
FROM  silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
--has issues


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
--three values 'M,F,Null'

SELECT
DISTINCT(cst_marital_status)
FROM  silver.crm_cust_info;

--------------------------------------------------------------------
-------------Build Silver layer, Clean & Load crm_prd_info table----
--------------------------------------------------------------------
SELECT prd_id,
COUNT(*) count
FROM  bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 or prd_id IS NULL
------No issues---


SELECT [prd_id]
      ,[prd_key]
	  ,REPLACE(SUBSTRING([prd_key],1,5),'-','_') AS cat_id
	  ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].[Bronze].[crm_prd_info]


SELECT id---underscore in between
FROM
bronze.erp_px_cat_g1v2;


SELECT [prd_id]
      ,[prd_key]
	  ,REPLACE(SUBSTRING([prd_key],1,5),'-','_') AS cat_id
	  ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].[Bronze].[crm_prd_info]
  WHERE REPLACE(SUBSTRING([prd_key],1,5),'-','_') NOT IN
  (SELECT id---underscore in between
	FROM
	bronze.erp_px_cat_g1v2
	--------only one missing categroy which is not avaialble in erp_px_cat_g1v2 table

SELECT id
	FROM bronze.erp_px_cat_g1v2
	WHERE id = 'CO_PE'


SELECT [prd_id]
      ,[prd_key]
	  ,REPLACE(SUBSTRING([prd_key],1,5),'-','_') AS cat_id
	  ,SUBSTRING([prd_key],7,LEN([prd_key])) AS prd_key
	  ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].[Bronze].[crm_prd_info];


SELECT 
sls_prd_key
FROM bronze.crm_sales_details;


SELECT [prd_id]
      ,[prd_key]
	  ,REPLACE(SUBSTRING([prd_key],1,5),'-','_') AS cat_id
	  ,SUBSTRING([prd_key],7,LEN([prd_key])) AS prd_key
	  ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].[Bronze].[crm_prd_info]
  WHERE SUBSTRING(prd_key,7,LEN(prd_key)) NOT IN (
  SELECT 
	sls_prd_key
	FROM bronze.crm_sales_details
  );
  -------A lot of products don't have data in sales table(No orders for those products)

-----------Let us confirm by checking individual products-----
SELECT 
	sls_prd_key
	FROM bronze.crm_sales_details 
	WHERE sls_prd_key = 'FR%';


-----Check for blank spaces in text columns
SELECT prd_nm
FROM  bronze.[crm_prd_info]
WHERE prd_nm != TRIM(prd_nm);
--No issues

-----Check for blank spaces in text columns
SELECT prd_cost
FROM  bronze.[crm_prd_info]
WHERE prd_cost < 0 or prd_cost IS NULL;
--NULL issues


SELECT [prd_id]
      ,[prd_key]
	  ,REPLACE(SUBSTRING([prd_key],1,5),'-','_') AS cat_id
	  ,SUBSTRING([prd_key],7,LEN([prd_key])) AS prd_key
	  ,[prd_nm]
      ,ISNULL([prd_cost],0) AS prd_cost
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].[Bronze].[crm_prd_info];

--Check the cardinality of values
SELECT
DISTINCT(prd_line)
FROM  bronze.[crm_prd_info];
--three values 'M,R,S,T,Null'


SELECT [prd_id]
      ,[prd_key]
	  ,REPLACE(SUBSTRING([prd_key],1,5),'-','_') AS cat_id
	  ,SUBSTRING([prd_key],7,LEN([prd_key])) AS prd_key
	  ,[prd_nm]
      ,ISNULL([prd_cost],0) AS prd_cost
	  ,CASE UPPER(TRIM([prd_line])) 
			WHEN 'S' THEN 'Other Sales'
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].[Bronze].[crm_prd_info];

-----Checking for Invalid end_dates
SELECT *
FROM [DataWarehouse].[Bronze].[crm_prd_info]
WHERE prd_end_dt < prd_start_dt;

SELECT *
FROM [DataWarehouse].[Bronze].[crm_prd_info]
WHERE prd_key = 'AC-HE-HL-U509-R';


SELECT [prd_id]
      ,[prd_key]
	  ,REPLACE(SUBSTRING([prd_key],1,5),'-','_') AS cat_id
	  ,SUBSTRING([prd_key],7,LEN([prd_key])) AS prd_key
	  ,[prd_nm]
      ,ISNULL([prd_cost],0) AS prd_cost
	  ,CASE UPPER(TRIM([prd_line])) 
			WHEN 'S' THEN 'Other Sales'
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line
      ,[prd_start_dt]
      ,LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt
  FROM [DataWarehouse].[Bronze].[crm_prd_info]
  WHERE prd_key in ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');


  SELECT [prd_id]
      ,[prd_key]
	  ,REPLACE(SUBSTRING([prd_key],1,5),'-','_') AS cat_id
	  ,SUBSTRING([prd_key],7,LEN([prd_key])) AS prd_key
	  ,[prd_nm]
      ,ISNULL([prd_cost],0) AS prd_cost
	  ,CASE UPPER(TRIM([prd_line])) 
			WHEN 'S' THEN 'Other Sales'
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line
      ,CAST(prd_start_dt AS DATE) AS prd_start_dt
      ,CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
  FROM [DataWarehouse].[Bronze].[crm_prd_info];

---------------------------------------------------------------------------------
-----------------Adding a new column,cat_id to the table silver.crm_prd_info
---------------------------------------------------------------------------------
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
	cat_id       NVARCHAR(50),
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME,
	dwh_create_date 	DATETIME2 DEFAULT GETDATE()
);
GO


INSERT INTO silver.crm_prd_info (
    prd_id,
	cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt,
	dwh_create_date
	)
	 SELECT [prd_id]
      ,REPLACE(SUBSTRING([prd_key],1,5),'-','_') AS cat_id
	  ,SUBSTRING([prd_key],7,LEN([prd_key])) AS prd_key
	  ,[prd_nm]
      ,ISNULL([prd_cost],0) AS prd_cost
	  ,CASE UPPER(TRIM([prd_line])) 
			WHEN 'S' THEN 'Other Sales'
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line
      ,CAST(prd_start_dt AS DATE) AS prd_start_dt
      ,CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
	  ,GETDATE() AS dwh_create_date
  FROM [DataWarehouse].[Bronze].[crm_prd_info]


----------------------------------------------------------
-----------Data Quality checks for crm_prd_info table in silver layer
----------------------------------------------------------
SELECT prd_id,
COUNT(*) count
FROM  silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 or prd_id IS NULL
------No issues---


SELECT [prd_id]
      ,[prd_key]
	  ,cat_id
	  ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].silver.[crm_prd_info]




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


SELECT [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
      ,[sls_order_dt]
      ,[sls_ship_dt]
      ,[sls_due_dt]
      ,[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
  FROM [DataWarehouse].[Bronze].[crm_sales_details]


  SELECT *
  FROM [DataWarehouse].[Bronze].[crm_sales_details]
  WHERE [sls_ord_num] != TRIM([sls_ord_num])
  --------No issues

  --------Checking for any missing products in [crm_prd_info] tables in silver layer
SELECT *
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE [sls_prd_key] NOT IN (SELECT [prd_key]
FROM [DataWarehouse].silver.[crm_prd_info])
--------No issues


  --------Checking for any missing customers in [crm_cust_info] tables in silver layer
SELECT *
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE [sls_cust_id] NOT IN (SELECT cst_id
FROM [DataWarehouse].silver.crm_cust_info)
--------No issues


-----------Checking for date values-----------
SELECT *
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE [sls_order_dt] <= 0
----zeroes in order date, zeroes or negative numbers cannot be cast to date

SELECT 
NULLIF([sls_order_dt],0) AS [sls_order_dt]
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE [sls_order_dt] <= 0

-------Since the date values are in (YYYYMMDD) format, there should be 8 letters in each column
SELECT 
NULLIF([sls_order_dt],0) AS [sls_order_dt]
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE LEN([sls_order_dt]) != 8
---2 values----


SELECT 
NULLIF([sls_order_dt],0) AS [sls_order_dt]
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE [sls_order_dt] <= 0
OR LEN([sls_order_dt]) != 8
OR [sls_order_dt] > 20500101---Boundary dTE FOR sales order(future values)
OR [sls_order_dt] < 19000101----Business start date


---------CAST Date filed [sls_order_dt]
SELECT [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
      ,CASE WHEN [sls_order_dt] <= 0 OR LEN([sls_order_dt]) != 8 THEN NULL
		   ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	   END sls_order_dt
      ,[sls_ship_dt]
      ,[sls_due_dt]
      ,[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
  FROM [DataWarehouse].[Bronze].[crm_sales_details]


  --------Check for shipping date------------
  SELECT 
NULLIF(sls_ship_dt,0) AS sls_ship_dt
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE sls_ship_dt <= 0
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101---Boundary dTE FOR sales order(future values)
OR sls_ship_dt < 19000101----Business start date
----------No issues


  SELECT 
NULLIF(sls_due_dt,0) AS sls_due_dt
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE sls_due_dt <= 0
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101---Boundary dTE FOR sales order(future values)
OR sls_due_dt < 19000101----Business start date
----------No issues




-----Update shipping date as well with transformatioms
SELECT [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
      ,CASE WHEN [sls_order_dt] <= 0 OR LEN([sls_order_dt]) != 8 THEN NULL
		   ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	   END sls_order_dt
	  ,CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		   ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
	   END sls_ship_dt
	  ,CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
		   ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
	   END sls_due_dt
      ,[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
  FROM [DataWarehouse].[Bronze].[crm_sales_details]


  --------------Order date must be less than shipping and due date------
SELECT 
*
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE sls_order_dt > sls_due_dt
OR sls_order_dt > sls_ship_dt
----------No issues

-----------Sales should be equal to quantity * price, Negative, zero and nulls are not allowed in sales---------
SELECT DISTINCT
		[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
  FROM [DataWarehouse].[Bronze].[crm_sales_details]
  WHERE [sls_sales] != [sls_quantity] * [sls_price]
  OR [sls_sales] IS NULL OR [sls_quantity] IS NULL OR [sls_price] IS NULL
  OR [sls_sales] <= 0 OR [sls_quantity] <= 0 OR [sls_price] <= 0
  ORDER BY [sls_sales]
		  ,[sls_quantity]
		  ,[sls_price];


------If sales is negative, zero, or null, calcualte using quantity and price
------If price is null, calculate using sales and quantity
------Negative prices should be converted to a positive value

SELECT [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
	  ,[sls_quantity]
      ,CASE WHEN [sls_order_dt] <= 0 OR LEN([sls_order_dt]) != 8 THEN NULL
		   ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	   END sls_order_dt
	  ,CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		   ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
	   END sls_ship_dt
	  ,CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
		   ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
	   END sls_due_dt
	  ,CASE WHEN [sls_sales] IS NULL OR [sls_sales] <= 0 OR [sls_sales] != [sls_quantity] * ABS([sls_price])
				THEN [sls_quantity] * ABS([sls_price])
			ELSE [sls_sales]
		END [sls_sales]
	  ,CASE WHEN [sls_price] IS NULL OR [sls_price] <= 0 
				THEN [sls_sales] / NULLIF([sls_quantity],0)
			ELSE [sls_price]
		END [sls_price]
  FROM [DataWarehouse].[Bronze].[crm_sales_details];

----------------------------------------------------------------------------------
-------------------Create  silver.crm_sales_details with the updated columns------
----------------------------------------------------------------------------------

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
   DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
	dwh_create_date 	DATETIME2 DEFAULT GETDATE()
);
GO


INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price,
	dwh_create_date 	 
)
SELECT [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
	  ,CASE WHEN [sls_order_dt] <= 0 OR LEN([sls_order_dt]) != 8 THEN NULL
		   ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	   END sls_order_dt
	  ,CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		   ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
	   END sls_ship_dt
	  ,CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
		   ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
	   END sls_due_dt
	  ,CASE WHEN [sls_sales] IS NULL OR [sls_sales] <= 0 OR [sls_sales] != [sls_quantity] * ABS([sls_price])
				THEN [sls_quantity] * ABS([sls_price])
			ELSE [sls_sales]
		END [sls_sales]
	  ,[sls_quantity]
	  ,CASE WHEN [sls_price] IS NULL OR [sls_price] <= 0 
				THEN [sls_sales] / NULLIF([sls_quantity],0)
			ELSE [sls_price]
		END [sls_price]
	   ,GETDATE() AS dwh_create_date
  FROM [DataWarehouse].[Bronze].[crm_sales_details];


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
-------------Build Silver layer, Clean & Load erp_cust_az12 table---
--------------------------------------------------------------------

SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;

------------cid in erp_cust_az12 table corresponds to cst_key in crm_cust_info table, so the values should match.
------------In cid in erp_cust_az12 there is an additional 3 characters in the front for some values 
SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE SUBSTRING(cid,4, LEN(cid)) IN (SELECT 
cst_key 
FROM bronze.crm_cust_info)


SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE cid = 'NASAW00011009';

SELECT 
* 
FROM bronze.crm_cust_info
WHERE cst_key='AW00011009';


SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
		 ELSE cid
	END cid,
    bdate,
    gen
FROM bronze.erp_cust_az12


------Check for validity of birth dates--------
SELECT
	bdate
FROM bronze.erp_cust_az12 WHERE bdate < '1924-01-01' OR bdate > GETDATE()

SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
		 ELSE cid
	END cid,
    CASE WHEN bdate > GETDATE() THEN NULL
		 ELSE bdate
    END bdate,
	gen
FROM bronze.erp_cust_az12
WHERE  bdate > GETDATE();


----------Checking cardinality of gender column
SELECT DISTINCT gen
FROM bronze.erp_cust_az12
--NULL,F ,Male, Female, M 


SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
		 ELSE cid
	END cid,
    CASE WHEN bdate > GETDATE() THEN NULL
		 ELSE bdate
    END bdate,
	gen
FROM bronze.erp_cust_az12