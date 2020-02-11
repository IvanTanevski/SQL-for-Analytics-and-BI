/*  Advanced SQL + MySQL for Analytics & Business Intelligence by Maven Analytics instructor John Pauler
    MID COURSE PROJECT 
    All code is my own, and bit different from the solution video by the instructor. Whenever possible I tried to 
    implement more than one solution. Some code is pretty much same, because it's made and guided from the lectures before
    this project. Also the YEAR() function I added after watching the solution video for the project. It is not necessary for
	obtaining correct result, but it's pretty much clearer with year extracted in the result sets before the month number. */

-- Task 1: Pulling monthly trends within given time interval for gsearch sessions and orders, so the company's growth can be shown.
SELECT YEAR(website_sessions.created_at) as 'year',
       MONTH(website_sessions.created_at) as 'month', 
	   COUNT(website_sessions.website_session_id) sessions,
       COUNT(orders.order_id) as orders
FROM website_sessions 
	LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY YEAR(website_sessions.created_at), MONTH(website_sessions.created_at);

-- Task 2: In addition to task 1 splitting out nonbrand and brand campaigns separately.
-- One solution:
SELECT YEAR(website_sessions.created_at) as 'year',
	   MONTH(website_sessions.created_at) as 'month',
       website_sessions.utm_source, 
	   website_sessions.utm_campaign as campaign,
	   COUNT(website_sessions.website_session_id) sessions,
       COUNT(orders.order_id) as orders
FROM website_sessions 
	LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY YEAR(website_sessions.created_at), MONTH(website_sessions.created_at), website_sessions.utm_campaign;

-- Second solution similar to the solution video by the instructor, both solution give the same results, the difference is in the structure
-- of the table(result set) obtained and what structure would be preferable for us to see, or for visualizing the result set.
SELECT YEAR(website_sessions.created_at) as 'year',
	   MONTH(website_sessions.created_at) as 'month',
       COUNT(CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN 1 ELSE NULL END) nonbrand_sessions, 
       COUNT(CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) nonbrand_orders,
       COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN 1 ELSE NULL END) brand_sessions, 
       COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) brand_orders
FROM website_sessions 
	LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY MONTH(website_sessions.created_at);

-- Task 3: In addition to task 1 splitting monthly sessions and orders by device type.
SELECT YEAR(website_sessions.created_at) as 'year',
       MONTH(website_sessions.created_at) as 'month',
       COUNT(CASE WHEN website_sessions.device_type = 'mobile' THEN 1 ELSE NULL END) mobile_sessions, 
       COUNT(CASE WHEN website_sessions.device_type = 'mobile' THEN orders.order_id ELSE NULL END) mobile_orders,
       COUNT(CASE WHEN website_sessions.device_type = 'desktop' THEN 1 ELSE NULL END) desktop_sessions, 
       COUNT(CASE WHEN website_sessions.device_type = 'desktop' THEN orders.order_id ELSE NULL END) desktop_orders
FROM website_sessions 
	LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY YEAR(website_sessions.created_at), MONTH(website_sessions.created_at);

-- Task 3: Second possible solution, again we choose one depending on how we want to present the resulting set and/or
-- visualize it, grouping it on the device type dimension also beside month and year.
SELECT YEAR(website_sessions.created_at) as 'year',
       MONTH(website_sessions.created_at) as 'month',
	   website_sessions.device_type as device,
	   COUNT(website_sessions.website_session_id) sessions,
       COUNT(orders.order_id) as orders
FROM website_sessions 
	LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2,3;

-- Task 4: Presenting gsearch source traffic trend, among other search channels.
-- First we find all combinations of utm_source, utm_campaign, and http_referer from website_sessions within the
-- predifined time range.
SELECT utm_source, 
	   utm_campaign, 
       http_referer 
FROM website_sessions 
WHERE created_at < '2012-11-27'
group by 1, 2, 3;

-- Grouping by month and aggregating traffic. Because both utm sources are connected with the campaigns(paid_traffic) we count 
-- the number of records from gsearch and bsearch as their paid traffic, else is either reffered from any of the search engines
-- (organic search traffic) or direct type-in session on the analyzed website.
SELECT YEAR(website_sessions.created_at) as 'year',
       MONTH(created_at) as 'month',
	   COUNT(CASE WHEN utm_source = 'gsearch' THEN 1 ELSE NULL END) gsearch_paid_traffic, 
       COUNT(CASE WHEN utm_source = 'bsearch' THEN 1 ELSE NULL END) bsearch_paid_traffic, 
       COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 1 ELSE NULL END) organic_search_sessions,
       COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN 1 ELSE NULL END) direct_sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

-- Task 5: Pulling out website performance, i.e. session to orders conversion rates from the first 8 months.
SELECT YEAR(website_sessions.created_at) as 'year',
       MONTH(website_sessions.created_at) AS 'month',
	   COUNT(website_sessions.website_session_id) AS sessions,
       COUNT(orders.website_session_id) AS orders, 
       COUNT(orders.website_session_id)/COUNT(website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
	LEFT JOIN orders on website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

-- Task 6: Estimating the increase in revenue and sessions that new lander-1 landing page earned us.
--   Step 1: Finding when the new campaign (lander-1) started
--   create temporary table campaign_start_date.
SELECT MIN(created_at) AS first_created_at, 
	   MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1';
-- We get result pageview_url = 23504 and date first created '2012-06-19 07:35:54'.

--   Step 2: Finding the first pageview_id per relevant (between '2012-06-19' and '2012-07-28') sessions.
DROP TABLE IF EXISTS first_pageview_per_session;
CREATE TEMPORARY TABLE first_pageview_per_session
SELECT website_session_id,
       MIN(website_pageview_id) AS min_id,
       pageview_url
FROM website_pageviews
WHERE (website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28') 
	AND (pageview_url = '/home' OR pageview_url = '/lander-1')
GROUP BY website_session_id;

--   Step 3: Find pageview counts for every session between '2012-06-19' and '2012-07-28'.
DROP TABLE IF EXISTS webpage_counts;
CREATE TEMPORARY TABLE webpage_counts
SELECT website_pageviews.website_session_id, 
	   count(website_pageview_id) AS count
FROM website_pageviews 
WHERE (website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28')
GROUP BY website_pageviews.website_session_id;

SELECT first_pageview_per_session.pageview_url, 
	   count(webpage_counts.count) AS sessions,
	   count(orders.website_session_id) AS orders, 
       count(orders.website_session_id)/count(webpage_counts.count) AS conv_rate
FROM first_pageview_per_session 
	JOIN webpage_counts ON first_pageview_per_session.website_session_id = webpage_counts.website_session_id
    JOIN website_sessions on website_sessions.website_session_id = first_pageview_per_session.website_session_id
	LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY 1;

SELECT ROUND(('0.0409' - '0.0321'), 4) AS increased_conversion_rate;
-- We get result 0.0088.

SELECT MAX(website_sessions.website_session_id) as last_home_page
FROM website_sessions 
	LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_pageviews.pageview_url = '/home'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand';
-- We get result 17145 (last website_session_id before the gsearch nonbrand campaign lander page is moved on lander-1).

SELECT SUM(orders.price_usd) - SUM(orders.price_usd)/1.088 AS profit_increase_due_new_lander_page
FROM website_sessions 
	LEFT JOIN orders on website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.website_session_id > 17145
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand';
-- We get profit increase 3691.54$

SELECT COUNT(website_session_id) - (COUNT(website_session_id)/1.0088) AS session_number_increased_due_new_lander_page
FROM website_sessions 
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'; 
-- We get result 197 increased number of sessions due to new lander page

-- Task 7: Analyzing full conversion funnels in given daterange for both landing pages.
-- Step 1: Creating temporary flagged table for each website session to get results where each session went maximim on
-- our website.
DROP TABLE IF EXISTS session_level_made_it;
CREATE TEMPORARY TABLE session_level_made_it
SELECT 
	website_session_id,
    MAX(landerpage) as landerpage,
    MAX(homepage) as homepage,
	MAX(products) AS product_made_it,
    MAX(mr_fuzzy_page) AS mr_fuzzy_mage_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thank_you_page) AS thank_you_made_it
	FROM(
    SELECT 
	website_sessions.website_session_id,
	website_pageviews.pageview_url,
	CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS landerpage,
    CASE WHEN website_pageviews.pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
	CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS products,
	CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
	CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
FROM website_sessions
	LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE 
	website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-27'
	AND website_pageviews.pageview_url IN ('/lander-1', '/home', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at
    ) AS pageview_level
GROUP BY 
	website_session_id;

-- Step 2: Creating result set, grouped by case statement by the criteria of a landing page. Then counting to which extent each session
-- went throught on our website.
SELECT CASE 
		WHEN homepage = 1 THEN 'homepage'
        WHEN landerpage = 1 THEN 'landerpage'
	   END AS pageviewed,
	COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN product_made_it > 0 THEN 1 ELSE NULL END) AS to_product,
    COUNT(CASE WHEN mr_fuzzy_mage_it > 0 THEN 1 ELSE NULL END) AS to_mr_fuzzy,
    COUNT(CASE WHEN cart_made_it > 0 THEN 1 ELSE NULL END) AS to_cart,
    COUNT(CASE WHEN shipping_made_it > 0 THEN 1 ELSE NULL END) AS to_shipping,
    COUNT(CASE WHEN billing_made_it > 0 THEN 1 ELSE NULL END) AS to_billing, 
    COUNT(CASE WHEN thank_you_made_it > 0 THEN 1 ELSE NULL END) AS to_thank_you_page
FROM session_level_made_it
GROUP BY 1
ORDER BY 1;

-- Step 3: Same as step 2, but with relative numbers (percentages) from each next step as proportion from the previous one.
SELECT CASE 
		WHEN homepage = 1 THEN 'homepage'
        WHEN landerpage = 1 THEN 'landerpage'
	   END AS pageviewed,
    COUNT(CASE WHEN product_made_it > 0 THEN 1 ELSE NULL END)/COUNT(website_session_id) AS lander_made_it,
    COUNT(CASE WHEN mr_fuzzy_mage_it > 0 THEN 1 ELSE NULL END)/COUNT(CASE WHEN product_made_it > 0 THEN 1 ELSE NULL END) AS product_made_it,
    COUNT(CASE WHEN cart_made_it > 0 THEN 1 ELSE NULL END)/COUNT(CASE WHEN mr_fuzzy_mage_it > 0 THEN 1 ELSE NULL END) AS cart_made_it,
    COUNT(CASE WHEN shipping_made_it > 0 THEN 1 ELSE NULL END)/COUNT(CASE WHEN cart_made_it > 0 THEN 1 ELSE NULL END) AS shipping_made_it,
    COUNT(CASE WHEN billing_made_it > 0 THEN 1 ELSE NULL END)/COUNT(CASE WHEN shipping_made_it > 0 THEN 1 ELSE NULL END) AS billing_mad_it, 
    COUNT(CASE WHEN thank_you_made_it > 0 THEN 1 ELSE NULL END)/COUNT(CASE WHEN billing_made_it > 0 THEN 1 ELSE NULL END) AS thank_you_made_it
FROM session_level_made_it
GROUP BY 1
ORDER BY 1;

-- Task 8: Quantifying the impact of the billing test. Analyzing the impact generated from the billing test (Sep 10 - Nov 10)
-- in terms of revenue per billing page session, and then pulling the number of billing page sessions from 2012-10-72 to 2012-10-72
-- to understang/estimate monthly impact.
-- Step 1: Creating the subquery. My idea/solution since there are only 2 billing webpages (binary choise), and after this query we will
-- need to aggregate(count) on that values, is the billing page to be set on 1 and other option(billing-2) set to NULL. The null values afterwards
-- will be counted as else in the second group by choise (billing-2) after counting the positive values for the first billing page.
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url, 
    website_pageviews.created_at, 
    CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE NULL END AS billing,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END AS orders
FROM 
	website_sessions LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-09-10' AND '2012-11-10'
	AND website_pageviews.pageview_url IN ('/billing', '/billing-2', '/thank-you-for-your-order');

-- Step 2: Creating the temporary table from the upper query.
DROP TABLE IF EXISTS orders_grouped;
CREATE TEMPORARY TABLE orders_grouped
SELECT
	website_session_id, 
    MAX(billing) AS billing,
    MAX(orders) AS orders
FROM (
	SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url, 
    website_pageviews.created_at, 
    CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE NULL END AS billing,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END AS orders
FROM 
	website_sessions LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-09-10' AND '2012-11-10'
	AND website_pageviews.pageview_url IN ('/billing', '/billing-2', '/thank-you-for-your-order')) AS SUBQUERY
GROUP BY website_session_id;

-- Step 3: From the upper temporary table, we make case statement so we can divide billing and billing-2 landing pages.
-- Then we group by the case criteria and join orders. Sum the orders grouped by landing page, divide by the grouped number 
-- of sessions and we get the result below.
SELECT 
	CASE WHEN billing = 1 THEN 'billing' ELSE 'billing-2' END AS lander_page, 
    COUNT(DISTINCT orders_grouped.website_session_id) as sessions, 
    SUM(orders.price_usd)/COUNT(DISTINCT orders_grouped.website_session_id) AS revenue_per_session
FROM orders_grouped
	LEFT JOIN orders ON orders_grouped.website_session_id = orders.website_session_id
GROUP BY lander_page;
-- Billing page revenue per session - $22.94
-- Billing-2 page revenue per session - $31.39
-- Lift: $31.39 - $22.94 = $8.45 per session

-- Step 4: Counting the total number of sessions that got to the billing pages, and make simple calculation of estimated revenue growth.
SELECT 
	COUNT(website_pageviews.website_session_id) AS sessions
FROM website_pageviews
	WHERE pageview_url IN ('/billing', '/billing-2')
		AND created_at BETWEEN '2012-10-27' AND '2012-11-27';
-- Sessions BETWEEN '2012-10-27' AND '2012-11-27' - 1156
-- According the data the revenue growth due to new lander page is 1156 x $8.45 = $9.768
