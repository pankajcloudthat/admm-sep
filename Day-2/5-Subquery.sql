-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_demo


-- Subqueries and Nested Queries
-- -------------------------------------

-- A subquery is a query written inside another SQL query.
--
-- The inner query provides a result that is used
-- by the outer query.
--
-- Subqueries are commonly used with:
--
-- IN
-- EXISTS
-- =
-- >
-- <
-- >=
-- <=
--
-- A subquery can be:
--
-- 1. Non-correlated subquery
-- 2. Correlated subquery
-- 3. Nested subquery


-- DROP DATABASE IF EXISTS retail_demo;

-- CREATE DATABASE retail_demo;

USE retail_demo;


-- Create Customers Table
-- -------------------------------------

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(100) NOT NULL,
    city VARCHAR(50)
);


-- Insert Customer Data
-- -------------------------------------

INSERT INTO customers
(first_name, last_name, email, city)
VALUES
('Rahul', 'Sharma', 'rahul@example.com', 'Delhi'),
('Priya', 'Verma', 'priya@example.com', 'Mumbai'),
('Amit', 'Kumar', 'amit@example.com', 'Bangalore'),
('Neha', 'Singh', 'neha@example.com', 'Pune'),
('Ravi', 'Patel', 'ravi@example.com', 'Ahmedabad'),
('Sneha', 'Gupta', 'sneha@example.com', 'Jaipur');


-- Create Orders Table
-- -------------------------------------

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'Pending',

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- Insert Order Data
-- -------------------------------------

INSERT INTO orders
(customer_id, order_date, product_name, product_category,
 total_amount, status)
VALUES
(1, '2026-01-05', 'Laptop', 'Electronics', 65000.00, 'Completed'),
(1, '2026-01-15', 'Headphones', 'Electronics', 5000.00, 'Completed'),
(1, '2026-02-10', 'Office Chair', 'Furniture', 12000.00, 'Shipped'),
(2, '2026-01-10', 'Smartphone', 'Electronics', 32000.00, 'Completed'),
(2, '2026-02-20', 'Running Shoes', 'Fashion', 5000.00, 'Shipped'),
(3, '2026-02-03', 'Dining Table', 'Furniture', 45000.00, 'Completed'),
(4, '2026-02-10', 'Monitor', 'Electronics', 30000.00, 'Completed'),
(4, '2026-03-05', 'Keyboard', 'Electronics', 3000.00, 'Pending'),
(5, '2026-02-15', 'Backpack', 'Fashion', 2500.00, 'Completed');


SELECT * FROM customers;

SELECT * FROM orders;


-- Simple Subquery
-- -------------------------------------

-- Business Question:
-- Find customers who have placed at least one order.


SELECT *
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
);


-- What is happening?
--
-- Inner query:
-- Returns customer IDs from orders.
--
-- Outer query:
-- Finds customers whose ID exists in that result.
--
-- The inner query does NOT depend on the outer query.
--
-- Therefore, this is a NON-CORRELATED subquery.


-- Subquery with Comparison
-- -------------------------------------

-- Business Question:
-- Find orders whose amount is greater than
-- the average order amount.


SELECT *
FROM orders
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM orders
);


-- Inner query:
-- Calculates the average order amount.
--
-- Outer query:
-- Finds orders above that average.


-- Subquery with MAX()
-- -------------------------------------

-- Business Question:
-- Find the most expensive order.


SELECT *
FROM orders
WHERE total_amount = (
    SELECT MAX(total_amount)
    FROM orders
);


-- Subquery with MIN()
-- -------------------------------------

-- Business Question:
-- Find the smallest order.


SELECT *
FROM orders
WHERE total_amount = (
    SELECT MIN(total_amount)
    FROM orders
);


-- Nested Subquery
-- -------------------------------------

-- A nested subquery means a subquery
-- inside another subquery.
--
-- Business Question:
--
-- Find customers who placed an order
-- greater than the average order amount.


SELECT *
FROM customers
WHERE customer_id IN (

    SELECT customer_id
    FROM orders

    WHERE total_amount > (

        SELECT AVG(total_amount)
        FROM orders

    )

);


-- What is happening?
--
-- Level 1 - Innermost query
-- Calculates the average order amount.
--
-- Level 2 - Middle query
-- Finds customers who have an order
-- greater than that average.
--
-- Level 3 - Outer query
-- Gets the customer details.


-- Nested Subquery with Product Category
-- -------------------------------------

-- Business Question:
-- Find customers who purchased from a category
-- whose average order value is greater than 20,000.


SELECT *
FROM customers
WHERE customer_id IN (

    SELECT customer_id
    FROM orders
    WHERE product_category IN (

        SELECT product_category
        FROM orders
        GROUP BY product_category
        HAVING AVG(total_amount) > 300

    )

);


-- Correlated Subquery
-- -------------------------------------

-- A correlated subquery depends on the
-- current row of the outer query.
--
-- Business Question:
-- Find customers whose total spending is
-- greater than 50,000.


SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE (
    SELECT SUM(o.total_amount)
    FROM orders o
    WHERE o.customer_id = c.customer_id
) > 50000;


-- Why is this correlated?
--
-- The inner query uses:
--
-- o.customer_id = c.customer_id
--
-- c.customer_id comes from the outer query.
--
-- Therefore, the inner query depends on
-- the current customer being processed.


-- Correlated Subquery with AVG()
-- -------------------------------------

-- Business Question:
-- Find customers whose total spending is
-- greater than the average order amount.


SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE (
    SELECT SUM(o.total_amount)
    FROM orders o
    WHERE o.customer_id = c.customer_id
) > (
    SELECT AVG(total_amount)
    FROM orders
);


-- EXISTS
-- -------------------------------------

-- EXISTS checks whether the subquery
-- returns at least one row.
--
-- Business Question:
-- Find customers who have placed at least
-- one order.


SELECT *
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- Why SELECT 1?
--
-- EXISTS does not care about the actual
-- value returned by the subquery.
--
-- It only checks whether a matching row exists.


-- NOT EXISTS
-- -------------------------------------

-- Business Question:
-- Find customers who have NEVER placed an order.


SELECT *
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- IN vs EXISTS
-- -------------------------------------

-- IN
-- -> Compares a value against a list of values.
--
-- EXISTS
-- -> Checks whether at least one matching row exists.


-- Using IN

SELECT *
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
);


-- Using EXISTS

SELECT *
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- Important NULL Edge Case
-- -------------------------------------

-- NOT IN can produce unexpected results
-- when the subquery contains NULL.
--
-- Example:
--
-- WHERE customer_id NOT IN (
--     SELECT customer_id FROM orders
-- )
--
-- If the subquery contains NULL,
-- comparisons can result in UNKNOWN.
--
-- NOT EXISTS is generally safer when
-- checking for missing related records.


-- Subquery in SELECT
-- -------------------------------------

-- A subquery can also be used in the SELECT list.
--
-- Business Question:
-- Show every customer along with
-- their total spending.


SELECT
    c.customer_id,
    c.first_name,
    c.last_name,

    (
        SELECT COALESCE(SUM(o.total_amount), 0)
        FROM orders o
        WHERE o.customer_id = c.customer_id
    ) AS total_spent

FROM customers c;


-- Subquery in FROM
-- -------------------------------------

-- A subquery can be treated as a temporary
-- result set (derived table).
--
-- Business Question:
-- Find customers whose spending is
-- greater than 50,000.


SELECT *
FROM (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

) customer_sales

WHERE total_spent > 50000;


-- Subquery vs JOIN
-- -------------------------------------

-- The same requirement can often be solved
-- using either a subquery or a JOIN.


-- Using Subquery

SELECT *
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
);


-- Using JOIN

SELECT DISTINCT
    c.*
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id;


-- Both can return customers who have orders.


-- Summary
-- -------------------------------------

-- Non-Correlated Subquery
-- -> Does not depend on outer query.
--
-- Example:
-- Find orders above average.


-- Correlated Subquery
-- -> Depends on the outer query.
--
-- Example:
-- Find customers based on their
-- individual order totals.


-- Nested Subquery
-- -> Subquery inside another subquery.
--
-- Example:
-- Customer -> Orders -> Average Order


-- IN
-- -> Checks whether a value exists
--    in a list returned by a subquery.


-- EXISTS
-- -> Checks whether at least one
--    matching row exists.


-- NOT EXISTS
-- -> Finds rows with no matching record.


-- Subquery in SELECT
-- -> Calculates a value for each outer row.


-- Subquery in FROM
-- -> Creates a temporary result set.









-- TODO Task
-- -------------------------------------

-- The retail manager wants to identify
-- high-value customers.
--
-- 1. Find customers whose total spending is greater than the average customer spending.
-- 2. Find the customer(s) who placed the highest-value order.
-- 3. Find customers who have never placed an order.
-- 4. Find orders whose value is greater than the average order value.
-- 5. Find customers who have at least one Completed order.