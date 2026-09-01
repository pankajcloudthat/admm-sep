-- SQLBook: Code

-- Task
-- 1. Create a database named "FoodDelivery".
-- 2. Create tables customers, restaurants, orders, and order_items with appropriate columns and constraints.
-- 3. Insert sample data into each table.
-- 4. Write Aggregation queries
-- 5. Write join queries
-- 6: Write subqueries
-- 7: Union and Union All
-- 8: DateTime Functions

-- -----------------------------------------------------------------

-- Task 1: Create Database FoodDelivery


-- Task 2: Create Tables

-- Customers Table Schema

-- | Column      | Type         | Constraints               |
-- | ----------- | ------------ | ------------------------- |
-- | customer_id | INT          | PRIMARY KEY               |
-- | name        | VARCHAR(100) | NOT NULL                  |
-- | email       | VARCHAR(100) | UNIQUE NOT NULL           |
-- | phone       | VARCHAR(15)  | UNIQUE                    |
-- | city        | VARCHAR(50)  | NOT NULL                  |
-- | signup_date | DATETIME     | DEFAULT CURRENT_TIMESTAMP |


-- Restaurants Table Schema

-- | Column          | Type         | Constraints                    |
-- | --------------- | ------------ | ------------------------------ |
-- | restaurant_id   | INT          | PRIMARY KEY                    |
-- | restaurant_name | VARCHAR(100) | NOT NULL                       |
-- | city            | VARCHAR(50)  | NOT NULL                       |
-- | rating          | DECIMAL(2,1) | CHECK (rating BETWEEN 0 AND 5) |



-- Menu table Schema

-- | Column        | Type         | Constraints       |
-- | ------------- | ------------ | ----------------- |
-- | item_id       | INT          | PRIMARY KEY       |
-- | restaurant_id | INT          | FOREIGN KEY       |
-- | item_name     | VARCHAR(100) | NOT NULL          |
-- | price         | DECIMAL(8,2) | CHECK (price > 0) |
-- | is_available  | BOOLEAN      | DEFAULT TRUE      |


-- Orders Table Schema

-- | Column        | Type          | Constraints                                           |
-- | ------------- | ------------- | ----------------------------------------------------- |
-- | order_id      | INT           | PRIMARY KEY                                           |
-- | customer_id   | INT           | FOREIGN KEY                                           |
-- | restaurant_id | INT           | FOREIGN KEY                                           |
-- | order_date    | DATETIME      | NOT NULL                                              |
-- | total_amount  | DECIMAL(10,2) | CHECK (total_amount >= 0)                             |
-- | status        | VARCHAR(20)   | CHECK (status IN ('Pending','Delivered','Cancelled')) |


-- Order_Items Table Schema

-- | Column        | Type | Constraints          |
-- | ------------- | ---- | -------------------- |
-- | order_item_id | INT  | PRIMARY KEY          |
-- | order_id      | INT  | FOREIGN KEY          |
-- | item_id       | INT  | FOREIGN KEY          |
-- | quantity      | INT  | CHECK (quantity > 0) |



-- Food Delivery Database
-- DDL: Database and Table Creation
-- ============================================================

-- Task 1: Create Database
-- ============================================================

CREATE DATABASE FoodDelivery;

USE FoodDelivery;


-- Task 2: Create Tables
-- ============================================================


-- Create Customers Table

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    city VARCHAR(50) NOT NULL,
    signup_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- Create Restaurants Table

CREATE TABLE Restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    rating DECIMAL(2,1) CHECK (rating BETWEEN 0 AND 5)
);


-- Create Menu Table

CREATE TABLE Menu (
    item_id INT PRIMARY KEY,
    restaurant_id INT,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(8,2) CHECK (price > 0),
    is_available BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_menu_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES Restaurants(restaurant_id)
);


-- Create Orders Table

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATETIME NOT NULL,
    total_amount DECIMAL(10,2) CHECK (total_amount >= 0),
    status VARCHAR(20)
        CHECK (status IN ('Pending', 'Delivered', 'Cancelled')),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    CONSTRAINT fk_orders_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES Restaurants(restaurant_id)
);


-- Create Order_Items Table

CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    item_id INT,
    quantity INT CHECK (quantity > 0),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),

    CONSTRAINT fk_order_items_item
        FOREIGN KEY (item_id)
        REFERENCES Menu(item_id)
);


-- Create Archived_Customers Table
-- Same structure as Customers

CREATE TABLE Archived_Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    city VARCHAR(50) NOT NULL,
    signup_date DATETIME DEFAULT CURRENT_TIMESTAMP
);



-- -------------------------------------------------------------------


-- Task 3: Insert Sample Data
-- -------------------------------

-- 3.1 Insert Data into Customers

INSERT INTO Customers
    (customer_id, name, email, phone, city, signup_date)
VALUES
    (1, 'Aarav Sharma', 'aarav@gmail.com', '9876543210', 'Mumbai', '2025-01-05 10:15:00'),
    (2, 'Priya Mehta', 'priya@gmail.com', '9876543211', 'Delhi', '2025-01-10 12:30:00'),
    (3, 'Rohan Verma', 'rohan@gmail.com', '9876543212', 'Bangalore', '2025-02-01 09:20:00'),
    (4, 'Sneha Iyer', 'sneha@gmail.com', '9876543213', 'Chennai', '2025-02-15 14:45:00'),
    (5, 'Kabir Khan', 'kabir@gmail.com', '9876543214', 'Mumbai', '2025-03-01 16:10:00'),
    (6, 'Ananya Patel', 'ananya@gmail.com', '9876543215', 'Pune', '2025-03-10 11:25:00');


-- 3.2 Insert Data into Restaurants

INSERT INTO Restaurants
    (restaurant_id, restaurant_name, city, rating)
VALUES
    (1, 'Spice Hub', 'Mumbai', 4.3),
    (2, 'Pizza Palace', 'Delhi', 4.5),
    (3, 'Burger Town', 'Bangalore', 4.1),
    (4, 'Healthy Bites', 'Pune', 4.7);


-- 3.3 Insert Data into Menu

INSERT INTO Menu
    (item_id, restaurant_id, item_name, price, is_available)
VALUES
    -- Spice Hub
    (1, 1, 'Paneer Butter Masala', 250.00, TRUE),
    (2, 1, 'Chicken Biryani', 300.00, TRUE),
    (3, 1, 'Butter Naan', 40.00, TRUE),

    -- Pizza Palace
    (4, 2, 'Margherita Pizza', 350.00, TRUE),
    (5, 2, 'Farmhouse Pizza', 450.00, TRUE),
    (6, 2, 'Garlic Bread', 150.00, TRUE),

    -- Burger Town
    (7, 3, 'Veg Burger', 120.00, TRUE),
    (8, 3, 'Chicken Burger', 180.00, TRUE),
    (9, 3, 'French Fries', 90.00, TRUE),

    -- Healthy Bites
    (10, 4, 'Quinoa Salad', 220.00, TRUE),
    (11, 4, 'Grilled Chicken', 320.00, TRUE),
    (12, 4, 'Smoothie Bowl', 180.00, TRUE);


-- 3.4 Insert Data into Orders

INSERT INTO Orders
    (order_id, customer_id, restaurant_id, order_date, total_amount, status)
VALUES
    (1, 1, 1, '2025-03-15 13:10:00', 340.00, 'Delivered'),
    (2, 2, 2, '2025-03-16 18:20:00', 500.00, 'Delivered'),
    (3, 1, 3, '2025-03-18 20:00:00', 210.00, 'Delivered'),
    (4, 3, 1, '2025-03-20 14:30:00', 300.00, 'Pending'),
    (5, 4, 2, '2025-03-22 19:45:00', 450.00, 'Delivered'),
    (6, 2, 3, '2025-03-25 21:15:00', 180.00, 'Cancelled'),
    (7, 5, 1, '2025-04-01 12:00:00', 290.00, 'Delivered'),
    (8, 1, 2, '2025-04-03 17:40:00', 350.00, 'Pending');


-- 3.5 Insert Data into Order_Items

INSERT INTO Order_Items
    (order_item_id, order_id, item_id, quantity)
VALUES
    -- Order 1
    (1, 1, 1, 1),
    (2, 1, 3, 2),

    -- Order 2
    (3, 2, 4, 1),
    (4, 2, 6, 1),

    -- Order 3
    (5, 3, 7, 1),
    (6, 3, 9, 1),

    -- Order 4
    (7, 4, 2, 1),

    -- Order 5
    (8, 5, 5, 1),

    -- Order 6 - Cancelled
    (9, 6, 8, 1),

    -- Order 7
    (10, 7, 1, 1),
    (11, 7, 3, 1),

    -- Order 8
    (12, 8, 4, 1),
    (13, 8, 6, 1),
    (14, 8, 6, 1),
    (15, 8, 5, 1);


-- 3.6 Insert Data into Archived_Customers

INSERT INTO Archived_Customers
    (customer_id, name, email, phone, city, signup_date)
VALUES
    (7, 'Rahul Singh', 'rahul@gmail.com', '9876543216', 'Delhi', '2024-12-10 10:30:00'),
    (8, 'Neha Gupta', 'neha@gmail.com', '9876543217', 'Mumbai', '2024-12-15 15:45:00');



-- -----------------------------------------------------------------


-- TODO 4: Aggregation Queries
-- --------------------------------

-- TODO:
-- 1. Find the total revenue generated.
-- 2. Find the average order value.
-- 3. Find the highest-priced menu item.
-- 4. Find the lowest-priced menu item.
-- 5. Find the number of orders grouped by status.
-- 6. Find the total number of orders.
-- 7. Find the total sales amount for each restaurant.
-- 8. Find the average rating of all restaurants.



-- TODO 5: JOIN Queries
-- --------------------------------

-- TODO 5.1: INNER JOIN
-- Display the following:
-- Customer Name
-- Restaurant Name
-- Order Date
-- Total Amount


-- TODO 5.2: LEFT JOIN
-- Display all restaurants and their orders.
-- Include restaurants that have no orders.


-- TODO 5.3: RIGHT JOIN
-- Display all customers and their orders.
-- Include customers who have not placed any orders.


-- TODO 5.4: Orders Per Restaurant
-- Count the number of orders for each restaurant.
-- Include restaurants with zero orders.


-- TODO 5.5: Total Sales Per Restaurant
-- Find the total sales amount for each restaurant.
-- Include restaurants with zero orders.



-- TODO 6: Subqueries
-- --------------------------------

-- TODO 6.1:
-- Find customers who have ordered from 'Spice Hub'.


-- TODO 6.2:
-- Find restaurants that have never received an order.


-- TODO 6.3:
-- Find customers whose total spending is above the average
-- customer spending.


-- TODO 6.4:
-- Find menu items whose price is higher than the
-- average menu item price.


-- TODO 6.5:
-- Find the restaurant(s) having the highest rating.



-- TODO 7: UNION and UNION ALL
-- --------------------------------

-- TODO 7.1: UNION
-- Find all unique cities where customers or restaurants
-- are located.
-- Use UNION to remove duplicate cities.


-- TODO 7.2: UNION ALL
-- Find all cities where customers or restaurants
-- are located.
-- Use UNION ALL to include duplicate cities.


-- TODO 7.3: Archived Customers
-- Create a table named Archived_Customers.
-- The table should have the same structure as Customers.
-- Insert 2 sample records.


-- TODO 7.4: UNION with Archived Customers
-- Display all active and archived customers using UNION.
-- Duplicate records should be removed.


-- TODO 7.5: UNION ALL with Archived Customers
-- Display all active and archived customers using UNION ALL.
-- Duplicate records should be retained.



-- TODO 8: DateTime Functions
-- --------------------------------

-- TODO 8.1:
-- Show orders placed in the last 7 days.


-- TODO 8.2:
-- Show the total revenue generated during March 2025.


-- TODO 8.3:
-- Extract the year from order_date.


-- TODO 8.4:
-- Extract the month from order_date.


-- TODO 8.5:
-- Display the order date along with its year and month.


-- TODO 8.6:
-- Calculate the number of days since each customer signed up.


-- TODO 8.7:
-- Group orders by month and count the number of orders.


-- TODO 8.8:
-- Display the current date and time.


-- TODO 8.9:
-- Display orders placed on a particular date.


-- TODO 8.10:
-- Calculate the number of days between the customer signup date
-- and their latest order date.



-- ------------------------------------------------------------
-- DateTime Functions to Practice:
--
-- NOW()
-- GETDATE()
-- CURRENT_DATE()
-- DATEDIFF()
-- MONTH()
-- YEAR()
-- DAY()
-- ------------------------------------------------------------