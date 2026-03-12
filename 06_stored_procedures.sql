-- ============================================================
--  FILE : 06_stored_procedures.sql
--  DESC : Stored procedures for the book issuance and return
--         workflow. These replace manual status updates with
--         reliable, repeatable logic.
--  Author : Yash Dewangan
-- ============================================================


-- ============================================================
--  PROCEDURE 1 : issue_book
--
--  Handles book issuance. Before inserting into issued_status,
--  it checks whether the book is actually available. If it is,
--  the record gets inserted and book status flips to 'no'.
--  If not, it raises a notice and does nothing.
--
--  Parameters:
--    p_issued_id         -- new issued_id to assign (e.g. 'IS155')
--    p_issued_member_id  -- the member borrowing the book
--    p_issued_book_isbn  -- isbn of the requested book
--    p_issued_emp_id     -- employee processing the request
-- ============================================================

CREATE OR REPLACE PROCEDURE issue_book(
    p_issued_id         VARCHAR(10),
    p_issued_member_id  VARCHAR(30),
    p_issued_book_isbn  VARCHAR(30),
    p_issued_emp_id     VARCHAR(10)
)
LANGUAGE plpgsql
AS $$

DECLARE
    v_status    VARCHAR(10);

BEGIN

    -- Pull current availability status for the requested book
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        -- Book is available — log the issuance
        INSERT INTO issued_status (
            issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES (
            p_issued_id,
            p_issued_member_id,
            CURRENT_DATE,
            p_issued_book_isbn,
            p_issued_emp_id
        );

        -- Mark the book as no longer available
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book issued successfully. ISBN: %', p_issued_book_isbn;

    ELSE
        RAISE NOTICE 'Book is currently unavailable. ISBN: %', p_issued_book_isbn;
    END IF;

END;
$$;


-- ------------------------------------------------------------
--  Test issue_book
-- ------------------------------------------------------------

-- Check current status of two books before calling
SELECT isbn, book_title, status FROM books
WHERE isbn IN ('978-0-553-29698-2', '978-0-375-41398-8');

-- '978-0-553-29698-2' should be 'yes' (available)
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

-- '978-0-375-41398-8' should be 'no' (already out) — expect a notice
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

-- Confirm status flipped to 'no' for the first book
SELECT isbn, book_title, status FROM books WHERE isbn = '978-0-553-29698-2';


-- ============================================================
--  PROCEDURE 2 : add_return_records
--
--  Handles book returns. Inserts a return record, then flips
--  the book status back to 'yes' so it can be issued again.
--  Also captures book condition at time of return.
--
--  Parameters:
--    p_return_id    -- new return_id to assign (e.g. 'RS138')
--    p_issued_id    -- the original issued_id being returned
--    p_book_quality -- condition on return ('Good', 'Damaged', etc.)
-- ============================================================

CREATE OR REPLACE PROCEDURE add_return_records(
    p_return_id     VARCHAR(10),
    p_issued_id     VARCHAR(10),
    p_book_quality  VARCHAR(10)
)
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn          VARCHAR(50);
    v_book_name     VARCHAR(80);

BEGIN

    -- Look up the isbn and title from the original issuance
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Log the return
    INSERT INTO return_status (
        return_id,
        issued_id,
        return_date,
        return_book_isbn,
        book_quality
    )
    VALUES (
        p_return_id,
        p_issued_id,
        CURRENT_DATE,
        v_isbn,
        p_book_quality
    );

    -- Mark the book as available again
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Return recorded for: %. Condition: %', v_book_name, p_book_quality;

END;
$$;


-- ------------------------------------------------------------
--  Test add_return_records
-- ------------------------------------------------------------

-- Check what's currently issued for IS135 and IS140
SELECT * FROM issued_status WHERE issued_id IN ('IS135', 'IS140');
SELECT isbn, book_title, status FROM books WHERE isbn = '978-0-307-58837-1';

-- Process the returns
CALL add_return_records('RS138', 'IS135', 'Good');
CALL add_return_records('RS148', 'IS140', 'Good');

-- Confirm the book flipped back to 'yes'
SELECT isbn, book_title, status FROM books WHERE isbn = '978-0-307-58837-1';

-- Confirm return records exist
SELECT * FROM return_status WHERE issued_id IN ('IS135', 'IS140');
