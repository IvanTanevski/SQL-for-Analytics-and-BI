/* Assignment 29: Analyzing repeat channel behavior.
   Comparing new vs repeated users by channel. */

-- Step 0: Checking all unique combination of channel so we can make the case to count pivot table(result set) next.
SELECT DISTINCT utm_source, 
                utm_campaign, 
                http_referer
FROM website_sessions 
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05';

-- Step 1: Summarizing combinations of channels and http_referer, we count in case is repeated or new session.
SELECT CASE 
		WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 'organic_search'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_source = 'socialbook' THEN 'paid_social'
	   END AS channel_group, 
       COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
       COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeated_sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1;