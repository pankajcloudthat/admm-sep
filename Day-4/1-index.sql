-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_index_demo


-- Indexes and Performance Optimization
-- -------------------------------------
-- Domain: Retail / E-commerce
--
-- Indexes help MySQL find rows faster
-- without scanning the entire table.
--
-- Important topics:
-- 1. How indexes improve query performance
-- 2. Creating and removing indexes
-- 3. EXPLAIN plans
-- 4. Identifying slow queries
-- 5. Reducing unnecessary query work


DROP DATABASE IF EXISTS retail_index_demo;
CREATE DATABASE retail_index_demo;
USE retail_index_demo;


-- 1. Create Sample Table
-- -------------------------------------

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    order_status VARCHAR(20),
    order_amount DECIMAL(10,2),
    order_date DATE
);


-- Sample data

INSERT INTO orders
(customer_id, product_name, category, order_status,
 order_amount, order_date)
VALUES
(101, 'Laptop', 'Electronics', 'Completed', 65000.00, '2026-01-05'),
(102, 'Headphones', 'Electronics', 'Completed', 5000.00, '2026-01-10'),
(103, 'Running Shoes', 'Fashion', 'Shipped', 5000.00, '2026-01-15'),
(104, 'Smartphone', 'Electronics', 'Completed', 32000.00, '2026-02-03'),
(105, 'Office Chair', 'Furniture', 'Pending', 12000.00, '2026-02-10'),
(101, 'Keyboard', 'Electronics', 'Completed', 3000.00, '2026-02-15'),
(102, 'Monitor', 'Electronics', 'Shipped', 30000.00, '2026-02-20'),
(106, 'Backpack', 'Fashion', 'Completed', 2500.00, '2026-03-01'),
(107, 'Dining Table', 'Furniture', 'Pending', 45000.00, '2026-03-05'),
(108, 'Mouse', 'Electronics', 'Completed', 1500.00, '2026-03-10');


-- 2. What is an Index?
-- -------------------------------------
-- An index is a data structure that helps
-- MySQL locate rows more efficiently.
--
-- Without an appropriate index:
--
-- MySQL may scan many/all rows.
-- With an appropriate index:
-- MySQL can locate matching rows faster.
--
-- Example:
--
-- SELECT *
-- FROM orders
-- WHERE customer_id = 101;
--
-- If customer_id is frequently searched,
-- an index can improve this query.


-- 3. Create an Index
-- -------------------------------------

CREATE INDEX idx_orders_customer
ON orders(customer_id);


-- Now MySQL can use this index when
-- searching by customer_id.


SELECT *
FROM orders
WHERE customer_id = 101;


-- 4. Index on Order Status
-- -------------------------------------
-- Useful when queries frequently filter
-- using order_status.

CREATE INDEX idx_orders_status
ON orders(order_status);


SELECT *
FROM orders
WHERE order_status = 'Completed';


-- 5. Index on Multiple Columns
-- -------------------------------------
-- A composite index contains more than
-- one column.

CREATE INDEX idx_orders_customer_status
ON orders(customer_id, order_status);


-- Useful for queries such as:


SELECT *
FROM orders
WHERE customer_id = 101
AND order_status = 'Completed';


-- 6. Important Composite Index Rule
-- -------------------------------------
-- For an index:
--
-- (customer_id, order_status)
--
-- MySQL can efficiently use it for:
--
-- customer_id
-- customer_id + order_status
--
-- But it is generally not equivalent to
-- having an index starting with order_status
-- for:
--
-- WHERE order_status = 'Completed'
--
-- This is called the LEFTMOST PREFIX rule.


-- 7. UNIQUE Index
-- -------------------------------------
-- A UNIQUE index prevents duplicate values.

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);


CREATE UNIQUE INDEX idx_customers_email
ON customers(email);


-- Duplicate email values are not allowed.


-- 8. View Existing Indexes
-- -------------------------------------

SHOW INDEX FROM orders;


-- 9. Remove an Index
-- -------------------------------------

DROP INDEX idx_orders_status
ON orders;


SHOW INDEX FROM orders;


-- 10. EXPLAIN
-- -------------------------------------
-- EXPLAIN shows how MySQL plans to execute
-- a SELECT query.
--
-- It helps identify:
-- - Which table is accessed
-- - Which index may be used
-- - How many rows may be examined
-- - Join information
-- - Access method



-- --------------------------------------------------------------------


USE retail_index_demo;

Drop Table if exists users;
CREATE TABLE users(
  id INT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  age TINYINT UNSIGNED NOT NULL
);

INSERT INTO users VALUES
(1, 'John', 'john@email.com', 25),
(2, 'Alice', 'alice@email.com', 30),
(3, 'Bob', 'bob@email.com', 22),
(4, 'David', 'david@email.com', 28),
(5, 'Emma', 'emma@email.com', 25),
(6, 'Chris', 'chris@email.com', 35),
(7, 'Sophia', 'sophia@email.com', 29),
(8, 'Daniel', 'daniel@email.com', 40),
(9, 'Olivia', 'olivia@email.com', 31),
(10, 'Liam', 'liam@email.com', 27);

EXPLAIN 
SELECT * 
FROM users 
WHERE age = 30;


-- id

-- The identifier of the SELECT query.
-- If you have subqueries or joins, different parts get different IDs.
-- Higher id usually runs first (especially with subqueries).


-- select_type

-- Tells what type of SELECT it is.
-- Common values:

-- SIMPLE → No subqueries or UNION
-- PRIMARY → Outer query in subquery
-- SUBQUERY → Inner subquery
-- DERIVED → Subquery in FROM clause
-- UNION → Part of UNION
-- DEPENDENT SUBQUERY → Subquery depends on outer query (can be slower)

Explain SELECT * FROM users WHERE age > (SELECT AVG(age) FROM users);

-- table

-- The table MySQL is accessing in that step.
-- If you join 3 tables, you’ll see 3 rows — one per table.


-- type (Very Important)

-- This shows how MySQL accesses the table.
-- Think of it as performance level.

-- Best → Worst:

-- | Type   | Meaning                                |
-- | ------ | -------------------------------------- |
-- | system | Only one row                           |
-- | const  | Primary key or unique index used       |
-- | eq_ref | One row per join                       |
-- | ref    | Index used, but multiple rows possible |
-- | range  | Using index range (BETWEEN, >, <)      |
-- | index  | Full index scan                        |
-- | ALL    | Full table scan                        |

EXPLAIN SELECT * FROM users WHERE id = 10;

Explain SELECT * FROM users WHERE age > (SELECT age FROM users WHERE id = 5);

-- possible_keys
-- Indexes MySQL could use.
-- If this is NULL → No useful index exists.

-- key
-- The actual index MySQL chose.
-- If NULL → No index used.

-- key_len
-- How many bytes of the index are used.
-- Helpful when debugging composite indexes.

-- Example:
-- Index on (first_name, last_name)
-- If only first_name used → shorter key_len


-- ref
-- Shows which column or constant is compared to the index.
-- Example:
-- ref: const
-- Means it’s comparing to a constant value (like WHERE id = 5).


-- rows
-- Estimated number of rows MySQL thinks it must examine.
-- Lower is better.
-- Important: this is an estimate, not exact.


-- filtered
-- Percentage of rows that pass the condition.
-- Example:
-- rows = 1000
-- filtered = 10
-- → MySQL expects 100 rows after filtering


-- Extra (Very Important)
-- Additional info about query execution.

-- Common values:
-- Using where → WHERE condition applied
-- Using index → Covering index used (good!)
-- Using temporary → Temporary table created (can be slow)
-- Using filesort → Sorting done manually (can be slow)
-- Range checked for each record → Not ideal



-- --------------------------------------------------------------------


EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 101;


-- Look at important columns such as:
--
-- type
-- key
-- rows
-- Extra


-- 11. EXPLAIN Without a Useful Index
-- -------------------------------------
-- Search using a column that does not
-- currently have a suitable index.

EXPLAIN
SELECT *
FROM orders
WHERE product_name = 'Laptop';


-- MySQL may need to examine many rows
-- when no suitable index exists.


-- 12. Add Index and Compare
-- -------------------------------------

CREATE INDEX idx_orders_product
ON orders(product_name);


EXPLAIN
SELECT *
FROM orders
WHERE product_name = 'Laptop';




-- 13. EXPLAIN with ORDER BY
-- -------------------------------------

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 101
ORDER BY order_date;


-- An index can sometimes help with both
-- filtering and ordering, depending on
-- the query and index structure.


-- 14. Composite Index for Filtering
-- -------------------------------------

CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);


EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 101
ORDER BY order_date;


-- 15. Identify Expensive Queries
-- -------------------------------------
-- Queries that process large numbers of
-- rows can become slow.
--
-- Example:

SELECT *
FROM orders
WHERE category = 'Electronics';


-- If category is frequently used for
-- filtering and the table is large,
-- consider an appropriate index.


-- 16. Reduce Unnecessary Columns
-- -------------------------------------
-- Avoid SELECT * when only a few columns
-- are required.

-- Less efficient:

SELECT *
FROM orders
WHERE customer_id = 101;


-- Better:

SELECT
    order_id,
    product_name,
    order_amount
FROM orders
WHERE customer_id = 101;


-- 17. Reduce Unnecessary Rows
-- -------------------------------------
-- Filter data as early as possible.

SELECT
    order_id,
    product_name,
    order_amount
FROM orders
WHERE order_status = 'Completed'
AND order_amount > 10000;


-- 18. Avoid Functions on Indexed Columns
-- -------------------------------------
-- Applying a function to an indexed column
-- can prevent efficient index usage in
-- many situations.
--
-- Avoid patterns such as:

-- WHERE YEAR(order_date) = 2026
--
-- Prefer a range condition when appropriate:
--
-- WHERE order_date >= '2026-01-01'
-- AND order_date < '2027-01-01'


-- 19. Avoid Leading Wildcards
-- -------------------------------------
-- This pattern can prevent efficient use
-- of a normal B-tree index.

-- Less index-friendly:

SELECT *
FROM orders
WHERE product_name LIKE '%phone%';


-- A prefix search can be more index-friendly:

SELECT *
FROM orders
WHERE product_name LIKE 'Phone%';


-- 20. Indexes Are Not Always Better
-- -------------------------------------
-- Indexes have a cost.
--
-- Every INSERT, UPDATE, and DELETE may need
-- to maintain the indexes.
--
-- Too many indexes can:
-- - Increase storage
-- - Slow INSERT operations
-- - Slow UPDATE operations
-- - Slow DELETE operations
-- - Increase maintenance cost
--
-- Therefore, create indexes based on
-- actual query patterns.


-- 21. Check Query Execution
-- -------------------------------------
-- MySQL also supports EXPLAIN ANALYZE
-- for supported SELECT statements.
--
-- It provides actual execution information
-- in addition to the optimizer's plan.

EXPLAIN ANALYZE
SELECT
    order_id,
    product_name,
    order_amount
FROM orders
WHERE customer_id = 101;


-- 22. Performance Optimization Checklist
-- -------------------------------------

-- 1. Use indexes on frequently searched columns.
-- 2. Use composite indexes when queries
--    commonly filter using multiple columns.
-- 3. Check queries with EXPLAIN.
-- 4. Look for queries examining too many rows.
-- 5. Avoid SELECT * when unnecessary.
-- 6. Avoid unnecessary joins.
-- 7. Filter rows early.
-- 8. Avoid functions on indexed columns
--    when they prevent efficient index use.
-- 9. Avoid unnecessary indexes.
-- 10. Test performance with realistic data.









-- TODO Task
-- -------------------------------------

-- 1. Create an index on category.
-- 2. Use EXPLAIN to check:
--
--    SELECT *
--    FROM orders
--    WHERE category = 'Electronics';

-- 3. Create a composite index on:
--    category and order_status.
-- 4. Use EXPLAIN on:
--
--    SELECT *
--    FROM orders
--    WHERE category = 'Electronics'
--    AND order_status = 'Completed';

-- 5. Find a query that does not have
--    a suitable index.

-- 6. Create an appropriate index and
--    compare the EXPLAIN plans.

-- 7. Identify one query using SELECT *
--    and rewrite it using only the
--    required columns.

