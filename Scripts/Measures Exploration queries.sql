-- Explore all object in database
SELECT * FROM INFORMATION_SCHEMA.TABLES 
--(Information schema contains all the metadata information about the database)


SELECT * FROM INFORMATION_SCHEMA.COLUMNS

SELECT DISTINCT country FROM gold.dim_customers

SELECT DISTINCT category, subcategory,product_name FROM gold.dim_products 
ORDER BY 1,2,3

--============================DATE EXPLORATION====================================
-- order month Range

SELECT 
MIN(order_date) AS min_order_date,
MAX(order_date) AS max_order_date,
DATEDIFF(MM,MIN(order_date),MAX(order_date)) as ORDER_RANGE_MONTH
FROM gold.fact_sales

--Age Difference
SELECT 
MAX(YEAR(birthdate)) AS max_birthyear,
MIN(YEAR(birthdate)) min_bithyear,
DATEDIFF(YEAR,MIN(birthdate),GETDATE()) AS max_age,
DATEDIFF(YEAR,MAX(birthdate),GETDATE()) AS min_age
FROM gold.dim_customers

--TOTAL SALES
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

--How many items sold
SELECT SUM(quantity) AS total_items_sold FROM gold.fact_sales

--Avg selling price
SELECT AVG(price) AS avg_selling_price FROM gold.fact_sales

--Total numbers of orders
SELECT COUNT(order_number) FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) FROM gold.fact_sales
--!!!!!!!!!!!!!!!!!!ALWAYS COMPARE NUMBERS BEFORE AND AFTER USING DISTINCT!!!!!!!!!!!!!!!

--Total Number Of products
SELECT COUNT(product_key) AS total_Products FROM gold.dim_products
SELECT COUNT(DISTINCT product_key) AS total_Products FROM gold.dim_products

--Total Number of Customers
SELECT COUNT(customer_id) AS total_customers  FROM gold.dim_customers
SELECT COUNT(DISTINCT customer_id) AS total_customers  FROM gold.dim_customers

--Total number of customers that have placed an order
SELECT COUNT( DISTINCT customer_key) FROM gold.fact_sales

-- generate a report that shows  all key metrices of a business
SELECT 'Total Sales' AS measure_name,  SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'total_items_sold', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'total_Products', COUNT(DISTINCT customer_id) FROM gold.dim_customers
UNION ALL
SELECT 'total_customers', COUNT(customer_id) FROM gold.dim_customers
UNION ALL
SELECT 'avg_selling_price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'total_customers', COUNT( DISTINCT customer_key) FROM gold.fact_sales