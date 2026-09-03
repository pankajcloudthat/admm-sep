-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@demo


-- Stored Procedure
-- -------------------------------------

-- A Stored Procedure in MySQL is a pre-written set
-- of SQL statements stored inside the database
-- and executed whenever needed.
--
-- Think of it like:
-- A reusable SQL program saved inside the database.
--
-- Instead of writing the same SQL queries again and again,
-- write them once inside a procedure and CALL it.


-- Why Do We Use Stored Procedures?
-- -------------------------------------

-- 1. Reusability
--    Write once and use multiple times.
--
-- 2. Better performance
--    SQL logic is stored and processed by the database.
--
-- 3. Reduced network traffic
--    Multiple SQL statements can be executed
--    using a single CALL.
--
-- 4. Security
--    Users can be given permission to execute
--    a procedure without giving direct table access.
--
-- 5. Centralized business logic
--    Business rules can be maintained inside
--    the database.


-- Basic Syntax
-- -------------------------------------

-- DELIMITER //
--
-- CREATE PROCEDURE procedure_name()
-- BEGIN
--     -- SQL statements
-- END //
--
-- DELIMITER ;


-- 1. Simple Stored Procedure
-- -------------------------------------

USE demo;

SHOW TABLES;


-- Create Users Table
-- -------------------------------------

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age INT
);


-- Insert Sample Users
-- -------------------------------------

INSERT INTO users (name, age)
VALUES
('Rahul Sharma', 25),
('Priya Verma', 17),
('Amit Kumar', 32),
('Neha Singh', 21);

DROP PROCEDURE IF EXISTS GetAllUsers;

DELIMITER //

CREATE PROCEDURE GetAllUsers()
BEGIN

    SELECT *
    FROM users;

END;

DELIMITER ;


-- Execute the procedure.

CALL GetAllUsers();


-- 2. Show Procedures
-- -------------------------------------

-- Show procedures in the current database.

SHOW PROCEDURE STATUS
WHERE Db = DATABASE();


-- Show procedure definitions.

SELECT
    ROUTINE_NAME,
    ROUTINE_DEFINITION
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
AND ROUTINE_SCHEMA = DATABASE();


-- 3. Drop a Procedure
-- -------------------------------------

DROP PROCEDURE IF EXISTS GetAllUsers;


-- Procedure with Parameters
-- -------------------------------------


-- 4. IN Parameter
-- -------------------------------------
-- IN is used to pass a value into
-- the stored procedure.
--
-- IN is the default parameter type.


DROP PROCEDURE IF EXISTS GetUserById;

DELIMITER //

CREATE PROCEDURE GetUserById(IN p_user_id INT)
BEGIN

    SELECT *
    FROM users
    WHERE id = p_user_id;

END;

DELIMITER ;


-- Call the procedure.

CALL GetUserById(1);


-- The value 1 is passed into p_user_id.


-- 5. Procedure with Multiple Parameters
-- -------------------------------------

DROP PROCEDURE IF EXISTS GetUsersByAge;

DELIMITER //

CREATE PROCEDURE GetUsersByAge(
    IN p_min_age INT,
    IN p_max_age INT
)
BEGIN

    SELECT *
    FROM users
    WHERE age BETWEEN p_min_age AND p_max_age;

END;

DELIMITER ;


CALL GetUsersByAge(18, 30);


-- 6. OUT Parameter
-- -------------------------------------
-- OUT is used when the procedure needs
-- to return a value to the caller.
--
-- Example:
-- Return the total number of users.


DROP PROCEDURE IF EXISTS GetUserCount;

DELIMITER //

CREATE PROCEDURE GetUserCount(OUT p_total INT)
BEGIN

    SELECT COUNT(*)
    INTO p_total
    FROM users;

END;

DELIMITER ;


-- OUT parameters are normally received
-- using a session variable.

CALL GetUserCount(@user_count);

SELECT @user_count AS total_users;


-- 7. INOUT Parameter
-- -------------------------------------
-- INOUT can:
--
-- 1. Accept an input value.
-- 2. Modify the value.
-- 3. Return the modified value.


DROP PROCEDURE IF EXISTS IncreaseValue;

DELIMITER //

CREATE PROCEDURE IncreaseValue(INOUT p_number INT)
BEGIN

    SET p_number = p_number + 10;

END;

DELIMITER ;


-- Set the initial value.

SET @value = 5;


-- Pass the value into the procedure.

CALL IncreaseValue(@value);


-- Value has been modified.

SELECT @value AS new_value;


-- Result:
-- 15


-- 8. Procedure with Business Logic
-- -------------------------------------
-- A procedure can contain multiple
-- SQL statements and business logic.


DROP PROCEDURE IF EXISTS GetUserSummary;

DELIMITER //

CREATE PROCEDURE GetUserSummary(IN p_user_id INT)
BEGIN

    -- User details
    SELECT
        id,
        name,
        age
    FROM users
    WHERE id = p_user_id;

    -- User count
    SELECT
        COUNT(*) AS total_matching_users
    FROM users
    WHERE id = p_user_id;

END;

DELIMITER ;


CALL GetUserSummary(1);


-- 9. Variables inside Procedure
-- -------------------------------------
-- DECLARE is used to create a local
-- variable inside a stored procedure.


DROP PROCEDURE IF EXISTS GetUserAge;

DELIMITER //

CREATE PROCEDURE GetUserAge(IN p_user_id INT)
BEGIN

    DECLARE user_age INT;

    SELECT age
    INTO user_age
    FROM users
    WHERE id = p_user_id;

    SELECT user_age AS age;

END;

DELIMITER ;


CALL GetUserAge(1);


-- 10. IF / ELSE inside Procedure
-- -------------------------------------
-- Stored procedures can contain
-- programming logic.


DROP PROCEDURE IF EXISTS CheckUserAge;

DELIMITER //

CREATE PROCEDURE CheckUserAge(IN p_user_id INT)
BEGIN

    DECLARE user_age INT;

    SELECT age
    INTO user_age
    FROM users
    WHERE id = p_user_id;

    IF user_age >= 18 THEN
        SELECT 'Adult' AS user_status;
    ELSE
        SELECT 'Minor' AS user_status;
    END IF;

END;

DELIMITER ;


CALL CheckUserAge(1);


-- 11. Procedure to Insert Data
-- -------------------------------------
-- Procedures can also perform INSERT,
-- UPDATE and DELETE operations.


DROP PROCEDURE IF EXISTS AddUser;

DELIMITER //

CREATE PROCEDURE AddUser(
    IN p_name VARCHAR(100),
    IN p_age INT
)
BEGIN

    INSERT INTO users(name, age)
    VALUES (p_name, p_age);

END;

DELIMITER ;


CALL AddUser('Rahul', 25);


SELECT * FROM users;


-- 12. Procedure to Update Data
-- -------------------------------------

DROP PROCEDURE IF EXISTS UpdateUserAge;

DELIMITER //

CREATE PROCEDURE UpdateUserAge(
    IN p_user_id INT,
    IN p_new_age INT
)
BEGIN

    UPDATE users
    SET age = p_new_age
    WHERE id = p_user_id;

END //

DELIMITER ;


CALL UpdateUserAge(1, 30);

SELECT * FROM users;


-- 13. Procedure to Delete Data
-- -------------------------------------

DROP PROCEDURE IF EXISTS DeleteUser;

DELIMITER //

CREATE PROCEDURE DeleteUser(IN p_user_id INT)
BEGIN

    DELETE FROM users
    WHERE id = p_user_id;

END //

DELIMITER ;


-- Example:
CALL DeleteUser(5);

SELECT * FROM users;


-- Types of Parameters
-- -------------------------------------

-- IN
-- -------------------------------------
-- Passes a value into the procedure.
--
-- The procedure can read the value.
--
-- Example:
-- CREATE PROCEDURE GetUser(IN p_id INT)


-- OUT
-- -------------------------------------
-- Returns a value from the procedure.
--
-- Example:
-- CREATE PROCEDURE GetUserCount(OUT p_count INT)


-- INOUT
-- -------------------------------------
-- Accepts a value, modifies it,
-- and returns the modified value.
--
-- Example:
-- CREATE PROCEDURE IncreaseValue(INOUT p_num INT)





-- Example: Bank money transfer
-- -------------------------------------

-- We’ll use two tables:

-- accounts — stores account balances
-- transactions — records every transfer

-- The stored procedure will:
-- Start a transaction
-- Check both accounts
-- Deduct money from sender
-- Add money to receiver
-- Insert a transaction record
-- Commit everything
-- Roll back everything if an error occurs



-- Create database
CREATE DATABASE IF NOT EXISTS bank_demo;
USE bank_demo;


-- 1. Accounts table
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    balance DECIMAL(10,2) NOT NULL
);


-- 2. Transactions table
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account INT NOT NULL,
    to_account INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Sample accounts
INSERT INTO accounts (account_id, customer_name, balance)
VALUES
    (1, 'Rahul', 1000.00),
    (2, 'Amit', 500.00);




DROP PROCEDURE IF EXISTS transfer_money;


DELIMITER //

CREATE PROCEDURE transfer_money(
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(10,2)
)
BEGIN

    DECLARE v_balance DECIMAL(10,2);

    -- If any SQL error occurs, rollback the transaction
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;


    -- Start transaction
    START TRANSACTION;


    -- Get sender's balance
    SELECT balance
    INTO v_balance
    FROM accounts
    WHERE account_id = p_from_account
    FOR UPDATE;


    -- Check sufficient balance
    IF v_balance < p_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;


    -- 1. Deduct money from sender
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account;


    -- 2. Add money to receiver
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account;


    -- 3. Record transaction
    INSERT INTO transactions (
        from_account,
        to_account,
        amount
    )
    VALUES (
        p_from_account,
        p_to_account,
        p_amount
    );


    -- Everything succeeded
    COMMIT;

END //

DELIMITER ;


SELECT * FROM accounts;
SELECT * FROM transactions;

-- CALL transfer_money(1, 2, 200.00);
CALL transfer_money(1, 2, 2000.00);

SELECT* FROM accounts;
SELECT * FROM transactions;



-- -------------------------------------
-- Procedure vs Function
-- -------------------------------------

-- Stored Procedure:
-- - Called using CALL.
-- - Can return multiple result sets.
-- - Can use IN, OUT and INOUT parameters.
-- - Can perform INSERT, UPDATE and DELETE.
-- - Does not have to return a value.
--
-- Function:
-- - Returns exactly one value.
-- - Can be used inside SELECT expressions.
-- - Called directly by its function name.
-- - Commonly used for calculations
--   or reusable value-returning logic.


-- Procedure:
CALL GetUserById(1);


-- Function:
-- SELECT AddNumbers(5, 7);


-- -------------------------------------
-- Important DELIMITER Concept
-- -------------------------------------

-- MySQL normally uses ; to end a statement.
--
-- But a procedure contains multiple statements,
-- each ending with ;.
--
-- Therefore, temporarily change the delimiter.
--
-- DELIMITER //
--
-- CREATE PROCEDURE ...
-- BEGIN
--     SELECT ...;
--     UPDATE ...;
-- END //
--
-- DELIMITER ;


-- -------------------------------------
-- Important Points
-- -------------------------------------

-- 1. CREATE PROCEDURE creates a procedure.
-- 2. CALL executes a procedure.
-- 3. DROP PROCEDURE removes a procedure.
-- 4. IN receives input.
-- 5. OUT returns output.
-- 6. INOUT receives and returns a value.
-- 7. DECLARE creates local variables.
-- 8. Procedures can contain:
--    SELECT
--    INSERT
--    UPDATE
--    DELETE
--    IF / ELSE
--    CASE
--    loops
--    variables
--
-- 9. A procedure can return multiple
--    result sets.
-- 10. Procedures are useful for reusable
--     database operations and business logic.


-- -------------------------------------
-- TODO Task
-- -------------------------------------

-- 1. Create a procedure GetUsersByCity()
--    that accepts a city and returns
--    all users from that city.
--
-- 2. Create a procedure GetUsersInAgeRange()
--    that accepts minimum and maximum age.
--
-- 3. Create a procedure GetUserCount()
--    using an OUT parameter.
--
-- 4. Create a procedure IncreaseUserAge()
--    using an INOUT parameter.
--
-- 5. Create a procedure AddUser()
--    that accepts name and age and
--    inserts a new user.
--
-- 6. Create a procedure CheckUserAge()
--    using IF / ELSE:
--
--    age >= 18 -> 'Adult'
--    age < 18  -> 'Minor'
--
-- 7. Display all procedures in the
--    current database.
--
-- 8. Drop one procedure using:
--    DROP PROCEDURE IF EXISTS procedure_name;