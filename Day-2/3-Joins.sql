-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_demo


-- SQL JOINs
-- Domain: Retail / E-commerce
-- ------------------------------------------------------------

-- Problem Statement
-- ------------------------------------------------------------

-- An e-commerce company stores customers, orders, and products
-- in separate tables.
--
-- Business teams need to combine this data to answer questions:
--
-- 1. Which customers have placed orders?
-- 2. Which customers have never placed an order?
-- 3. Which orders contain which products?
-- 4. Which products have never been ordered?
-- 5. Show all customers and their orders.
-- 6. Find customers who have no orders.
--
-- JOINs allow us to combine related data from multiple tables.



-- INNER JOIN
-- ------------------------------------------------------------
-- Returns only records that have a match
-- in both tables.


-- LEFT JOIN
-- ------------------------------------------------------------
-- Returns ALL records from the left table
-- and matching records from the right table.
--
-- No match -> NULL


-- RIGHT JOIN
-- ------------------------------------------------------------
-- Returns ALL records from the right table
-- and matching records from the left table.
--
-- No match -> NULL


-- FULL OUTER JOIN
-- ------------------------------------------------------------
-- Returns ALL records from both tables.
--
-- MySQL does not directly support FULL OUTER JOIN.
--
-- Can be simulated using:
-- LEFT JOIN
-- UNION
-- RIGHT JOIN


-- CROSS JOIN
-- ------------------------------------------------------------
-- Returns every possible combination
-- of rows from both tables.


-- SELF JOIN
-- ------------------------------------------------------------
-- A table is joined with itself.
--
-- Example:
-- Employee -> Manager
-- Employee -> Employee


-- ------------------------------------------------------------
-- Quick Reference
-- ------------------------------------------------------------

-- INNER JOIN  -> Matching records only
-- LEFT JOIN   -> Everything from LEFT table
-- RIGHT JOIN  -> Everything from RIGHT table
-- FULL JOIN   -> Everything from BOTH tables
-- CROSS JOIN  -> Every possible combination
-- SELF JOIN   -> Table joined with itself


-- Create Database
-- ------------------------------------------------------------

DROP DATABASE IF EXISTS retail_demo;

CREATE DATABASE retail_demo;

USE retail_demo;


-- ------------------------------------------------------------
-- CUSTOMER TABLE
-- ------------------------------------------------------------

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50)
);


INSERT INTO customers
(customer_id, customer_name, city)
VALUES
(1, 'Rahul Sharma', 'Delhi'),
(2, 'Priya Verma', 'Mumbai'),
(3, 'Amit Kumar', 'Bangalore'),
(4, 'Neha Singh', 'Pune'),
(5, 'Ravi Patel', 'Ahmedabad');


-- PRODUCT TABLE
-- ------------------------------------------------------------

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2)
);


INSERT INTO products
(product_id, product_name, category, price)
VALUES
(101, 'Laptop', 'Electronics', 65000),
(102, 'Smartphone', 'Electronics', 32000),
(103, 'Running Shoes', 'Fashion', 5000),
(104, 'Office Chair', 'Furniture', 12000),
(105, 'Coffee Maker', 'Home Appliances', 8500);


-- ORDERS TABLE
-- ------------------------------------------------------------

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE
);


INSERT INTO orders
(order_id, customer_id, product_id, quantity, order_date)
VALUES
(1001, 1, 101, 1, '2026-01-05'),
(1002, 2, 102, 1, '2026-01-10'),
(1003, 1, 103, 2, '2026-01-15'),
(1004, 3, 104, 1, '2026-02-03'),
(1005, 4, 101, 1, '2026-02-10');


-- Ravi has no order.
-- Coffee Maker has never been ordered.


-- View Tables
-- ------------------------------------------------------------

SELECT * FROM customers;

SELECT * FROM products;

SELECT * FROM orders;


-- 1. INNER JOIN
-- ------------------------------------------------------------

-- Returns only rows that have a match in BOTH tables.

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;


-- Business Question:
-- Show customers who have placed at least one order.


-- 2. LEFT JOIN
-- ------------------------------------------------------------

-- Returns ALL rows from the left table,
-- and matching rows from the right table.
--
-- If there is no match, NULL is returned.

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;


-- Ravi appears even though he has no order.


-- Find Customers With NO Orders
-- ------------------------------------------------------------

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- 3. RIGHT JOIN
-- ------------------------------------------------------------

-- Returns ALL rows from the right table,
-- and matching rows from the left table.

SELECT
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
RIGHT JOIN orders o
    ON c.customer_id = o.customer_id;


-- In practice, LEFT JOIN is often preferred because
-- the query can be written in a more natural way.


-- 4. JOIN THREE TABLES
-- ------------------------------------------------------------

-- Combine Customers + Orders + Products.

SELECT
    c.customer_name,
    o.order_id,
    p.product_name,
    p.category,
    o.quantity,
    p.price,
    o.quantity * p.price AS order_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN products p
    ON o.product_id = p.product_id;


-- 5. LEFT JOIN - Find Products Never Ordered
-- ------------------------------------------------------------

SELECT
    p.product_id,
    p.product_name,
    p.category
FROM products p
LEFT JOIN orders o
    ON p.product_id = o.product_id
WHERE o.order_id IS NULL;


-- Coffee Maker will appear because it has no orders.


-- 6. FULL OUTER JOIN
-- ------------------------------------------------------------

-- MySQL does NOT directly support FULL OUTER JOIN.
--
-- It can be simulated using LEFT JOIN + RIGHT JOIN
-- with UNION.

SELECT
    c.customer_name,
    o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id

UNION

SELECT
    c.customer_name,
    o.order_id
FROM customers c
RIGHT JOIN orders o
    ON c.customer_id = o.customer_id;


-- 7. CROSS JOIN
-- ------------------------------------------------------------

-- CROSS JOIN creates every possible combination
-- between two tables.
--
-- 5 customers × 5 products = 25 combinations.

SELECT
    c.customer_name,
    p.product_name
FROM customers c
CROSS JOIN products p;


-- Use carefully!
-- Large tables can produce a huge number of rows.


-- 8. SELF JOIN
-- ------------------------------------------------------------

-- A SELF JOIN joins a table with itself.
--
-- Example: Employees and their managers.

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    manager_id INT NULL
);


INSERT INTO employees
(employee_id, employee_name, manager_id)
VALUES
(1, 'Anil', NULL),
(2, 'Rahul', 1),
(3, 'Priya', 1),
(4, 'Amit', 2);


SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.employee_id;





-- IMPORTANT JOIN EDGE CASES
-- ------------------------------------------------------------


-- Edge Case 1: No Matching Record
-- ------------------------------------------------------------

-- What happens when a customer has no order?
--
-- LEFT JOIN keeps the customer record.
-- Columns from the orders table become NULL.

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;


-- Ravi appears in the result even though he has no order.
-- His order_id and order_date will be NULL.


-- Edge Case 2: Find Records Without a Match
-- ------------------------------------------------------------

-- Find customers who have NEVER placed an order.
--
-- LEFT JOIN + IS NULL is a common pattern
-- for finding records without a match.

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;



-- Edge Case 3: One-to-Many Relationship
-- ------------------------------------------------------------

-- A customer can place multiple orders.
--
-- In this case, the customer appears once
-- for each matching order.

SELECT
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;

-- Rahul has multiple orders,
-- so Rahul appears multiple times.


-- Edge Case 4: LEFT JOIN + WHERE Condition
-- ------------------------------------------------------------

-- Be careful when filtering columns from the
-- right-side table in the WHERE clause.


-- This query removes customers who have no orders.

SELECT
    c.customer_name,
    o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NOT NULL;


-- Although LEFT JOIN was used,
-- the WHERE condition removes NULL values.
--
-- Therefore, this behaves like an INNER JOIN.



-- Edge Case 5: Filter in ON vs WHERE
-- ------------------------------------------------------------

-- Suppose we want:
--
-- "Show ALL customers, but only their orders
-- placed from February 2026 onwards."


-- Correct approach:

SELECT
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.order_date >= '2026-02-01';


-- The date condition is part of the JOIN.
--
-- Customers without matching February orders
-- are still displayed with NULL order values.


-- Compare with this:

SELECT
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_date >= '2026-02-01';


-- Here the WHERE condition removes NULL values.
--
-- Customers without a matching order are removed.
--
-- Important:
-- Conditions in ON and WHERE can produce
-- different results with OUTER JOINs.



-- Edge Case 6: Duplicate Matches
-- ------------------------------------------------------------

-- If the JOIN condition matches multiple rows,
-- the result contains multiple rows.

SELECT
    c.customer_name,
    o.order_id,
    p.product_name
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN products p
    ON o.product_id = p.product_id;


-- One customer
--     +
-- Multiple orders
--     +
-- Multiple matching records
--
-- = Multiple result rows.



-- Edge Case 7: CROSS JOIN Explosion
-- ------------------------------------------------------------

-- CROSS JOIN creates every possible combination.

SELECT
    c.customer_name,
    p.product_name
FROM customers c
CROSS JOIN products p;


-- If there are:
--
-- 5 customers
-- 5 products
--
-- Result = 5 × 5 = 25 rows.
--
-- With large tables, this can produce millions
-- or billions of rows.
--
-- Use CROSS JOIN carefully.



-- Edge Case 8: NULL Join Values
-- ------------------------------------------------------------

-- NULL means "unknown" or "missing".

-- Important:
-- NULL does NOT equal NULL.

-- Therefore:
-- NULL = NULL
-- does NOT return TRUE.


-- Simple Example
-- ------------------------------------------------------------

DROP TABLE IF EXISTS customer_demo;
DROP TABLE IF EXISTS order_demo;


CREATE TABLE customer_demo (
    customer_id INT,
    customer_name VARCHAR(50)
);


CREATE TABLE order_demo (
    order_id INT,
    customer_id INT
);


INSERT INTO customer_demo VALUES
(1, 'Rahul'),
(2, 'Priya'),
(NULL, 'Unknown Customer');


INSERT INTO order_demo VALUES
(101, 1),
(102, 2),
(103, NULL);


-- View the data

SELECT * FROM customer_demo;

SELECT * FROM order_demo;


-- JOIN using =
-- ------------------------------------------------------------

SELECT
    c.customer_name,
    o.order_id
FROM customer_demo c
LEFT JOIN order_demo o
    ON c.customer_id = o.customer_id;


-- Result:
--
-- Rahul  -> 101
-- Priya  -> 102
-- Unknown Customer -> NULL

-- The order with order_id = 103 is NOT matched
-- with customer_id = NULL.

-- Why?
-- Because:

-- NULL = NULL
-- is not TRUE.


-- See the NULL Comparison Directly
-- ------------------------------------------------------------

SELECT
    NULL = NULL AS result;


-- Result:
-- NULL
-- It is NOT TRUE.


-- Correct Way to Compare NULL Values
-- ------------------------------------------------------------

-- MySQL provides the <=> operator for NULL-safe comparison.

SELECT
    NULL <=> NULL AS result;


-- Result:
-- 1

-- 1 means TRUE.


-- NULL-Safe JOIN
-- ------------------------------------------------------------

SELECT
    c.customer_name,
    o.order_id
FROM customer_demo c
LEFT JOIN order_demo o
    ON c.customer_id <=> o.customer_id;


-- Now:
-- Unknown Customer -> 103
-- because <=> treats NULL and NULL as equal.