-- SQLBook: Code
-- Data Warehouse
-- ----------------


-- Business Scenario — Food Delivery Analytics

-- Imagine a food delivery company such as Zomato or Swiggy.

-- The company receives thousands of food orders every day from customers across different cities. 
-- Each order may contain one or more food items from a restaurant and is delivered by a delivery partner.

-- The company already has an operational system that stores information about customers, restaurants, food items, orders, payments, and delivery partners. 
-- However, management wants to analyze this data to understand business performance and make better decisions.

-- The management wants to answer questions such as:

-- What is the daily, monthly, and yearly revenue trend?
-- Which restaurants generate the highest revenue?
-- Who are the top customers based on their spending?
-- Which food items and categories are most popular?
-- What is the average delivery time?
-- Which cities generate the most revenue?
-- Which delivery partners handle the highest number of orders?
-- How much discount is given to customers?
-- What is the average order value?
-- How does the company's performance change over time?

-- To answer these questions efficiently, the company decides to build a Data Warehouse for Food Delivery Analytics.

-- The Data Warehouse will collect and organize historical data from the operational systems and structure it in a way that makes analytical queries fast and easy.

-- The analytical model will use a Star Schema, where a central FactOrders table contains measurable business events such as order amount, quantity, discount, and delivery time. 
-- Dimension tables such as Date, Customer, Restaurant, Food, City, and Delivery Partner will provide different perspectives from which the business can analyze these measures.

-- The overall goal is to transform the company's operational order data into meaningful KPIs, trends, comparisons, and business insights that management can use for decision-making.




-- END-TO-END DATA WAREHOUSE DESIGN
-- DOMAIN: FOOD DELIVERY
-- -----------------------------------------


-- STEP 1 — START WITH THE END GOAL
-- =================================
-- Always start with the BUSINESS questions.
--
-- Do not start by creating tables.
-- First understand what the business wants to ANALYZE.


-- Imagine we are working for a Food Delivery company.
--
-- The management wants to analyze food orders and answer questions such as:

-- 1. What is the daily / monthly revenue trend?
-- 2. Which restaurant generates highest revenue?
-- 3. Who are the top customers by spending?
-- 4. What are the popular food categories?
-- 5. What is the average delivery time?
-- 6. How is revenue trending by city?

-- These questions tell us WHAT we need to measure
-- and from WHICH perspectives we need to analyze those measurements.


-- STEP 2 — IDENTIFY MEASURES AND DIMENSIONS
-- ==========================================

-- Once we know the business questions,
-- identify:
--
--     1. MEASURES  → What do we want to calculate?
--     2. DIMENSIONS → From which perspective do we want to analyze?


-- MEASURES / FACTS
-- ----------------
-- Measures are numeric values that can be aggregated
-- using SUM(), AVG(), COUNT(), MIN(), MAX(), etc.


-- Examples:
--
-- Order Amount
-- Quantity
-- Delivery Time
-- Discount Amount
-- Order Count


-- For example:
--
-- SUM(OrderAmount)
-- AVG(DeliveryMinutes)
-- SUM(DiscountAmount)
-- COUNT(OrderID)


-- These measures will be stored in the FACT TABLE.



-- DIMENSIONS
-- ----------
-- Dimensions provide the CONTEXT for analyzing the facts.
--
-- They answer questions such as:
--
--     When?
--     Who?
--     Which restaurant?
--     Which food?
--     Where?
--     Who delivered the order?


-- Dimensions:
--
-- Date
-- Customer
-- Restaurant
-- Food
-- City
-- Delivery Partner



-- STEP 3 — IDENTIFY THE GRAIN OF THE FACT TABLE
-- ==============================================

-- Before creating the fact table,
-- we MUST answer one very important question:
--
--     "What does ONE ROW in my fact table represent?"


-- For our Food Delivery example:
--
--     ONE ROW = ONE FOOD ITEM IN ONE CUSTOMER ORDER
--
-- OR
--
--     ONE ROW = ONE ORDER
--
-- We need to decide this before designing the table.


-- If one order can contain multiple food items,
-- then using:
--
--     ONE ROW = ONE FOOD ITEM IN ONE ORDER
--
-- gives us better analysis of:
--
--     - food quantity
--     - food revenue
--     - popular food items
--     - food categories
--
-- Therefore, for this example we will use:


-- GRAIN:
-- "One row represents one food item purchased
--  as part of one customer order."





-- STEP 4 — DESIGN THE FACT TABLE
-- ==============================

-- FACT TABLE: FactOrders
-- ----------------------

-- The fact table stores:
--
--     1. Foreign Keys → links to dimensions
--     2. Measures     → numeric values for analysis


-- FactOrders
--
-- DateKey                (FK)
-- CustomerKey            (FK)
-- RestaurantKey          (FK)
-- FoodKey                (FK)
-- CityKey                (FK)
-- DeliveryPartnerKey     (FK)
-- OrderID                (Degenerate Dimension)
--
-- Quantity
-- OrderAmount
-- DiscountAmount
-- DeliveryMinutes


-- Notice:
--
-- The fact table does NOT store descriptive information such as:
--
--     CustomerName
--     RestaurantName
--     FoodName
--     CityName
--
-- Instead, it stores KEYS that point to dimension tables.





-- STEP 5 — DESIGN THE DIMENSION TABLES
-- ====================================


-- 1. DimDate
-- ----------

-- Used to analyze data over time.

-- DateKey       (PK)
-- FullDate
-- Day
-- Month
-- Year
-- Quarter
-- DayName


-- Example:
--
-- DateKey   FullDate     Day   Month   Year   Quarter   DayName
-- ----------------------------------------------------------------
-- 20260901  2026-09-01    1      9     2026      3      Tuesday
-- 20260902  2026-09-02    2      9     2026      3      Wednesday


-- Why do we need DimDate?
--
-- Because the business wants to answer:
--
--     Revenue by day
--     Revenue by month
--     Revenue by quarter
--     Revenue by year
--     Orders by day of week
--
-- Instead of performing date calculations repeatedly,
-- we keep useful calendar attributes in DimDate.



-- 2. DimCustomer
-- --------------

-- Contains customer information.

-- CustomerKey       (PK - Surrogate Key)
-- CustomerID        (Business Key)
-- Name
-- Email
-- City
-- StartDate
-- EndDate
-- IsCurrent


-- This dimension is an example of:
--
--     SCD TYPE 2
--     (Slowly Changing Dimension Type 2)


-- Why?
--
-- Suppose customer Pankaj initially lives in Sagar.
--
-- Later, the customer moves to Bhopal.
--
-- If we simply UPDATE the City:
--
--     Sagar → Bhopal
--
-- we lose the historical information.
--
-- With SCD Type 2, we keep both versions.


-- Example:
--
-- CustomerKey | CustomerID | Name   | City    | StartDate  | EndDate    | IsCurrent
-- --------------------------------------------------------------------------------
-- 101         | C001       | Pankaj | Sagar   | 2025-01-01 | 2026-05-31 | 0
-- 205         | C001       | Pankaj | Bhopal  | 2026-06-01 | NULL       | 1


-- This allows us to answer:
--
-- "What was the customer's city when the order was placed?"


-- The FACT TABLE stores CustomerKey,
-- not CustomerID.
--
-- Therefore historical orders continue to point
-- to the correct version of the customer.



-- 3. DimRestaurant
-- ----------------

-- Contains restaurant information.

-- RestaurantKey       (PK)
-- RestaurantID        (Business Key)
-- RestaurantName
-- Category
-- City


-- Examples of analysis:
--
-- Revenue by restaurant
-- Orders by restaurant
-- Restaurant performance
-- Revenue by restaurant category



-- 4. DimFood
-- ----------

-- Contains food item information.

-- FoodKey              (PK)
-- FoodID               (Business Key)
-- FoodName
-- Category
-- Price


-- Examples:
--
-- Pizza
-- Burger
-- Biryani
-- Pasta
-- Sandwich


-- This dimension allows us to answer:
--
-- Which food item is most popular?
-- Which food category generates the most revenue?
-- Which food items have the highest sales?



-- 5. DimCity
-- ----------

-- Contains geographic information.

-- CityKey       (PK)
-- CityName
-- State


-- This allows us to analyze:
--
-- Revenue by city
-- Orders by city
-- Customers by city
-- Restaurant performance by city



-- 6. DimDeliveryPartner
-- ---------------------

-- Contains delivery partner information.

-- PartnerKey       (PK)
-- PartnerID        (Business Key)
-- PartnerName


-- This allows us to analyze:
--
-- Orders delivered by each partner
-- Average delivery time
-- Delivery partner performance
-- Number of completed deliveries



-- STEP 6 — FINAL STAR SCHEMA
-- ===========================


--                         DimDate
--                            |
--                            |
--                            |
--                    +---------------+
--                    |               |
-- DimCustomer -------|               |------- DimRestaurant
--                    |               |
-- DimFood -----------|  FactOrders   |------- DimCity
--                    |               |
-- DimDeliveryPartner-|               |
--                    +---------------+
--                            |
--                            |
--                         Measures
--
--
-- FactOrders is at the CENTER.
--
-- Dimension tables provide CONTEXT.
--
-- Fact table provides MEASURES.



-- STEP 7 — UNDERSTAND THE KEYS
-- =============================

-- Dimension tables generally contain:
--
--     Surrogate Key (PK)
--     Business Key
--     Descriptive Attributes


-- Example:
--
-- DimRestaurant
--
-- RestaurantKey       ← Surrogate Key
-- RestaurantID        ← Business Key
-- RestaurantName
-- Category
-- City


-- FactOrders contains:
--
--     RestaurantKey ← FK
--
-- This creates the relationship between:
--
--     FactOrders → DimRestaurant



-- STEP 8 — IDENTIFY KEY METRICS
-- ==============================

-- Now that the Star Schema is designed,
-- we can calculate BUSINESS KPIs.


-- 1. TOTAL REVENUE
-- ----------------
--
-- SUM(OrderAmount)


-- Business question:
--
-- "How much revenue did the food delivery company generate?"



-- 2. TOTAL ORDERS
-- ---------------

-- COUNT(DISTINCT OrderID)


-- Business question:
--
-- "How many orders were placed?"



-- 3. AVERAGE ORDER VALUE
-- ----------------------

-- SUM(OrderAmount) / COUNT(DISTINCT OrderID)


-- Business question:
--
-- "How much does a customer spend on average per order?"



-- 4. TOTAL DISCOUNT
-- -----------------

-- SUM(DiscountAmount)


-- Business question:
--
-- "How much discount did the company provide?"



-- 5. AVERAGE DELIVERY TIME
-- ------------------------

-- AVG(DeliveryMinutes)


-- Business question:
--
-- "How quickly are orders being delivered?"



-- 6. TOP RESTAURANTS BY REVENUE
-- -----------------------------

-- SUM(OrderAmount)
-- GROUP BY Restaurant



-- 7. TOP CUSTOMERS BY SPENDING
-- ----------------------------

-- SUM(OrderAmount)
-- GROUP BY Customer



-- 8. POPULAR FOOD ITEMS
-- ---------------------

-- SUM(Quantity)
-- GROUP BY Food



-- 9. REVENUE BY CITY
-- ------------------

-- SUM(OrderAmount)
-- GROUP BY City



-- 10. MONTHLY REVENUE TREND
-- --------------------------

-- SUM(OrderAmount)
-- GROUP BY Year, Month



-- STEP 9 — CONNECT BUSINESS QUESTIONS
-- ====================================

-- The important point is that the STAR SCHEMA
-- is designed based on the business questions.


-- Business Question
--          ↓
-- Identify Measure
--          ↓
-- Identify Dimension
--          ↓
-- Design Fact + Dimension
--          ↓
-- Create Star Schema
--          ↓
-- Write Analytical Queries
--          ↓
-- Calculate KPIs
--          ↓
-- Generate Business Insights



-- Example:
--
-- QUESTION:
-- "Which restaurant generates the highest revenue?"
--
-- Measure:
--     OrderAmount
--
-- Dimension:
--     Restaurant
--
-- Query concept:
--
--     SUM(OrderAmount)
--     GROUP BY Restaurant
--
--
-- Another example:
--
-- QUESTION:
-- "What is the monthly revenue trend?"
--
-- Measure:
--     OrderAmount
--
-- Dimension:
--     Date
--
-- Query concept:
--
--     SUM(OrderAmount)
--     GROUP BY Year, Month



-- STEP 10 — THE BIG PICTURE
-- =========================

-- Operational Database
--          |
--          |  ETL / ELT
--          ↓
--    Data Warehouse
--          |
--          ↓
--     Star Schema
--          |
--          ↓
--     Fact + Dimensions
--          |
--          ↓
--     Analytical Queries
--          |
--          ↓
--         KPIs
--          |
--          ↓
--     Reports / Dashboard
--          |
--          ↓
--   Business Decision Making







-- -------------------------------
-- Star Schema Design
-- -------------------------------

-- FACT TABLE: FactOrders
-- -----------------------

-- DateKey (FK)
-- CustomerKey (FK)
-- RestaurantKey (FK)
-- FoodKey (FK)
-- CityKey (FK)
-- DeliveryPartnerKey (FK)
-- OrderID (degenerate)
-- Quantity
-- OrderAmount
-- DiscountAmount
-- DeliveryMinutes


-- Dimension Tables
-- -----------------------

-- 1. DimDate
-- -------------
-- DateKey (PK)
-- FullDate
-- Day
-- Month
-- Year
-- Quarter
-- DayName


-- 2. DimCustomer (SCD Type 2)
-- ---------------------------
-- CustomerKey (PK surrogate)
-- CustomerID (business key)
-- Name
-- Email
-- City
-- StartDate
-- EndDate
-- IsCurrent

-- 3. DimRestaurant
-- ---------------
-- RestaurantKey
-- RestaurantID
-- RestaurantName
-- Category
-- City

-- 4. DimFood
-- ----------
-- FoodKey
-- FoodID
-- FoodName
-- Category
-- Price

-- 5. DimCity
-- ---------
-- CityKey
-- CityName
-- State

-- 6. DimDeliveryPartner
-- ---------------------
-- PartnerKey
-- PartnerID
-- PartnerName