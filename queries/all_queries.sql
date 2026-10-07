-- SQL for Analysts Who Hate SQL, by Mathew Kariuki
-- All 50 book queries and all 50 'Try it' answers, tested on SQLite with bean_and_leaf.db
-- Open bean_and_leaf.db in DB Browser for SQLite, copy one query into Execute SQL and run it.

-- =================== THE 50 QUESTIONS ===================

-- Question 1: What does our product catalogue look like?
SELECT *
FROM products;

-- Question 2: Which products cost more than $30?
SELECT product_name, category, unit_price
FROM products
WHERE unit_price > 30
ORDER BY unit_price DESC;

-- Question 3: Who are our 10 newest customers?
SELECT customer_id, first_name, last_name, country, signup_date
FROM customers
ORDER BY signup_date DESC
LIMIT 10;

-- Question 4: Which orders were cancelled last month?
SELECT order_id, customer_id, order_date
FROM orders
WHERE status = 'Cancelled'
  AND order_date >= '2025-12-01'
  AND order_date <  '2026-01-01'
ORDER BY order_date;

-- Question 5: Which Australian customers signed up through Instagram?
SELECT first_name, last_name, email, signup_date
FROM customers
WHERE country = 'Australia'
  AND channel = 'Instagram'
ORDER BY signup_date;

-- Question 6: How many customers do we have?
SELECT COUNT(*) AS total_customers
FROM customers;

-- Question 7: What's the total value of everything we've sold?
SELECT SUM(quantity * unit_price) AS total_sales_value
FROM order_items;

-- Question 8: What's our average order value?
SELECT ROUND(SUM(quantity * unit_price)
             / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM order_items;

-- Question 9: How many orders were cancelled or refunded?
SELECT COUNT(*) AS problem_orders
FROM orders
WHERE status IN ('Cancelled', 'Refunded');

-- Question 10: What are our cheapest and dearest products?
SELECT MIN(unit_price) AS cheapest,
       MAX(unit_price) AS dearest,
       AVG(unit_price) AS average_price
FROM products;

-- Question 11: How many customers come from each country?
SELECT country, COUNT(*) AS customers
FROM customers
GROUP BY country
ORDER BY customers DESC;

-- Question 12: How many orders did we get each month?
SELECT SUBSTR(order_date, 1, 7) AS order_month,
       COUNT(*) AS orders
FROM orders
GROUP BY SUBSTR(order_date, 1, 7)
ORDER BY order_month;

-- Question 13: Which categories have an average price above $25?
SELECT category,
       COUNT(*) AS products,
       ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(unit_price) > 25
ORDER BY avg_price DESC;

-- Question 14: Which customers have placed more than five orders?
SELECT customer_id, COUNT(*) AS orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 5
ORDER BY orders DESC;

-- Question 15: Which products have sold more than 500 units?
SELECT product_id, SUM(quantity) AS units_sold
FROM order_items
GROUP BY product_id
HAVING SUM(quantity) > 500
ORDER BY units_sold DESC;

-- Question 16: What's the product name on every order line?
SELECT oi.order_id,
       p.product_name,
       oi.quantity,
       oi.unit_price
FROM order_items AS oi
JOIN products AS p
  ON p.product_id = oi.product_id
ORDER BY oi.order_id
LIMIT 10;

-- Question 17: What is revenue by country?
SELECT c.country,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders AS o
JOIN customers AS c    ON c.customer_id = o.customer_id
JOIN order_items AS oi ON oi.order_id   = o.order_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY c.country
ORDER BY revenue DESC;

-- Question 18: Which customers signed up but never ordered?
SELECT c.customer_id, c.first_name, c.last_name, c.signup_date
FROM customers AS c
LEFT JOIN orders AS o
  ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.signup_date;

-- Question 19: Which products have never sold?
SELECT p.product_id, p.product_name, p.category
FROM products AS p
LEFT JOIN order_items AS oi
  ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;

-- Question 20: What are revenue and gross profit per product?
SELECT p.product_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue,
       ROUND(SUM(oi.quantity * (oi.unit_price - p.unit_cost)), 2)
         AS gross_profit
FROM order_items AS oi
JOIN orders   AS o ON o.order_id   = oi.order_id
JOIN products AS p ON p.product_id = oi.product_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY p.product_name
ORDER BY gross_profit DESC
LIMIT 10;

-- Question 21: Can we split customers into light, regular and big spenders?
SELECT c.customer_id,
       c.first_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent,
       CASE
         WHEN SUM(oi.quantity * oi.unit_price) >= 500 THEN 'Big spender'
         WHEN SUM(oi.quantity * oi.unit_price) >= 100 THEN 'Regular'
         ELSE 'Light'
       END AS segment
FROM customers AS c
JOIN orders AS o       ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id   = o.order_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY c.customer_id, c.first_name
ORDER BY total_spent DESC
LIMIT 10;

-- Question 22: Which customers are missing an email address?
SELECT customer_id, first_name, last_name, country
FROM customers
WHERE email IS NULL;

-- Question 23: How many orders used a discount code?
SELECT CASE
         WHEN discount_code IS NULL THEN 'No code'
         ELSE 'Used a code'
       END AS code_used,
       COUNT(*) AS orders
FROM orders
GROUP BY CASE
         WHEN discount_code IS NULL THEN 'No code'
         ELSE 'Used a code'
       END;

-- Question 24: How do we tidy "UK", "U.K." and "United Kingdom" into one value?
SELECT country AS original,
       CASE
         WHEN UPPER(country) IN ('UK', 'U.K.', 'UNITED KINGDOM', 'ENGLAND')
           THEN 'United Kingdom'
         WHEN UPPER(country) IN ('US', 'USA', 'U.S.A.', 'UNITED STATES')
           THEN 'United States'
         WHEN UPPER(country) IN ('AU', 'AUS', 'AUSTRALIA')
           THEN 'Australia'
         ELSE country
       END AS clean_country,
       COUNT(*) AS customers
FROM customers
GROUP BY country
ORDER BY clean_country, customers DESC;

-- Question 25: Which shipping region does each order belong to?
SELECT o.order_id,
       c.country,
       CASE
         WHEN UPPER(c.country) IN ('AUSTRALIA', 'AU', 'AUS') THEN 'APAC'
         WHEN UPPER(c.country) IN ('US', 'USA', 'U.S.A.', 'UNITED STATES')
           THEN 'Americas'
         ELSE 'EMEA'
       END AS shipping_region,
       COALESCE(c.email, 'no email on file') AS contact
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
LIMIT 10;

-- Question 26: Which weekday gets the most orders?
SELECT CASE STRFTIME('%w', order_date)
         WHEN '0' THEN 'Sunday'   WHEN '1' THEN 'Monday'
         WHEN '2' THEN 'Tuesday'  WHEN '3' THEN 'Wednesday'
         WHEN '4' THEN 'Thursday' WHEN '5' THEN 'Friday'
         ELSE 'Saturday'
       END AS weekday,
       COUNT(*) AS orders
FROM orders
GROUP BY STRFTIME('%w', order_date)
ORDER BY orders DESC;

-- Question 27: How many days pass between signup and first order?
SELECT c.customer_id,
       c.signup_date,
       MIN(o.order_date) AS first_order,
       ROUND(JULIANDAY(MIN(o.order_date))
             - JULIANDAY(c.signup_date), 0) AS days_to_first_order
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.signup_date
ORDER BY days_to_first_order DESC
LIMIT 10;

-- Question 28: Which customers ordered in the last 90 days?
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.order_date >= DATE('2025-12-31', '-90 days')
ORDER BY c.customer_id;

-- Question 29: How long do support tickets take to close?
SELECT topic,
       COUNT(*) AS tickets,
       ROUND(AVG((JULIANDAY(closed_at) - JULIANDAY(opened_at)) * 24), 1)
         AS avg_hours_to_close
FROM support_tickets
WHERE closed_at IS NOT NULL
GROUP BY topic
ORDER BY avg_hours_to_close DESC;

-- Question 30: What was weekly revenue over the last quarter?
SELECT DATE(o.order_date, '-6 days', 'weekday 1') AS week_starting,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('Completed', 'Shipped')
  AND o.order_date >= '2025-10-06'
GROUP BY week_starting
ORDER BY week_starting;

-- Question 31: Which orders are above our average order value?
WITH order_totals AS (
  SELECT order_id,
         SUM(quantity * unit_price) AS order_value
  FROM order_items
  GROUP BY order_id
)
SELECT order_id, ROUND(order_value, 2) AS order_value
FROM order_totals
WHERE order_value > (SELECT AVG(order_value) FROM order_totals)
ORDER BY order_value DESC
LIMIT 10;

-- Question 32: Who is the top-spending customer in each country?
WITH customer_spend AS (
  SELECT c.customer_id,
         c.first_name || ' ' || c.last_name AS customer,
         c.country,
         SUM(oi.quantity * oi.unit_price) AS spent
  FROM customers AS c
  JOIN orders AS o       ON o.customer_id = c.customer_id
  JOIN order_items AS oi ON oi.order_id   = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
    AND c.country IN ('Australia', 'United Kingdom', 'United States')
  GROUP BY c.customer_id, customer, c.country
),
country_max AS (
  SELECT country, MAX(spent) AS top_spend
  FROM customer_spend
  GROUP BY country
)
SELECT cs.country, cs.customer, ROUND(cs.spent, 2) AS spent
FROM customer_spend AS cs
JOIN country_max AS cm
  ON cm.country = cs.country
 AND cm.top_spend = cs.spent
ORDER BY spent DESC;

-- Question 33: What share of customers come back for a second order?
WITH orders_per_customer AS (
  SELECT customer_id, COUNT(*) AS orders
  FROM orders
  WHERE status IN ('Completed', 'Shipped')
  GROUP BY customer_id
)
SELECT COUNT(*) AS buyers,
       SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) AS repeat_buyers,
       ROUND(100.0 * SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS repeat_rate_pct
FROM orders_per_customer;

-- Question 34: Which customers spend more than twice the average customer?
WITH customer_spend AS (
  SELECT o.customer_id,
         SUM(oi.quantity * oi.unit_price) AS spent
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
  GROUP BY o.customer_id
)
SELECT customer_id, ROUND(spent, 2) AS spent
FROM customer_spend
WHERE spent > 2 * (SELECT AVG(spent) FROM customer_spend)
ORDER BY spent DESC
LIMIT 10;

-- Question 35: Which discount codes brought in first-time buyers?
WITH first_orders AS (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM orders
  GROUP BY customer_id
)
SELECT o.discount_code,
       COUNT(*) AS customers
FROM first_orders AS f
JOIN orders AS o
  ON o.customer_id = f.customer_id
 AND o.order_date  = f.first_order_date
WHERE o.discount_code IS NOT NULL
GROUP BY o.discount_code
ORDER BY customers DESC;

-- Question 36: How do products rank by revenue within their category?
WITH product_revenue AS (
  SELECT p.category,
         p.product_name,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM order_items AS oi
  JOIN products AS p ON p.product_id = oi.product_id
  JOIN orders   AS o ON o.order_id   = oi.order_id
  WHERE o.status IN ('Completed', 'Shipped')
  GROUP BY p.category, p.product_name
)
SELECT category,
       product_name,
       ROUND(revenue, 2) AS revenue,
       RANK() OVER (PARTITION BY category ORDER BY revenue DESC)
         AS rank_in_category
FROM product_revenue
ORDER BY category, rank_in_category;

-- Question 37: What's the running total of revenue through the year?
WITH monthly AS (
  SELECT SUBSTR(o.order_date, 1, 7) AS month,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
    AND o.order_date >= '2025-01-01'
  GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_total
FROM monthly
ORDER BY month;

-- Question 38: How much did revenue grow month over month?
WITH monthly AS (
  SELECT SUBSTR(o.order_date, 1, 7) AS month,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
  GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS previous_month,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS growth_pct
FROM monthly
ORDER BY month;

-- Question 39: What was each customer's most recent order?
WITH numbered AS (
  SELECT customer_id,
         order_id,
         order_date,
         ROW_NUMBER() OVER (PARTITION BY customer_id
                            ORDER BY order_date DESC) AS rn
  FROM orders
)
SELECT customer_id, order_id, order_date AS latest_order
FROM numbered
WHERE rn = 1
ORDER BY latest_order DESC
LIMIT 10;

-- Question 40: What's the three-month moving average of sales?
WITH monthly AS (
  SELECT SUBSTR(o.order_date, 1, 7) AS month,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
  GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(AVG(revenue) OVER (ORDER BY month
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)
         AS moving_avg_3m
FROM monthly
ORDER BY month;

-- Question 41: Which customers have stopped buying?
WITH customer_history AS (
  SELECT customer_id,
         COUNT(*) AS orders,
         MAX(order_date) AS last_order
  FROM orders
  WHERE status IN ('Completed', 'Shipped')
  GROUP BY customer_id
)
SELECT customer_id,
       orders,
       DATE(last_order) AS last_order,
       CAST(JULIANDAY('2025-12-31') - JULIANDAY(last_order) AS INTEGER)
         AS days_since_last_order
FROM customer_history
WHERE orders >= 2
  AND last_order < DATE('2025-12-31', '-180 days')
ORDER BY orders DESC, days_since_last_order DESC;

-- Question 42: How well do monthly first-order cohorts keep buying?
WITH first_order AS (
  SELECT customer_id, MIN(SUBSTR(order_date, 1, 7)) AS cohort
  FROM orders
  GROUP BY customer_id
),
activity AS (
  SELECT DISTINCT f.cohort,
         o.customer_id,
         (CAST(SUBSTR(o.order_date, 1, 4) AS INTEGER) * 12
          + CAST(SUBSTR(o.order_date, 6, 2) AS INTEGER))
         - (CAST(SUBSTR(f.cohort, 1, 4) AS INTEGER) * 12
          + CAST(SUBSTR(f.cohort, 6, 2) AS INTEGER)) AS months_after
  FROM orders AS o
  JOIN first_order AS f ON f.customer_id = o.customer_id
)
SELECT cohort,
       COUNT(DISTINCT CASE WHEN months_after = 0 THEN customer_id END) AS m0,
       COUNT(DISTINCT CASE WHEN months_after = 1 THEN customer_id END) AS m1,
       COUNT(DISTINCT CASE WHEN months_after = 2 THEN customer_id END) AS m2,
       COUNT(DISTINCT CASE WHEN months_after = 3 THEN customer_id END) AS m3,
       COUNT(DISTINCT CASE WHEN months_after = 6 THEN customer_id END) AS m6
FROM activity
WHERE cohort BETWEEN '2025-01' AND '2025-06'
GROUP BY cohort
ORDER BY cohort;

-- Question 43: What is a customer worth over their lifetime?
WITH customer_value AS (
  SELECT c.customer_id,
         c.channel,
         COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS lifetime_revenue
  FROM customers AS c
  LEFT JOIN orders AS o
    ON o.customer_id = c.customer_id
   AND o.status IN ('Completed', 'Shipped')
  LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
  GROUP BY c.customer_id, c.channel
)
SELECT channel,
       COUNT(*) AS customers,
       ROUND(AVG(lifetime_revenue), 2) AS avg_lifetime_value
FROM customer_value
GROUP BY channel
ORDER BY avg_lifetime_value DESC;

-- Question 44: Which marketing channel gives the best return on spend?
WITH revenue_by_channel AS (
  SELECT c.channel,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM customers AS c
  JOIN orders AS o       ON o.customer_id = c.customer_id
  JOIN order_items AS oi ON oi.order_id   = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
    AND c.signup_date >= '2025-01-01'
  GROUP BY c.channel
),
spend_by_channel AS (
  SELECT channel, SUM(spend) AS spend
  FROM marketing_spend
  WHERE month >= '2025-01-01'
  GROUP BY channel
)
SELECT r.channel,
       ROUND(r.revenue, 2) AS revenue,
       ROUND(s.spend, 2)   AS spend,
       ROUND(r.revenue / NULLIF(s.spend, 0), 2) AS revenue_per_dollar
FROM revenue_by_channel AS r
JOIN spend_by_channel AS s ON s.channel = r.channel
ORDER BY revenue_per_dollar DESC;

-- Question 45: Do customers who contact support buy less afterwards?
WITH customer_stats AS (
  SELECT o.customer_id,
         COUNT(DISTINCT o.order_id) AS orders,
         SUM(oi.quantity * oi.unit_price) AS spent
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
  GROUP BY o.customer_id
),
ticket_customers AS (
  SELECT DISTINCT customer_id FROM support_tickets
)
SELECT CASE WHEN t.customer_id IS NULL THEN 'No tickets'
            ELSE 'Raised a ticket' END AS group_name,
       COUNT(*) AS customers,
       ROUND(AVG(cs.orders), 2) AS avg_orders,
       ROUND(AVG(cs.spent), 2)  AS avg_spent
FROM customer_stats AS cs
LEFT JOIN ticket_customers AS t ON t.customer_id = cs.customer_id
GROUP BY group_name;

-- Question 46: Do we have duplicate customers?
SELECT email,
       COUNT(*) AS records,
       MIN(customer_id) AS first_id,
       MAX(customer_id) AS last_id
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY records DESC, email;

-- Question 47: How do we keep only one record per duplicate?
WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY COALESCE(email, customer_id)
                            ORDER BY signup_date, customer_id) AS rn
  FROM customers
)
SELECT customer_id, first_name, last_name, email, country, signup_date
FROM ranked
WHERE rn = 1;

-- Question 48: Which orders look like outliers or typos?
SELECT oi.order_id,
       p.product_name,
       oi.quantity,
       oi.unit_price,
       oi.quantity * oi.unit_price AS line_value
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
WHERE oi.quantity > 10 * (SELECT AVG(quantity) FROM order_items)
ORDER BY oi.quantity DESC;

-- Question 49: Are there orders with no line items?
SELECT o.order_id, o.order_date, o.status
FROM orders AS o
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
ORDER BY o.order_date;

-- Question 50: How do we save the monthly report as a reusable view?
CREATE VIEW monthly_report AS
SELECT SUBSTR(o.order_date, 1, 7) AS month,
       COUNT(DISTINCT o.order_id)    AS orders,
       COUNT(DISTINCT o.customer_id) AS customers,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue,
       ROUND(SUM(oi.quantity * oi.unit_price)
             / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY SUBSTR(o.order_date, 1, 7);


-- =================== TRY IT ANSWERS ===================
-- Answer 42 needs the first_order and activity CTEs from Question 42 placed above it.

-- Try it 1
SELECT product_name, unit_price
FROM products;

-- Try it 2
SELECT product_name, unit_price
FROM products
WHERE category = 'Tea'
  AND unit_price < 10;

-- Try it 3
SELECT customer_id, first_name, last_name, signup_date
FROM customers
ORDER BY signup_date, customer_id
LIMIT 5;

-- Try it 4
SELECT order_id, customer_id, order_date
FROM orders
WHERE status = 'Refunded'
  AND order_date >= '2025-11-01'
  AND order_date <  '2025-12-01';

-- Try it 5
SELECT first_name, last_name, country
FROM customers
WHERE country IN ('United Kingdom', 'United States')
  AND channel = 'Referral';

-- Try it 6
SELECT COUNT(*) AS tea_products
FROM products
WHERE category = 'Tea';

-- Try it 7
SELECT SUM(quantity) AS units_sold
FROM order_items;

-- Try it 8
SELECT ROUND(AVG(quantity), 2) AS avg_quantity
FROM order_items;

-- Try it 9
SELECT COUNT(discount_code) AS orders_with_code
FROM orders;

-- Try it 10
SELECT MIN(order_date) AS first_order,
       MAX(order_date) AS latest_order
FROM orders;

-- Try it 11
SELECT category, COUNT(*) AS products
FROM products
GROUP BY category;

-- Try it 12
SELECT status, COUNT(*) AS orders
FROM orders
GROUP BY status
ORDER BY orders DESC;

-- Try it 13
SELECT country, COUNT(*) AS customers
FROM customers
GROUP BY country
HAVING COUNT(*) > 50;

-- Try it 14
SELECT product_id, COUNT(*) AS order_lines
FROM order_items
GROUP BY product_id
HAVING COUNT(*) > 300
ORDER BY order_lines DESC;

-- Try it 15
SELECT SUBSTR(order_date, 1, 4) AS year, COUNT(*) AS orders
FROM orders
GROUP BY SUBSTR(order_date, 1, 4);

-- Try it 16
SELECT o.order_id, o.order_date, c.first_name, c.country
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
ORDER BY o.order_id
LIMIT 10;

-- Try it 17
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items AS oi
JOIN orders   AS o ON o.order_id   = oi.order_id
JOIN products AS p ON p.product_id = oi.product_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY p.category
ORDER BY revenue DESC;

-- Try it 18
SELECT COUNT(*) AS customers_without_tickets
FROM customers AS c
LEFT JOIN support_tickets AS t ON t.customer_id = c.customer_id
WHERE t.ticket_id IS NULL;

-- Try it 19
SELECT COUNT(*) AS never_cancelled
FROM customers AS c
LEFT JOIN orders AS o
  ON o.customer_id = c.customer_id
 AND o.status = 'Cancelled'
WHERE o.order_id IS NULL;

-- Try it 20
SELECT p.category,
       ROUND(100.0 * SUM(oi.quantity * (oi.unit_price - p.unit_cost))
             / SUM(oi.quantity * oi.unit_price), 1) AS margin_pct
FROM order_items AS oi
JOIN orders   AS o ON o.order_id   = oi.order_id
JOIN products AS p ON p.product_id = oi.product_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY p.category
ORDER BY margin_pct DESC;

-- Try it 21
SELECT CASE
         WHEN unit_price < 15 THEN 'Budget'
         WHEN unit_price <= 50 THEN 'Mid'
         ELSE 'Premium'
       END AS price_band,
       COUNT(*) AS products
FROM products
GROUP BY price_band;

-- Try it 22
SELECT COUNT(*) AS open_tickets
FROM support_tickets
WHERE closed_at IS NULL;

-- Try it 23
SELECT COALESCE(discount_code, 'No code') AS code,
       COUNT(*) AS orders
FROM orders
GROUP BY COALESCE(discount_code, 'No code')
ORDER BY orders DESC;

-- Try it 24
SELECT CASE
         WHEN UPPER(c.country) IN ('UK', 'U.K.', 'UNITED KINGDOM', 'ENGLAND')
           THEN 'United Kingdom'
         WHEN UPPER(c.country) IN ('US', 'USA', 'U.S.A.', 'UNITED STATES')
           THEN 'United States'
         WHEN UPPER(c.country) IN ('AU', 'AUS', 'AUSTRALIA')
           THEN 'Australia'
         ELSE c.country
       END AS clean_country,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders AS o
JOIN customers AS c    ON c.customer_id = o.customer_id
JOIN order_items AS oi ON oi.order_id   = o.order_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY clean_country
ORDER BY revenue DESC;

-- Try it 25
SELECT CASE
         WHEN UPPER(country) IN ('AUSTRALIA', 'AU', 'AUS') THEN 'APAC'
         WHEN UPPER(country) IN ('US', 'USA', 'U.S.A.', 'UNITED STATES')
           THEN 'Americas'
         ELSE 'EMEA'
       END AS shipping_region,
       COUNT(*) AS customers
FROM customers
GROUP BY shipping_region;

-- Try it 26
SELECT STRFTIME('%H', order_date) AS hour, COUNT(*) AS orders
FROM orders
GROUP BY hour
ORDER BY orders DESC
LIMIT 3;

-- Try it 27
WITH firsts AS (
  SELECT c.customer_id, c.channel,
         JULIANDAY(MIN(o.order_date)) - JULIANDAY(c.signup_date) AS days
  FROM customers AS c
  JOIN orders AS o ON o.customer_id = c.customer_id
  GROUP BY c.customer_id, c.channel
)
SELECT channel, ROUND(AVG(days), 1) AS avg_days_to_first_order
FROM firsts
GROUP BY channel
ORDER BY avg_days_to_first_order;

-- Try it 28
SELECT COUNT(*) AS orders
FROM orders
WHERE order_date >= '2025-12-01';

-- Try it 29
SELECT COUNT(*) AS slow_tickets
FROM support_tickets
WHERE closed_at IS NOT NULL
  AND (JULIANDAY(closed_at) - JULIANDAY(opened_at)) * 24 > 72;

-- Try it 30
SELECT CASE
         WHEN SUBSTR(o.order_date, 6, 2) IN ('01', '02', '03') THEN 'Q1'
         WHEN SUBSTR(o.order_date, 6, 2) IN ('04', '05', '06') THEN 'Q2'
         WHEN SUBSTR(o.order_date, 6, 2) IN ('07', '08', '09') THEN 'Q3'
         ELSE 'Q4'
       END AS quarter,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('Completed', 'Shipped')
  AND o.order_date >= '2025-01-01'
GROUP BY quarter
ORDER BY quarter;

-- Try it 31
SELECT product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY unit_price DESC;

-- Try it 32
WITH units AS (
  SELECT p.category, p.product_name, SUM(oi.quantity) AS units
  FROM order_items AS oi
  JOIN products AS p ON p.product_id = oi.product_id
  GROUP BY p.category, p.product_name
),
top_units AS (
  SELECT category, MAX(units) AS max_units
  FROM units
  GROUP BY category
)
SELECT u.category, u.product_name, u.units
FROM units AS u
JOIN top_units AS t
  ON t.category = u.category AND t.max_units = u.units;

-- Try it 33
WITH buyers AS (
  SELECT DISTINCT customer_id FROM orders
)
SELECT ROUND(100.0 * COUNT(DISTINCT t.customer_id)
             / COUNT(DISTINCT b.customer_id), 1) AS pct_with_ticket
FROM buyers AS b
LEFT JOIN support_tickets AS t ON t.customer_id = b.customer_id;

-- Try it 34
WITH customer_spend AS (
  SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS spent
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
  GROUP BY o.customer_id
)
SELECT COUNT(*) AS above_average
FROM customer_spend
WHERE spent > (SELECT AVG(spent) FROM customer_spend);

-- Try it 35
WITH first_orders AS (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM orders
  GROUP BY customer_id
)
SELECT COUNT(*) AS holiday_first_timers
FROM first_orders
WHERE SUBSTR(first_order_date, 6, 2) IN ('11', '12');

-- Try it 36
WITH monthly AS (
  SELECT SUBSTR(o.order_date, 1, 7) AS month,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
    AND o.order_date >= '2025-01-01'
  GROUP BY month
)
SELECT month, ROUND(revenue, 2) AS revenue,
       RANK() OVER (ORDER BY revenue DESC) AS month_rank
FROM monthly
ORDER BY month_rank;

-- Try it 37
WITH signups AS (
  SELECT SUBSTR(signup_date, 1, 7) AS month, COUNT(*) AS new_customers
  FROM customers
  WHERE signup_date >= '2025-01-01'
  GROUP BY month
)
SELECT month, new_customers,
       SUM(new_customers) OVER (ORDER BY month) AS running_total
FROM signups
ORDER BY month;

-- Try it 38
WITH monthly AS (
  SELECT SUBSTR(o.order_date, 1, 7) AS month,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
  GROUP BY month
),
compared AS (
  SELECT month, revenue,
         LAG(revenue, 12) OVER (ORDER BY month) AS last_year
  FROM monthly
)
SELECT month, ROUND(revenue, 2) AS revenue,
       ROUND(last_year, 2) AS same_month_2024,
       ROUND(100.0 * (revenue - last_year) / last_year, 1) AS yoy_growth_pct
FROM compared
WHERE month >= '2025-01';

-- Try it 39
WITH numbered AS (
  SELECT o.customer_id, o.order_id, o.order_date, c.signup_date,
         ROW_NUMBER() OVER (PARTITION BY o.customer_id
                            ORDER BY o.order_date) AS rn
  FROM orders AS o
  JOIN customers AS c ON c.customer_id = o.customer_id
)
SELECT customer_id, order_id, order_date
FROM numbered
WHERE rn = 1
ORDER BY signup_date DESC, customer_id
LIMIT 10;

-- Try it 40
WITH customer_spend AS (
  SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS spent
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
  GROUP BY o.customer_id
),
quartiles AS (
  SELECT spent, NTILE(4) OVER (ORDER BY spent) AS quartile
  FROM customer_spend
)
SELECT quartile, COUNT(*) AS customers,
       ROUND(MIN(spent), 2) AS lowest, ROUND(MAX(spent), 2) AS highest
FROM quartiles
GROUP BY quartile
ORDER BY quartile;

-- Try it 41
WITH customer_history AS (
  SELECT o.customer_id,
         COUNT(DISTINCT o.order_id) AS orders,
         MAX(o.order_date) AS last_order,
         SUM(oi.quantity * oi.unit_price) AS spent
  FROM orders AS o
  JOIN order_items AS oi ON oi.order_id = o.order_id
  WHERE o.status IN ('Completed', 'Shipped')
  GROUP BY o.customer_id
)
SELECT COUNT(*) AS lapsed_big_spenders
FROM customer_history
WHERE orders >= 2
  AND last_order < DATE('2025-12-31', '-180 days')
  AND spent >= 500;

-- Try it 42
-- Reuse the first_order and activity CTEs from Question 42, then:
SELECT cohort,
       COUNT(DISTINCT CASE WHEN months_after = 0 THEN customer_id END) AS m0,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN months_after = 3 THEN customer_id END)
             / COUNT(DISTINCT CASE WHEN months_after = 0 THEN customer_id END), 1)
         AS m3_retention_pct
FROM activity
WHERE cohort BETWEEN '2025-01' AND '2025-06'
GROUP BY cohort
ORDER BY cohort;

-- Try it 43
WITH customer_value AS (
  SELECT c.customer_id,
         CASE
           WHEN UPPER(c.country) IN ('UK', 'U.K.', 'UNITED KINGDOM', 'ENGLAND')
             THEN 'United Kingdom'
           WHEN UPPER(c.country) IN ('US', 'USA', 'U.S.A.', 'UNITED STATES')
             THEN 'United States'
           ELSE 'Australia'
         END AS clean_country,
         COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS lifetime_revenue
  FROM customers AS c
  LEFT JOIN orders AS o
    ON o.customer_id = c.customer_id
   AND o.status IN ('Completed', 'Shipped')
  LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
  GROUP BY c.customer_id, clean_country
)
SELECT clean_country, COUNT(*) AS customers,
       ROUND(AVG(lifetime_revenue), 2) AS avg_lifetime_value
FROM customer_value
GROUP BY clean_country
ORDER BY avg_lifetime_value DESC;

-- Try it 44
SELECT month, ROUND(SUM(spend), 2) AS total_spend
FROM marketing_spend
WHERE month >= '2025-01-01'
GROUP BY month
ORDER BY total_spend DESC
LIMIT 1;

-- Try it 45
WITH orders_per_customer AS (
  SELECT customer_id, COUNT(*) AS orders
  FROM orders
  WHERE status IN ('Completed', 'Shipped')
  GROUP BY customer_id
)
SELECT CASE WHEN customer_id IN (SELECT customer_id FROM support_tickets)
            THEN 'Raised a ticket' ELSE 'No tickets' END AS group_name,
       ROUND(100.0 * SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS repeat_rate_pct
FROM orders_per_customer
GROUP BY group_name;

-- Try it 46
SELECT COUNT(*) AS name_groups, SUM(records) AS records
FROM (
  SELECT first_name, last_name, country, COUNT(*) AS records
  FROM customers
  GROUP BY first_name, last_name, country
  HAVING COUNT(*) > 1
) AS shared_names;

-- Try it 47
WITH ranked AS (
  SELECT customer_id,
         ROW_NUMBER() OVER (PARTITION BY email
                            ORDER BY signup_date, customer_id) AS rn
  FROM customers
  WHERE email IS NOT NULL
)
SELECT COUNT(*) AS orders_on_duplicates
FROM orders
WHERE customer_id IN (SELECT customer_id FROM ranked WHERE rn > 1);

-- Try it 48
SELECT oi.order_id, p.product_name, oi.unit_price,
       p.unit_price AS catalogue_price
FROM order_items AS oi
JOIN orders   AS o ON o.order_id   = oi.order_id
JOIN products AS p ON p.product_id = oi.product_id
WHERE ABS(oi.unit_price
          - CASE WHEN o.order_date >= '2025-01-01'
                 THEN p.unit_price * 1.05 ELSE p.unit_price END)
      > 0.10 * p.unit_price;

-- Try it 49
SELECT COUNT(*) AS orphan_lines
FROM order_items AS oi
LEFT JOIN products AS p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL;

-- Try it 50
SELECT ROUND(SUM(revenue), 2) AS q4_revenue,
       ROUND(SUM(revenue) / SUM(orders), 2) AS q4_avg_order_value
FROM monthly_report
WHERE month BETWEEN '2025-10' AND '2025-12';
