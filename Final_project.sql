-- FINAL PROJECT - Advanced SQL + MySQL for Analytics and Business Intelligence. 
-- The tasks here are shown like messages, requests from the management of the company to the analyst.

/* Task 1: First, I'd like to show our volume growth. Can you pull overall session and order volume, trended by quarter
   for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it. */

SELECT YEAR(website_sessions.created_at) AS 'year',
	   QUARTER(website_sessions.created_at) 'quarter',
       COUNT(website_sessions.website_session_id) AS sessions,
       COUNT(orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/* Task 2: Next, let's showcase all of our efficiency improvements. I would like to show quarterly figures since we
   launched, for session-to-order conversion rate, revenue per order, and revenue per session. */
   
SELECT YEAR(website_sessions.created_at) AS 'year',
	   QUARTER(website_sessions.created_at) 'quarter',
       COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) AS conv_rate, 
       SUM(orders.price_usd)/COUNT(orders.order_id) AS revenue_per_order, 
       SUM(orders.price_usd)/COUNT(website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/* Task 3: I'd like to show how we've grown specific channels. Could you pull a quarterly view of orders from Gsearch
   nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in? */
   
-- Step 0: Checking all unique combination of channels so we can make the case to count pivot table(result set) next.
SELECT DISTINCT utm_source, 
                utm_campaign, 
                http_referer
FROM website_sessions;

-- Solution: Grouping by year and quarter, counting orders in case they meet the defined criteria by what channel they are coming.
SELECT YEAR(website_sessions.created_at) AS 'year',
	   QUARTER(website_sessions.created_at) 'quarter',
       COUNT(CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS 'gsearch_nonbrand', 
       COUNT(CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS 'bsearch_nonbrand', 
       COUNT(CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS 'brand_search_overall',
       COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS 'organic_search', 
       COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS 'direct_type_in'
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/* Task 4: Next, let's show the overall session-to-order conversion rate trends for those same channels, by quarter.
   Please also make a note of any periods where we made mayor improvements or optimizations. */

/* Solution: Similar to the upper task, using the count in case pivot method, we divide the number of orders by number of sessions 
   so that we can get result set with conversion rate metrics per each channel per quarter. */
SELECT YEAR(website_sessions.created_at) AS 'year',
	   QUARTER(website_sessions.created_at) 'quarter',
       COUNT(CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)/
			COUNT(CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS 'gsearch_nonbrand_conv_rate', 
       COUNT(CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)/
			COUNT(CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS 'bsearch_nonbrand_conv_rate', 
       COUNT(CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END)/
			COUNT(CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS 'brand_search_overall_conv_rate',
       COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END)/
			COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS 'organic_search_conv_rate', 
       COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END)/
			COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS 'direct_ type_in_conv_rate'
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/*** Conclusion: After running the code, we can see that all channels have substantial increase on conversion rate which is very
   good for the company, and for potential investors. ***/

/* Task 5: We've come a long day since the days of selling a single product. Let's pull monthly trending for revenue
   and margin by product, along with total sales and revenue. Note everything you notice about seasonality. */

-- Step 0: Checking the products we have, and their unique product_id numbers.
select distinct product_id from order_items;
-- Product IDs: 1, 2, 3, 4 (mrfuzzy, lovebear, birthdaybear, minibear)

-- Solution: Grouping the data per year and month, summaring the metrics per product, then summarizing total sales and margin.
SELECT YEAR(created_at) AS 'year',
	   MONTH(created_at) AS 'month',
       SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfyzzy_rev,
       SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfyzzy_margin,
       SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
       SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_margin,
       SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
       SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_margin,
       SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev, 
       SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_margin,
       SUM(price_usd) AS total_sales,
       SUM(price_usd-cogs_usd) AS total_margin
FROM order_items
GROUP BY 1,2
ORDER BY 1,2;

/* Task 6: Let's dive deeper into the impact of introducing new products. Please pull monthly sessions to the '/products' 
   page, and show how the % of those sessions clicking through another page has changed over time, along with
   a view of how conversion from '/products' to placing an order has improved. */

/* Step 1: Creating temporary table click_through_products to create field next_pg_id per each session that get to the '/products' 
   page, if that session continued on our website, clicking on some on the products, or NULL (because of the left join) if not 
   continued, so we can later count the sessions that countinued after seeing the '/products' page. */
   
DROP TABLE IF EXISTS click_through_products;
CREATE TEMPORARY TABLE click_through_products
SELECT subquery.website_session_id,   -- the id of the session we are grouping by.
	   subquery.first_products_page_view_time, -- timestamp of the session when viewed the '/products' page.
       subquery.first_products_page_view_id, -- pageview_id of the '/products' page.
       MIN(website_pageviews.website_pageview_id) AS next_pg_id -- the first(min) next pageview_id if session continued(clicked) on other page.
from (
	SELECT website_session_id,
	MIN(created_at) first_products_page_view_time, 
	MIN(website_pageview_id) first_products_page_view_id
	FROM website_pageviews
	WHERE pageview_url = '/products'
	GROUP BY 1) AS subquery
		LEFT JOIN
			website_pageviews ON website_pageviews.website_session_id = subquery.website_session_id
				AND website_pageviews.website_pageview_id > subquery.first_products_page_view_id -- getting only the next pageview_ids per session
		GROUP BY 1;
    
select * from click_through_products; -- checking and observing the click_through_products table, so we can summarize and group the results next.

/* Step 2: Summarizing the metrics by year and month, counting the sessions on the '/products' page, the session that continued on our website,
  '/products' page click through rate, orders and conversion rate per session that viewed the products page. */
SELECT YEAR(subquery.first_products_page_view_time) AS yr,
       MONTH(subquery.first_products_page_view_time) AS mo,
       COUNT(subquery.first_products_page_view_id) AS products_page_clicks,
       COUNT(subquery.next_pg_id) AS next_pg_clicks,
       COUNT(subquery.next_pg_id)/COUNT(first_products_page_view_id) AS sessions_with_next_pg_rate,
       COUNT(order_id) AS orders,
       COUNT(order_id)/COUNT(first_products_page_view_id) AS conv_rate_products_to_order
FROM (
	SELECT table1.*, orders.order_id 
	FROM table1 
	LEFT JOIN
		orders ON table1.website_session_id = orders.website_session_id ) AS subquery
GROUP BY 1,2
ORDER BY 1,2;

