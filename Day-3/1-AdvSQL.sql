-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@fooddelivery


-- Advanced SQL Aggregations
-- Window Functions (ROW_NUMBER, RANK, DENSE_RANK)
-- OVER() and PARTITION BY
-- Running Totals & Moving Averages

USE fooddelivery;

-- Advanced SQL Aggregations
-------------------------------------

-- Why Do We Need Advanced SQL?

-- Basic SQL can:
--      Filter rows (WHERE)
--      Aggregate data (GROUP BY)
--      Join tables

-- But…

-- Basic SQL cannot analyze trends, rankings, patterns, or row-level comparisons properly.

-- That’s where Advanced SQL (Window Functions) becomes powerful.



-- Problem with GROUP BY (Limitation)
-- Suppose you want:
--      Show each order
--      AND also show total revenue of that restaurant

-- If you use GROUP BY:
SELECT restaurant_id, SUM(total_amount)
FROM Orders
GROUP BY restaurant_id;

SELECT * FROM orders;

-- Problem:
-- It collapses rows
-- You lose individual order details


-- But what if business wants:
-- Show each order and also tell me how much that restaurant has earned so far.

-- Solution: Advanced SQL (Window Function)

SELECT 
    order_id,
    restaurant_id,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY restaurant_id
    ) AS restaurant_total_revenue
FROM Orders;


-- Every row still exists
-- But you also get aggregated info


-- -----------------------------------------------------------------


-- Window Function
-- -------------------------
-- What is a Window Function?

-- A window function performs a calculation across a set of rows related to the current row
-- but it does NOT collapse rows like GROUP BY.

-- Key idea: It gives aggregated or analytical results while keeping every row visible.

-- When Should You Use Window Functions?

-- Use when you need:
-- Ranking (Top N)
-- Running totals
-- Moving averages
-- Compare with previous row
-- Contribution percentage
-- Trend analysis



-- Basic Syntax 
-- ---------------

-- function() OVER (
--     PARTITION BY column
--     ORDER BY column
-- )

-- or

-- function() OVER (window_spec)



-- OVER(window_spec)
-- -----------------

-- Each window operation in the query is signified by inclusion of an OVER clause 
-- that specifies how to partition query rows into groups for processing by the window function.

-- This tells SQL:
-- “Don’t collapse rows. Apply this calculation over a window.”

-- Without OVER(), it becomes normal aggregate.

-- Example: Without OVER()
-- One row per restaurant.

SELECT restaurant_id, SUM(total_amount)
FROM Orders
GROUP BY restaurant_id;


-- Example: With OVER()
-- All rows kept + aggregate added.

SELECT 
    order_id,
    restaurant_id,
    total_amount,
    SUM(total_amount) OVER (PARTITION BY restaurant_id) AS restaurant_total
FROM Orders;


-- To use a window function (or to treat an aggregate function as a window function), 
-- you must include an OVER clause immediately after the function call. 

-- The OVER clause defines the window of rows the function should operate on, 
-- such as specifying partitions, ordering, or frame boundaries.


-- Empty OVER(): which treats the entire set of query rows as a single partition. 
-- Example:

SELECT SUM(total_amount) as total_revenue
FROM orders;

SELECT 
    order_id,
    total_amount,
    SUM(total_amount) OVER() AS total_revenue
FROM Orders;


SELECT 
    order_id,
    COUNT(*) OVER() AS total_orders
FROM Orders;


-- Use it when:

-- You need global total
-- You need global average
-- You need percentage contribution
-- You need total row count
-- But still want row-level detail.




-- OVER (window_spec)
-- -------------------

-- window_spec:
--     [partition_clause] 
--     [order_clause]


-- PARTITION BY [partition_clause]
-----------------------------------

-- This divides rows into groups (like GROUP BY)
-- BUT keeps rows separate.

-- Example:
-- SUM(total_amount) OVER (PARTITION BY restaurant_id)

-- Meaning:
-- Calculate sum separately for each restaurant
-- Show it for every row of that restaurant


SELECT 
    order_id,
    restaurant_id,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY restaurant_id
    ) AS restaurant_total
FROM Orders;


-- ORDER BY (Inside OVER) [order_clause]
-- -----------------------------------------

-- An ORDER BY clause indicates how to sort rows in each partition.

-- Used for:

-- Ranking
-- Running totals
-- Moving averages

-- Rank orders by amount within each restaurant
SELECT 
    order_id,
    restaurant_id,
    total_amount,
    RANK() OVER (
        PARTITION BY restaurant_id
        ORDER BY total_amount DESC
    ) AS rank_within_restaurant
FROM Orders;












-- Window Functions (ROW_NUMBER, RANK, DENSE_RANK, ...)
-- -----------------------------------------------------

-- MySQL Window Function list

-- | Function     | One-Line Revision                 |
-- | ------------ | --------------------------------- |
-- | CUME_DIST    | Percentage of rows ≤ current row. |
-- | DENSE_RANK   | Rank with no gaps.                |
-- | FIRST_VALUE  | First value in window.            |
-- | LAG          | Value from previous row.          |
-- | LAST_VALUE   | Last value in window.             |
-- | LEAD         | Value from next row.              |
-- | NTH_VALUE    | Value from Nth row in window.     |
-- | NTILE        | Split rows into N groups.         |
-- | PERCENT_RANK | Percentile rank of row.           |
-- | RANK         | Rank with gaps.                   |
-- | ROW_NUMBER   | Unique row number per row.        |


-- The OVER clause is permitted for many aggregate functions, 
-- which therefore can be used as window or nonwindow function


-- Types of Window Functions, There are 3 major categories:

-- Aggregate Window Functions
-- --------------------------

--     SUM()
--     AVG()
--     COUNT()
--     MAX()
--     MIN()


-- SUM()
-- Total Revenue per Restaurant
SELECT 
    order_id,
    restaurant_id,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY restaurant_id
    ) AS restaurant_total_revenue
FROM Orders
WHERE status = 'Delivered';


-- AVG() – Average Order Value per Restaurant
SELECT 
    order_id,
    restaurant_id,
    total_amount,
    AVG(total_amount) OVER (
        PARTITION BY restaurant_id
    ) AS avg_order_value
FROM Orders
WHERE status = 'Delivered';

-- COUNT() – Total Orders per Customer
SELECT 
    order_id,
    customer_id,
    COUNT(*) OVER (
        PARTITION BY customer_id
    ) AS total_orders_by_customer
FROM Orders;


-- MAX() – Highest Order per Restaurant

SELECT 
    order_id,
    restaurant_id,
    total_amount,
    MAX(total_amount) OVER (
        PARTITION BY restaurant_id
    ) AS highest_order_amount
FROM Orders;


-- MIN() – Lowest Order per Restaurant

SELECT 
    order_id,
    restaurant_id,
    total_amount,
    MIN(total_amount) OVER (
        PARTITION BY restaurant_id
    ) AS lowest_order_amount
FROM Orders;




-- Ranking Functions
-- -------------------

-- | Function       | What It Does                                                        |
-- | -------------- | ------------------------------------------------------------------- |
-- | ROW_NUMBER()   | Assigns a unique sequential number to each row.                     |
-- | RANK()         | Assigns rank with gaps when ties occur.                             |
-- | DENSE_RANK()   | Assigns rank without gaps when ties occur.                          |
-- | NTILE(n)       | Divides rows into *n* ranked groups.                                |
-- | PERCENT_RANK() | Returns the percentile rank of a row.                               |
-- | CUME_DIST()    | Returns cumulative distribution (percentage of rows ≤ current row). |


-- Create Sales table
DROP TABLE IF EXISTS sales_data;
CREATE TABLE sales_data (
    sale_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    department VARCHAR(50),
    sale_date DATE,
    sale_amount DECIMAL(10,2)
);


INSERT INTO sales_data VALUES
-- =======================
-- ELECTRONICS (Jan–Jun)
-- =======================
(1,  'Amit',   'Electronics', '2024-01-05', 7000),
(2,  'Neha',   'Electronics', '2024-01-20', 5000),
(3,  'Raj',    'Electronics', '2024-02-10', 7000),
(4,  'Simran', 'Electronics', '2024-02-25', 4000),
(5,  'Karan',  'Electronics', '2024-03-15', 9000),
-- =======================
-- CLOTHING (Jan–Jun)
-- =======================
(11, 'Pooja',  'Clothing', '2024-01-03', 6000),
(12, 'Arjun',  'Clothing', '2024-01-18', 6000),
(13, 'Meera',  'Clothing', '2024-02-07', 3500),
(14, 'Rohit',  'Clothing', '2024-02-22', 2500),
(15, 'Isha',   'Clothing', '2024-03-10', 8000),
-- =======================
-- GROCERY (Jan–Jun)
-- =======================
(21, 'Vikas',  'Grocery', '2024-01-08', 2000),
(22, 'Anita',  'Grocery', '2024-01-27', 3000),
(23, 'Sahil',  'Grocery', '2024-02-11', 2500),
(24, 'Nisha',  'Grocery', '2024-02-28', 4000),
(25, 'Vikas',  'Grocery', '2024-03-17', 3500),
-- =======================
-- FURNITURE (Jan–Jun)
-- =======================
(31, 'Rahul',  'Furniture', '2024-01-12', 10000),
(32, 'Sneha',  'Furniture', '2024-01-29', 8500),
(33, 'Deepak', 'Furniture', '2024-02-14', 9500),
(34, 'Priya',  'Furniture', '2024-02-27', 7000),
(35, 'Rahul',  'Furniture', '2024-03-20', 11000);


-- Example Ranking Query
SELECT 
    department,
    employee_name,
    sale_date,
    sale_amount,

    ROW_NUMBER() OVER (
        PARTITION BY department
        ORDER BY sale_amount DESC
    ) AS row_number_rank,

    RANK() OVER (
        PARTITION BY department
        ORDER BY sale_amount DESC
    ) AS rank_position,

    DENSE_RANK() OVER (
        PARTITION BY department
        ORDER BY sale_amount DESC
    ) AS dense_rank_position,

    NTILE(4) OVER (
        PARTITION BY department
        ORDER BY sale_amount DESC
    ) AS quartile_group

FROM sales_data;







-- Value Functions
-- ------------------

-- | Function      | What It Does                                      |
-- | ------------- | ------------------------------------------------- |
-- | FIRST_VALUE() | Returns the first value in the window.            |
-- | LAST_VALUE()  | Returns the last value in the window.             |
-- | NTH_VALUE()   | Returns the value from the Nth row in the window. |
-- | LAG()         | Returns value from a previous row.                |
-- | LEAD()        | Returns value from a next row.                    |



-- LAG() — Previous Row Value
-- ----------------------------
-- Used to compare current row with previous row
-- Common for growth analysis

-- Compare current sale with previous sale in same department
SELECT 
    department,
    sale_date,
    employee_name,
    sale_amount,

    LAG(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
    ) AS previous_sale,

    sale_amount - LAG(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
    ) AS difference_from_previous

FROM sales_data;


-- LEAD() — Next Row Value
-- ---------------------------
-- Look forward instead of backward
-- Compare current sale with next sale

SELECT 
    department,
    employee_name,
    sale_date,
    sale_amount,

    LEAD(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
    ) AS next_sale

FROM sales_data;


-- FIRST_VALUE()
-- ------------------
-- Returns first value in the window
-- First sale amount in each department


SELECT 
    department,
    sale_date,
    employee_name,
    sale_amount,

    FIRST_VALUE(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
    ) AS first_sale_in_department

FROM sales_data;


-- LAST_VALUE()
-- ----------------
-- Important: Must define frame properly.
-- If you don’t define frame, result may not behave as expected.
-- Get last sale in each department

SELECT 
    department,
    sale_date,
    employee_name,
    sale_amount,

    LAST_VALUE(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_sale_in_department

FROM sales_data;



-- NTH_VALUE()
-- ---------------
-- Get nth value in window
-- Get 2nd sale in each department

SELECT 
    department,
    sale_date,
    employee_name,
    sale_amount,

    NTH_VALUE(sale_amount, 2) OVER (
        PARTITION BY department
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_sale_in_department

FROM sales_data;


-- Frame
-- ------

-- What Is a Frame?

-- Inside a window function, we define:
--    Partition (group)
--    Order
--    Frame (which rows inside that ordered partition should be used)

-- The frame decides:
--    From which row to which row should the calculation happen?


-- Structure: 
-- ROWS BETWEEN start_point AND end_point

-- Where start and end can be:

-- UNBOUNDED PRECEDING
-- n PRECEDING
-- CURRENT ROW
-- n FOLLOWING
-- UNBOUNDED FOLLOWING


-- Example:

-- Imagine ordered sales:
-- | Row | Sale |
-- | --- | ---- |
-- | 1   | 100  |
-- | 2   | 200  |
-- | 3   | 300  |
-- | 4   | 400  |
-- | 5   | 500  |


-- If current row = 3 (value = 300)
-- Frame examples:

-- | Frame Clause                      | Included Rows |
-- | --------------------------------- | ------------- |
-- | UNBOUNDED PRECEDING → CURRENT ROW | 1,2,3         |
-- | 2 PRECEDING → CURRENT ROW         | 1,2,3         |
-- | CURRENT ROW → 2 FOLLOWING         | 3,4,5         |
-- | 1 PRECEDING → 1 FOLLOWING         | 2,3,4         |




-- Example: ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING

-- UNBOUNDED PRECEDING: Start from the very first row in the partition.
-- UNBOUNDED FOLLOWING: Go until the very last row in the partition.


-- Running Total
SELECT 
    department,
    sale_date,
    sale_amount,
    SUM(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM sales_data;


-- Row Moving Average
-- (Start: 2 rows before → End: Current Row)
SELECT 
    department,
    sale_date,
    sale_amount,
    AVG(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_rows
FROM sales_data;





-- Query Execution Order (Very Important Concept)

-- Actual logical execution order:

-- FROM
-- WHERE
-- GROUP BY
-- HAVING
-- WINDOW FUNCTIONS
-- SELECT
-- DISTINCT
-- ORDER BY
-- LIMIT


-- That’s why window functions:

-- Cannot be used in WHERE
-- Cannot be used in GROUP BY
-- Cannot be used in HAVING

-- Because they are calculated AFTER those steps.






-- More queries
-- ---------------

-- How much revenue did each department generate per month?





SELECT 
    department,
    DATE_FORMAT(sale_date, '%Y-%m') AS month,
    SUM(sale_amount) AS monthly_revenue
FROM sales_data
GROUP BY department, DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY department, month;





-- How is revenue growing over time?






SELECT 
    department,
    sale_date,
    sale_amount,
    SUM(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM sales_data
ORDER BY department, sale_date;





-- How much did revenue change compared to previous month?









SELECT 
    department,
    DATE_FORMAT(sale_date, '%Y-%m') AS month,
    SUM(sale_amount) AS monthly_revenue,
    SUM(sale_amount) -
    LAG(SUM(sale_amount)) OVER (
        PARTITION BY department
        ORDER BY DATE_FORMAT(sale_date, '%Y-%m')
    ) AS revenue_difference
FROM sales_data
GROUP BY department, DATE_FORMAT(sale_date, '%Y-%m');







-- When did revenue drop compared to previous sale?






SELECT 
    department, sale_date, sale_amount,
    LAG(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
    ) AS previous_sale,
    sale_amount -
    LAG(sale_amount) OVER (
        PARTITION BY department
        ORDER BY sale_date
    ) AS difference
FROM sales_data
WHERE department = 'Electronics';








-- Who are the best employees in each department?







SELECT *
FROM (
    SELECT 
        department,
        employee_name,
        SUM(sale_amount) AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY department
            ORDER BY SUM(sale_amount) DESC
        ) AS sales_rank
    FROM sales_data
    GROUP BY department, employee_name
) t
WHERE sales_rank <= 1;








-- Divide employees into 4 performance groups.








SELECT 
    employee_name,
    SUM(sale_amount) AS total_sales,
    NTILE(4) OVER (
        ORDER BY SUM(sale_amount) DESC
    ) AS performance_segment
FROM sales_data
GROUP BY employee_name;






-- Which month had highest revenue?







SELECT *
FROM (
    SELECT 
        department,
        DATE_FORMAT(sale_date, '%Y-%m') AS month,
        SUM(sale_amount) AS monthly_revenue,
        RANK() OVER (
            PARTITION BY department
            ORDER BY SUM(sale_amount) DESC
        ) AS month_rank
    FROM sales_data
    GROUP BY department, DATE_FORMAT(sale_date, '%Y-%m')
) t
WHERE month_rank = 1;







-- Overall Department Ranking







SELECT 
    department,
    SUM(sale_amount) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(sale_amount) DESC
    ) AS department_rank
FROM sales_data
GROUP BY department;
