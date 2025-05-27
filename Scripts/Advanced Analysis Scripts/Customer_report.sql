CREATE OR ALTER VIEW gold.report_customers AS 
WITH basic_query AS(
SELECT
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name,' ',c.last_name) AS customer_name,
	DATEDIFF(year,c.birthdate,GETDATE()) AS age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key=c.customer_key )

, customer_aggregations AS (
SELECT 
	customer_key,
	customer_number,
    customer_name,
	age,
	COUNT(DISTINCT order_number) AS  total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
FROM basic_query
GROUP BY 
	customer_key,
	customer_number,
    customer_name,
	age )


SELECT 
	customer_key,
	customer_number,
    customer_name,
	age,
	CASE 
		WHEN age<20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 30 THEN '20-30'
		WHEN age BETWEEN 30 AND 40 THEN '30-40'
		WHEN age BETWEEN 40 AND 50 THEN '40-50'
		WHEN age BETWEEN 50 AND 60 THEN '50-60'
		WHEN age>60 THEN 'Above 60'
	END AS age_group,
	total_orders,
	total_sales,
	CASE 
		WHEN lifespan>=12 AND total_sales>5000 THEN 'VIP'
		WHEN lifespan>=12 AND total_sales<=5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	total_quantity,
	total_products,
		CASE WHEN total_orders =0 THEN 0
		 ELSE total_sales/total_orders
	END AS avg_order_value,
	CASE WHEN lifespan=0 THEN total_sales
		ELSE total_sales/lifespan
	END AS average_monthly_spend,
	last_order,
	lifespan,
	DATEDIFF(MONTH,last_order,GETDATE()) AS recency
FROM customer_aggregations