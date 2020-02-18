-- Assignment 18: Analyzing seasonality up to date (January 01, 2013)

-- Step 1: Analyzing seasonality by month, summarizing sessions and orders
SELECT YEAR(website_sessions.created_at) AS yr,
	   MONTH(website_sessions.created_at) as mo,
       COUNT(website_sessions.website_session_id) AS sessions,
       COUNT(orders.order_id) as orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 1, 2;

-- Step 2: Analyzing seasonality by week, summarizing sessions and orders
SELECT MIN(DATE(website_sessions.created_at)) week_start_date, -- grouping by week, with the min() function we obtain the first date of the week.
	   COUNT(website_sessions.website_session_id) AS sessions,
       COUNT(orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY WEEK(website_sessions.created_at);