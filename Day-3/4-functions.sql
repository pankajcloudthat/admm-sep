-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_function_demo

-- MySQL Built-in Functions
-- ============================================
-- Domain: Retail / E-commerce
--
-- Important function categories:
-- 1. String Functions
-- 2. Numeric Functions
-- 3. NULL / Conditional Functions
-- 4. Conversion Functions



DROP DATABASE IF EXISTS retail_function_demo;
CREATE DATABASE retail_function_demo;
USE retail_function_demo;


-- Customers
-- -------------------------------------

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    phone VARCHAR(20)
);

INSERT INTO customers
(first_name, last_name, email, city, phone)
VALUES
('Rahul', 'Sharma', 'rahul.sharma@example.com', 'Delhi', '9876543210'),
('Priya', 'Verma', 'priya.verma@example.com', 'Mumbai', '9876543211'),
('Amit', 'Kumar', 'amit.kumar@example.com', 'Bangalore', '9876543212'),
('Neha', 'Singh', NULL, 'Pune', NULL),
('Ravi', 'Patel', 'ravi.patel@example.com', NULL, '9876543214');


-- Orders
-- -------------------------------------

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2),
    discount DECIMAL(10,2),
    shipping_charge DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders
(customer_id, product_name, category, quantity, price,
 discount, shipping_charge, status)
VALUES
(1, 'Laptop', 'Electronics', 1, 65000.00, 5000.00, 500.00, 'Completed'),
(1, 'Headphones', 'Electronics', 2, 2500.00, 200.00, 100.00, 'Completed'),
(2, 'Running Shoes', 'Fashion', 1, 5000.00, 500.00, 150.00, 'Shipped'),
(2, 'Smartphone', 'Electronics', 1, 32000.00, NULL, 300.00, 'Completed'),
(3, 'Office Chair', 'Furniture', 2, 12000.00, 1000.00, 500.00, 'Pending'),
(4, 'Keyboard', 'Electronics', 1, 3000.00, NULL, NULL, 'Pending'),
(5, 'Backpack', 'Fashion', 3, 2500.00, 300.00, 200.00, 'Completed');


-- 1. String Functions
-- -------------------------------------

-- UPPER()
-- Convert text to uppercase.

SELECT
    first_name,
    UPPER(first_name) AS uppercase_name
FROM customers;


-- LOWER()
-- Convert text to lowercase.

SELECT
    email,
    LOWER(email) AS lowercase_email
FROM customers;


-- CONCAT()
-- Combine multiple strings.

SELECT
    CONCAT(first_name, ' ', last_name) AS customer_name
FROM customers;


-- CONCAT_WS()
-- Combine strings using a separator.

SELECT
    CONCAT_WS(' - ', first_name, last_name, city) AS customer_details
FROM customers;


-- LENGTH()
-- Find the length of a string.

SELECT
    product_name,
    LENGTH(product_name) AS name_length
FROM orders;


-- CHAR_LENGTH()
-- Count the number of characters.

SELECT
    product_name,
    CHAR_LENGTH(product_name) AS character_count
FROM orders;


-- TRIM()
-- Remove leading and trailing spaces.

SELECT
    TRIM('   Laptop   ') AS cleaned_product;


-- LEFT()
-- Get characters from the left side.

SELECT
    product_name,
    LEFT(product_name, 3) AS first_five_characters
FROM orders;


-- RIGHT()
-- Get characters from the right side.

SELECT
    product_name,
    RIGHT(product_name, 5) AS last_five_characters
FROM orders;


-- SUBSTRING()
-- Extract part of a string.

SELECT
    product_name,
    SUBSTRING(product_name, 1, 5) AS short_name
FROM orders;


-- REPLACE()
-- Replace text inside a string.

SELECT
    email,
    REPLACE(email, '@example.com', '@retail.com') AS new_email
FROM customers;


-- LOCATE()
-- Find the position of a substring.

SELECT
    email,
    LOCATE('@', email) AS at_position
FROM customers;






-- -------------------------------------
-- 2. Numeric Functions
-- -------------------------------------

-- ROUND()
-- Round a decimal value.

SELECT
    product_name,
    price,
    ROUND(price * quantity, 2) AS total_price
FROM orders;


-- CEIL() / CEILING()
-- Round a number upward.

SELECT
    price,
    price / 1000 AS val,
    CEIL(price / 1000) AS rounded_up
FROM orders;


-- FLOOR()
-- Round a number downward.

SELECT
    price,
    price / 1000 AS val,
    FLOOR(price / 1000) AS rounded_down
FROM orders;


-- ABS()
-- Return the absolute value.

SELECT
    ABS(-500) AS absolute_value;


-- MOD()
-- Find the remainder.

SELECT
    order_id,
    MOD(order_id, 2) AS remainder
FROM orders;


-- POWER()
-- Calculate a number raised to a power.

SELECT
    POWER(2, 3) AS result;


-- SQRT()
-- Calculate square root.

SELECT
    SQRT(144) AS result;





-- 3. NULL and Conditional Functions
-- -------------------------------------

-- IFNULL()
-- Replace NULL with another value.

SELECT
    product_name,
    discount,
    IFNULL(discount, 0) AS final_discount
FROM orders;


-- COALESCE()
-- Return the first non-NULL value.

SELECT
    customer_id,
    first_name,
    COALESCE(email, phone, 'No Contact Information') AS contact
FROM customers;


-- NULLIF()
-- Return NULL when two values are equal.

SELECT
    order_id,
    quantity,
    NULLIF(quantity, 1) AS result
FROM orders;


-- IF()
-- Return one value when condition is TRUE
-- and another when condition is FALSE.

SELECT
    product_name,
    price,
    IF(price >= 10000, 'Expensive', 'Affordable') AS price_category
FROM orders;




-- CASE
-- Handle multiple conditions.

SELECT
    product_name,
    price,
    CASE
        WHEN price >= 50000 THEN 'Premium'
        WHEN price >= 10000 THEN 'High'
        WHEN price >= 5000 THEN 'Medium'
        ELSE 'Low'
    END AS price_category
FROM orders;



-- Order Status
SELECT
    order_id,
    product_name,
    status,
    CASE
        WHEN status = 'Completed' THEN 'Order Finished'
        WHEN status = 'Shipped' THEN 'In Transit'
        WHEN status = 'Pending' THEN 'Waiting'
        ELSE 'Unknown'
    END AS status_description
FROM orders;



-- Discount Category
SELECT
    product_name,
    discount,
    CASE
        WHEN discount IS NULL THEN 'No Discount'
        WHEN discount >= 5000 THEN 'High Discount'
        WHEN discount >= 1000 THEN 'Medium Discount'
        ELSE 'Low Discount'
    END AS discount_category
FROM orders;


-- CASE with Aggregate Functions
SELECT
    category,
    SUM(
        CASE
            WHEN status = 'Completed'
            THEN price * quantity
            ELSE 0
        END
    ) AS completed_sales
FROM orders
GROUP BY category;



-- 4. Conversion Functions
-- -------------------------------------

-- CAST()
-- Convert a value from one data type to another.

SELECT
    price,
    CAST(price AS SIGNED) AS integer_price
FROM orders;


-- CONVERT()
-- Convert data into another data type.

SELECT
    price,
    CONVERT(price, SIGNED) AS integer_price
FROM orders;





-- 7. Functions with JOIN
-- -------------------------------------

-- Display customer name and order value.

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.product_name,
    o.quantity,
    o.price,
    ROUND(o.price * o.quantity, 2) AS order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id;



-- -------------------------------------

-- Calculate final order amount:
--
-- Product Total
-- - Discount
-- + Shipping Charge

SELECT
    order_id,
    product_name,
    ROUND(
        (price * quantity)
        - IFNULL(discount, 0)
        + IFNULL(shipping_charge, 0),
        2
    ) AS final_order_amount
FROM orders;



-- Customer Display Name

SELECT
    customer_id,
    UPPER(
        CONCAT(first_name, ' ', last_name)
    ) AS customer_name
FROM customers;


--Customer Contact Information

SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    COALESCE(
        email,
        phone,
        'No Contact Information'
    ) AS contact_information
FROM customers;





-- ---------------------------------------------------------

-- User-Defined Functions
-- -------------------------------------
--
-- A User-Defined Function (UDF) is a function
-- created by the developer to perform a specific
-- calculation or business operation.
--
-- A function:
-- 1. Accepts input parameters.
-- 2. Performs some logic.
-- 3. Returns exactly one value.
--
-- Syntax:
--
-- CREATE FUNCTION function_name(parameters)
-- RETURNS data_type
-- DETERMINISTIC
-- BEGIN
--     -- logic
--     RETURN value;
-- END;
--
-- Important:
-- DELIMITER is used because the function body
-- contains semicolons.


DROP DATABASE IF EXISTS retail_udf_demo;
CREATE DATABASE retail_udf_demo;
USE retail_udf_demo;


-- -------------------------------------
-- Sample Orders Table
-- -------------------------------------

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    discount DECIMAL(10,2)
);

INSERT INTO orders
(product_name, quantity, price, discount)
VALUES
('Laptop', 1, 65000.00, 5000.00),
('Headphones', 2, 2500.00, 200.00),
('Running Shoes', 1, 5000.00, 500.00),
('Smartphone', 1, 32000.00, NULL),
('Office Chair', 2, 12000.00, 1000.00);


-- 1. Simple User-Defined Function
-- -------------------------------------
-- Calculate the total product price.
--
-- quantity × price

DELIMITER $$

CREATE FUNCTION CalculateTotal(
    p_quantity INT,
    p_price DECIMAL(10,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN p_quantity * p_price;
END;

DELIMITER ;


-- Call the function.

SELECT CalculateTotal(2, 5000.00) AS total_amount;


-- Use the function with a table.

SELECT
    order_id,
    product_name,
    quantity,
    price,
    CalculateTotal(quantity, price) AS total_amount
FROM orders;


-- 2. Function with Business Logic
-- -------------------------------------
-- Calculate the final amount after discount.
--
-- Final Amount =
-- (Quantity × Price) - Discount
--
-- If discount is NULL, treat it as 0.

DELIMITER $$

CREATE FUNCTION CalculateFinalAmount(
    p_quantity INT,
    p_price DECIMAL(10,2),
    p_discount DECIMAL(10,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN
        (p_quantity * p_price) - IFNULL(p_discount, 0);
END;

DELIMITER ;


SELECT
    order_id,
    product_name,
    CalculateFinalAmount(
        quantity,
        price,
        discount
    ) AS final_amount
FROM orders;


-- 3. Function Using CASE
-- -------------------------------------
-- Categorize a product based on its price.

DELIMITER $$

CREATE FUNCTION GetPriceCategory(
    p_price DECIMAL(10,2)
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN

    RETURN CASE
        WHEN p_price >= 50000 THEN 'Premium'
        WHEN p_price >= 10000 THEN 'High'
        WHEN p_price >= 5000 THEN 'Medium'
        ELSE 'Low'
    END;

END;

DELIMITER ;


SELECT
    product_name,
    price,
    GetPriceCategory(price) AS price_category
FROM orders;


-- 4. Function with IF
-- -------------------------------------
-- Check whether an order qualifies
-- for free shipping.
--
-- Orders >= 10,000 -> Free Shipping
-- Otherwise        -> Shipping Charges

DELIMITER $$

CREATE FUNCTION GetShippingStatus(
    p_quantity INT,
    p_price DECIMAL(10,2)
)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN

    DECLARE total_amount DECIMAL(12,2);

    SET total_amount = p_quantity * p_price;

    IF total_amount >= 10000 THEN
        RETURN 'Free Shipping';
    ELSE
        RETURN 'Shipping Charges';
    END IF;

END;

DELIMITER ;


SELECT
    order_id,
    product_name,
    GetShippingStatus(quantity, price) AS shipping_status
FROM orders;



-- 5. Function with Multiple Conditions
-- -------------------------------------
-- Assign a customer/order value level.

DELIMITER $$

CREATE FUNCTION GetOrderLevel(
    p_amount DECIMAL(12,2)
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN

    IF p_amount >= 50000 THEN
        RETURN 'Very High';

    ELSEIF p_amount >= 20000 THEN
        RETURN 'High';

    ELSEIF p_amount >= 5000 THEN
        RETURN 'Medium';

    ELSE
        RETURN 'Low';

    END IF;

END;

DELIMITER ;


SELECT
    order_id,
    product_name,
    CalculateTotal(quantity, price) AS total_amount,
    GetOrderLevel(
        CalculateTotal(quantity, price)
    ) AS order_level
FROM orders;



-- 6. Function in WHERE
-- -------------------------------------
-- Find orders whose calculated value
-- is greater than 20,000.

SELECT
    order_id,
    product_name,
    CalculateTotal(quantity, price) AS total_amount
FROM orders
WHERE CalculateTotal(quantity, price) > 30000;


-- 7. Function in ORDER BY
-- -------------------------------------
-- Sort products by calculated order value.

SELECT
    product_name,
    CalculateTotal(quantity, price) AS total_amount
FROM orders
ORDER BY CalculateTotal(quantity, price) DESC;


-- 8. View Existing Functions
-- -------------------------------------

SHOW FUNCTION STATUS
WHERE Db = 'retail_udf_demo';


-- 9. Delete a User-Defined Function
-- -------------------------------------

DROP FUNCTION IF EXISTS GetOrderLevel;


-- Important Points
-- -------------------------------------

-- 1. CREATE FUNCTION is used to create a UDF.
-- 2. Parameters receive input values.
-- 3. RETURNS defines the return data type.
-- 4. RETURN returns exactly one value.
-- 5. DETERMINISTIC means the same input
--    produces the same output.
-- 6. A function can be called inside SQL queries.
-- 7. A function can contain IF, ELSEIF,
--    CASE, variables, and calculations.
-- 8. DROP FUNCTION removes the function.
-- 9. A function returns a value.
--    A PROCEDURE is generally used to perform
--    an operation and does not have to return
--    a single value.


-- -------------------------------------------------



-- TODO Task
-- -------------------------------------

-- 1. Create a function CalculateDiscountedPrice()
--    that accepts price and discount percentage.
--
-- 2. Create a function GetStockStatus()
--    that accepts quantity and returns:
--
--    >= 10 -> 'In Stock'
--    1-9   -> 'Low Stock'
--    0     -> 'Out of Stock'
--
-- 3. Create a function CalculateTax()
--    that calculates 18% tax on an amount.
--
-- 4. Use your functions inside a SELECT query.
--
-- 5. Drop one of the functions using:
--    DROP FUNCTION IF EXISTS function_name;