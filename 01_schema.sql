-- ============================================================
--  FILE : 01_schema.sql
--  DESC : Full schema for the Library Management System.
--         Run this first before anything else.
--  Author : Yash Dewangan
-- ============================================================


-- If you're re-running this from scratch, drop tables
-- in reverse dependency order to avoid FK conflicts.

DROP TABLE IF EXISTS return_status;
DROP TABLE IF EXISTS issued_status;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS branch;


-- ------------------------------------------------------------
--  BRANCH
--  Each row is one physical library location.
-- ------------------------------------------------------------

CREATE TABLE branch (
    branch_id       VARCHAR(10)  PRIMARY KEY,
    manager_id      VARCHAR(10),
    branch_address  VARCHAR(30),
    contact_no      VARCHAR(15)
);


-- ------------------------------------------------------------
--  EMPLOYEES
--  Staff members tied to a branch.
-- ------------------------------------------------------------

CREATE TABLE employees (
    emp_id      VARCHAR(10)   PRIMARY KEY,
    emp_name    VARCHAR(30),
    position    VARCHAR(30),
    salary      DECIMAL(10,2),
    branch_id   VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);


-- ------------------------------------------------------------
--  MEMBERS
--  Registered library members.
-- ------------------------------------------------------------

CREATE TABLE members (
    member_id       VARCHAR(10)  PRIMARY KEY,
    member_name     VARCHAR(30),
    member_address  VARCHAR(30),
    reg_date        DATE
);


-- ------------------------------------------------------------
--  BOOKS
--  The full catalog. status 'yes' = available, 'no' = issued.
-- ------------------------------------------------------------

CREATE TABLE books (
    isbn            VARCHAR(50)   PRIMARY KEY,
    book_title      VARCHAR(80),
    category        VARCHAR(30),
    rental_price    DECIMAL(10,2),
    status          VARCHAR(10),
    author          VARCHAR(30),
    publisher       VARCHAR(30)
);


-- ------------------------------------------------------------
--  ISSUED STATUS
--  One row per book issuance event.
-- ------------------------------------------------------------

CREATE TABLE issued_status (
    issued_id           VARCHAR(10)  PRIMARY KEY,
    issued_member_id    VARCHAR(30),
    issued_book_name    VARCHAR(80),
    issued_date         DATE,
    issued_book_isbn    VARCHAR(50),
    issued_emp_id       VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_emp_id)    REFERENCES employees(emp_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn)
);


-- ------------------------------------------------------------
--  RETURN STATUS
--  Tracks returns, linked back to the original issuance.
--  book_quality is captured by the return procedure.
-- ------------------------------------------------------------

CREATE TABLE return_status (
    return_id           VARCHAR(10)  PRIMARY KEY,
    issued_id           VARCHAR(30),
    return_book_name    VARCHAR(80),
    return_date         DATE,
    return_book_isbn    VARCHAR(50),
    book_quality        VARCHAR(10),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);


-- ------------------------------------------------------------
--  QUICK CHECK — confirm all 6 tables exist
-- ------------------------------------------------------------

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
