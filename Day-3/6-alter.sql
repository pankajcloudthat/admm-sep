-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@retail_schema_demo


-- Modifying Tables
-- -------------------------------------
-- Domain: Retail / E-commerce
--
-- Table structure may need to be changed
-- after the table has already been created.
--
-- ALTER TABLE is used to modify the structure
-- of an existing table.
--
-- Common operations:
-- 1. ADD COLUMN
-- 2. MODIFY COLUMN
-- 3. CHANGE COLUMN
-- 4. DROP COLUMN
-- 5. RENAME TABLE
-- 6. DROP TABLE


-- 1. Create Sample Table
-- -------------------------------------

DROP DATABASE IF EXISTS retail_schema_demo;

CREATE DATABASE retail_schema_demo;

USE retail_schema_demo;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2)
);


INSERT INTO products
(product_name, category, price)
VALUES
('Laptop', 'Electronics', 65000.00),
('Headphones', 'Electronics', 2500.00),
('Office Chair', 'Furniture', 12000.00);


SELECT * FROM products;


-- 2. ADD COLUMN
-- -------------------------------------
-- Add a new column to an existing table.

ALTER TABLE products
ADD COLUMN stock_quantity INT;


-- Add another column.

ALTER TABLE products
ADD COLUMN brand VARCHAR(50);


SELECT * FROM products;


-- 3. ADD COLUMN with DEFAULT
-- -------------------------------------
-- Add a column and give existing/new rows
-- a default value.

ALTER TABLE products
ADD COLUMN status VARCHAR(20) DEFAULT 'Active';


SELECT * FROM products;


-- 4. ADD Multiple Columns
-- -------------------------------------

ALTER TABLE products
ADD COLUMN supplier_name VARCHAR(100),
ADD COLUMN warranty_months INT;


SELECT * FROM products;


-- 5. MODIFY COLUMN
-- -------------------------------------
-- Change the data type or properties
-- of an existing column.
--
-- Example:
-- Increase product_name size.

ALTER TABLE products
MODIFY COLUMN product_name VARCHAR(150) NOT NULL;


DESC products;

-- 6. CHANGE COLUMN
-- -------------------------------------
-- CHANGE can rename a column and also
-- modify its definition.
--
-- Syntax:
-- ALTER TABLE table_name
-- CHANGE old_name new_name data_type;


ALTER TABLE products
CHANGE COLUMN brand brand_name VARCHAR(100);


DESC products;


-- 7. DROP COLUMN
-- -------------------------------------
-- Permanently remove a column
-- from the table.

ALTER TABLE products
DROP COLUMN warranty_months;


SELECT * FROM products;


-- 8. Rename Table
-- -------------------------------------
-- Change the table name.

RENAME TABLE products TO retail_products;


SELECT * FROM retail_products;


-- 9. ALTER TABLE Rename Table
-- -------------------------------------
-- Another way to rename a table.

ALTER TABLE retail_products
RENAME TO products;


SELECT * FROM products;


-- 10. DROP TABLE
-- -------------------------------------
-- Permanently delete the table,
-- including its data and structure.

DROP TABLE products;


-- The table no longer exists.
-- SELECT * FROM products;
-- This will generate an error.


-- 11. DROP TABLE IF EXISTS
-- -------------------------------------
-- Safer way to remove a table.
--
-- If the table does not exist,
-- no error is generated.

DROP TABLE IF EXISTS products;


-- 12. Check Table Structure
-- -------------------------------------
-- DESCRIBE shows the current structure
-- of a table.

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2)
);

DESCRIBE products;


-- SHOW CREATE TABLE displays the complete
-- CREATE TABLE definition.

SHOW CREATE TABLE products;


-- Important Difference
-- -------------------------------------

-- ALTER TABLE
-- -> Modifies the structure of an existing table.
--
-- ADD COLUMN
-- -> Adds a new column.
--
-- MODIFY COLUMN
-- -> Changes a column's data type/properties.
--
-- CHANGE COLUMN
-- -> Renames a column and can change its definition.
--
-- DROP COLUMN
-- -> Removes a column permanently.
--
-- RENAME TABLE
-- -> Changes the table name.
--
-- DROP TABLE
-- -> Deletes the complete table and its data.





-- 13. Modifying Primary Key
-- -------------------------------------
-- A Primary Key uniquely identifies
-- each record in a table.
--
-- ALTER TABLE can be used to:
-- 1. Add a Primary Key
-- 2. Drop a Primary Key


-- Create a table without a Primary Key.

CREATE TABLE categories (
    category_id INT,
    category_name VARCHAR(50)
);


-- Add Primary Key.

ALTER TABLE categories
ADD PRIMARY KEY (category_id);


DESCRIBE categories;


-- 14. Drop Primary Key
-- -------------------------------------
-- Remove the Primary Key constraint.

ALTER TABLE categories
DROP PRIMARY KEY;


DESCRIBE categories;


-- Add the Primary Key again.

ALTER TABLE categories
ADD PRIMARY KEY (category_id);


-- 15. Modifying Foreign Key
-- -------------------------------------
-- A Foreign Key creates a relationship
-- between two tables.
--
-- Parent Table
--     |
--     | Primary Key
--     ↓
-- Child Table
--     |
--     | Foreign Key


-- Create parent table.

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);


-- Create child table.

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_amount DECIMAL(10,2)
);


-- Add Foreign Key after table creation.

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- 16. Verify Foreign Key
-- -------------------------------------

SHOW CREATE TABLE orders;


-- 17. Drop Foreign Key
-- -------------------------------------
-- Foreign Key must be removed using
-- its constraint name.

ALTER TABLE orders
DROP FOREIGN KEY fk_orders_customer;


-- 18. Add Foreign Key Again
-- -------------------------------------

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- 19. Foreign Key with ON DELETE
-- -------------------------------------
-- Define what happens to child records
-- when the parent record is deleted.


ALTER TABLE orders
DROP FOREIGN KEY fk_orders_customer;


ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON DELETE CASCADE;


-- If a customer is deleted,
-- their related orders will also be deleted.


-- 20. Foreign Key with ON UPDATE
-- -------------------------------------
-- Define what happens when the parent
-- Primary Key value is updated.

ALTER TABLE orders
DROP FOREIGN KEY fk_orders_customer;


ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON DELETE CASCADE
ON UPDATE CASCADE;


-- Important Points
-- -------------------------------------

-- Primary Key:
-- ADD PRIMARY KEY (column_name)
-- DROP PRIMARY KEY
--
-- Foreign Key:
-- ADD CONSTRAINT constraint_name
-- FOREIGN KEY (column_name)
-- REFERENCES parent_table(parent_column)
--
-- Remove Foreign Key:
-- DROP FOREIGN KEY constraint_name
--
-- ON DELETE CASCADE:
-- Delete child records automatically
-- when the parent record is deleted.
--
-- ON UPDATE CASCADE:
-- Update child Foreign Key values
-- when the parent Primary Key changes.




-- TODO Task
-- -------------------------------------

-- Create a table named customers with:
-- customer_id, customer_name, email, city.
--
-- 1. Add a phone column.
-- 2. Add an account_status column
--    with default value 'Active'.
-- 3. Increase customer_name to VARCHAR(100).
-- 4. Rename city to customer_city.
-- 5. Add a registration_source column.
-- 6. Remove registration_source.
-- 7. Rename customers to retail_customers.
-- 8. Display the final table structure.



-- TODO Task
-- -------------------------------------

-- 1. Create a suppliers table with:
--    supplier_id
--    supplier_name
--
-- 2. Create a products table with:
--    product_id
--    product_name
--    supplier_id
--
-- 3. Add the Primary Key to suppliers.
-- 4. Add the Primary Key to products.
-- 5. Add supplier_id as a Foreign Key
--    referencing suppliers.
-- 6. Verify the Foreign Key using
--    SHOW CREATE TABLE.
-- 7. Remove the Foreign Key.
-- 8. Add the Foreign Key again with
--    ON DELETE CASCADE.