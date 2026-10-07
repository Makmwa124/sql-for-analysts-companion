-- Bean & Leaf Co. sample database for PostgreSQL
-- From 'SQL for Analysts Who Hate SQL' by Mathew Kariuki

DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (customer_id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, email TEXT, country TEXT, signup_date DATE, channel TEXT);
\copy customers FROM 'customers.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE products (product_id INTEGER PRIMARY KEY, product_name TEXT, category TEXT, unit_price NUMERIC(10,2), unit_cost NUMERIC(10,2));
\copy products FROM 'products.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (order_id INTEGER PRIMARY KEY, customer_id INTEGER REFERENCES customers(customer_id), order_date TIMESTAMP, status TEXT, discount_code TEXT);
\copy orders FROM 'orders.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS order_items CASCADE;
CREATE TABLE order_items (order_id INTEGER REFERENCES orders(order_id), product_id INTEGER REFERENCES products(product_id), quantity INTEGER, unit_price NUMERIC(10,2));
\copy order_items FROM 'order_items.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS marketing_spend CASCADE;
CREATE TABLE marketing_spend (month DATE, channel TEXT, spend NUMERIC(10,2));
\copy marketing_spend FROM 'marketing_spend.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS support_tickets CASCADE;
CREATE TABLE support_tickets (ticket_id INTEGER PRIMARY KEY, customer_id INTEGER REFERENCES customers(customer_id), opened_at TIMESTAMP, closed_at TIMESTAMP, topic TEXT);
\copy support_tickets FROM 'support_tickets.csv' WITH (FORMAT csv, HEADER true);
