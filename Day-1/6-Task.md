# Lab Exercise: MySQL DDL + DML (Banking Domain)
-----------------------------------------------

**Objective**:

Create a simple Banking Database:
- CREATE DATABASE
- CREATE TABLE
- INSERT
- SELECT (for verification)



## Business Scenario
-------------------------

You are working as a Database Developer for a bank.

The bank wants to store:
- Customer details
- Account details
- Basic transaction records

You need to design and populate the database.

### Task 1: Create Database
------------------------------

Create a database named: BankingSystem


- Verify that the database is created.
- Select the database for use.

### Task 2: Create Tables
-------------------------------

You must create the following tables.

#### Table 1: Customers

Create a table named Customers with the following columns:

| Column Name | Data Type    | Constraints                 |
| ----------- | ------------ | --------------------------- |
| CustomerID  | Integer      | Primary Key, Auto Increment |
| FirstName   | VARCHAR(50)  | NOT NULL                    |
| LastName    | VARCHAR(50)  | NOT NULL                    |
| Email       | VARCHAR(100) | UNIQUE                      |
| Phone       | VARCHAR(15)  |                             |
| City        | VARCHAR(50)  |                             |
| CreatedDate | DATETIME     | DEFAULT CURRENT_TIMESTAMP   |



After creating: Verify structure using DESCRIBE.

---

#### Table 2: Accounts

Create a table named Accounts with:

| Column Name | Data Type     | Constraints                 |
| ----------- | ------------- | --------------------------- |
| AccountID   | Integer       | Primary Key, Auto Increment |
| CustomerID  | Integer       | Foreign Key                 |
| AccountType | VARCHAR(20)   | NOT NULL                    |
| Balance     | DECIMAL(12,2) | NOT NULL                    |
| CreatedDate | DATETIME      | DEFAULT CURRENT_TIMESTAMP   |


> Constraint: CustomerID should reference Customers(CustomerID)

Verify the table structure.


---

#### Table 3: Transactions

Create a table named Transactions with:

| Column Name     | Data Type     | Constraints                 |
| --------------- | ------------- | --------------------------- |
| TransactionID   | Integer       | Primary Key, Auto Increment |
| AccountID       | Integer       | Foreign Key                 |
| TransactionType | VARCHAR(20)   | NOT NULL                    |
| Amount          | DECIMAL(12,2) | NOT NULL                    |
| TransactionDate | DATETIME      | DEFAULT CURRENT_TIMESTAMP   |


> Constraint: AccountID should reference Accounts(AccountID)

Verify the structure.


---

#### Task 3: Insert Data

Insert the following:

- Customers: Insert at least 3 customers.
- Accounts: Insert at least:
  - One Savings account
  - One Current account

> Ensure accounts are linked to existing customers

- Transactions: Insert at least:
  - 2 deposits
  - 1 withdrawal

---

#### Task 4: Verify Data

Write queries to verify:
- All customers are inserted.
- All accounts are inserted.
- All transactions are inserted.

