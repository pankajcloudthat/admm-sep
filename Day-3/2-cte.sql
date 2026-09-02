-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_demo

-- CTE (Common Table Expression)
-- -------------------------------------

-- CTE stands for Common Table Expression.
--
-- A CTE is a temporary named result set
-- that exists only for the duration of a single SQL statement.
--
-- It allows us to break a complex query into
-- smaller and easier-to-understand steps.


-- Why Use CTE?
-- -------------------------------------

-- CTEs improve:
--
-- 1. Readability
--    Complex queries become easier to understand.
--
-- 2. Logical Separation
--    Break one large query into multiple steps.
--
-- 3. Reusability
--    A CTE can be referenced multiple times
--    within the same query.
--
-- 4. Maintenance
--    Easier to modify and debug complex queries.
--
-- 5. Complex Analysis
--    Useful with GROUP BY, JOIN, and Window Functions.


-- When Should You Use a CTE?
-- -------------------------------------

-- Use a CTE when:
--
-- -> A query is becoming difficult to read.
-- -> You need to perform multiple logical steps.
-- -> You need to aggregate data and then analyze the aggregated result.
-- -> You need to use window functions on aggregated data.
-- -> You need the same intermediate result more than once.
-- -> You need a recursive query such as employee hierarchy.


USE retail_demo;


-- View Sample Data
-- -------------------------------------

SELECT * FROM customers;

SELECT * FROM orders;


-- Basic CTE
-- -------------------------------------

-- Business Question:
-- Calculate total spending for each customer.


WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

)

SELECT *
FROM customer_spending;


-- What happens?
--
-- Step 1:
-- The CTE calculates spending for each customer.
--
-- Step 2:
-- The outer query reads the CTE result.
--
-- The CTE exists only for this query.


-- CTE with JOIN
-- -------------------------------------

-- Business Question:
-- Show customer names along with their
-- total spending.


WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    cs.total_spent

FROM customers c
JOIN customer_spending cs
    ON c.customer_id = cs.customer_id
ORDER BY cs.total_spent DESC;


-- CTE with Filtering
-- -------------------------------------

-- Business Question:
-- Find customers who spent more than 30,000.


WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

)

SELECT
    c.first_name,
    c.last_name,
    cs.total_spent

FROM customers c
JOIN customer_spending cs
    ON c.customer_id = cs.customer_id
WHERE cs.total_spent > 30000
ORDER BY cs.total_spent DESC;


-- Multiple CTEs
-- -------------------------------------

-- Business Question:
-- Find the average customer spending
-- and identify customers who spent
-- more than the average.


WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

),
average_spending AS (

    SELECT
        AVG(total_spent) AS avg_spending
    FROM customer_spending

)
SELECT
    cs.customer_id,
    cs.total_spent,
    a.avg_spending

FROM customer_spending cs
CROSS JOIN average_spending a
WHERE cs.total_spent > a.avg_spending
ORDER BY cs.total_spent DESC;


-- What is happening?
--
-- CTE 1:
-- Calculates spending per customer.
--
-- CTE 2:
-- Calculates the average of those
-- customer spending amounts.
--
-- Final query:
-- Finds customers above the average.




-- CTE with Window Function
-- -------------------------------------

-- Business Question:
-- Rank customers based on total spending.


WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

)

SELECT
    customer_id,
    total_spent,

    DENSE_RANK() OVER (
        ORDER BY total_spent DESC
    ) AS spending_rank

FROM customer_spending
ORDER BY spending_rank;


-- Why use a CTE here?
--
-- First we calculate customer-level totals.
--
-- Then we apply the window function
-- to those aggregated results.




-- Top Customers
-- -------------------------------------

-- Business Question:
-- Find the top 3 customers by spending.


WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

)

SELECT
    c.first_name,
    c.last_name,
    cs.total_spent

FROM customer_spending cs
JOIN customers c
    ON c.customer_id = cs.customer_id
ORDER BY cs.total_spent DESC
LIMIT 3;


-- Monthly Revenue
-- -------------------------------------

-- Business Question:
-- Calculate monthly retail revenue.


WITH monthly_revenue AS (

    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(total_amount) AS total_revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)

)

SELECT
    order_year,
    order_month,
    total_revenue

FROM monthly_revenue
ORDER BY
    order_year,
    order_month;


-- Month-over-Month Revenue
-- -------------------------------------

-- Business Question:
-- Compare each month's revenue
-- with the previous month.


WITH monthly_revenue AS (

    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(total_amount) AS total_revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)

)

SELECT
    order_year,
    order_month,
    total_revenue,

    LAG(total_revenue) OVER (
        ORDER BY order_year, order_month
    ) AS previous_month_revenue,

    total_revenue
    -
    LAG(total_revenue) OVER (
        ORDER BY order_year, order_month
    ) AS revenue_change

FROM monthly_revenue

ORDER BY
    order_year,
    order_month;





-- CTE with Multiple Business Steps
-- -------------------------------------

-- Business Question:
--
-- 1. Calculate spending for each customer.
-- 2. Rank customers by spending.
-- 3. Display only the top 3.


WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

),

ranked_customers AS (

    SELECT
        customer_id,
        total_spent,

        DENSE_RANK() OVER (
            ORDER BY total_spent DESC
        ) AS spending_rank

    FROM customer_spending

)

SELECT
    c.first_name,
    c.last_name,
    rc.total_spent,
    rc.spending_rank

FROM ranked_customers rc
JOIN customers c
    ON c.customer_id = rc.customer_id
WHERE rc.spending_rank <= 3
ORDER BY rc.spending_rank;




-- CTE vs Subquery
-- -------------------------------------

-- The same problem can often be solved
-- using a subquery or a CTE.


-- Using Subquery:

SELECT *
FROM (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

) customer_spending

WHERE total_spent > 30000;


-- Using CTE:

WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

)

SELECT *
FROM customer_spending
WHERE total_spent > 30000;


-- The CTE version is often easier to read,
-- especially when the query has multiple steps.


-- A CTE is NOT a permanent table.


WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id

)

SELECT *
FROM customer_spending;


-- This works because the CTE is used
-- immediately by the SELECT statement.
--
-- After the statement finishes,
-- the CTE is gone.










-- TODO Task
-- -------------------------------------

-- The retail manager wants a customer spending report.
--
-- 1. Create a CTE to calculate total spending for each customer.
-- 2. Add customer name using JOIN.
-- 3. Calculate the spending rank using DENSE_RANK().
-- 4. Display only the top 3 customers.
-- 5. Create another CTE to calculate monthly revenue.
-- 6. Use LAG() to calculate the difference between the current month and previous month.