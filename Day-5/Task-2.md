
# Scenario: Finance — Banking Transaction & Customer Analytics

## Business Scenario

A bank wants to build a **Data Warehouse** to analyze customer accounts, transactions, loans, branches, and financial performance.

Currently, customer and transaction information is maintained across different operational systems.

Management wants a centralized Data Warehouse to analyze:

* Customer activity
* Account balances
* Deposits and withdrawals
* Loan performance
* Branch performance
* Transaction trends
* Customer segmentation

The Data Warehouse should allow management to analyze financial activities over time and across customers, accounts, branches, and transaction types.

### Business Requirements

Management wants to answer questions such as:

1. What is the total transaction amount per month?
2. What is the total deposit and withdrawal amount?
3. Which branch has the highest transaction volume?
4. Which customers have the highest account balances?
5. What is the average account balance by account type?
6. How many active customers does the bank have?
7. What is the total outstanding loan amount?
8. Which branch has the highest loan amount?
9. What is the monthly growth in deposits?
10. What percentage of transactions are deposits vs withdrawals?
11. Which customers perform the highest number of transactions?
12. What is the average loan amount by loan type?
13. Which loan types have the highest default rate?
14. What is the total interest earned from loans?

---

## Suggested Source Data

### Customer

| Column       | Description         |
| ------------ | ------------------- |
| CustomerID   | Unique customer     |
| CustomerName | Customer name       |
| Gender       | Gender              |
| DateOfBirth  | Date of birth       |
| City         | Customer city       |
| CustomerType | Individual/Business |

### Account

| Column      | Description          |
| ----------- | -------------------- |
| AccountID   | Unique account       |
| CustomerID  | Account owner        |
| AccountType | Savings/Current/etc. |
| BranchID    | Branch               |
| OpenDate    | Account opening date |
| Balance     | Current balance      |
| Status      | Active/Closed        |

### Transaction

| Column          | Description                 |
| --------------- | --------------------------- |
| TransactionID   | Unique transaction          |
| AccountID       | Account                     |
| TransactionDate | Transaction date            |
| TransactionType | Deposit/Withdrawal/Transfer |
| Amount          | Transaction amount          |
| Channel         | ATM/Online/Branch/Mobile    |
| Status          | Success/Failed              |

### Branch

| Column     | Description   |
| ---------- | ------------- |
| BranchID   | Unique branch |
| BranchName | Branch name   |
| City       | Branch city   |
| Region     | Branch region |

### Loan

| Column            | Description            |
| ----------------- | ---------------------- |
| LoanID            | Unique loan            |
| CustomerID        | Customer               |
| BranchID          | Branch                 |
| LoanType          | Home/Car/Personal/etc. |
| LoanAmount        | Original loan amount   |
| InterestRate      | Interest rate          |
| LoanDate          | Loan date              |
| OutstandingAmount | Outstanding amount     |
| LoanStatus        | Active/Closed/Default  |

---

# Task — Data Warehouse Design

You should design a **Star Schema** for banking analytics.

A possible central fact could be:

**FactTransaction**

**Grain:**

> One row represents **one financial transaction performed on one account on a specific date**.

Possible measures:

* TransactionAmount
* TransactionCount
* DepositAmount
* WithdrawalAmount

**Possible dimensions**:

* DimCustomer
* DimAccount
* DimBranch
* DimTransactionType
* DimChannel
* DimDate

You should decide whether **Loan** requires a separate fact table, such as:

**FactLoan**

A Data Warehouse can contain **multiple fact tables sharing common dimensions**.