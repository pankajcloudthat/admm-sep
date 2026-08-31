-- Active: 1770471809351@@127.0.0.1@3306@ecommerce

-- Filtering data using operators
-- --------------------------------

DROP DATABASE IF EXISTS ecommerce;

CREATE DATABASE ecommerce;
Use ecommerce;

SHOW TABLEs;


Drop Table if exists users;
CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  middle_name VARCHAR(50) NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  age TINYINT UNSIGNED NOT NULL,
  first_paid_at TIMESTAMP
);

INSERT INTO users(first_name, middle_name, last_name, email, age) VALUES
('John', 'Michael', 'Smith', 'johnsmith@gmail.com', 25),
('Jane', 'Elizabeth', 'Doe', 'janedoe@Gmail.com', 28),
('Xavier', NULL, 'Wills', 'xavier@wills.io', 35),
('Bev', NULL, 'Scott', 'bev@bevscott.com', 16),
('Bree', 'Marie', 'Jensen', 'bjensen@corp.net', 42),
('John', 'Robert', 'Jacobs', 'jjacobs@corp.net', 56),
('Rick', NULL, 'Fullman', 'fullman@hotmail.com', 16);

SELECT * FROm users; 


-- Logical operators (AND / OR / NOT)
-------------------------------------

-- Using AND
-- Returns rows where all conditions are true.

-- Example: Users older than 28 and named John
SELECT * FROM users
WHERE age > 28 AND first_name = 'John';

-- Example: Users with first name John and last name Smith
SELECT *
FROM users
WHERE first_name = 'John'
  AND last_name = 'Smith';


-- OR: Returns rows where at least one condition is true.
SELECT *
FROM users
WHERE first_name = 'John'
  OR last_name = 'Doe';

-- AND and OR
SELECT *
FROM users
WHERE
(
  first_name = 'John'
  AND last_name = 'Smith'
)
OR last_name = 'Doe';



-- NOT: Reverses a condition
SELECT *
FROM users
WHERE NOT age = 25;


SELECT *
FROM users
WHERE NOT
(
  (
    first_name = 'John'
    AND last_name = 'Smith'
  )
  OR last_name = 'Doe'
);



-- Comparison operators (=, <, >, <=, >=)
------------------------------------------

-- Equal To =
SELECT * FROM users
WHERE first_name = 'John';


-- Not Equal != or <>
SELECT * FROM users
WHERE age != 25;


-- Greater Than > & >=
SELECT * FROM users WHERE age > 28;
SELECT * FROM users WHERE age >= 28;

-- select users with age between 25 and 35
SELECT * FROM users WHERE age > 25 AND age <= 35;


-- BETWEEN (Range Comparison)
SELECT * FROM users WHERE age BETWEEN 25 AND 35;

-- Equivalent to:
SELECT * FROM users
WHERE age >= 25 AND age <= 35;


-- Like: LIKE is used for pattern matching in strings.
-----------------------------------------------------
-- Example:
-- SELECT column_name
-- FROM table_name
-- WHERE column_name LIKE pattern;

-- LIKE is case-insensitive (usually)

-- Wildcards Used with LIKE
-- | Wildcard | Meaning                              |
-- | -------- | ------------------------------------ |
-- | `%`      | Any number of characters (0 or more) |
-- | `_`      | Exactly one character                |


-- Names starting with "J"
SELECT * 
FROM users
WHERE first_name LIKE 'J%';

-- Names containing "i"
SELECT * 
FROM users
WHERE first_name LIKE '%i%';


-- Exactly 4-letter names
SELECT *
FROM users
WHERE first_name LIKE '___';


-- Email domain search
SELECT *
FROM users
WHERE email LIKE '%@gmail.com';


SELECT * FROM users WHERE email LIKE '%j%o%';


-- Arithmetic operators (+, -, *, /, %)
------------------------------------------

-- | Operator | Meaning             |
-- | -------- | ------------------- |
-- | `+`      | Addition            |
-- | `-`      | Subtraction         |
-- | `*`      | Multiplication      |
-- | `/`      | Division            |
-- | `%`      | Modulus (remainder) |


-- Example: Calculate half of their age
SELECT *, age / 2 AS half_of_their_age
FROM users;

-- Example: Calculate age after 5 years
SELECT first_name, age, age + 5 AS age_after_5_years
FROM users;


-- Show how many years until user turns 60:
SELECT first_name, age, 60 - age AS years_until_60
FROM users;


-- Show double of their age:
SELECT first_name, age, age * 2 AS double_age
FROM users;

-- Modulus operator: Show users with even age
SELECT first_name, age FROM users WHERE (age % 2) = 0;

-- Show users with odd age
SELECT first_name, age FROM users WHERE (age % 2) <> 0;


-- Arithmetic in WHERE
SELECT first_name, age FROM users
WHERE (age + 5) > 30;


-- Multiple Value Comparison operators (IN / NOT IN)
----------------------------------------------------

-- IN checks if a value matches any value in a list.
-- IN (Multiple Value Comparison)
SELECT * FROM users
WHERE first_name IN ('John', 'Jane', 'Mike');

-- Equivalent to:
SELECT * FROM users
WHERE first_name = 'John'
   OR first_name = 'Jane'
   OR first_name = 'Mike';


-- Filter by age group
SELECT * FROM users
WHERE age IN (16, 25, 28);


-- NOT IN: Opposite of IN.

SELECT *
FROM users
WHERE first_name NOT IN ('John', 'Jane', 'Rick');




-- Working with NULL Values
--------------------------------------

-- What is NULL in SQL?
-- NULL means: No value exists.

-- It does NOT mean: 0, Empty string '', False
-- It literally means unknown / missing / not stored.

-- Example:
-- | id | name | middle_name |
-- | -- | ---- | ----------- |
-- | 1  | John | NULL        |

-- John doesn’t have a middle name stored. It’s not empty — it’s unknown.


SELECT
  1 = 1,
  1 = 2;

-- Important: NULL behaves differently
-- You cannot compare NULL with =
SELECT 1 = NULL;
-- Null display is "NULL".


SELECT NULL = NULL;

-- This will NOT work:
SELECT * FROM users
WHERE middle_name = NULL;

-- Instead use IS NULL or IS NOT NULL
SELECT
  NULL IS NULL,
  NULL IS NOT NULL; 


SELECT * FROM users
WHERE middle_name IS NULL


DESC users;

SELECT * FROM users;

SELECT NOW();

UPDATE users SET first_paid_at = NOW() WHERE id = 1;

UPDATE users SET first_paid_at = (NOW() - INTERVAL 1 MONTH) WHERE id = 2;

UPDATE users SET first_paid_at = (NOW() - INTERVAL 1 YEAR) WHERE id in (3, 5, 6);
UPDATE users SET first_paid_at = (NOW() - INTERVAL 3 DAY) WHERE id = 4;



SELECT *
FROM users
WHERE first_paid_at IS NULL;



SELECT * FROM users



-- Comparison operators with dates and times
-----------------------------------------------

SELECT *
FROM users
WHERE first_paid_at < NOW() - INTERVAL 3 DAY;




SELECT *
FROM users
WHERE first_paid_at < (NOW());




SELECT *
FROM users
WHERE  age BETWEEN 25 AND 35;




-- Existence using EXISTS / NOT EXISTS
------------------------------------------
-- What is EXISTS?
-- EXISTS checks whether a subquery returns at least one row.

-- If the subquery returns even 1 row → TRUE
-- If it returns 0 rows → FALSE

-- It does NOT care about the actual values — only whether rows exist.


CREATE TABLE posts(
  id SERIAL PRIMARY KEY,
  body TEXT NOT NULL,
  user_id INTEGER REFERENCES users
);



INSERT INTO posts(body, user_id) VALUES
('Here is post 1', 1),
('Here is post 2', 1),
('Here is post 3', 2),
('Here is post 4', 3);



-- EXISTS: Find users who have at least one post
-- This query returns all users that have created posts
SELECT *
FROM users
WHERE EXISTS (
  SELECT 1
  FROM posts
  WHERE posts.user_id = users.id
);

-- For each user:
-- MySQL checks the subquery.
-- If matching post exists → include user.


SELECT *
FROM users
WHERE NOT EXISTS (
  SELECT 1
  FROM posts
  WHERE posts.user_id = users.id
);




-- Alternate Way--
-- But not recommended way
SELECT *
FROM users
WHERE users.id IN (
  SELECT user_id
  FROM posts
);


-- EXISTS is better when:

-- ✔ Subquery returns large data
-- ✔ You are checking related rows
-- ✔ You need better performance in correlated subqueries

-- EXISTS stops checking once it finds one match.
-- IN compares full result set.


-- ------------------------
-- Bitwise operators
-- ------------------------

-- Bitwise operators work on binary representation (bits) of integers.
-- Computers store numbers in binary:
-- 5  →  0101
-- 3  →  0011

-- Bitwise Operators in MySQL
-- | Operator | Name        | Description             |                            |
-- | -------- | ----------- | ----------------------- | -------------------------- |
-- | `&`      | AND         | 1 if both bits are 1    |                            |
-- | `        | `           | OR                      | 1 if at least one bit is 1 |
-- | `^`      | XOR         | 1 if bits are different |                            |
-- | `~`      | NOT         | Inverts bits            |                            |
-- | `<<`     | Left Shift  | Shifts bits left        |                            |
-- | `>>`     | Right Shift | Shifts bits right       |                            |


-- Bitwise AND (&)
SELECT age & 11111111 FROM users;


SELECT age | 11111111 FROM users;    -- bitwise OR


SELECT age ^ 11111111 FROM users;    -- bitwise XOR



SELECT age << 1 FROM users;   -- bitwise shift left



SELECT age >> 1 FROM users;   -- bitwise shift right



SELECT ~age FROM users;