-- Performance analysis

/*Analyse yearly performance of products by comparing their sales 
to both the avg sales performance and prev year sales each products's sale*/
WITH yearly_product_sales AS (
SELECT 
	YEAR(s.order_date) AS current_year,
	p.product_name,
	SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
	ON s.product_key=p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),p.product_name )

SELECT 
current_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY current_year) AS avg_sales,
current_sales- AVG(current_sales) OVER(PARTITION BY current_year)  AS sales_diff,
CASE 
	WHEN current_sales- AVG(current_sales) OVER(PARTITION BY current_year)>0 THEN 'Above Avg'
	WHEN current_sales- AVG(current_sales) OVER(PARTITION BY current_year)<0 THEN 'Below Avg'
	ELSE 'Average'
END AS sales_deviation,
LAG(current_sales) OVER(PARTITION BY product_name order by current_year) AS prev_year_sales,
current_sales- LAG(current_sales) OVER(PARTITION BY product_name order by current_year) prev_year_sales,
-- YEEAR-ON-YEAR-Analysis
CASE 
	WHEN current_sales- LAG(current_sales) OVER(PARTITION BY product_name order by current_year) <0 THEN 'Decrese'
	WHEN current_sales- LAG(current_sales) OVER(PARTITION BY product_name order by current_year) >0 THEN 'Increase'
	ELSE 'No change'
END AS prev_year_change

FROM yearly_product_sales
ORDER BY product_name, current_year

-- PART TO WHOLE Analysis
-- which category contribute the most to overall sales
WITH category_sales AS(
SELECT 
	p.category,
	SUM(s.sales_amount) AS sales
FROM gold.dim_products p
LEFT JOIN gold.fact_sales s ON p.product_key=s.product_key 
WHERE s.sales_amount IS NOT NULL
GROUP BY p.category)

SELECT 
	category,
	CAST(sales AS float) AS sales,
	SUM(sales) OVER() AS overall_sales,
	CONCAT(ROUND(CAST(sales AS float)/SUM(sales) OVER()*100,2),'%') AS percentage_sales
FROM category_sales
ORDER BY sales DESC


WITH product_sales AS (
SELECT 
	p.product_name,
	SUM(s.sales_amount) as product_sales
FROM
gold.dim_products p
LEFT JOIN gold.fact_sales s ON p.product_key=s.product_key 
WHERE s.sales_amount IS NOT NULL
GROUP BY p.product_name )

SELECT product_name,
product_sales,
SUM(product_sales) OVER() AS overall_sales,
CONCAT(ROUND(CAST(product_sales AS float)/SUM(product_sales) OVER() *100,2),'%') AS percentage_sales
FROM product_sales
ORDER BY product_sales DESC

-- DATA Segmentation
-- segment products into cost ranges and count how many fall into each segment
WITH product_segment AS  (
SELECT 
	product_key,
	product_name,
	cost,
	CASE WHEN cost<100 THEN 'below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN 'between 100-500'
		 WHEN cost BETWEEN 500 AND 1000 THEN 'between 500-1000'
		 ELSE 'Above 1000'
	END AS cost_category
FROM
gold.dim_products )

SELECT 
	cost_category,
	COUNT(product_key) AS products
FROM product_segment
GROUP BY cost_category
ORDER BY COUNT(product_key) DESC



--CUSTOMER SEGMENTATION
-- Step 1: Calculate year-wise order gaps per customer
WITH customer_duration AS (
    SELECT 
        s.customer_key,
		SUM(s.sales_amount) AS total_sales,
        MIN(s.order_date) AS first_year,
		MAX(s.order_date) AS last_order,
        DATEDIFF(month,MIN(s.order_date),MAX(s.order_date)) AS month_diff
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales s 
        ON c.customer_key = s.customer_key
	WHERE s.order_date IS NOT NULL
	GROUP BY s.customer_key)

SELECT 
	customer_category,
	COUNT(customer_key) AS customer_counts
FROM(
SELECT
	customer_key,
	month_diff,
	total_sales,
	CASE WHEN month_diff>=12 AND total_sales>5000 THEN 'VIP'
		WHEN month_diff>=12 AND total_sales<=5000 THEN 'Regular'
		ELSE 'New'
END AS customer_category
FROM customer_duration )t
GROUP BY customer_category
ORDER BY customer_category


