-- ============================================================
--  FILE : 02_crud_operations.sql
--  DESC : CRUD tasks: insert, update, delete, and basic reads.
--         Run after 01_schema.sql and your data load.
--  Author : Yash Dewangan
-- ============================================================


-- ------------------------------------------------------------
--  TASK 1: Insert a new book into the catalog
-- ------------------------------------------------------------

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES (
    '978-1-60129-456-2',
    'To Kill a Mockingbird',
    'Classic',
    6.00,
    'yes',
    'Harper Lee',
    'J.B. Lippincott & Co.'
);

-- Confirm it landed
SELECT * FROM books WHERE isbn = '978-1-60129-456-2';


-- ------------------------------------------------------------
--  TASK 2: Update a member's address
-- ------------------------------------------------------------

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- Confirm the change
SELECT member_id, member_name, member_address FROM members WHERE member_id = 'C103';


-- ------------------------------------------------------------
--  TASK 3: Delete a specific record from issued_status
-- ------------------------------------------------------------

-- Check it exists before deleting
SELECT * FROM issued_status WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121';


-- ------------------------------------------------------------
--  TASK 4: All books issued by a specific employee
-- ------------------------------------------------------------

SELECT
    ist.issued_id,
    ist.issued_book_name,
    ist.issued_date,
    m.member_name
FROM issued_status AS ist
JOIN members AS m ON m.member_id = ist.issued_member_id
WHERE ist.issued_emp_id = 'E101'
ORDER BY ist.issued_date DESC;


-- ------------------------------------------------------------
--  TASK 5: Members who have issued more than one book
--  Grouped by member rather than employee to show member behavior
-- ------------------------------------------------------------

SELECT
    issued_member_id,
    COUNT(*)            AS total_issued
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1
ORDER BY total_issued DESC;
