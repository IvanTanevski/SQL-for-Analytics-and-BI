/* Assignment 28: Analyze the minimum, maximum and average time between the first and second session for customers who 
  do have come back within given time period between '2014-01-01' and '2014-11-03' */

/* Step 1: Create temporary table with subquery, so in one step we extract the first and second session per users who came back
  on the website, and calculate the time period between their first and second session. In the inner query the is constraint to 
  select only new users, while in the outer query only existing users who came back second time on our website. */
DROP TABLE IF EXISTS table1;
CREATE TEMPORARY TABLE table1
SELECT subquery.user_id, 
	   min_ AS first_date,
       min_session_id AS first_session_id,
       min(website_sessions.website_session_id) AS next_session_id, 
       min(website_sessions.created_at) AS repeat_date,
       datediff(min(website_sessions.created_at), min_) AS days_diff
FROM (
	SELECT user_id,
		min(created_at) AS min_,
		min(website_session_id) AS min_session_id
	FROM website_sessions
	WHERE is_repeat_session = 0
	AND created_at >= '2014-01-01' AND created_at < '2014-11-03'
	GROUP BY 1) AS subquery
JOIN website_sessions ON website_sessions.user_id = subquery.user_id
	AND website_sessions.website_session_id > subquery.min_session_id
WHERE website_sessions.is_repeat_session = 1
	AND website_sessions.created_at >= '2014-01-01' 
		AND created_at < '2014-11-03'
GROUP BY 1;

-- Step 2: Extract and summarizing the required metrics from the temporary table.
SELECT AVG(days_diff) AS avg_days_first_to_second,
       MIN(days_diff) AS min_days_first_to_second,
       MAX(days_diff) AS max_days_first_to_second
FROM table1;

-- Check 1 - Check users with min days_diff to check the min result (0 days) from the upper result set
SELECT *
FROM table1
WHERE days_diff = 0;

-- Check 2 - Check the users from check one to see clearly each their session i.e when they came back
SELECT website_session_id, 
       user_id, 
       created_at
FROM website_sessions
WHERE user_id IN (182172 , 254605, 265222, 279800)
GROUP BY 1
ORDER BY 2;