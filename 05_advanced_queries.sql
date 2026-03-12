-- ============================================================
--  FILE : 05_advanced_queries.sql
--  DESC : Advanced analysis: Tasks 13, 17, 18.
--         Covers overdue detection, employee rankings, and
--         members with a pattern of damaging books.
--  Author : Yash Dewangan
-- ============================================================


-- ------------------------------------------------------------
--  TASK 13: Members with overdue books
--  30-day return window. Shows member, book, issue date,
--  and exact days overdue. Only includes unreturned books.
-- ------------------------------------------------------------

SELECT
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    bk.category,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date          AS days_out,
    (CURRENT_DATE - ist.issued_date) - 30   AS days_overdue
FROM issued_status AS ist
JOIN members AS m  ON m.member_id  = ist.issued_member_id
JOIN books   AS bk ON bk.isbn      = ist.issued_book_isbn
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE
    rs.return_date IS NULL
    AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY days_overdue DESC;


-- ------------------------------------------------------------
--  TASK 17: Top 3 employees by books processed
--  Useful for workload analysis and recognition
-- ------------------------------------------------------------

SELECT
    e.emp_id,
    e.emp_name,
    e.position,
    b.branch_id,
    b.branch_address,
    COUNT(ist.issued_id)    AS books_processed
FROM issued_status  AS ist
JOIN employees      AS e  ON e.emp_id    = ist.issued_emp_id
JOIN branch         AS b  ON b.branch_id = e.branch_id
GROUP BY e.emp_id, e.emp_name, e.position, b.branch_id, b.branch_address
ORDER BY books_processed DESC
LIMIT 3;


-- ------------------------------------------------------------
--  TASK 18: Members who repeatedly issue damaged books
--  Flags members with more than 2 damaged-book issuances.
--  Requires book condition to be tracked in return_status.
-- ------------------------------------------------------------

SELECT
    m.member_id,
    m.member_name,
    bk.book_title,
    COUNT(*)                AS times_issued_damaged
FROM issued_status  AS ist
JOIN return_status  AS rs ON rs.issued_id  = ist.issued_id
JOIN members        AS m  ON m.member_id   = ist.issued_member_id
JOIN books          AS bk ON bk.isbn       = ist.issued_book_isbn
WHERE LOWER(rs.book_quality) = 'damaged'
GROUP BY m.member_id, m.member_name, bk.book_title
HAVING COUNT(*) > 2
ORDER BY times_issued_damaged DESC;
