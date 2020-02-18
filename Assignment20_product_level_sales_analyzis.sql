-- Assignment 20: Product level sales analysis
-- Pull monthly trends to date (January 04, 2013) for number of sales, total revenue, and total margin generated for business

SELECT YEAR(created_at) AS yr, 
	   MONTH(created_at) AS mo, 
       COUNT(order_id) AS number_of_sales, 
       SUM(price_usd) AS total_revenue, 
       SUM(price_usd - cogs_usd) AS total_margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY 1,2;