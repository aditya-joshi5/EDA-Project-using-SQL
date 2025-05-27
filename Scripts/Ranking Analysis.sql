-- RANKING ANALYSIS

-- products which generated highest revenue
SELECT 
p.product_name,
p.category,
p.subcategory,
SUM(s.sales_amount) sales_per_product
FROM gold.fact_sales s
LEFT JOIN
gold.dim_products p ON p.product_key=s.product_key
GROUP BY 
p.product_name,
p.category,
p.subcategory
ORDER BY sales_per_product DESC

-- 5 worst performing products in terms of sales
SELECT 
	TOP 5
	p.product_name,
	p.category,
	p.subcategory,
	SUM(s.sales_amount) sales_per_product
FROM gold.fact_sales s
LEFT JOIN
	gold.dim_products p ON p.product_key=s.product_key
GROUP BY 
	p.product_name,
	p.category,
	p.subcategory
ORDER BY sales_per_product ASC


SELECT *
FROM
	(SELECT 
	customer_id,
	first_name,
	last_name,
	total_sales,
	ROW_NUMBER() OVER(ORDER BY total_sales DESC) customer_rank
	FROM
		(SELECT  
		c.customer_id,
		c.first_name,
		c.last_name,
		SUM(s.sales_amount) AS total_sales
		FROM gold.fact_sales s
		LEFT JOIN
		gold.dim_customers c ON c.customer_key=s.customer_key
		GROUP BY 
		c.customer_id,
		c.first_name,
		c.last_name )t)z
WHERE customer_rank<5
