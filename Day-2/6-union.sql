-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_demo
-- Active: 1770471809351@@127.0.0.1@3306@demo


-- UNION and UNION ALL
-- -------------------------------------

-- UNION combines the results of two or more SELECT statements
-- into a single result set.
--
-- UNION removes duplicate rows automatically.
--
-- UNION ALL also combines results from multiple SELECT statements,
-- but it keeps duplicate rows.


-- Create Database
-- -------------------------------------

CREATE DATABASE IF NOT EXISTS retail_demo;

USE retail_demo;


-- Online Customers
-- -------------------------------------

DROP TABLE IF EXISTS online_customers;

CREATE TABLE online_customers (
    customer_id INT,
    customer_name VARCHAR(100),
    city VARCHAR(50)
);


INSERT INTO online_customers
(customer_id, customer_name, city)
VALUES
(1, 'Rahul Sharma', 'Delhi'),
(2, 'Priya Verma', 'Mumbai'),
(3, 'Amit Kumar', 'Bangalore'),
(4, 'Neha Singh', 'Pune');


-- Store Customers
-- -------------------------------------

DROP TABLE IF EXISTS store_customers;

CREATE TABLE store_customers (
    customer_id INT,
    customer_name VARCHAR(100),
    city VARCHAR(50)
);


INSERT INTO store_customers
(customer_id, customer_name, city)
VALUES
(3, 'Amit Kumar', 'Bangalore'),
(4, 'Neha Singh', 'Pune'),
(5, 'Ravi Patel', 'Ahmedabad'),
(6, 'Sneha Gupta', 'Jaipur');


SELECT * FROM online_customers;

SELECT * FROM store_customers;


-- UNION
-- -------------------------------------

-- Combine online and store customers.
--
-- Duplicate rows are removed.

SELECT
    customer_id,
    customer_name,
    city
FROM online_customers

UNION

SELECT
    customer_id,
    customer_name,
    city
FROM store_customers;


-- Amit and Neha appear only once because
-- UNION removes duplicate rows.


-- UNION ALL
-- -------------------------------------

-- Combine online and store customers.
--
-- Duplicate rows are retained.

SELECT
    customer_id,
    customer_name,
    city
FROM online_customers

UNION ALL

SELECT
    customer_id,
    customer_name,
    city
FROM store_customers;


-- Amit and Neha appear twice because
-- UNION ALL does not remove duplicates.


-- UNION with Source Information
-- -------------------------------------

-- Business Question:
-- Combine customers from both channels
-- and identify where the record came from.


SELECT
    customer_id,
    customer_name,
    city,
    'Online' AS customer_source
FROM online_customers

UNION ALL

SELECT
    customer_id,
    customer_name,
    city,
    'Store' AS customer_source
FROM store_customers;


-- This is useful when we want to keep
-- the source of each record.


-- Find Unique Customers
-- -------------------------------------

-- UNION can be used to create a unique
-- customer list from multiple sources.


SELECT
    customer_id,
    customer_name,
    city
FROM online_customers

UNION

SELECT
    customer_id,
    customer_name,
    city
FROM store_customers;


-- Count Unique Customers
-- -------------------------------------

SELECT COUNT(*) AS unique_customers
FROM (

    SELECT
        customer_id,
        customer_name,
        city
    FROM online_customers

    UNION

    SELECT
        customer_id,
        customer_name,
        city
    FROM store_customers

) AS all_customers;


-- UNION Column Rules
-- -------------------------------------

-- The SELECT statements used with UNION
-- must have the same number of columns.


-- Correct:

SELECT customer_id, customer_name
FROM online_customers

UNION

SELECT customer_id, customer_name
FROM store_customers;


-- Column names do NOT have to be the same,
-- but the position of the columns must match.


-- Data Types
-- -------------------------------------

-- Corresponding columns should have compatible
-- data types.


-- Example:

SELECT customer_id, customer_name
FROM online_customers

UNION

SELECT customer_id, customer_name
FROM store_customers;


-- The first SELECT determines the column names
-- in the final result.


-- ORDER BY with UNION
-- -------------------------------------

-- ORDER BY is normally placed at the end
-- of the complete UNION query.


SELECT
    customer_id,
    customer_name,
    city
FROM online_customers

UNION

SELECT
    customer_id,
    customer_name,
    city
FROM store_customers

ORDER BY customer_name;


-- UNION vs UNION ALL
-- -------------------------------------

-- UNION
-- -> Combines result sets
-- -> Removes duplicates
-- -> Performs duplicate checking
--
-- UNION ALL
-- -> Combines result sets
-- -> Keeps duplicates
-- -> Generally faster than UNION


-- Important Difference
-- -------------------------------------

-- If the same customer exists in both tables:
--
-- UNION:
--     Customer appears once
--
-- UNION ALL:
--     Customer appears twice


-- Business Example
-- -------------------------------------

-- Retail company has customers from:
--
-- 1. Online store
-- 2. Physical stores
--
-- Management wants one customer list.






-- TODO Task
-- -------------------------------------

-- The retail company has customers from
-- Online and Store channels.
--
-- 1. Create a third table called mobile_customers.
-- 2. Add at least 3 customers to it.
-- 3. Use UNION to create one unique customer list from all three tables.
-- 4. Use UNION ALL to see all records, including duplicates.
-- 5. Add a "source" column using:
--    'Online'
--    'Store'
--    'Mobile'
-- 6. Sort the final customer list by customer_name.