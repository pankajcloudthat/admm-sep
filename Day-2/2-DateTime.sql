-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_demo
-- ------------------------------------------------------------
-- Date & Time Functions
-- Domain: Retail - Transaction & Order Analysis


-- Problem Statement
-- ------------------------------------------------------------
-- A retail company stores customer orders and transactions.
--
-- The business wants to analyze:
--
-- 1. When orders were placed
-- 2. When orders were delivered
-- 3. How many days delivery took
-- 4. Which orders were delivered late
-- 5. Daily and monthly sales
-- 6. How long customers take to complete payment
-- 7. Recent transactions
-- 8. Order and transaction patterns by day/month/year


-- Date and Time functions help the business analyze
-- these timelines and generate useful reports.

-- Why Date & Time Functions Are Important
-- ------------------------------------------------------------
-- Date & Time functions can be used to:
--
-- Extract year, month, day, hour, minute and second
-- Filter transactions by date
-- Calculate delivery duration
-- Find delayed orders
-- Calculate payment processing time
-- Generate daily/monthly sales reports
-- Calculate future dates
-- Calculate past dates
-- Format dates for reports



-- Create Database
-- ------------------------------------------------------------
DROP DATABASE IF EXISTS retail_demo;

CREATE DATABASE retail_demo;

USE retail_demo;

-- Create Retail Orders Table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS retail_orders;

CREATE TABLE retail_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    order_date DATETIME NOT NULL,
    payment_date DATETIME NULL,
    delivery_date DATETIME NULL,
    return_date DATETIME NULL
);

-- Insert Sample Retail Transactions
-- ------------------------------------------------------------
INSERT INTO
    retail_orders (
        customer_name,
        product_name,
        category,
        quantity,
        total_amount,
        order_date,
        payment_date,
        delivery_date,
        return_date
    )
VALUES (
        'Rahul Sharma',
        'Laptop',
        'Electronics',
        1,
        65000.00,
        '2026-01-05 10:15:20',
        '2026-01-05 10:18:45',
        '2026-01-08 15:30:00',
        NULL
    ),
    (
        'Priya Verma',
        'Smartphone',
        'Electronics',
        1,
        32000.00,
        '2026-01-10 14:25:10',
        '2026-01-10 14:27:30',
        '2026-01-14 17:45:00',
        NULL
    ),
    (
        'Amit Kumar',
        'Running Shoes',
        'Fashion',
        2,
        5000.00,
        '2026-01-15 09:30:00',
        '2026-01-15 09:35:15',
        '2026-01-17 12:10:00',
        NULL
    ),
    (
        'Neha Singh',
        'Office Chair',
        'Furniture',
        1,
        12000.00,
        '2026-02-03 16:45:30',
        '2026-02-03 16:50:10',
        '2026-02-12 14:30:00',
        NULL
    ),
    (
        'Ravi Patel',
        'Headphones',
        'Electronics',
        1,
        3500.00,
        '2026-02-10 11:20:15',
        '2026-02-10 11:22:30',
        '2026-02-13 16:00:00',
        '2026-02-20 10:30:00'
    ),
    (
        'Sneha Gupta',
        'Coffee Maker',
        'Home Appliances',
        1,
        8500.00,
        '2026-02-18 19:10:25',
        '2026-02-18 19:15:45',
        '2026-02-22 13:20:00',
        NULL
    ),
    (
        'Arjun Mehta',
        'Monitor',
        'Electronics',
        2,
        30000.00,
        '2026-03-01 08:45:10',
        '2026-03-01 08:50:30',
        '2026-03-05 11:15:00',
        NULL
    ),
    (
        'Kavita Joshi',
        'Backpack',
        'Fashion',
        1,
        2500.00,
        '2026-03-05 13:20:40',
        '2026-03-05 13:25:10',
        '2026-03-07 15:30:00',
        NULL
    ),
    (
        'Vikas Shah',
        'Tablet',
        'Electronics',
        1,
        28000.00,
        '2026-03-12 17:35:20',
        '2026-03-12 17:40:00',
        '2026-03-20 18:45:00',
        NULL
    ),
    (
        'Anjali Rao',
        'Dining Table',
        'Furniture',
        1,
        45000.00,
        '2026-03-20 10:05:30',
        '2026-03-20 10:10:45',
        '2026-03-29 16:30:00',
        '2026-04-05 11:20:00'
    );

SELECT * FROM retail_orders;

-- NOW()
-- ------------------------------------------------------------
-- NOW() returns the current date and time.
SELECT NOW() AS current_datetime;

SELECT CURRENT_TIMESTAMP() AS current_datetime;

-- Use Cases:
--
-- Transaction timestamp
-- Audit logs
-- Created_at fields
-- Payment tracking
-- Login tracking


-- CURDATE()
-- ------------------------------------------------------------
-- Returns only the current date.
SELECT CURDATE() AS curr_date;

-- Use Cases:
--
-- Daily sales reports
-- Compare only dates
-- Daily transaction processing


-- DATE()
-- ------------------------------------------------------------
-- Extract only the date portion from DATETIME.
SELECT order_date, DATE(order_date) AS order_date_only
FROM retail_orders;

-- YEAR(), MONTH(), DAY()
-- ------------------------------------------------------------
SELECT
    order_date,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    DAY(order_date) AS order_day
FROM retail_orders;


-- HOUR(), MINUTE(), SECOND()
-- ------------------------------------------------------------
SELECT
    order_date,
    HOUR(order_date) AS order_hour,
    MINUTE(order_date) AS order_minute,
    SECOND(order_date) AS order_second
FROM retail_orders;


-- Business Question
-- ------------------------------------------------------------
-- At what time do customers place most orders?
SELECT HOUR(order_date) AS order_hour, COUNT(*) AS total_orders
FROM retail_orders
GROUP BY
    HOUR(order_date)
ORDER BY total_orders DESC;


-- DATE_ADD()
-- ------------------------------------------------------------
-- Adds a specified time interval to a date.
SELECT
    order_id,
    order_date,
    DATE_ADD(order_date, INTERVAL 7 DAY) AS expected_delivery_date
FROM retail_orders;

-- Other examples:
SELECT DATE_ADD(NOW(), INTERVAL 7 DAY) AS next_week;

SELECT DATE_ADD(NOW(), INTERVAL 1 MONTH) AS next_month;

SELECT DATE_ADD(NOW(), INTERVAL 1 YEAR) AS next_year;

-- Use Cases:
--
-- Expected delivery date
-- Subscription renewal
-- Warranty expiration
-- Promotional campaigns


-- DATE_SUB()
-- ------------------------------------------------------------
-- Subtract a specified time interval from a date.
SELECT DATE_SUB(NOW(), INTERVAL 30 DAY) AS date_30_days_ago;


-- Find Recent Orders
-- ------------------------------------------------------------
-- Orders from the last 30 days.
SELECT *
FROM retail_orders
WHERE
    order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY);


-- DATEDIFF()
-- ------------------------------------------------------------
-- Returns the number of days between two dates.
SELECT
    order_id,
    order_date,
    delivery_date,
    DATEDIFF(delivery_date, order_date) AS delivery_days
FROM retail_orders
WHERE
    delivery_date IS NOT NULL;


-- Business Question
-- ------------------------------------------------------------
-- Find orders that took more than 5 days to deliver.
SELECT
    order_id,
    customer_name,
    order_date,
    delivery_date,
    DATEDIFF(delivery_date, order_date) AS delivery_days
FROM retail_orders
WHERE
    delivery_date IS NOT NULL
    AND DATEDIFF(delivery_date, order_date) > 5;


-- TIMESTAMPDIFF()
-- ------------------------------------------------------------
-- TIMESTAMPDIFF() calculates the difference between
-- two dates/timestamps in a specified unit.
--
-- Supported units:
--
-- YEAR
-- MONTH
-- DAY
-- HOUR
-- MINUTE
-- SECOND


-- Calculate Payment Processing Time
-- ------------------------------------------------------------
SELECT
    order_id,
    order_date,
    payment_date,
    TIMESTAMPDIFF(
        MINUTE,
        order_date,
        payment_date
    ) AS processing_minutes
FROM retail_orders
WHERE
    payment_date IS NOT NULL;


-- Calculate payment processing time in seconds.
SELECT
    order_id,
    TIMESTAMPDIFF(
        SECOND,
        order_date,
        payment_date
    ) AS processing_seconds
FROM retail_orders;


-- Calculate Delivery Time in Hours
-- ------------------------------------------------------------
SELECT
    order_id,
    customer_name,
    TIMESTAMPDIFF(
        HOUR,
        order_date,
        delivery_date
    ) AS delivery_hours
FROM retail_orders
WHERE
    delivery_date IS NOT NULL;


-- Business Question
-- ------------------------------------------------------------
-- Find orders delivered in more than 120 hours.
SELECT
    order_id,
    customer_name,
    product_name,
    TIMESTAMPDIFF(
        HOUR,
        order_date,
        delivery_date
    ) AS delivery_hours
FROM retail_orders
WHERE
    delivery_date IS NOT NULL
    AND TIMESTAMPDIFF(
        HOUR,
        order_date,
        delivery_date
    ) > 120;



-- YEAR / MONTH Analysis
-- ------------------------------------------------------------
-- Monthly sales report
SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    SUM(total_amount) AS total_sales
FROM retail_orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY sales_year, sales_month;



-- Daily Sales Report
-- ------------------------------------------------------------
SELECT
    DATE(order_date) AS sales_date,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_sales
FROM retail_orders
GROUP BY
    DATE(order_date)
ORDER BY sales_date;






-- DAYNAME()
-- ------------------------------------------------------------
-- Returns the name of the day.
SELECT order_date, DAYNAME(order_date) AS order_day_name
FROM retail_orders;


-- MONTHNAME()
-- ------------------------------------------------------------
SELECT order_date, MONTHNAME(order_date) AS order_month_name
FROM retail_orders;


-- Business Question
-- ------------------------------------------------------------
-- Which day of the week receives the most orders?
SELECT DAYNAME(order_date) AS order_day, COUNT(*) AS total_orders
FROM retail_orders
GROUP BY
    DAYNAME(order_date)
ORDER BY total_orders DESC;



-- LAST_DAY()
-- ------------------------------------------------------------
-- Returns the last day of the month.
SELECT LAST_DAY('2026-02-01') AS month_end;

-- Monthly sales with month-end date
SELECT
    MONTH(order_date) AS sales_month,
    LAST_DAY(order_date) AS month_end,
    SUM(total_amount) AS total_sales
FROM retail_orders
GROUP BY
    MONTH(order_date),
    LAST_DAY(order_date);



-- DATE_FORMAT()
-- ------------------------------------------------------------
-- Converts a date into a formatted string.
SELECT
    order_date,
    DATE_FORMAT(order_date, '%d, %W %M, %Y') AS formatted_order_date
FROM retail_orders;

-- Common format codes:
--
-- %Y -> 4 digit year
-- %y -> 2 digit year
-- %m -> month number
-- %M -> month name
-- %d -> day
-- %W -> weekday name
-- %H -> hour
-- %i -> minute
-- %s -> second



-- Format Transaction Timestamp
-- ------------------------------------------------------------
SELECT
    order_id,
    DATE_FORMAT(
        order_date,
        '%d-%m-%Y %H:%i:%s'
    ) AS transaction_timestamp
FROM retail_orders;



-- STR_TO_DATE()
-- ------------------------------------------------------------
-- Converts a string into a DATE/DATETIME value.
SELECT STR_TO_DATE('10-03-2026', '%d-%m-%Y') AS converted_date;

SELECT STR_TO_DATE(
        '10-03-2026 14:30:45', '%d-%m-%Y %H:%i:%s'
    ) AS converted_datetime;








-- RETAIL BUSINESS QUERIES
-- ------------------------------------------------------------

-- 1. Total Sales for Each Month
-- ------------------------------------------------------------
SELECT YEAR(order_date), MONTH(order_date), SUM(total_amount) AS total_sales
FROM retail_orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


-- 2. Orders Placed Today
-- ------------------------------------------------------------
SELECT *
FROM retail_orders
WHERE
    DATE(order_date) = CURDATE();


-- 3. Orders from the Last 7 Days
-- ------------------------------------------------------------
SELECT *
FROM retail_orders
WHERE
    order_date >= DATE_SUB(NOW(), INTERVAL 7 DAY);


-- 4. Orders Delivered Late
-- ------------------------------------------------------------
SELECT
    order_id,
    customer_name,
    product_name,
    DATEDIFF(delivery_date, order_date) AS delivery_days
FROM retail_orders
WHERE
    delivery_date IS NOT NULL
    AND DATEDIFF(delivery_date, order_date) > 5;


-- 5. Returned Products
-- ------------------------------------------------------------
SELECT
    order_id,
    customer_name,
    product_name,
    order_date,
    return_date,
    DATEDIFF(return_date, delivery_date) AS days_before_return
FROM retail_orders
WHERE
    return_date IS NOT NULL;


-- 6. Orders Placed During Business Hours
-- ------------------------------------------------------------
SELECT *
FROM retail_orders
WHERE
    HOUR(order_date) BETWEEN 9 AND 18;


-- 7. Weekend Orders
-- ------------------------------------------------------------
SELECT
    order_id,
    customer_name,
    order_date,
    DAYNAME(order_date) AS day_name
FROM retail_orders
WHERE
    DAYNAME(order_date) IN ('Saturday', 'Sunday');


-- 8. Average Delivery Time
-- ------------------------------------------------------------
SELECT AVG(
        DATEDIFF(delivery_date, order_date)
    ) AS average_delivery_days
FROM retail_orders
WHERE
    delivery_date IS NOT NULL;


-- 9. Highest Sales Day
-- ------------------------------------------------------------
SELECT DATE(order_date) AS sales_date, SUM(total_amount) AS daily_sales
FROM retail_orders
GROUP BY
    DATE(order_date)
ORDER BY daily_sales DESC
LIMIT 1;


-- 10. Final Transaction Report
-- ------------------------------------------------------------
SELECT
    order_id,
    customer_name,
    product_name,
    category,
    total_amount,
    DATE_FORMAT(order_date, '%d-%m-%Y %H:%i') AS order_time,
    DATE_FORMAT(
        delivery_date,
        '%d-%m-%Y %H:%i'
    ) AS delivery_time,
    DATEDIFF(delivery_date, order_date) AS delivery_days
FROM retail_orders
ORDER BY order_date;