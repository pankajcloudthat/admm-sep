-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@bank_demo


-- SQL Constraints Demo
-- Domain: BFSI - Banking


-- Problem Statement
-- ------------------------

-- A bank wants to maintain customer and account information.

-- Business Rules:
-- 1. Every customer must have a unique Customer ID.
-- 2. Customer name and email are mandatory.
-- 3. Email address must be unique.
-- 4. Customer age must be between 18 and 100.
-- 5. Account number must be unique.
-- 6. Every account must belong to a valid customer.
-- 7. Account type can only be:
--       Savings
--       Current
--       Salary
-- 8. Account balance cannot be negative.
-- 9. Account should be Active by default.
-- 10. Account creation date should be automatically generated.
--
-- We will use SQL constraints to enforce these business rules.



-- What Are Constraints?
-- -------------------------------
-- Constraints are rules applied to table columns to control
-- what data can be inserted or updated.
--
-- They help maintain data integrity and accuracy.



-- Common Types of Constraints
-- --------------------------------

-- | Constraint  | Purpose                             |
-- |-------------|-------------------------------------|
-- | NOT NULL    | Column cannot have NULL value       |
-- | UNIQUE      | All values must be different        |
-- | PRIMARY KEY | Unique + Not Null identifier        |
-- | FOREIGN KEY | Links one table to another          |
-- | CHECK       | Limits values based on condition    |
-- | DEFAULT     | Provides a default value             |



-- Create Database
DROP DATABASE IF EXISTS bank_demo;

CREATE DATABASE bank_demo;

USE bank_demo;



-- CUSTOMER TABLE
DROP TABLE IF EXISTS customer;


CREATE TABLE customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age TINYINT NOT NULL,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    CONSTRAINT chk_customer_age
        CHECK (age BETWEEN 18 AND 100)
);



-- ACCOUNT TABLE
DROP TABLE IF EXISTS account;


CREATE TABLE account (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    account_status VARCHAR(20) NOT NULL DEFAULT 'Active',
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_account_type
        CHECK (
            account_type IN ('Savings', 'Current', 'Salary')
        ),

    CONSTRAINT chk_account_balance
        CHECK (balance >= 0),

    CONSTRAINT chk_account_status
        CHECK (
            account_status IN ('Active', 'Inactive', 'Closed')
        ),

    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
);



-- View Table Structure
DESC customer;

DESC account;



-- List All Constraints
SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'bank_demo';



-- Insert Valid Customer Data
INSERT INTO customer
(name, age, email, city)
VALUES
('Rahul Sharma', 35, 'rahul.sharma@example.com', 'Delhi'),
('Priya Verma', 29, 'priya.verma@example.com', 'Mumbai'),
('Amit Kumar', 42, 'amit.kumar@example.com', 'Bangalore'),
('Neha Singh', 31, 'neha.singh@example.com', 'Pune');



-- View Customers
SELECT *
FROM customer;



-- Insert Valid Account Data
INSERT INTO account
(customer_id, account_number, account_type, balance)
VALUES
(1, 'ACC10001', 'Savings', 50000.00),
(2, 'ACC10002', 'Current', 125000.00),
(3, 'ACC10003', 'Salary', 75000.00),
(4, 'ACC10004', 'Savings', 25000.00);



-- View Accounts
SELECT *
FROM account;



-- FOREIGN KEY DEMO
-- ---------------------

-- Customer ID 999 does not exist.
--
-- This INSERT should FAIL because of the
-- FOREIGN KEY constraint.

INSERT INTO account
(customer_id, account_number, account_type, balance)
VALUES
(999, 'ACC10005', 'Savings', 10000.00);



-- CHECK CONSTRAINT DEMO - AGE
-- ---------------------------------
-- Age 15 is invalid because customers must be
-- between 18 and 100.

INSERT INTO customer
(name, age, email, city)
VALUES
('Rohan Mehta', 15, 'rohan@example.com', 'Delhi');


-- Age 120 is also invalid.

INSERT INTO customer
(name, age, email, city)
VALUES
('Suresh Kumar', 120, 'suresh@example.com', 'Chennai');



-- NOT NULL DEMO
-- ----------------

-- Name cannot be NULL.

INSERT INTO customer
(name, age, email, city)
VALUES
(NULL, 30, 'test@example.com', 'Delhi');


-- Age cannot be NULL.

INSERT INTO customer
(name, age, email, city)
VALUES
('Test Customer', NULL, 'test2@example.com', 'Delhi');



-- UNIQUE CONSTRAINT DEMO - EMAIL
-- ---------------------------------

-- Rahul's email already exists.
--
-- This INSERT should FAIL.

INSERT INTO customer
(name, age, email, city)
VALUES
('Rahul Verma', 40, 'rahul.sharma@example.com', 'Mumbai');



-- UNIQUE CONSTRAINT DEMO - ACCOUNT NUMBER
-- --------------------------------------------

-- ACC10001 already exists.
--
-- This INSERT should FAIL.

INSERT INTO account
(customer_id, account_number, account_type, balance)
VALUES
(1, 'ACC10001', 'Savings', 15000.00);



-- CHECK CONSTRAINT DEMO - ACCOUNT TYPE
-- -----------------------------------------

-- 'Loan' is not a valid account type.
--
-- Valid values:
-- Savings
-- Current
-- Salary

INSERT INTO account
(customer_id, account_number, account_type, balance)
VALUES
(1, 'ACC10005', 'Loan', 10000.00);



-- CHECK CONSTRAINT DEMO - NEGATIVE BALANCE
-- ---------------------------------------------

-- Bank account balance cannot be negative.

INSERT INTO account
(customer_id, account_number, account_type, balance)
VALUES
(2, 'ACC10006', 'Savings', -5000.00);



-- DEFAULT CONSTRAINT DEMO
-- ----------------------------

-- Balance is not provided.
-- DEFAULT value = 0.00

INSERT INTO account
(customer_id, account_number, account_type)
VALUES
(3, 'ACC10005', 'Savings');


-- Account status is not provided.
-- DEFAULT value = 'Active'
-- Created date is not provided.
-- DEFAULT value = CURRENT_TIMESTAMP


SELECT *
FROM account
WHERE account_number = 'ACC10005';



-- Multiple Valid Records
-- ---------------------------

INSERT INTO account
(customer_id, account_number, account_type, balance)
VALUES
(1, 'ACC10007', 'Current', 85000.00),
(2, 'ACC10008', 'Salary', 45000.00),
(3, 'ACC10009', 'Savings', 15000.00);



-- UPDATE DATA
-- ---------------

-- Update a single customer's city

UPDATE customer
SET city = 'Noida'
WHERE customer_id = 1;


SELECT *
FROM customer
WHERE customer_id = 1;



-- UPDATE WITH UNIQUE CONSTRAINT
-- ----------------------------------

-- Try changing Priya's email to Rahul's email.
-- This should FAIL because email is UNIQUE.

UPDATE customer
SET email = 'rahul.sharma@example.com'
WHERE customer_id = 2;



-- UPDATE WITH CHECK CONSTRAINT
-- ---------------------------------

-- Try changing customer's age to 10.
-- This should FAIL.

UPDATE customer
SET age = 10
WHERE customer_id = 3;



-- UPDATE ACCOUNT BALANCE
-- -----------------------------

-- Valid balance update

UPDATE account
SET balance = 60000.00
WHERE account_number = 'ACC10001';


SELECT *
FROM account
WHERE account_number = 'ACC10001';



-- UPDATE WITH CHECK CONSTRAINT
-- --------------------------------

-- Try setting balance to a negative value.
--
-- This should FAIL.

UPDATE account
SET balance = -1000.00
WHERE account_number = 'ACC10001';



-- UPDATE ACCOUNT TYPE
-- ---------------------------

-- Valid update

UPDATE account
SET account_type = 'Current'
WHERE account_number = 'ACC10001';


-- Invalid update
--
-- This should FAIL.

UPDATE account
SET account_type = 'Loan'
WHERE account_number = 'ACC10001';



-- FOREIGN KEY RELATIONSHIP
-- ------------------------------

-- View customer and their accounts together

SELECT
    c.customer_id,
    c.name,
    c.email,
    a.account_number,
    a.account_type,
    a.balance,
    a.account_status,
    a.created_date
FROM customer c
INNER JOIN account a
    ON c.customer_id = a.customer_id;



-- DELETE DEMO - FOREIGN KEY
-- ------------------------------

-- Customer 1 has accounts.
--
-- Deleting this customer should FAIL because
-- account.customer_id references customer.customer_id.

DELETE FROM customer
WHERE customer_id = 1;



-- Final Data
-- ----------------

SELECT *
FROM customer;


SELECT *
FROM account;



-- View Constraints Separately
-- -------------------------------

SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'bank_demo'
ORDER BY TABLE_NAME, CONSTRAINT_TYPE;








-- TO DO
-- Problem Statement
-- > The bank wants to add a new customer and create a bank account for that customer. Before completing the operation, verify that the database constraints correctly prevent invalid data.

-- **Tasks**
-- 1. Add a new customer:
--    * Name: `Vikram Patel`
--    * Age: `38`
--    * Email: `vikram.patel@example.com`
--    * City: `Ahmedabad`
-- 2. Create a **Savings** account for Vikram with a balance of `₹75,000`.
-- 3. Try creating another account using the **same account number**.
--    * What happens?
-- 4. Try creating an account with:
--    * Account Type: `Loan`
--    * Balance: `-5000`
--    * What happens?
-- 5. Try creating an account for a `customer_id` that does not exist.
--    * What happens?
-- 6. Display Vikram's customer and account details using an `INNER JOIN`.