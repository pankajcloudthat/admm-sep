-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_oltp

--  Imagine a small Retail Sales System
-- ---------------------------------------

DROP DATABASE IF EXISTS Retail_OLTP;
CREATE DATABASE Retail_OLTP;
USE Retail_OLTP;


-- Customers Table
CREATE TABLE Retail_OLTP.Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    City VARCHAR(50),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- Products Table
CREATE TABLE Retail_OLTP.Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);


-- Orders Table
CREATE TABLE Retail_OLTP.Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


INSERT INTO Retail_OLTP.Customers (FirstName, LastName, City)
VALUES 
('Rahul','Sharma','Delhi'),
('Anita','Verma','Mumbai');

INSERT INTO Retail_OLTP.Products (ProductName, Category, Price)
VALUES
('Laptop','Electronics',50000),
('Mobile','Electronics',20000);

INSERT INTO Retail_OLTP.Orders (CustomerID, ProductID, Quantity)
VALUES
(1,1,1),
(2,2,2);


-- Verify the data

SELECT * FROM retail_oltp.customers;
SELECT * FROM retail_oltp.products;
SELEct * FROm retail_oltp.orders;



-- -------------------------------------------------------




-- Create Data Warehouse (Star Schema)
-- --------------------------------------

DROP DATABASE IF EXISTS Retail_DWH;
CREATE DATABASE Retail_DWH;
USE Retail_DWH;


DROP TABLE IF EXISTS Retail_DWH.DimCustomer;
-- DimCustomer
CREATE TABLE Retail_DWH.DimCustomer (
    CustomerKey INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    FullName VARCHAR(100),
    City VARCHAR(50)
);




-- DimProduct

DROP TABLE IF EXISTS Retail_DWH.DimProduct;

CREATE TABLE Retail_DWH.DimProduct (
    ProductKey INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);



-- FactSales
DROP TABLE IF EXISTS Retail_DWH.FactSales;
CREATE TABLE Retail_DWH.FactSales (
    SalesKey INT PRIMARY KEY AUTO_INCREMENT,
    CustomerKey INT,
    ProductKey INT,
    OrderDate DATE,
    Quantity INT,
    TotalAmount DECIMAL(10,2)
);


-- --------------------------------------------------------

-- Rejection Tables in DWH
-- -------------------------
DROP TABLE IF EXISTS Retail_DWH.RejectCustomer;
CREATE TABLE Retail_DWH.RejectCustomer (
    CustomerID INT,
    Reason VARCHAR(255),
    RejectedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Retail_DWH.RejectProduct;

CREATE TABLE Retail_DWH.RejectProduct (
    ProductID INT,
    Reason VARCHAR(255),
    RejectedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Retail_DWH.RejectFactSales;

CREATE TABLE Retail_DWH.RejectFactSales (
    OrderID INT,
    Reason VARCHAR(255),
    RejectedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);




-- ETL Using Stored Procedure
-- ---------------------------------

-- We will:

-- Load Dimensions
-- Load Fact Table
-- Clean and Transform data during load


-- Load_DimCustomer
-- --------------------

-- Validation Rules:
-- FirstName NOT NULL
-- LastName NOT NULL
-- City NOT NULL

DELIMITER //

CREATE PROCEDURE Retail_DWH.Load_DimCustomer()
BEGIN

    -- Insert Valid Records
    INSERT INTO Retail_DWH.DimCustomer (CustomerID, FullName, City)
    SELECT 
        CustomerID,
        CONCAT(FirstName,' ',LastName),
        City
    FROM Retail_OLTP.Customers
    WHERE FirstName IS NOT NULL
      AND LastName IS NOT NULL
      AND City IS NOT NULL
      AND CustomerID NOT IN (
            SELECT CustomerID FROM Retail_DWH.DimCustomer
      );

    -- Insert Invalid Records
    INSERT INTO Retail_DWH.RejectCustomer (CustomerID, Reason)
    SELECT 
        CustomerID,
        'Missing FirstName or LastName or City'
    FROM Retail_OLTP.Customers
    WHERE FirstName IS NULL
       OR LastName IS NULL
       OR City IS NULL;

END //

DELIMITER ;



-- Load_DimProduct
-- -------------------

-- Validation Rules:
-- ProductName NOT NULL
-- Category NOT NULL
-- Price NOT NULL AND > 0


DELIMITER //

CREATE PROCEDURE Retail_DWH.Load_DimProduct()
BEGIN

    -- Valid Records
    INSERT INTO Retail_DWH.DimProduct 
    (ProductID, ProductName, Category, Price)

    SELECT 
        ProductID,
        ProductName,
        Category,
        Price
    FROM Retail_OLTP.Products
    WHERE ProductName IS NOT NULL
      AND Category IS NOT NULL
      AND Price IS NOT NULL
      AND Price > 0
      AND ProductID NOT IN (
            SELECT ProductID FROM Retail_DWH.DimProduct
      );

    -- Invalid Records
    INSERT INTO Retail_DWH.RejectProduct (ProductID, Reason)
    SELECT 
        ProductID,
        'Missing ProductName/Category or Invalid Price'
    FROM Retail_OLTP.Products
    WHERE ProductName IS NULL
       OR Category IS NULL
       OR Price IS NULL
       OR Price <= 0;

END //

DELIMITER ;



-- Load_FactSales
-- ----------------

-- Validation Rules:

-- Quantity NOT NULL
-- Quantity > 0
-- Customer exists in DimCustomer
-- Product exists in DimProduct


DELIMITER //

CREATE PROCEDURE Retail_DWH.Load_FactSales()
BEGIN

    -- Valid Fact Records
    INSERT INTO Retail_DWH.FactSales
    (CustomerKey, ProductKey, OrderDate, Quantity, TotalAmount)

    SELECT 
        dc.CustomerKey,
        dp.ProductKey,
        DATE(o.OrderDate),
        o.Quantity,
        o.Quantity * dp.Price

    FROM Retail_OLTP.Orders o
    JOIN Retail_DWH.DimCustomer dc 
        ON o.CustomerID = dc.CustomerID
    JOIN Retail_DWH.DimProduct dp
        ON o.ProductID = dp.ProductID

    WHERE o.Quantity IS NOT NULL
      AND o.Quantity > 0;

    -- Invalid Fact Records
    INSERT INTO Retail_DWH.RejectFactSales (OrderID, Reason)
    SELECT 
        OrderID,
        'Invalid Quantity or Missing Dimension Reference'
    FROM Retail_OLTP.Orders
    WHERE Quantity IS NULL
       OR Quantity <= 0;

END //

DELIMITER ;




-- Execute ETL in Order
-- ---------------------

CALL Retail_DWH.Load_DimCustomer();
CALL Retail_DWH.Load_DimProduct();
CALL Retail_DWH.Load_FactSales();


-- Verify Data
SELECT * FROM Retail_DWH.DimCustomer;
SELECT * FROM Retail_DWH.DimProduct;
SELECT * FROM Retail_DWH.FactSales;




-- Query
-- ---------------------

-- Show all sales with customer name, product name, quantity, and total amount


SELECT 
    dc.FullName,
    dc.City,
    dp.ProductName,
    dp.Category,
    fs.OrderDate,
    fs.Quantity,
    fs.TotalAmount
FROM Retail_DWH.FactSales fs
JOIN Retail_DWH.DimCustomer dc 
    ON fs.CustomerKey = dc.CustomerKey
JOIN Retail_DWH.DimProduct dp 
    ON fs.ProductKey = dp.ProductKey
ORDER BY fs.OrderDate;







-- Load more data
-- ------------------

INSERT INTO Retail_OLTP.Customers (FirstName, LastName, City) VALUES
(NULL, 'Singh', 'Delhi'),
('Amit', NULL, 'Mumbai'),
('Neha', 'Kumari', 'Delhi'),
(NULL, NULL, 'Chennai'),
('Ravi', NULL, NULL),
(NULL, 'Shah', NULL),
(NULL, NULL, NULL),
('Priya', NULL, 'Pune'),
('Karan', 'Mehta', NULL),
('Ankush', 'Patel', 'Ahmedabad');



INSERT INTO Retail_OLTP.Products (ProductName, Category, Price) VALUES
('Headphones', 'Electronics', NULL),
('Camera', 'Electronics', -5000),
('MobileA', 'Electronics', 15000),
('Watch', NULL, 3000),
(NULL, NULL, 2000),
('Speaker', 'Electronics', 0);



INSERT INTO Retail_OLTP.Orders (CustomerID, ProductID, Quantity) VALUES
(1, 1, NULL),
(2, 2, 0),
(1, 1, 5),
(3, 1, NULL),
(4, 2, -1),
(2, 3, 0),
(5, 1, 2),
(6, 2, -10),
(7, 3, 0),
(8, 4, NULL),
(9, 5, -2),
(10, 6, 0),
(11, 7, NULL),
(12, 8, -3);


CALL Retail_DWH.Load_DimCustomer();
CALL Retail_DWH.Load_DimProduct();
CALL Retail_DWH.Load_FactSales();



SELECT COUNT(*) FROM Retail_DWH.RejectCustomer;
SELECT COUNT(*) FROM Retail_DWH.RejectProduct;
SELECT COUNT(*) FROM Retail_DWH.RejectFactSales;


SELECT * FROM Retail_DWH.DimCustomer;
SELECT * FROM Retail_DWH.DimProduct;
SELECT * FROM Retail_DWH.FactSales;


















-- -- ------------------------------------------------------
-- No need to run this
-- Simple ETL

-- DELIMITER //

-- CREATE PROCEDURE Retail_DWH.Load_Retail_DWH()
-- BEGIN

--     -- Load DimCustomer
--     INSERT INTO Retail_DWH.DimCustomer (CustomerID, FullName, City)
--     SELECT 
--         CustomerID,
--         CONCAT(FirstName, ' ', LastName),
--         City
--     FROM Retail_OLTP.Customers
--     WHERE CustomerID NOT IN (
--         SELECT CustomerID FROM Retail_DWH.DimCustomer
--     );

--     -- Load DimProduct
--     INSERT INTO Retail_DWH.DimProduct (ProductID, ProductName, Category, Price)
--     SELECT 
--         ProductID,
--         ProductName,
--         Category,
--         Price
--     FROM Retail_OLTP.Products
--     WHERE ProductID NOT IN (
--         SELECT ProductID FROM Retail_DWH.DimProduct
--     );

--     -- Load FactSales
--     INSERT INTO Retail_DWH.FactSales
--     (CustomerKey, ProductKey, OrderDate, Quantity, TotalAmount)

--     SELECT 
--         dc.CustomerKey,
--         dp.ProductKey,
--         DATE(o.OrderDate),
--         o.Quantity,
--         o.Quantity * dp.Price

--     FROM Retail_OLTP.Orders o
--     JOIN Retail_DWH.DimCustomer dc 
--         ON o.CustomerID = dc.CustomerID
--     JOIN Retail_DWH.DimProduct dp 
--         ON o.ProductID = dp.ProductID;

-- END //

-- DELIMITER ;


-- -- Run ETL
-- CALL Retail_DWH.Load_Retail_DWH();

-- SELECT * FROM Retail_DWH.DimCustomer;
-- SELECT * FROM Retail_DWH.DimProduct;
-- SELECT * FROM Retail_DWH.FactSales;