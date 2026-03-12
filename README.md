# Library Management System

| | |
|---|---|
| **Author** | Yash Dewangan |
| **Database** | `library_db` |
| **Tools** | PostgreSQL, pgAdmin / psql |
| **Topics Covered** | Schema Design, CRUD, Joins, CTEs, Stored Procedures, CTAS, Window Functions |

---

## About Project

I built this project to practice working with a realistic relational database, something with actual foreign key relationships, multi-table joins, and business logic baked into stored procedures.

The dataset simulates a library system: branches, employees, members, books, and a full issuance/return cycle. The queries go beyond basic SELECT statements, they cover things like overdue tracking, branch performance reporting, fine calculation, and member activity segmentation.

If you're here to learn SQL or review my work, the files are organized so you can run them top to bottom without issues.

---

## Database Schema

Six tables, all related:

```
branch          ←── employees ──→ issued_status ──→ return_status
                                        ↑                  ↑
                     members ───────────┘         books ───┘
```

| Table | What It Stores |
|---|---|
| `branch` | Physical library branches and their managers |
| `employees` | Staff records, roles, salaries, branch assignment |
| `members` | Registered library members |
| `books` | Book catalog with pricing and availability status |
| `issued_status` | Every book issuance event |
| `return_status` | Return records linked back to issuances |

Full schema is in `sql/01_schema.sql`.

---

## Project Structure

```
library-management-sql/
│
├── sql/
│   ├── 01_schema.sql          -- All CREATE TABLE statements + FK relationships
│   ├── 02_crud_operations.sql -- Insert, Update, Delete, basic Select tasks
│   ├── 03_ctas_tables.sql     -- CREATE TABLE AS SELECT queries
│   ├── 04_analysis_queries.sql-- Core data analysis
│   ├── 05_advanced_queries.sql-- Advanced SQL: overdue tracking, reports, procedures
│   └── 06_stored_procedures.sql-- Stored procedures for book issue and return logic
│
└── results/
    └── key_findings.md        -- Summary of insights from the analysis
```

---

## What's Covered

### CRUD Operations
Basic but important: inserts, updates, deletes, and targeted selects across the schema. Just making sure the fundamentals are clean.

### CTAS (Create Table As Select)
Used to spin up summary tables that can be queried repeatedly without re-running expensive joins, things like `book_issued_cnt`, `branch_reports`, `active_members`, and an overdue fines table.

### Analysis Queries
- Rental income by book category
- Members registered in the last 180 days
- Books not yet returned
- Employees and their branch manager details
- Books priced above a rental threshold

### Advanced Queries
- **Overdue detection:** members past the 30 day return window, with days overdue calculated
- **Branch performance report:** books issued, returned, and total revenue per branch
- **Active members:** anyone who's issued a book in the last 2 months
- **Top employees:** who's processed the most issuances
- **Overdue fines table:** per member fine totals at $0.50/day

### Stored Procedures
Two procedures that handle the core library workflow:

1. `issue_book`: checks availability before issuing; updates book status to `'no'` if available, raises a notice if not
2. `add_return_records`: logs the return, flips book status back to `'yes'`, records book condition

---

## How to Run

```bash
# 1. Clone the repo
git clone https://github.com/kyrtyy/SQL--Library-Management-System

# 2. Create the database
psql -U postgres -c "CREATE DATABASE library_db;"

# 3. Connect and run in order
psql -U postgres -d library_db -f sql/01_schema.sql
psql -U postgres -d library_db -f sql/02_crud_operations.sql
psql -U postgres -d library_db -f sql/03_ctas_tables.sql
psql -U postgres -d library_db -f sql/04_analysis_queries.sql
psql -U postgres -d library_db -f sql/05_advanced_queries.sql
psql -U postgres -d library_db -f sql/06_stored_procedures.sql
```

Or open them individually in pgAdmin and run as needed.

---

## Key Findings

A few things worth noting from the analysis, more detail in `results/key_findings.md`:

- Some members have had books out well past the 30 day limit. The overdue query surfaces these with exact day counts, which could feed into an automated reminder system.
- Branch performance varies meaningfully, both in issuance volume and revenue. The `branch_reports` CTAS table makes this easy to monitor on an ongoing basis.
- A small number of employees handle a disproportionate share of book issuances. Useful for workload balancing.
- The stored procedures make the issuance/return workflow reliable, no manual status updates needed.

---

## About Me

**Yash Dewangan:** Final year Physics Undergraduate student at Indian Institute of Science, Banglore, also a data analyst with a focus on SQL, data modeling, and turning raw records into something useful.

- **LinkedIn**: [https://linkedin.com/in/yash-dewangan-a61619250]
- **GitHub**: [https://github.com/kyrtyy]
- **Email**: [dewyashangan@gmail.com]
