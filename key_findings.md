# Key Findings : Library Management System

> **Author:** Yash Dewangan
> **Database:** library_db (PostgreSQL)

---

## Overdue Books

Run `05_advanced_queries.sql` → Task 13 to see the full list.

A meaningful portion of issued books have passed the 30-day return window with no return record. The query shows exact days overdue per member, which is the raw material for any automated reminder or fine enforcement system.

The `overdue_fines_summary` table (built in `03_ctas_tables.sql`) rolls this up per member, total overdue books and total fine owed at $0.50/day. Worth reviewing periodically.

---

## Branch Performance

Run `03_ctas_tables.sql` → Task 15 to build the `branch_reports` table.

Branches differ noticeably in both issuance volume and total rental revenue. The performance table makes it straightforward to rank branches and spot which ones are under-utilised. Manager IDs are included so accountability is clear.

---

## Employee Workload

Run `05_advanced_queries.sql` → Task 17.

A small number of employees account for a disproportionate share of processed issuances. The top 3 query surfaces who they are and which branch they're at — useful for workload balancing or recognising high performers.

---

## Book Demand

Run `03_ctas_tables.sql` → Task 6 to build `book_issued_cnt`.

Some titles have been issued significantly more than others. The `book_issued_cnt` table ranks every book by how many times it's been checked out. High-demand titles with status `'no'` for extended periods are good candidates for additional copies.

---

## Rental Revenue by Category

Run `04_analysis_queries.sql` → Task 8.

Categories vary in both volume and revenue. Some categories get issued frequently but at low price points; others have fewer issuances but generate more per transaction. The split between `times_issued` and `total_rental_income` in that query shows both sides.

---

## Member Activity

Run `03_ctas_tables.sql` → Task 16 to build `active_members`.

The `active_members` table captures everyone who's borrowed a book in the last 2 months. Comparing this count against total registered members gives a quick read on how much of the member base is actually active, and how large the inactive segment is.

New member registration trend is in `04_analysis_queries.sql` → Task 9 (last 180 days).

---

## Stored Procedures

Both procedures in `06_stored_procedures.sql` are working as expected:

- `issue_book`: correctly blocks issuance when a book's status is `'no'` and raises a notice rather than silently failing
- `add_return_records`: logs return condition, resets book availability atomically

These make the issuance/return workflow reliable without requiring manual `UPDATE` statements each time.

---

*Run order: 01 → 02 → 03 → 04 → 05 → 06*
