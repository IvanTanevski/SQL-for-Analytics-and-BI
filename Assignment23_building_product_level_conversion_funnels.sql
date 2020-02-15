-- Assignment 23: Build conversion funnel from each product page to conversion. 
-- Produce a comparison between the two conversion funnels for each website traffic within given dates.

-- Step 0: Finding the relevant pages (billing, cart etc.) we need for the subquery.
/* SELECT DISTINCT pageview_url 
FROM website_pageviews 
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'; */

-- Step 1: Creating temporary table with flags, till which page each session ended.
DROP TABLE IF EXISTS session_level_made_it;
CREATE TEMPORARY TABLE session_level_made_it
SELECT website_session_id, 
       pageview_url,
	   MAX(mr_fuzzy_page) AS mr_fuzzy_mage_it,
       MAX(lovebear_page) AS lovebear_mage_it,
       MAX(cart_page) AS cart_made_it,
       MAX(shipping_page) AS shipping_made_it,
       MAX(billing_page) AS billing_made_it,
       MAX(thank_you_page) AS thank_you_made_it
FROM
(SELECT website_sessions.website_session_id, 
	   website_pageviews.pageview_url,
	   CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
       CASE WHEN website_pageviews.pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END AS lovebear_page,
	   CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	   CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	   CASE WHEN website_pageviews.pageview_url IN ('/billing', '/billing-2') THEN 1 ELSE 0 END AS billing_page,
	   CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
FROM website_sessions
	LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2013-01-06' AND '2013-04-10'
	AND website_pageviews.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear','/cart', '/shipping', '/billing', '/billing-2', '/thank-you-for-your-order')) AS subquery
GROUP BY 1;

-- Step 2: Grouping the sessions by product page, and summing the flags to count the click to every session final pageview.
SELECT 
	CASE 
		WHEN mr_fuzzy_mage_it = 1 THEN 'mrfuzzy' 
        ELSE 'lovebear'
	END AS product_seen,
	COUNT(website_session_id) AS sessions, 
    SUM(cart_made_it) AS to_cart,
    SUM(shipping_made_it) AS to_shipping,
    SUM(billing_made_it) AS to_billing,
    SUM(thank_you_made_it) AS to_thank_you
FROM session_level_made_it
GROUP BY 1;

-- Step 2/2: Similar to the upper query, calculating relative click rates for each next step a session made it.
SELECT 
	CASE 
		WHEN mr_fuzzy_mage_it = 1 THEN 'mrfuzzy' 
        ELSE 'lovebear'
	END AS product_seen,
	SUM(cart_made_it)/COUNT(website_session_id) AS product_page_click_rate, 
    SUM(shipping_made_it)/SUM(cart_made_it) AS cart_click_rate,
    SUM(billing_made_it)/SUM(shipping_made_it) AS shipping_click_rate,
    SUM(thank_you_made_it)/SUM(billing_made_it) AS billing_click_rate
FROM session_level_made_it
GROUP BY 1;
