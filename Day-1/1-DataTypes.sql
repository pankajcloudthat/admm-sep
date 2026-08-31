-- MySQL data types
-- -----------------

-- MySQL supports a number of SQL standard data types in various categories. 
-- MySQL has Numeric Types, the DATETIME, DATE, and TIMESTAMP Types and String Types. 
-- Note: Data types are discussed on this page are based on MySQL community server 5.6




-- MySQL Numeric Types
-- ----------------------------

-- MySQL supports all standard SQL numeric data types which include 
-- INTEGER, SMALLINT, DECIMAL, and NUMERIC. 
-- It also supports the approximate numeric data types (FLOAT, REAL, and DOUBLE PRECISION). 
-- The keyword INT is a synonym for INTEGER, and the keywords DEC and FIXED are synonyms for DECIMAL. 
-- DOUBLE is a synonym for DOUBLE PRECISION (a nonstandard extension). 
-- REAL is a synonym for DOUBLE PRECISION (a nonstandard variation) unless the REAL_AS_FLOAT SQL mode is enabled. 
-- The BIT data type stores bit-field values and is supported for MyISAM, MEMORY, InnoDB, and NDB tables.


-- Integer types
-- --------------------
-- SQL standard integer types INTEGER (or INT) and SMALLINT are supported by MySQL.
-- In MySQL, the INTEGER (or INT) data type is used to store whole numbers — meaning numbers with no decimal points.
-- As an extension to the standard, MySQL also supports the integer types TINYINT, MEDIUMINT, and BIGINT. 

-- Following table shows the required storage and range (maximum and minimum value for signed and 
-- unsigned integer) for each integer type.


-- | Type      | Bytes | Min (S)                    | Max (S)                   | Min (U) | Max (U)                    |
-- | --------- | ----- | -------------------------- | ------------------------- | ------- | -------------------------- |
-- | TINYINT   | 1     | -128                       | 127                       | 0       | 255                        |
-- | SMALLINT  | 2     | -32,768                    | 32,767                    | 0       | 65,535                     |
-- | MEDIUMINT | 3     | -8,388,608                 | 8,388,607                 | 0       | 16,777,215                 |
-- | INT       | 4     | -2,147,483,648             | 2,147,483,647             | 0       | 4,294,967,295              |
-- | BIGINT    | 8     | -9,223,372,036,854,775,808 | 9,223,372,036,854,775,807 | 0       | 18,446,744,073,709,551,615 |


-- ------------------------------------------------------------------------------


-- Floating-Point Types
-- -----------------------

-- Floating-point types are used to store numbers with decimal values.
-- The FLOAT and DOUBLE types represent approximate numeric data values. 
-- MySQL uses four bytes for single-precision values and eight bytes for double-precision values.

-- Types	Description
-- FLOAT(p)	A precision from 0 to 23 results in a four-byte single-precision FLOAT
-- FLOAT(p)	A precision from 24 to 53 results in an eight-byte double-precision DOUBLE

-- MySQL allows a nonstandard syntax: FLOAT(M,D) or REAL(M,D) or DOUBLE PRECISION(M,D). 
-- Here values can be stored up to M digits in total where D represents the decimal point. 
-- For example, a column defined as FLOAT(8,5) will look like -999.99999. 
-- MySQL performs rounding when storing values, so if you insert 999.00009 into a FLOAT(7,4) column, 
-- the approximate result is 999.0001.


-- | Type    | Bytes  | Precision  | Exact? |
-- | ------- | ------ | ---------- | ------ |
-- | FLOAT   | 4      | ~7 digits  | No     |
-- | DOUBLE  | 8      | ~15 digits | No     |
-- | DECIMAL | Varies | Exact      | Yes    |



-- Fixed-Point Types (DECIMAL)
-- ----------------------------

-- Fixed-Point data types are used to preserve exact precision, for example with currency data. 
-- In MySQL DECIMAL and NUMERIC types store exact numeric data values. MySQL 5.6 stores DECIMAL values in binary format.

-- In standard SQL the syntax DECIMAL(5,2)  (where 5 is the precision and 2 is the scale. ) 
-- be able to store any value with five digits and two decimals. Therefore the value range will be from -999.99 to 999.99. 
-- The syntax DECIMAL(M) is equivalent to DECIMAL(M,0). Similarly, the syntax DECIMAL is equivalent to DECIMAL(M,0). 
-- MySQL supports both of these variant forms of DECIMAL syntax. The default value of M is 10. 
-- If the scale is 0, DECIMAL values contain no decimal point or fractional part.



-- ------------------------------------------------------------------------------


-- Bit Value Types
-- -----------------

-- The BIT data type is used to store bit-field values. A type of BIT(N) enables storage of N-bit values. 
-- N can range from 1 to 64. Default is 1

-- To specify bit values, b'value' notation can be used. value is a binary value written using zeros and ones.
-- For example, b'111' and b'10000000' represent 7 and 128, respectively


-- Example:
-- INSERT INTO users (is_active) VALUES (b'1');

-- Important Difference: BIT vs BOOLEAN
-- BOOLEAN = TINYINT(1)

-- So:
-- BOOLEAN actually stores numbers (0 or 1)
-- BIT stores true binary data

-- | Type    | Range         | Storage      | Common Use        |
-- | ------- | ------------- | ------------ | ----------------- |
-- | BIT(1)  | 0 or 1        | 1 bit        | Boolean flags     |
-- | BIT(M)  | Up to 64 bits | Depends on M | Binary flags      |
-- | BOOLEAN | 0 or 1        | 1 byte       | True/False values |


-- ------------------------------------------------------------------------------

-- ------------------------------------------
-- DATETIME, DATE, and TIMESTAMP Types
-- ------------------------------------------


-- DATE	(3 bytes)
-- ---------------
-- Use when you need only date information.	
-- YYYY-MM-DD	'1000-01-01' to '9999-12-31'.

-- Use it when:

-- You only need the date
-- Birthdays
-- Holidays
-- Registration dates (no time needed)



-- DATETIME	(8 bytes)
-- -------------------
-- Use when you need values containing both date and time information.	
-- YYYY-MM-DD HH:MM:SS	'1000-01-01 00:00:00' to '9999-12-31 23:59:59'.

-- Important:
-- It does NOT depend on timezone.
-- It stores exactly what you insert.

-- Use it when:
-- Event schedules
-- Appointments
-- Logs where timezone conversion is NOT required



-- TIMESTAMP (4 bytes)
-- --------------------
-- Values are converted from the current time zone to UTC while storing and 
-- converted back from UTC to the current time zone when retrieved.	

-- YYYY-MM-DD HH:MM:SS	'1970-01-01 00:00:01' UTC to '2038-01-19 03:14:07' UTC


-- This is often used in:

-- Login systems
-- Audit logs
-- Tracking row updates


-- Example
-- created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
-- updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;


-- | Type      | Stores      | Storage | Timezone Aware? | Range     |
-- | --------- | ----------- | ------- | --------------- | --------- |
-- | DATE      | Date only   | 3 bytes | No              | 1000–9999 |
-- | DATETIME  | Date + Time | 8 bytes | No              | 1000–9999 |
-- | TIMESTAMP | Date + Time | 4 bytes | Yes             | 1970–2038 |


-- When to Use What?

-- Use DATE → Only date needed
-- Use DATETIME → Long date range, no timezone conversion
-- Use TIMESTAMP → Auto-tracking, timezone-aware, smaller storage



-- Year Type
-- -----------

-- The YEAR type is a 1-byte type used to represent year values. 
-- It can be declared as YEAR(2) or YEAR(4) to specify a display width of two or four characters. 
-- If no width is given the default is four characters

-- YEAR(4) and YEAR(2) have different display format but have the same range of values.

-- For 4-digit format, MySQL displays YEAR values in YYYY format, with a range of 1901 to 2155, or 0000.

-- For 2-digit format, MySQL displays only the last two (least significant) digits; 
-- for example, 70 (1970 or 2070) or 69 (2069).

-- Important Notes

-- Only stores the year, not month or date.
-- 2-digit year format (like 23) is not recommended in modern MySQL.
-- It automatically converts valid inputs into 4-digit format.


-- When to Use YEAR?

-- Use it when you only need:
-- Manufacturing year
-- Admission year
-- Graduation year
-- Model year

-- If you need full date → use DATE
-- If you need date + time → use DATETIME or TIMESTAMP


-- ------------------------------------------------------------------------------

-- ---------------
-- String Types
-- ---------------

-- MySQL string types are mainly divided into 3 categories:
-- 1. Fixed-length strings
-- 2. Variable-length strings
-- 3. Large text & binary strings

-- The string types are CHAR, VARCHAR, BINARY, VARBINARY, BLOB, TEXT, ENUM, and SET.



-- CHAR and VARCHAR Types
-------------------------------

-- The CHAR and VARCHAR types are similar but differ in the way they are stored and retrieved. 
-- They also differ in maximum length and in whether trailing spaces are retained.


-- CHAR(M): Fixed-length characters
-- Length is fixed as you declare while creating a table. 
-- When stored, they are right-padded with spaces to the specified length.	
-- Trailing spaces are removed.
-- The length can be any value from 0 to 255.

-- Example
-- code CHAR(5);
-- If you insert 'abc' into a CHAR(5) column, it will be stored as 'abc  ' (with two trailing spaces).

-- Use when:

-- Values are always same length
-- Country codes (IN, US)
-- Gender (M/F)
-- PIN codes (fixed size)


-- VARCHAR(): Variable-length characters
-- Columns are variable-length strings.	As stored.	
-- A value from 0 to 65,535 in 5.0.3 and later versions.
-- Stores only actual characters + 1 or 2 extra bytes

-- Example:
-- name VARCHAR(50);
-- if you insert 'abc' into a VARCHAR(50) column, it will be stored as 'abc' (without trailing spaces).

-- Use when:

-- Names
-- Emails
-- Addresses

-- Most commonly used string type.


-- ------------------------------------------------------------------------------


-- BLOB and TEXT Types
---------------------------

-- A BLOB is a binary large object that can hold a variable amount of data. 
-- There are four types of BLOB, TINYBLOB, BLOB, MEDIUMBLOB, and LONGBLOB. 
-- These differ only in the maximum length of the values they can hold.

-- The four TEXT types are TINYTEXT, TEXT, MEDIUMTEXT, and LONGTEXT. 
-- These correspond to the four BLOB types and have the same maximum lengths and storage requirements.


-- BLOB	(Binary Large Objects)
-- ----------------------------
-- Like TEXT, but for binary data.
-- Large binary object that containing a variable amount of data. 
-- Values are treated as binary strings.
-- You don't need to specify length while creating a column.	

-- | Type       | Max Size  |
-- | ---------- | --------- |
-- | TINYBLOB   | 255 bytes |
-- | BLOB       | 65 KB     |
-- | MEDIUMBLOB | 16 MB     |
-- | LONGBLOB   | 4 GB      |

-- Used for:

-- Images
-- Files
-- PDFs
-- Videos



-- TEXT	
-- -------
-- Values are treated as character strings having a character set.

-- | Type       | Max Size  |
-- | ---------- | --------- |
-- | TINYTEXT   | 255 bytes |
-- | TEXT       | 65 KB     |
-- | MEDIUMTEXT | 16 MB     |
-- | LONGTEXT   | 4 GB      |

-- Example:
-- description TEXT;

-- Use when:
-- Articles
-- Blog posts
-- Long descriptions
-- Comments



-- Quick Comparison

-- | Type    | Fixed? | Stores Text? | Common Use         |
-- | ------- | ------ | ------------ | ------------------ |
-- | CHAR    | Yes    | Yes          | Fixed-length codes |
-- | VARCHAR | No     | Yes          | Names, emails      |
-- | TEXT    | No     | Yes          | Large text         |
-- | BLOB    | No     | No (binary)  | Files, images      |



-- ------------------------------------------------------------------------------



-- BINARY and VARBINARY Types
---------------------------------

-- Like CHAR and VARCHAR, but store binary data (not text).

-- BINARY(M)
-- ----------
-- Stores fixed-length binary data
-- M = lenght (0 to 255 bytes)
-- Always stores exactly M bytes
-- Pads with \0 (null bytes) if shorter than M

-- Example:
-- code BINARY(5);
-- If you insert 'abc' into a BINARY(5) column, it will be stored as 'abc\0\0' (with two null bytes).

-- VARBINARY(M)
-- -------------
-- Contains binary strings.	
-- M = max length
-- Stores only actual bytes
-- No padding

-- Example:
-- token VARBINARY(50);
-- If you store 10 bytes → only 10 bytes stored.

-- Key Differences

-- | Type         | Fixed Length? | Padding        | Storage                    |
-- | ------------ | ------------- | -------------- | -------------------------- |
-- | BINARY(M)    | Yes           | Pads with `\0` | Exactly M bytes            |
-- | VARBINARY(M) | No            | No padding     | Actual bytes + length info |


-- Used for:

-- Encrypted data
-- Hash values (MD5, SHA)
-- Authentication tokens
-- Raw byte storage

-- Example: password_hash VARBINARY(64);
