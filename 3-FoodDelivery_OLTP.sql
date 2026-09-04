-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@fooddelivery

-- FoodDelivery OLT System
-- ---------------------------

DROP DATABASE IF EXISTS fooddelivery;
CREATE DATABASE fooddelivery;

USE fooddelivery;


-- Cities
-- --------
DROP TABLE IF EXISTS fooddelivery.cities;
CREATE TABLE fooddelivery.cities (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(30),
    state VARCHAR(30),
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
);

TRUNCATE TABLE fooddelivery.cities;
INSERT INTO fooddelivery.cities (city_name, state) VALUES
('Bengaluru', 'Karnataka'),
('Mumbai', 'Maharashtra'),
('Delhi', 'Delhi'),
('Hyderabad', 'Telangana'),
('Chennai', 'Tamil Nadu'),
('Pune', 'Maharashtra'),
('Kolkata', 'West Bengal'),
('Ahmedabad', 'Gujarat'),
('Jaipur', 'Rajasthan'),
('Lucknow', 'Uttar Pradesh'),
('Chandigarh', 'Chandigarh'),
('Indore', 'Madhya Pradesh'),
('Surat', 'Gujarat'),
('Bhopal', 'Madhya Pradesh'),
('Kochi', 'Kerala');

SELECT * FROM fooddelivery.cities;

-- Customers
-- -----------
DROP TABLE IF EXISTS fooddelivery.customers;
CREATE TABLE fooddelivery.customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city_id INT,
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    FOREIGN KEY (city_id) REFERENCES fooddelivery.cities(city_id)
);


INSERT INTO fooddelivery.customers 
(first_name, last_name, email, city_id)
VALUES
('Rahul', 'Sharma', 'rahul.sharma@email.com', 1),
('Priya', 'Verma', 'priya.verma@email.com', 2),
('Amit', 'Patel', 'amit.patel@email.com', 3),
('Sneha', 'Reddy', 'sneha.reddy@email.com', 4),
('Arjun', 'Mehta', 'arjun.mehta@email.com', 5),
('Neha', 'Gupta', 'neha.gupta@email.com', 6),
('Vikram', 'Singh', 'vikram.singh@email.com', 7),
('Pooja', 'Iyer', 'pooja.iyer@email.com', 8),
('Karan', 'Malhotra', 'karan.malhotra@email.com', 9),
('Ananya', 'Nair', 'ananya.nair@email.com', 10);


SELECT * FROM fooddelivery.customers;

-- Restaurants
-- ------------
DROP TABLE IF EXISTS restaurants;
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_name VARCHAR(100),
    category VARCHAR(50),
    city_id INT,
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

TRUNCATE TABLE fooddelivery.restaurants;
INSERT INTO fooddelivery.restaurants
(restaurant_name, category, city_id)
VALUES
-- Bengaluru
('Biryani House', 'Biryani', 1),
('Pizza Palace', 'Italian', 1),
('Dosa Corner', 'South Indian', 1),
-- Mumbai
('Bombay Tandoor', 'North Indian', 2),
('Seafood Bay', 'Seafood', 2),
-- Delhi
('Delhi Darbar', 'Mughlai', 3),
('Chaat Junction', 'Street Food', 3),
-- Hyderabad
('Hyderabadi Dum Biryani', 'Biryani', 4),
('Spice Route', 'Multi Cuisine', 4),
-- Chennai
('Madras Meals', 'South Indian', 5),
('Grill House', 'Barbecue', 5),
-- Pune
('Pune Cafe', 'Cafe', 6),
('Burger Town', 'Fast Food', 6),
-- Kolkata
('Kolkata Rolls', 'Street Food', 7),
('Bengal Sweets', 'Desserts', 7),
-- Ahmedabad
('Gujarati Thali House', 'Gujarati', 8),
-- Jaipur
('Royal Rajasthani', 'Rajasthani', 9),
-- Lucknow
('Awadhi Kitchen', 'Awadhi', 10);

SELECT * FROM fooddelivery.restaurants;


-- Food Items
-- ------------
DROP TABLE IF EXISTS fooddelivery.food_items;
CREATE TABLE fooddelivery.food_items (
    food_id INT PRIMARY KEY AUTO_INCREMENT,
    food_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    restaurant_id INT,
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

INSERT INTO fooddelivery.food_items
(food_name, category, price, restaurant_id)
VALUES
-- Biryani House (1)
('Chicken Biryani', 'Biryani', 249.00, 1),
('Mutton Biryani', 'Biryani', 329.00, 1),
('Veg Biryani', 'Biryani', 199.00, 1),
-- Pizza Palace (2)
('Margherita Pizza', 'Pizza', 299.00, 2),
('Farmhouse Pizza', 'Pizza', 399.00, 2),
('Pepperoni Pizza', 'Pizza', 449.00, 2),
-- Dosa Corner (3)
('Masala Dosa', 'South Indian', 120.00, 3),
('Rava Dosa', 'South Indian', 140.00, 3),
('Idli Sambhar', 'South Indian', 80.00, 3),
-- Delhi Darbar (5)
('Butter Chicken', 'North Indian', 320.00, 5),
('Paneer Lababdar', 'North Indian', 260.00, 5),
('Tandoori Roti', 'Bread', 25.00, 5),
-- Madras Meals (6)
('South Indian Thali', 'Thali', 220.00, 6),
('Curd Rice', 'South Indian', 110.00, 6),
-- Burger Town (7)
('Veg Burger', 'Fast Food', 150.00, 7),
('Chicken Burger', 'Fast Food', 180.00, 7),
('French Fries', 'Snacks', 99.00, 7),
-- Hyderabadi Dum Biryani (8)
('Special Chicken Biryani', 'Biryani', 299.00, 8),
('Family Pack Biryani', 'Biryani', 799.00, 8);

SELECT * FROM fooddelivery.food_items;



SELECT f.food_id,
       f.food_name,
       f.category,
       f.price,
       r.restaurant_name
FROM fooddelivery.food_items f
JOIN fooddelivery.restaurants r
    ON f.restaurant_id = r.restaurant_id
ORDER BY f.food_id;




-- Delivery Partner
-- ------------------
DROP TABLE IF EXISTS fooddelivery.delivery_partner;
CREATE TABLE fooddelivery.delivery_partner (
    partner_id INT PRIMARY KEY AUTO_INCREMENT,
    partner_name VARCHAR(100),
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
);


INSERT INTO fooddelivery.delivery_partner
(partner_name)
VALUES
('Ravi Kumar'),
('Suresh Yadav'),
('Amit Singh'),
('Mohammed Arif'),
('Rahul Das'),
('Vikram Joshi'),
('Imran Khan'),
('Deepak Sharma'),
('Manoj Verma'),
('Kiran Reddy');


SELECT * FROM fooddelivery.delivery_partner;




-- Orders
-- --------
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    delivery_partner_id INT NOT NULL,

    order_date DATETIME NOT NULL,
    delivered_at DATETIME NULL,

    order_status VARCHAR(30) NOT NULL, 
    -- Placed, Confirmed, Preparing, Out for Delivery, Delivered, Cancelled

    total_amount DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0.00,
    delivery_fee DECIMAL(10,2) DEFAULT 0.00,

    payment_mode VARCHAR(30), 
    -- UPI, Card, Cash, Wallet

    payment_status VARCHAR(30),
    -- Paid, Pending, Refunded

    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (delivery_partner_id) REFERENCES delivery_partner(partner_id)
);


-- --------------------------------------------------------------

INSERT INTO fooddelivery.orders
(
    customer_id,
    restaurant_id,
    delivery_partner_id,
    order_date,
    delivered_at,
    order_status,
    total_amount,
    discount,
    delivery_fee,
    payment_mode,
    payment_status
)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 100
)
SELECT
    FLOOR(1 + RAND() * 10),
    FLOOR(1 + RAND() * 8),
    FLOOR(1 + RAND() * 5),

    NOW() - INTERVAL FLOOR(RAND()*10) DAY 
          - INTERVAL FLOOR(RAND()*600) MINUTE,

    CASE 
        WHEN RAND() > 0.3 
        THEN NOW() - INTERVAL FLOOR(RAND()*10) DAY 
              - INTERVAL FLOOR(20 + RAND()*40) MINUTE
        ELSE NULL
    END,
    -- @status := 'Delivered',
    @status := ELT(FLOOR(1 + RAND()*3),
        'Delivered',
        'Cancelled',
        'Preparing'
    ),

    ROUND(100 + RAND()*400, 2),
    ROUND(RAND()*50, 2),
    ROUND(10 + RAND()*40, 2),

    ELT(FLOOR(1 + RAND()*4),
        'UPI','Card','Cash','Wallet'),

    CASE 
        WHEN @status = 'Delivered' THEN 'Paid'
        WHEN @status = 'Cancelled' THEN 'Refunded'
        ELSE 'Pending'
    END

FROM seq;



-- Verify data
SELECT COUNT(*) FROM fooddelivery.orders;


-- Check distribution of order statuses
SELECT order_status, COUNT(*)
FROM fooddelivery.orders
GROUP BY order_status;

-- --------------------------------------------------------------



-- Order Details
-- ---------------
DROP TABLE IF EXISTS fooddelivery.order_details;
CREATE TABLE fooddelivery.order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    food_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id), 
    FOREIGN KEY (food_id) REFERENCES food_items(food_id),
    UNIQUE KEY uk_order_food (order_id, food_id)
);


-- ------------------------------------------------------------------------

INSERT INTO fooddelivery.order_details
(order_id, food_id, quantity, price)
SELECT
    o.order_id,
    f.food_id,
    FLOOR(1 + RAND()*3) AS quantity,
    f.price
FROM fooddelivery.orders o
JOIN fooddelivery.food_items f
    ON f.restaurant_id = o.restaurant_id
WHERE RAND() < 0.8;


-- Verify
SELECT COUNT(*) FROM fooddelivery.order_details;

SELECT od.order_id,
       od.food_id,
       od.quantity,
       od.price,
       f.food_name
FROM fooddelivery.order_details od
JOIN fooddelivery.food_items f
    ON od.food_id = f.food_id
ORDER BY od.order_id


-- ------------------------------------------------------------------------







SHOW  TABLES;