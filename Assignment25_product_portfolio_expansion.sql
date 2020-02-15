-- Assignment 25: On December 25th there was a third product launched - Birthday Bear. Run a pre-post analysis comparing the
-- month before and month after in terms of session to order conversion rate, AOV, products per order and revenue per session.

SELECT   
	   CASE	
		   WHEN website_sessions.created_at < '2013-12-12' THEN 'A_Pre_Birthday_Bear'
		   ELSE 'B_Post_Birthday_Bear'
	   END AS time_period,
       COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) AS conv_rate,
       AVG(orders.price_usd) AS AOV,
       AVG(orders.items_purchased) AS products_per_order,
       SUM(orders.price_usd)/COUNT(website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1;
       