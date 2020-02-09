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
-- My solution:
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

-- Solution similar to the solution video by the instructor, both solution give the same results, the difference is in the structure of
-- the table(result set) obtained and what structure would be preferable for us to see or for visualizing the result set.
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
-- visualize it.
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
-- predifined time range
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

-- Task 5: Pulling out website performance, i.e. session to orders conversion rates from the first 8 months. Again I didn't
-- group by year because the starting record in the database is in 3rd month, and our whole project is for records ending
-- the same year in 11th month.
SELECT YEAR(website_sessions.created_at) as 'year',
       MONTH(website_sessions.created_at) AS 'month',
	   COUNT(website_sessions.website_session_id) AS sessions,
       COUNT(orders.website_session_id) AS orders, 
       COUNT(orders.website_session_id)/COUNT(website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
	LEFT JOIN orders on website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

-- Task 6: 
--   Step 1: Finding when the new campaign (lander-1) started
--   create temporary table campaign_start_date
select created_at as first_created_at, min(website_pageview_id) as first_pageview_id
from website_pageviews
where pageview_url = '/lander-1';
-- We get result 23504

--   Step 2: Finding the first pageview_id per relevant (between '2012-06-19' and '2012-07-28') sessions
drop table if exists first_pageview_per_session;
create temporary table first_pageview_per_session
select website_session_id,
       min(website_pageview_id) as min_id,
       pageview_url
	from website_pageviews
    where (website_pageviews.created_at between '2012-06-19' and '2012-07-28') and (pageview_url = '/home' or pageview_url = '/lander-1')
    group by website_session_id;

--   Step 3: Find counts for every session between '2012-06-19' and '2012-07-28'
drop table if exists webpage_counts;
create temporary table webpage_counts
select website_pageviews.website_session_id, 
	   count(website_pageview_id) as count
from website_pageviews 
where (website_pageviews.created_at between '2012-06-19' and '2012-07-28')
    group by website_pageviews.website_session_id;

select first_pageview_per_session.pageview_url, 
	   count(webpage_counts.count) as sessions,
	   count(orders.website_session_id) as orders, 
       count(orders.website_session_id)/count(webpage_counts.count) as conv_rate
from first_pageview_per_session join webpage_counts 
on first_pageview_per_session.website_session_id = webpage_counts.website_session_id
join website_sessions on website_sessions.website_session_id = first_pageview_per_session.website_session_id
left join orders on website_sessions.website_session_id = orders.website_session_id
where utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by 1;

SELECT ROUND(('0.0409' - '0.0321'), 4) AS increased_conversion_rate;
-- We get result 0.0088 

SELECT MAX(website_sessions.website_session_id) as last_home_page
FROM website_sessions LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_pageviews.pageview_url = '/home'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand';
-- We get result 17145 (last website_session_id before the gsearch nonbrand campaign lander page is moved on lander-1)

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