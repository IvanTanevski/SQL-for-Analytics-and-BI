-- Assignment 21: Analyzing product launches
-- Pull monthly order volume, overall conversion rates, revenues per session, and a breakdown of sales by product from '2012-04-01' to '2013-04-05'

SELECT YEAR(website_sessions.created_at) AS yr, 
	   MONTH(website_sessions.created_at) AS mo, 
       COUNT(orders.order_id) AS orders, 
       COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) AS conv_rate, 
       SUM(orders.price_usd)/COUNT(website_sessions.website_session_id) AS revenue_per_session, 
       COUNT(CASE WHEN orders.primary_product_id = 1 THEN orders.order_id ELSE NULL END) AS product_one_orders,
       COUNT(CASE WHEN orders.primary_product_id = 2 THEN orders.order_id ELSE NULL END) AS product_two_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY 1,2;