-- SQLBook: Code

-- Recursive CTE
-- -------------------------------------

-- A Recursive CTE is a CTE that refers to itself.
--
-- It is useful when data has a hierarchical relationship,
-- such as:
--
-- Employee -> Manager
-- Category -> Subcategory
-- Employee -> Department Head
-- Parent Account -> Child Account
-- Folder -> Subfolder
--
-- A recursive CTE repeatedly executes the CTE
-- using the result from the previous iteration.


-- Basic Structure
-- -------------------------------------

-- WITH RECURSIVE cte_name AS (
--
--     -- Anchor Query
--     -- Starting point
--
--     SELECT ...
--
--     UNION ALL
--
--     -- Recursive Query
--     -- Refers back to the CTE
--
--     SELECT ...
--     FROM cte_name
--     JOIN ...
--
-- )
-- SELECT *
-- FROM cte_name;


-- Recursive CTE has two important parts:
--
-- 1. Anchor Query
--    Defines where the recursion starts.
--
-- 2. Recursive Query
--    Finds the next level using the previous result.
--
-- The recursion stops when the recursive query
-- no longer produces new rows.


-- Business Scenario
-- -------------------------------------

-- A retail company has employees organized
-- in a management hierarchy.
--
-- Example:
--
-- CEO
--  |
--  +-- Store Manager
--       |
--       +-- Sales Manager
--            |
--            +-- Sales Executive
--
-- We want to display the complete hierarchy
-- starting from the CEO.


-- Create Employee Table
-- -------------------------------------

DROP TABLE IF EXISTS employees;


CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    manager_id INT NULL
);


-- Insert Employee Data
-- -------------------------------------

INSERT INTO employees
(employee_id, employee_name, manager_id)
VALUES
(1, 'Raj Malhotra', NULL),
(2, 'Priya Sharma', 1),
(3, 'Amit Kumar', 1),
(4, 'Neha Singh', 2),
(5, 'Ravi Patel', 2),
(6, 'Sneha Gupta', 3),
(7, 'Vikas Shah', 4);


SELECT * FROM employees;


-- Understanding the Hierarchy
-- -------------------------------------

-- Raj Malhotra
--     |
--     +-- Priya Sharma
--     |      |
--     |      +-- Neha Singh
--     |             |
--     |             +-- Vikas Shah
--     |
--     +-- Amit Kumar
--            |
--            +-- Sneha Gupta
--


-- Simple Recursive CTE
-- -------------------------------------

WITH RECURSIVE employee_hierarchy AS (
    -- Anchor Query
    -- ---------------------------------
    -- Start with the top-level employee.
    --
    -- Raj has no manager.
    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS hierarchy_level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL
    -- Recursive Query
    -- ---------------------------------
    -- Find employees whose manager
    -- is already present in the CTE.
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        eh.hierarchy_level + 1

    FROM employees e
    JOIN employee_hierarchy eh
        ON e.manager_id = eh.employee_id

)

SELECT
    employee_id,
    employee_name,
    manager_id,
    hierarchy_level

FROM employee_hierarchy
ORDER BY hierarchy_level, employee_id;



-- Display Hierarchy as Tree
-- -------------------------------------

-- We can use the hierarchy level
-- to visually represent the organization.


WITH RECURSIVE employee_hierarchy AS (

    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS hierarchy_level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        eh.hierarchy_level + 1
    FROM employees e
    JOIN employee_hierarchy eh
        ON e.manager_id = eh.employee_id
)

SELECT
    employee_id,
    CONCAT(
        REPEAT('    ', hierarchy_level),
        '-> ',
        employee_name
    ) AS employee_hierarchy,
    hierarchy_level
FROM employee_hierarchy
ORDER BY employee_id;


-- Find All Employees Under One Manager
-- -------------------------------------

-- Business Question:
--
-- Find everyone who reports directly or indirectly
-- to Priya Sharma (employee_id = 2).


WITH RECURSIVE employee_hierarchy AS (

    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS hierarchy_level
    FROM employees
    WHERE employee_id = 2

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        eh.hierarchy_level + 1
    FROM employees e
    JOIN employee_hierarchy eh
        ON e.manager_id = eh.employee_id
)

SELECT
    employee_id,
    employee_name,
    hierarchy_level
FROM employee_hierarchy
ORDER BY hierarchy_level;



-- Find the Management Chain
-- -------------------------------------

-- Business Question:
--
-- Who are the managers above Vikas Shah?


WITH RECURSIVE management_chain AS (

    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS hierarchy_level
    FROM employees
    WHERE employee_id = 7

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        mc.hierarchy_level + 1
    FROM employees e
    JOIN management_chain mc
        ON e.employee_id = mc.manager_id
)

SELECT
    employee_id,
    employee_name,
    hierarchy_level

FROM management_chain
ORDER BY hierarchy_level;




-- Recursive CTE with Path
-- -------------------------------------

-- We can also build the complete
-- management path.


WITH RECURSIVE employee_hierarchy AS (

    SELECT
        employee_id,
        employee_name,
        manager_id,
        employee_name AS management_path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,

        CONCAT(
            eh.management_path,
            ' -> ',
            e.employee_name
        )

    FROM employees e
    JOIN employee_hierarchy eh
        ON e.manager_id = eh.employee_id

)

SELECT
    employee_id,
    employee_name,
    management_path
FROM employee_hierarchy
ORDER BY employee_id;


-- Recursive CTE vs Normal CTE
-- -------------------------------------

-- Normal CTE:
-- WITH customer_sales AS (...)
-- The CTE does NOT refer to itself.

-- Recursive CTE:
-- WITH RECURSIVE employee_hierarchy AS (...)
-- The CTE refers to itself to process
-- multiple levels of data.


-- Important Points
-- -------------------------------------

-- 1. Use the RECURSIVE keyword.
-- 2. The Anchor Query defines the starting point.
-- 3. UNION ALL connects the anchor and recursive query.
-- 4. The recursive query refers back to the CTE.
-- 5. Recursion continues until no more matching rows are found.
-- 6. Recursive CTEs are useful for hierarchical data.








-- TODO Task
-- -------------------------------------

-- Healthcare Patient Referral Data
-- -------------------------------------

CREATE DATABASE healthcare;

USE healthcare;


-- Create Referral Table
-- -------------------------------------

DROP TABLE IF EXISTS patient_referrals;

CREATE TABLE patient_referrals (
    referral_id INT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    referred_by INT NULL,
    referral_reason VARCHAR(100) NOT NULL
);


-- Insert Sample Data
-- -------------------------------------

INSERT INTO patient_referrals
(referral_id, patient_name, referred_by, referral_reason)
VALUES
(1, 'Rahul Sharma', NULL, 'General Consultation'),
(2, 'Priya Verma', NULL, 'General Consultation'),
(3, 'Amit Kumar', NULL, 'General Consultation'),
(4, 'Rahul Sharma', 1, 'Cardiology'),
(5, 'Rahul Sharma', 1, 'Diabetes Specialist'),
(6, 'Priya Verma', 2, 'Neurology'),
(7, 'Amit Kumar', 3, 'Orthopedics'),
(8, 'Rahul Sharma', 4, 'Cardiac Surgery'),
(9, 'Rahul Sharma', 5, 'Endocrinology'),
(10, 'Priya Verma', 6, 'Neurosurgery'),
(11, 'Amit Kumar', 7, 'Physiotherapy'),
(12, 'Rahul Sharma', 8, 'Cardiac Rehabilitation'),
(13, 'Priya Verma', 10, 'Neurological Rehabilitation'),
(14, 'Amit Kumar', 11, 'Sports Rehabilitation');


-- View Data
-- -------------------------------------

SELECT *
FROM patient_referrals
ORDER BY referral_id;


-- TODO Task
-- -------------------------------------
-- A hospital wants to analyze patient referrals.

-- 1. Use a Recursive CTE to display all referral records
--    along with their referral level.
-- 2. Display the complete referral path for each patient.
-- 3. Find all referrals that are at Level 2 or deeper.
-- 4. Find the deepest referral chain for each patient.
-- 5. Find the maximum referral level in the hospital.


