-- Assignment 24: On September 25th the customers were given an option to add a second product while they were on the /cart page.
-- Compare the month before and after the change, CTR (if the stayed on the website) to any page from the /cart page,
-- Avg Products per Order, AOV and revenue per /cart page.

-- Step 1: Find the relevant /cart page views within given time period and add column Pre or Post cross sell option
DROP TABLE IF EXISTS cart_sessions;
CREATE TEMPORARY TABLE cart_sessions
SELECT website_session_id, 
	   created_at, 
       website_pageview_id,
       CASE	
		WHEN created_at < '2013-09-25' THEN 'A_Pre_cross_Sell'
        ELSE 'B_Post_Cross_Sell'
	   END AS time_period
FROM website_pageviews
WHERE pageview_url = '/cart'
	AND created_at BETWEEN '2013-08-25' AND '2013-10-25';

-- Step 2: Flag the /cart sessions that continued on our website, flag if the made an order, how many items they purchased
-- per order and the price of the order for that session.
DROP TABLE IF EXISTS sessions_with_orders;
CREATE TEMPORARY TABLE sessions_with_orders
SELECT cart_sessions.time_period,
       cart_sessions.website_session_id AS sessions, 
       orders.order_id,
       orders.items_purchased,
       orders.price_usd,
       MIN(website_pageviews.website_pageview_id) as next_pageview_id
FROM cart_sessions
	LEFT JOIN website_pageviews ON cart_sessions.website_session_id = website_pageviews.website_session_id
		AND website_pageviews.website_pageview_id > cart_sessions.website_pageview_id
	LEFT JOIN orders ON cart_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2;

-- Step 3: Count, summarize and group the results extracting from the upper temporary table.
SELECT time_period, 
	   COUNT(sessions) AS sessions,
       COUNT(next_pageview_id) AS click_through,
       COUNT(next_pageview_id)/COUNT(sessions) AS cart_rate, 
       AVG(items_purchased) as products_per_order, 
       AVG(price_usd) AS AOV,
       SUM(price_usd)/COUNT(sessions) rev_per_cart_session
FROM sessions_with_orders
GROUP BY 1;