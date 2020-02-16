-- Assignment 26: Pull the data on how many of our visitors come back for another session from '2014-01-01' to '2014-11-01'.

-- In the subquery, we are summing and grouping repeated sessions by user, and in the outer query we are selecting the number of repeat
-- sessions and their count, with constraint in the where clause to count only by new user_id so we don't double the result metric users,
-- because repeat sessions are already grouped by user in the subquery, and we need to count only distinct (not repeated records) users (user_ids).
SELECT repeat_sessions, 
	   COUNT(user_id) AS users
FROM(
	SELECT user_id,
		   is_repeat_session,
		   SUM(is_repeat_session) AS repeat_sessions
	FROM website_sessions
	WHERE created_at BETWEEN '2014-01-01' AND '2014-11-01'
	GROUP BY 1) AS subquery
WHERE is_repeat_session = 0
GROUP BY 1
ORDER BY 1;