-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@fd_dwh

-- Analytic Queries for Food Delivery DWH
-- -----------------------------------------

USE FD_DWH;


-- 1. What is the daily / monthly revenue trend?

SELECT 
    d.FullDate,
    SUM(f.OrderAmount) AS DailyRevenue
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimDate d
    ON f.DateKey = d.DateKey
GROUP BY d.FullDate
ORDER BY d.FullDate;



SELECT 
    d.Year,
    d.Month,
    SUM(f.OrderAmount) AS MonthlyRevenue
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimDate d
    ON f.DateKey = d.DateKey
GROUP BY d.Year, d.Month
ORDER BY d.Year, d.Month;


-- 2. Which restaurant generates highest revenue?

SELECT 
    r.RestaurantName,
    SUM(f.OrderAmount) AS TotalRevenue
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimRestaurant r
    ON f.RestaurantKey = r.RestaurantKey
GROUP BY r.RestaurantName
ORDER BY TotalRevenue DESC
LIMIT 5;


-- 3. Who are the top customers by spending?

SELECT 
    c.Name,
    SUM(f.OrderAmount) AS TotalSpent
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimCustomer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY c.Name
ORDER BY TotalSpent DESC
LIMIT 10;


-- 4. What are the popular food categories?

SELECT 
    df.Category,
    SUM(f.Quantity) AS TotalItemsSold,
    SUM(f.OrderAmount) AS CategoryRevenue
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimFood df
    ON f.FoodKey = df.FoodKey
GROUP BY df.Category
ORDER BY CategoryRevenue DESC;


-- 6. How is revenue trending by city?
SELECT 
    dc.CityID,
    city.CityName,
    SUM(f.OrderAmount) AS CityRevenue
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimCustomer dc
    ON f.CustomerKey = dc.CustomerKey
JOIN FD_DWH.DimCity city
    ON dc.CityID = city.CityKey
GROUP BY dc.CityID, city.CityName
ORDER BY CityRevenue DESC;




-- Discount Impact

SELECT 
    SUM(OrderAmount) AS GrossRevenue,
    SUM(DiscountAmount) AS TotalDiscount,
    SUM(OrderAmount - DiscountAmount) AS NetRevenue,
    ROUND(
        (SUM(DiscountAmount) / SUM(OrderAmount)) * 100,
        2
    ) AS DiscountPercent
FROM FD_DWH.FactOrders;



-- Average Order Value
SELECT 
    ROUND(SUM(OrderAmount) / COUNT(DISTINCT OrderID),2) AS AvgOrderValue
FROM FD_DWH.FactOrders;


-- Restaurant Ranking (Window Function)

SELECT *
FROM (
    SELECT 
        r.RestaurantName,
        SUM(f.OrderAmount) AS Revenue,
        RANK() OVER (ORDER BY SUM(f.OrderAmount) DESC) AS RevenueRank
    FROM FD_DWH.FactOrders f
    JOIN FD_DWH.DimRestaurant r
        ON f.RestaurantKey = r.RestaurantKey
    GROUP BY r.RestaurantName
) t;


-- Revenue Trend with Moving Average (7-Day)

SELECT
    d.FullDate,
    SUM(f.OrderAmount) AS DailyRevenue,
    ROUND(
        AVG(SUM(f.OrderAmount)) OVER (
            ORDER BY d.FullDate
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),2
    ) AS MovingAvg7Day
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimDate d
    ON f.DateKey = d.DateKey
GROUP BY d.FullDate
ORDER BY d.FullDate;



-- CUSTOMER BEHAVIOR ANALYSIS

-- We’ll analyze:

-- ✔ Spending patterns
-- ✔ Frequency
-- ✔ Repeat behavior
-- ✔ High-value customers
-- ✔ Order habits



-- Top Customers by Revenue
SELECT 
    c.Name,
    COUNT(DISTINCT f.OrderID) AS TotalOrders,
    SUM(f.OrderAmount) AS TotalSpent
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimCustomer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY c.Name
ORDER BY TotalSpent DESC
LIMIT 10;



-- Repeat vs One-Time Customers
SELECT 
    CASE 
        WHEN COUNT(DISTINCT f.OrderID) = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS CustomerType,
    COUNT(*) AS CustomerCount
FROM FD_DWH.FactOrders f
GROUP BY f.CustomerKey;


-- Customer Segmentation (NTILE)
SELECT *
FROM (
    SELECT 
        c.Name,
        SUM(f.OrderAmount) AS TotalSpent,
        NTILE(4) OVER (ORDER BY SUM(f.OrderAmount) DESC) AS SpendingQuartile
    FROM FD_DWH.FactOrders f
    JOIN FD_DWH.DimCustomer c
        ON f.CustomerKey = c.CustomerKey
    GROUP BY c.Name
) t;


-- Customer Ordering Time Pattern
SELECT 
    HOUR(d.FullDate) AS OrderHour,
    COUNT(DISTINCT f.OrderID) AS OrderCount
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimDate d
    ON f.DateKey = d.DateKey
GROUP BY OrderHour
ORDER BY OrderHour;


-- Customer Lifetime Value
SELECT 
    c.Name,
    SUM(f.OrderAmount) AS LifetimeValue,
    MIN(d.FullDate) AS FirstOrder,
    MAX(d.FullDate) AS LastOrder
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimCustomer c
    ON f.CustomerKey = c.CustomerKey
JOIN FD_DWH.DimDate d
    ON f.DateKey = d.DateKey
GROUP BY c.Name
ORDER BY LifetimeValue DESC;





-- PLATFORM FEE ANALYSIS
-- Total Platform Revenue (Delivery Fees)

SELECT 
    SUM(DeliveryFee) AS TotalPlatformRevenue
FROM FD_DWH.FactOrders;


-- Platform Revenue by Restaurant
SELECT 
    r.RestaurantName,
    SUM(f.DeliveryFee) AS PlatformRevenue
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimRestaurant r
    ON f.RestaurantKey = r.RestaurantKey
GROUP BY r.RestaurantName
ORDER BY PlatformRevenue DESC;


-- Monthly Platform Revenue Trend
SELECT 
    d.Year,
    d.Month,
    SUM(f.DeliveryFee) AS MonthlyPlatformRevenue
FROM FD_DWH.FactOrders f
JOIN FD_DWH.DimDate d
    ON f.DateKey = d.DateKey
GROUP BY d.Year, d.Month
ORDER BY d.Year, d.Month;


-- Average Delivery Fee per Order
SELECT 
    ROUND(
        SUM(DeliveryFee) / COUNT(DISTINCT OrderID),
        2
    ) AS AvgDeliveryFee
FROM FD_DWH.FactOrders;


-- If platform takes 20% commission on food:
SELECT 
    SUM(OrderAmount * 0.20) AS CommissionRevenue,
    SUM(DeliveryFee) AS DeliveryRevenue,
    SUM(OrderAmount * 0.20) + SUM(DeliveryFee) AS TotalPlatformRevenue
FROM FD_DWH.FactOrders;




-- Cancellation impact KPI

-- Lost revenue
-- Refund volume
-- Customer dissatisfaction
-- Partner inefficiency


-- Cancellation Rate
SELECT 
    ROUND(
        (SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)
        / COUNT(*)) * 100,
        2
    ) AS CancellationRatePercent
FROM fooddelivery.orders o;


-- Revenue Lost Due to Cancellation
SELECT 
    SUM(total_amount) AS CancelledRevenue
FROM fooddelivery.orders
WHERE order_status = 'Cancelled';



-- Cancellation Trend (Daily)
SELECT 
    DATE(order_date) AS OrderDate,
    COUNT(*) AS CancelledOrders
FROM fooddelivery.orders
WHERE order_status = 'Cancelled'
GROUP BY DATE(order_date)
ORDER BY OrderDate;


-- Cancellation by City (Customer Location)
SELECT 
    city.CityName,
    COUNT(*) AS CancelledOrders
FROM fooddelivery.orders o
JOIN FD_DWH.DimCustomer dc
    ON o.customer_id = dc.CustomerID
JOIN FD_DWH.DimCity city
    ON dc.CityID = city.CityKey
WHERE o.order_status = 'Cancelled'
GROUP BY city.CityName
ORDER BY CancelledOrders DESC;


-- Cancellation Rate by Restaurant
SELECT 
    r.restaurant_name,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
    ROUND(
        (SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)
        / COUNT(*)) * 100,
        2
    ) AS CancellationRatePercent
FROM fooddelivery.orders o
JOIN fooddelivery.restaurants r
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY CancellationRatePercent DESC;



-- Cancellation by Delivery Partner
SELECT 
    dp.partner_name,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
    ROUND(
        (SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)
        / COUNT(*)) * 100,
        2
    ) AS CancellationRatePercent
FROM fooddelivery.orders o
JOIN fooddelivery.delivery_partner dp
    ON o.delivery_partner_id = dp.partner_id
GROUP BY dp.partner_name
ORDER BY CancellationRatePercent DESC;


-- Avg Time Before Cancellation
SELECT 
    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, order_date, updated_at)),
        2
    ) AS AvgMinutesBeforeCancel
FROM fooddelivery.orders
WHERE order_status = 'Cancelled';


-- Net Revenue Impact KPI
SELECT 
    SUM(CASE WHEN order_status = 'Delivered' 
             THEN total_amount 
             ELSE 0 END) AS DeliveredRevenue,
    SUM(CASE WHEN order_status = 'Cancelled' 
             THEN total_amount 
             ELSE 0 END) AS LostRevenue,
    ROUND(
        (SUM(CASE WHEN order_status = 'Cancelled' 
                  THEN total_amount 
                  ELSE 0 END)
         / SUM(total_amount)) * 100,
        2
    ) AS RevenueLossPercent
FROM fooddelivery.orders;
