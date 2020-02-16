/* Assignement 30: Analyzing new and repeated conversion rates.
   Make a comparison if conversion rates and revenue per session for repeated sessions versus new sessions. */
   
-- Grouping by is_repeat_session, counting the website sessions for given time period, conversion rate, and average revenue per session.
SELECT website_sessions.is_repeat_session, 
	   COUNT(website_sessions.website_session_id) AS sessions, 
       COUNT(orders.website_session_id)/COUNT(website_sessions.website_session_id) AS conv_rate, 
       SUM(orders.price_usd)/COUNT(website_sessions.website_session_id) as revenue_per_session
FROM website_sessions
	LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1;

select * from orders;