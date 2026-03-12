-- ============================================================
--  FILE : 03_ctas_tables.sql
--  DESC : CTAS queries: builds summary tables that can be
--         reused without re-running expensive joins each time.
--  Author : Yash Dewangan
-- ============================================================


-- ------------------------------------------------------------
--  TASK 6: Book issuance count per title
--  Useful for quickly spotting high-demand books
-- ------------------------------------------------------------

DROP TABLE IF EXISTS book_issued_cnt;

CREATE TABLE book_issued_cnt AS
SELECT
    b.isbn,
    b.book_title,
    b.category,
    b.rental_price,
    COUNT(ist.issued_id)    AS issue_count
FROM issued_status AS ist
JOIN books AS b ON b.isbn = ist.issued_book_isbn
GROUP BY b.isbn, b.book_title, b.category, b.rental_price;

SELECT * FROM book_issued_cnt ORDER BY issue_count DESC;


-- ------------------------------------------------------------
--  TASK 11: Books with rental price above $7.00
--  Isolates the premium tier of the catalog
-- ------------------------------------------------------------

DROP TABLE IF EXISTS expensive_books;

CREATE TABLE expensive_books AS
SELECT
    isbn,
    book_title,
    category,
    rental_price,
    author
FROM books
WHERE rental_price > 7.00;

SELECT * FROM expensive_books ORDER BY rental_price DESC;


-- ------------------------------------------------------------
--  TASK 15: Branch performance report
--  Issued count, return count, and total rental revenue per branch
-- ------------------------------------------------------------

DROP TABLE IF EXISTS branch_reports;

CREATE TABLE branch_reports AS
SELECT
    b.branch_id,
    b.manager_id,
    b.branch_address,
    COUNT(ist.issued_id)        AS books_issued,
    COUNT(rs.return_id)         AS books_returned,
    SUM(bk.rental_price)        AS total_revenue
FROM issued_status AS ist
JOIN employees AS e  ON e.emp_id      = ist.issued_emp_id
JOIN branch    AS b  ON b.branch_id   = e.branch_id
LEFT JOIN return_status AS rs ON rs.issued_id  = ist.issued_id
JOIN books     AS bk ON bk.isbn       = ist.issued_book_isbn
GROUP BY b.branch_id, b.manager_id, b.branch_address;

SELECT * FROM branch_reports ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
--  TASK 16: Active members (issued at least once in last 2 months)
-- ------------------------------------------------------------

DROP TABLE IF EXISTS active_members;

CREATE TABLE active_members AS
SELECT *
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '2 months'
);

SELECT * FROM active_members ORDER BY reg_date DESC;


-- ------------------------------------------------------------
--  TASK 20: Overdue fines summary per member
--  30-day return window, $0.50 fine per day overdue
-- ------------------------------------------------------------

DROP TABLE IF EXISTS overdue_fines_summary;

CREATE TABLE overdue_fines_summary AS
SELECT
    ist.issued_member_id                                        AS member_id,
    m.member_name,
    COUNT(*)                                                    AS overdue_books,
    SUM(CURRENT_DATE - ist.issued_date - 30)                    AS total_days_overdue,
    SUM((CURRENT_DATE - ist.issued_date - 30) * 0.50)          AS total_fine_usd
FROM issued_status AS ist
JOIN members AS m ON m.member_id = ist.issued_member_id
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE
    rs.return_date IS NULL
    AND (CURRENT_DATE - ist.issued_date) > 30
GROUP BY ist.issued_member_id, m.member_name
ORDER BY total_fine_usd DESC;

SELECT * FROM overdue_fines_summary;
