-- SQLBook: Code
-- Active: 1788178851148@@127.0.0.1@3306@demo


-- Primary Key
-- --------------

-- A Primary Key (PK) is a column (or combination of columns) that uniquely identifies each row in a table.

-- Rules:
-- Must be unique
-- Cannot be NULL
-- Only one primary key per table

DROP DATABASE IF EXISTS demo;

CREATE DATABASE demo;

use demo;


CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);




-- Foreign Key
-- -------------

-- A Foreign Key (FK) is a column in one table that refers to the Primary Key of another table.
-- It creates a relationship between tables.

CREATE TABLE course (
    course_id INT PRIMARY KEY,
    student_id INT,
    course_name VARCHAR(100),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);


INSERT INTO
course
VALUES (1, 101, "SQL")


INSERT INTO
students
VALUES (101, "Ravi", "ravi@email.com");


-- What is ON DELETE?
-- ---------------------------
-- When you delete a row in the parent table, what should happen to related rows in the child table?
-- That’s where ON DELETE rules come in.


DELETE FROM students WHERE student_id = 101;


-- ON DELETE CASCADE
-- --------------------
-- If parent is deleted → child rows are automatically deleted.

-- Example:
-- FOREIGN KEY (student_id)
-- REFERENCES Students(student_id)
-- ON DELETE CASCADE

DROP TABLE course;
DROP TABLE IF EXISTS students;


CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE course (
    order_id INT PRIMARY KEY,
    student_id INT,
    course_name VARCHAR(100),
    FOREIGN KEY (student_id) 
        REFERENCES Students(student_id)
        ON DELETE CASCADE
);



INSERT INTO Students VALUES 
(1, 'Aisha', 'aisha@email.com'),
(2, 'Rahul', 'rahul@email.com');

INSERT INTO course VALUES 
(101, 1, 'SQL'),
(102, 1, 'Python'),
(103, 2, 'Java');


SELECT * FROM students;

SELECT * FRom course;

DELETE FROM Students WHERE student_id = 1;

SELECT * FRom course;



-- ON DELETE SET NULL
-- ----------------------
-- If parent is deleted → foreign key becomes NULL.

-- Example:
-- FOREIGN KEY (student_id)
-- REFERENCES Students(student_id)
-- ON DELETE SET NULL



CREATE TABLE IF NOT EXISTS Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

DROP TABLE course;
CREATE TABLE course (
    order_id INT PRIMARY KEY,
    student_id INT NULL,
    course_name VARCHAR(100),
    FOREIGN KEY (student_id) 
        REFERENCES Students(student_id)
        ON DELETE SET NULL
);

INSERT INTO Students VALUES 
(1, 'Aisha', 'aisha@email.com');

INSERT INTO course VALUES 
(101, 1, 'SQL'),
(102, 1, 'Python'),
(103, 2, 'Java');


SELECT * FROM course;

DELETE FROM Students WHERE student_id = 1;

SELECT * FROM course;




-- ON DELETE RESTRICT
-- --------------------------
-- Prevents deletion if child records exist.

-- Example:
-- FOREIGN KEY (student_id)
-- REFERENCES Students(student_id)
-- ON DELETE RESTRICT


CREATE TABLE IF NOT EXISTS Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

DROP TABLE course;
CREATE TABLE course (
    order_id INT PRIMARY KEY,
    student_id INT,
    course_name VARCHAR(100),
    FOREIGN KEY (student_id) 
        REFERENCES Students(student_id)
        ON DELETE RESTRICT
);

INSERT INTO Students VALUES 
(1, 'Aisha', 'aisha@email.com');

INSERT INTO course VALUES 
(101, 1, 'SQL'),
(102, 1, 'Python'),
(103, 2, 'Java');


-- Cannot delete or update a parent row: a foreign key constraint fails.
DELETE FROM Students WHERE student_id = 1;


-- You must first delete child rows:
DELETE FROM course WHERE student_id = 2;
DELETE FROM Students WHERE student_id = 2;

SELECT * FROM course;
SELECT* FROM students;
