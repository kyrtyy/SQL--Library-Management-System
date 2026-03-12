-- ============================================================
--  FILE : 04_analysis_queries.sql
--  DESC : Core analysis queries: Tasks 7 through 12.
--         These answer specific business questions about the
--         library's catalog, members, staff, and operations.
--  Author : Yash Dewangan
-- ============================================================


-- ------------------------------------------------------------
--  TASK 7: All books in a specific category
--  Swap 'Classic' for any category in your catalog
-- ------------------------------------------------------------

SELECT
    isbn,
    book_title,
    author,
    rental_price,
    status
FROM books
WHERE category = 'Classic'
ORDER BY book_title;


-- ------------------------------------------------------------
--  TASK 8: Total rental income by category
--  Joins issued_status to get actual revenue, not just catalog price
-- ------------------------------------------------------------

SELECT
    b.category,
    COUNT(ist.issued_id)            AS times_issued,
    SUM(b.rental_price)             AS total_rental_income
FROM issued_status AS ist
JOIN books AS b ON b.isbn = ist.issued_book_isbn
GROUP BY b.category
ORDER BY total_rental_income DESC;


-- ------------------------------------------------------------
--  TASK 9: Members who registered in the last 180 days
--  Useful for tracking new member growth
-- ------------------------------------------------------------

SELECT
    member_id,
    member_name,
    member_address,
    reg_date,
    CURRENT_DATE - reg_date     AS days_since_registration
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'
ORDER BY reg_date DESC;


-- ------------------------------------------------------------
--  TASK 10: Employees with their branch and manager's name
--  Self-join on employees to pull manager name from same table
-- ------------------------------------------------------------

SELECT
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.branch_id,
    b.branch_address,
    b.contact_no,
    e2.emp_name     AS manager_name
FROM employees AS e1
JOIN branch     AS b  ON b.branch_id = e1.branch_id
JOIN employees  AS e2 ON e2.emp_id   = b.manager_id
ORDER BY b.branch_id, e1.emp_name;


-- ------------------------------------------------------------
--  TASK 12: Books that have never been returned
--  LEFT JOIN + NULL check finds issuances with no matching return
-- ------------------------------------------------------------

SELECT
    ist.issued_id,
    ist.issued_member_id,
    m.member_name,
    ist.issued_book_name,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date      AS days_out
FROM issued_status AS ist
LEFT JOIN return_status AS rs ON rs.issued_id  = ist.issued_id
JOIN members            AS m  ON m.member_id   = ist.issued_member_id
WHERE rs.return_id IS NULL
ORDER BY days_out DESC;
