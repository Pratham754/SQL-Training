--List all customers

--SELECT customer_id, first_name, last_name, city
--FROM sales_customers;


--List all staffs with their store

--SELECT s.staff_id, s.first_name, st.store_name
--FROM sales_staffs s
--JOIN sales_stores st ON s.store_id = st.store_id;


--Orders with customer names

--SELECT o.order_id,
--       c.first_name + ' ' + c.last_name AS customer_name,
--       o.order_date,
--       o.order_status
--FROM sales_orders o
--JOIN sales_customers c ON o.customer_id = c.customer_id;

--Total orders per customer

--SELECT c.customer_id,
--       c.first_name,
--       COUNT(o.order_id) AS total_orders
--FROM sales_customers c
--LEFT JOIN sales_orders o ON c.customer_id = o.customer_id
--GROUP BY c.customer_id, c.first_name;
