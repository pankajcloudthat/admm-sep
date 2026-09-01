-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_demo

-- Aggregation
-- -------------------------------------

-- Aggregation means performing calculations on multiple rows
-- and returning a single summarized result.
--
-- In MySQL, common aggregate functions are:
--
-- COUNT() -> Count rows
-- SUM()   -> Calculate total
-- AVG()   -> Calculate average
-- MIN()   -> Find smallest value
-- MAX()   -> Find largest value
--
-- Aggregation is commonly used with GROUP BY to summarize
-- data by customer, product, category, month, status, etc.


-- Create Database
-- -------------------------------------

CREATE DATABASE IF NOT EXISTS retail_demo;

USE retail_demo;


-- Create Customers Table
-- -------------------------------------

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Create Orders Table
-- -------------------------------------

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'Pending',

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- Insert Customers
-- -------------------------------------

INSERT INTO customers
(first_name, last_name, email, city)
VALUES
('Rahul', 'Sharma', 'rahul@example.com', 'Delhi'),
('Priya', 'Verma', 'priya@example.com', 'Mumbai'),
('Amit', 'Kumar', 'amit@example.com', 'Bangalore'),
('Neha', 'Singh', 'neha@example.com', 'Pune'),
('Ravi', 'Patel', 'ravi@example.com', 'Ahmedabad');


-- Insert Orders
-- -------------------------------------

INSERT INTO orders
(customer_id, order_date, product_category, total_amount, status)
VALUES
(1, '2026-01-05', 'Electronics', 65000.00, 'Completed'),
(2, '2026-01-10', 'Fashion', 5000.00, 'Pending'),
(1, '2026-01-15', 'Electronics', 32000.00, 'Completed'),
(3, '2026-02-03', 'Furniture', 12000.00, 'Shipped'),
(4, '2026-02-10', 'Electronics', 35000.00, 'Completed'),
(5, '2026-02-15', 'Fashion', 2500.00, 'Cancelled'),
(2, '2026-02-20', 'Electronics', 28000.00, 'Shipped'),
(3, '2026-03-05', 'Furniture', 45000.00, 'Completed');


SELECT * FROM customers;

SELECT * FROM orders;


-- Simple Aggregation
-- -------------------------------------

-- Total revenue from all orders

SELECT
    SUM(total_amount) AS total_revenue
FROM orders;


-- Total number of orders

SELECT
    COUNT(*) AS total_orders
FROM orders;


-- Average order value

SELECT
    AVG(total_amount) AS average_order_value
FROM orders;


-- Minimum order value

SELECT
    MIN(total_amount) AS minimum_order_value
FROM orders;


-- Maximum order value

SELECT
    MAX(total_amount) AS maximum_order_value
FROM orders;


-- Aggregation with GROUP BY
-- -------------------------------------

-- GROUP BY divides rows into groups.
--
-- Then aggregate functions calculate a value
-- for each group.


-- Total amount spent by each customer

SELECT
    customer_id,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;


-- Count orders per customer

SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;


-- Average order value per customer

SELECT
    customer_id,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY customer_id;


-- Using JOIN + Aggregation
-- -------------------------------------

-- Show customer names along with:
-- Total number of orders
-- Total amount spent
-- Average order value

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS average_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    o.customer_id,
    c.first_name,
    c.last_name;


-- Include Customers With No Orders
-- -------------------------------------

-- INNER JOIN removes customers who have no orders.
--
-- LEFT JOIN keeps all customers.


DELETE FROM orders WHERE customer_id = 5;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;


-- Filtering Rows Before Aggregation
-- -------------------------------------

-- WHERE filters rows BEFORE GROUP BY.


-- Find completed orders only

SELECT
    customer_id,
    SUM(total_amount) AS total_spent
FROM orders
WHERE status = 'Completed'
GROUP BY customer_id;


-- Filtering Aggregated Results
-- -------------------------------------

-- HAVING filters groups AFTER aggregation.
--
-- Example:
-- Find customers whose total spending is
-- greater than 30,000.


SELECT
    customer_id,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > 30000;


-- WHERE vs HAVING
-- -------------------------------------

-- WHERE
-- -> Filters individual rows
-- -> Applied before GROUP BY
--
-- HAVING
-- -> Filters groups
-- -> Applied after GROUP BY


-- Aggregation by Order Status
-- -------------------------------------

-- Count orders by status

SELECT
    status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY status;


-- Total revenue by status

SELECT
    status,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY status;


-- Average order value by status

SELECT
    status,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY status;


-- Aggregation by Product Category
-- -------------------------------------

SELECT
    product_category,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_sales,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY product_category
ORDER BY total_sales DESC;


-- Monthly Revenue Aggregation
-- -------------------------------------

-- Calculate revenue for each month.

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;


-- Monthly Order Count
-- -------------------------------------

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;


-- Aggregation by City
-- -------------------------------------

-- Total customers by city

SELECT
    city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city;


-- Customer Spending Report
-- -------------------------------------

SELECT
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY total_revenue DESC;


-- Handling NULLs in Aggregation
-- -------------------------------------

-- Aggregate functions generally ignore NULL values.
--
-- COUNT(column) -> ignores NULL
-- SUM(column)   -> ignores NULL
-- AVG(column)   -> ignores NULL
-- MIN(column)   -> ignores NULL
-- MAX(column)   -> ignores NULL


-- Insert an order with NULL amount

INSERT INTO orders
(customer_id, order_date, product_category, total_amount, status)
VALUES
(3, '2026-03-10', 'Electronics', NULL, 'Pending');


-- SUM ignores the NULL value

SELECT
    SUM(total_amount) AS total_revenue
FROM orders;


-- COUNT(*) counts all rows

SELECT
    COUNT(*) AS total_orders
FROM orders;


-- COUNT(column) ignores NULL values

SELECT
    COUNT(total_amount) AS orders_with_amount
FROM orders;


-- Compare COUNT(*), COUNT(column)
-- -------------------------------------

SELECT
    COUNT(*) AS all_orders,
    COUNT(total_amount) AS orders_with_amount
FROM orders;


-- DISTINCT Aggregation
-- -------------------------------------

-- Number of unique customers who placed orders

SELECT
    COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;


-- Number of different product categories

SELECT
    COUNT(DISTINCT product_category) AS unique_categories
FROM orders;


-- COALESCE with Aggregation
-- -------------------------------------

-- COALESCE(value, default)
-- returns the value if it is not NULL.
-- Otherwise, it returns the default value.


SELECT
    COALESCE(SUM(total_amount), 0) AS total_revenue
FROM orders;


-- Top Customers by Revenue
-- -------------------------------------

SELECT
    customer_id,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 3;


-- Business Report
-- -------------------------------------

-- Find customers who:
-- 1. Placed at least 2 orders
-- 2. Spent more than 30,000


SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING
    COUNT(*) >= 2
    AND SUM(total_amount) > 30000;


-- Execution Order
-- -------------------------------------

-- Simplified SQL execution order:
--
-- FROM
-- JOIN
-- WHERE
-- GROUP BY
-- HAVING
-- SELECT
-- ORDER BY
-- LIMIT


-- TODO Task
-- -------------------------------------

-- The retail manager wants a sales summary.
--
-- 1. Find the total revenue for each product category.
-- 2. Find the customer who has spent the most.
-- 3. Find the number of orders for each month.
-- 4. Find customers who have placed more than 1 order.
-- 5. Find customers whose total spending is greater than 50,000.
-- 6. Find the average order value for Completed orders only.