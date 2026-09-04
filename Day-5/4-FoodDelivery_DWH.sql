-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@fd_dwh

-- Fooddelivery Data Warehouse
-- -----------------------------

DROP DATABASE IF EXISTS FD_DWH;
CREATE DATABASE FD_DWH;

USE FD_DWH;


-- Create Dimension Tables 
-- -------------------------


-- DimDate
-- ---------
DROP TABLE IF EXISTS DimDate;
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Day INT,
    Month INT,
    Year INT,
    Quarter INT,
    DayName VARCHAR(20)
);


-- Open PopulateDimDate.sql and run the code
-- After that verify the data
-- --------------------------

SELECT COUNT(*) FROM FD_DWH.DimDate;

SELECT * FROM FD_DWH.DimDate;


-- DimCity
-- ---------
CREATE TABLE DimCity (
    CityKey INT AUTO_INCREMENT PRIMARY KEY,
    CityID INT,
    CityName VARCHAR(30),
    State VARCHAR(30)
);




-- DimCustomer (SCD Type 2)
-- --------------------------
DROP TABLE IF EXISTS DimCustomer;
CREATE TABLE DimCustomer (
    CustomerKey INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    Name VARCHAR(100),
    Email VARCHAR(100),
    CityID INT,
    StartDate DATETIME,
    EndDate DATETIME,
    IsCurrent CHAR(1)
);




-- DimRestaurant
-- ---------------
DROP TABLE IF EXISTS FD_DWH.DimRestaurant;
CREATE TABLE FD_DWH.DimRestaurant (
    RestaurantKey INT AUTO_INCREMENT PRIMARY KEY,
    RestaurantID INT,
    RestaurantName VARCHAR(100),
    Category VARCHAR(50),
    CityID INT,
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    FOREIGN KEY (CityID) REFERENCES FD_DWH.DimCity(CityKey)
);




-- DimFood
-- ----------
DROP TABLE IF EXISTS DimFood;
CREATE TABLE DimFood (
    FoodKey INT AUTO_INCREMENT PRIMARY KEY,
    FoodID INT,
    FoodName VARCHAR(100),
    Category VARCHAR(50),
    RestaurantID INT,
    CurrentPrice DECIMAL(10,2),
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    UNIQUE KEY uk_foodid (FoodID)
);




-- DimDeliveryPartner
-- --------------------
DROP  TABLE IF EXISTS DimDeliveryPartner;
CREATE TABLE DimDeliveryPartner (
    PartnerKey INT AUTO_INCREMENT PRIMARY KEY,
    PartnerID INT,
    PartnerName VARCHAR(100),
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    UNIQUE KEY uk_partnerid (PartnerID)
);








-- FactOrders Table
-- ------------------
DROP TABLE IF EXISTS FD_DWH.FactOrders;
CREATE TABLE FD_DWH.FactOrders (
    FactKey INT AUTO_INCREMENT PRIMARY KEY,
    -- Dimension Keys
    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    RestaurantKey INT NOT NULL,
    FoodKey INT NOT NULL,
    DeliveryPartnerKey INT NOT NULL,
    -- Degenerate Dimension
    OrderID INT NOT NULL,
    -- Measures
    Quantity INT NOT NULL,
    ItemPrice DECIMAL(10,2) NOT NULL,
    OrderAmount DECIMAL(10,2) NOT NULL,
    DiscountAmount DECIMAL(10,2) DEFAULT 0.00,
    DeliveryFee DECIMAL(10,2) DEFAULT 0.00,
    DeliveryMinutes INT,
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey), 
    FOREIGN KEY (FoodKey) REFERENCES DimFood(FoodKey), 
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey), 
    FOREIGN KEY (RestaurantKey) REFERENCES DimRestaurant(RestaurantKey), 
    FOREIGN KEY (DeliveryPartnerKey) REFERENCES DimDeliveryPartner(PartnerKey)
);

SHOW TABLES;