-- ADVANCED DATA ANALYTICS
-- CHANGES OVER TIME ANALYSIS

-- Changes over Year
SELECT 
YEAR(order_date) AS order_year,
SUM(sales_amount) AS yearly_sales,
COUNT( DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) 

-- Changes over month
SELECT 
MONTH(order_date) AS order_month,
SUM(sales_amount) as monthly_sales,
COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date) 

SELECT 
FORMAT(order_date,'yyyy-MMM') AS order_month,
SUM(sales_amount) as monthly_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
GROUP BY FORMAT(order_date,'yyyy-MMM')
ORDER BY FORMAT(order_date,'yyyy-MMM')

--============================Cumulative Analysis==============================
--Calculate total sales per month
--Running Total of sales over time
SELECT 
  order_date,
  monthly_sales,
  SUM(monthly_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date) AS cum_sum,
  AVG(sales_avg) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS moving_avg
FROM (
  SELECT
    DATETRUNC(MONTH, order_date) AS order_date,
    SUM(sales_amount) AS monthly_sales,
	AVG(sales_amount) AS sales_avg
  FROM gold.fact_sales
  WHERE order_date IS NOT NULL
  GROUP BY DATETRUNC(MONTH, order_date)
) t





