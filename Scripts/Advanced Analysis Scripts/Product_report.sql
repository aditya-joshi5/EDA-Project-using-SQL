CREATE OR ALTER VIEW gold.report_products AS
SELECT
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost,
	SUM(s.sales_amount) AS product_sales,
	CASE WHEN SUM(s.sales_amount)< 10000 THEN 'Low Performer'
		 WHEN SUM(s.sales_amount) BETWEEN 10000 AND 500000 THEN 'Mid Performer'
		 ELSE 'High performer'
	END AS product_segment,
	COUNT(DISTINCT s.order_number) AS  total_orders,
	COUNT(DISTINCT s.customer_key) AS customers,
	DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) AS lifespan,
	DATEDIFF(MONTH,MAX(s.order_date),GETDATE()) AS recency,
	ROUND(AVG(CAST(s.sales_amount AS FLOAT) / NULLIF(s.quantity, 0)),1) AS avg_selling_price,
	CASE WHEN COUNT(DISTINCT s.order_number) = 0 THEN 0
		 ELSE ROUND(CAST(SUM(s.sales_amount) AS float)/COUNT(DISTINCT s.order_number),2)  
	END AS avg_order_revenue,
	CASE WHEN DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date))=0 THEN 0
		 ELSE ROUND(CAST(SUM(s.sales_amount) AS float)/DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)),2)  
	END AS avg_monthly_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p 
ON s.product_key=p.product_key
GROUP BY 
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost

