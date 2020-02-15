-- Assignement 22: Product level website pathing

-- Step 1: Find the relevean /products pageviews with website_session_id and add time_period column needed for the next step.
DROP TABLE IF EXISTS product_pageviews;
CREATE TEMPORARY TABLE product_pageviews
SELECT website_session_id, 
	   created_at, 
       website_pageview_id,
       CASE	
		WHEN created_at < '2013-01-06' THEN 'A_Pre_product_2'
        ELSE 'B_Post_Product_2'
	   END AS time_period
FROM website_pageviews
WHERE pageview_url = '/products'
	AND created_at BETWEEN '2012-10-06' AND '2013-04-06';

-- Step 2: Find the next pageview_id that occurs AFTER the product pageview.
DROP TABLE IF EXISTS sessions_with_next_pageview_id;
CREATE TEMPORARY TABLE sessions_with_next_pageview_id
SELECT product_pageviews.time_period, 
	   product_pageviews.website_session_id,
       MIN(website_pageviews.website_pageview_id) AS next_pageview_url
FROM product_pageviews
	LEFT JOIN website_pageviews on product_pageviews.website_session_id = website_pageviews.website_session_id
		AND website_pageviews.website_pageview_id > product_pageviews.website_pageview_id
GROUP BY 1,2;

-- Step 3: Fing the pageview_url associated with any applicable next_pageview_id.
DROP TABLE IF EXISTS sessions_with_next_pageview_url;
CREATE TEMPORARY TABLE sessions_with_next_pageview_url
SELECT sessions_with_next_pageview_id.time_period, 
	   sessions_with_next_pageview_id.website_session_id,
       website_pageviews.pageview_url AS next_pageview_url
FROM sessions_with_next_pageview_id
	LEFT JOIN 
		website_pageviews on sessions_with_next_pageview_id.next_pageview_url = website_pageviews.website_pageview_id;

-- Step 4: Grouping by time_period, and summarizing sessions and rates by product.
SELECT time_period,
	   COUNT(website_session_id) AS sessions,
       COUNT(CASE WHEN next_pageview_url IS NOT NULL THEN 1 ELSE NULL END)/COUNT(website_session_id) AS with_next_pg,
       COUNT(CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END) AS to_mrfuzzy,
       COUNT(CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END)/
		COUNT(website_session_id) pct_to_mrfuzzy, 
	   COUNT(CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN 1 ELSE NULL END) AS to_lovebear,
       COUNT(CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN 1 ELSE NULL END)/
		COUNT(website_session_id) pct_to_lovebear
FROM sessions_with_next_pageview_url
GROUP BY 1;