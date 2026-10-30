# Student Registration and Grading System (Oracle PL/SQL)

**Course:** Database Development with PL/SQL (INSY 8311)
**Assignment:** Group Assignment IV: Records, Collections, Cursors, Bulk Processing, Procedures, Functions and Exception Handling
**Instructor:** Eric Maniraguha

## 1. Group members

| Full name | Student ID | 
|-----------|-----------|----
|Nkwaya Frank | 20251IMA029 | 
|Nkurunziza Amiable | 29692 | 

**Class group:** _I_ 

## 2. Application description

We chose a **Student Registration and Grading System**. A university registers students, offers courses, and enrolls students in those courses. Lecturers enter marks, and the system converts marks to letter grades, calculates GPA, and records every grade change in an audit table.

### Requirements we set for the system
- A student ID and an email can only be used once.
- A student can only be enrolled once in the same course.
- Only **ACTIVE** students can enroll. SUSPENDED and GRADUATED students are refused.
- Marks must be between 0 and 100.
- Grade scale: A >= 80, B >= 70, C >= 60, D >= 50, F < 50.
- Every grade change is saved in `grade_audit`.
- A whole course can be graded, or given bonus marks, in one bulk operation.
- Every error returns a clear message. Nothing is silently ignored.

## 3. Database design

```
STUDENTS ──< ENROLLMENTS >── COURSES
                 │
                 └──< GRADE_AUDIT
```

| Table | Purpose | Key constraints |
|---|---|---|
| `students` | Student details and status | PK `student_id`, UNIQUE `email`, CHECK status in (ACTIVE, SUSPENDED, GRADUATED) |
| `courses` | Course catalogue | PK `course_id`, UNIQUE `course_code`, CHECK credits 1 to 6 |
| `enrollments` | Which student takes which course, with marks and grade | PK identity, FK to students and courses, UNIQUE (student_id, course_id), CHECK marks 0 to 100 |
| `grade_audit` | History of grade changes | PK identity, FK to enrollments |

Sample data: 6 students (one SUSPENDED, one GRADUATED), 4 courses and 9 enrollments.

## 4. What we built

### Functions (`02_functions/`)
| Function | What it does |
|---|---|
| `get_letter_grade` | Converts marks to a letter grade, and rejects invalid marks |
| `calculate_gpa` | Credit-weighted GPA using an explicit cursor and a record |
| `get_student_name` | Returns a student's full name |
| `get_student_by_status` | Finds the one student with a status (shows NO_DATA_FOUND and TOO_MANY_ROWS) |
| `count_enrollments` | Counts students in a course, and can be used inside SQL |

### Procedures (`01_procedures/`)
| Procedure | What it does |
|---|---|
| `add_student` | Registers a student using a `%ROWTYPE` record |
| `enroll_student` | Enrolls an active student in a course |
| `update_marks` | Updates marks and grade for one student and writes an audit row |
| `drop_enrollment` | Deletes an enrollment (blocked if it has audit history) |
| `bulk_grade_course` | Grades a whole course with BULK COLLECT and FORALL |
| `bulk_adjust_marks` | Adds bonus marks in bulk with FORALL ... SAVE EXCEPTIONS |
| `student_transcript` | Prints a transcript with a user-defined record and an explicit cursor |
| `course_summary` | Course averages and grade distribution using an associative array, a VARRAY and a cursor FOR loop |

### Where each required concept is used
| Requirement | Where |
|---|---|
| `%ROWTYPE` records | `add_student`, `enroll_student`, `get_student_name`, `calculate_gpa` |
| User-defined record | `student_transcript` (`t_line`) |
| Nested table | `bulk_grade_course`, `bulk_adjust_marks` |
| Associative array | `course_summary` |
| VARRAY | `course_summary` |
| Implicit cursor (`SQL%ROWCOUNT`, `SQL%FOUND`, `SQL%NOTFOUND`) | `add_student`, `update_marks`, `drop_enrollment`, `bulk_grade_course` |
| Explicit cursor (OPEN / FETCH / CLOSE) | `student_transcript`, `calculate_gpa` |
| Cursor FOR loop | `course_summary` |
| BULK COLLECT | `bulk_grade_course`, `bulk_adjust_marks` |
| FORALL and bulk error handling (SAVE EXCEPTIONS) | `bulk_adjust_marks`, `bulk_grade_course` |
| NO_DATA_FOUND, TOO_MANY_ROWS, DUP_VAL_ON_INDEX | `get_student_by_status`, `enroll_student`, `add_student`, test E12 |
| User-defined exceptions | `e_invalid_email`, `e_not_active`, `e_has_history`, `e_bulk_errors` |
| RAISE_APPLICATION_ERROR | All procedures and functions (codes -20001 to -20062) |

## 5. How we set up and ran the project

These are the exact steps we followed.

### Database setup (done once)
1. Opened SQL*Plus and found that we were in `CDB$ROOT` (the container root), which does not allow normal users.
2. Connected as `SYSDBA` and opened our pluggable database:
   ```sql
   CONNECT / AS SYSDBA
   ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
   ALTER SESSION SET CONTAINER = ORCLPDB;
   ```
3. Created a dedicated user so our project tables are separate from system tables:
   ```sql
   CREATE USER grading_user IDENTIFIED BY <password> DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
   GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE, CREATE VIEW TO grading_user;
   ```
4. Connected as that user:
   ```sql
   CONNECT grading_user/<password>@localhost:1521/ORCLPDB
   SET SERVEROUTPUT ON SIZE UNLIMITED
   SET LINESIZE 200
   SET PAGESIZE 100
   ```

### Running the project (in this order)
| Step | Script | Result |
|---|---|---|
| 1 | `00_schema/01_create_tables.sql` | 4 tables created |
| 2 | `00_schema/02_insert_sample_data.sql` | 6 students, 4 courses, 9 enrollments |
| 3 | `02_functions/get_letter_grade.sql`, then the other 4 function files | 5 functions, all VALID |
| 4 | All 8 files in `01_procedures/` | 8 procedures, all VALID |
| 5 | `03_tests/test_success_cases.sql` | Success cases pass |
| 6 | `03_tests/test_error_cases.sql` | Errors are raised and handled as expected |
| 7 | `03_tests/test_performance.sql` | Row-by-row vs FORALL timing |

Functions are compiled before procedures because `update_marks` and `bulk_grade_course` call `get_letter_grade`. In SQL*Plus a file is run with `@"full\path\to\file.sql"`. The test files end with `ROLLBACK`, so they can be run again without changing the sample data.

## 6. Test results

| Test | Output screenshot |
|---|---|
| Tables created | `screenshots/01_create_tables_output.png` |
| Sample data (6 / 4 / 9) | `screenshots/02_sample_data_output.png` |
| Functions compiled | `screenshots/03_functions_compiled_output.png` |
| Procedures compiled | `screenshots/04_procedures_compiled_output.png` |
| Success cases | `screenshots/05a_...` to `05d_...` |
| Error cases | `screenshots/06a_...` to `06d_...` |
| Performance | `screenshots/07_test_performance_output.png` |

**Highlights**
- The bulk error test (E13) updated the valid row and reported the failing row with `ORA-02290` (CHECK constraint violated), using `SAVE EXCEPTIONS`.
- Suspended students are refused enrollment (`ORA-20011`).
- The performance test with 100,000 rows showed **row-by-row = 8.19 s** and **FORALL = 0.44 s**, so FORALL was about **18 times faster**.

## 7. Error codes

| Code | Meaning |
|---|---|
| -20001 / -20002 | Duplicate student / invalid email |
| -20010 | Marks outside 0 to 100 |
| -20011 / -20012 / -20013 / -20014 | Enroll: student not active / student not found / course not found / already enrolled |
| -20020 / -20021 | GPA: student not found / no graded courses |
| -20022 | Student name: not found |
| -20023 / -20024 | Status lookup: too many / none |
| -20025 | Course not found (`count_enrollments`) |
| -20041 | Student not enrolled in the course |
| -20051 / -20052 | Drop: enrollment not found / has audit history |
| -20061 / -20062 | Bulk: course not found / transcript: student not found |

## 8. Repository structure

```
plsql-assignment4-20251IMA029-29692/
├── README.md
├── .gitignore
├── 00_schema/        01_create_tables.sql, 02_insert_sample_data.sql
├── 01_procedures/    one file per procedure (8)
├── 02_functions/     one file per function (5)
├── 03_tests/         test_success_cases.sql, test_error_cases.sql, test_performance.sql
├── screenshots/      output of every test
└── docs/             IMPLEMENTATION_NOTES.md
```


## 9. Work distribution

| Member | Contribution |
|---|---|
| Nkwaya Frank | I did this schema, sample data, registration and marks procedures, success tests, README_ |
| Nkurunziza Amiable |  I contributed to  functions, bulk and report procedures, error and performance tests, implementation notes_ |

## 10. AI usage disclosure

We used an AI assistant (Claude by Anthropic) while working on this assignment. It helped us plan the application, draft the SQL and PL/SQL code, and guided us through the setup and testing steps. We then did the following ourselves: set up the Oracle user and pluggable database, ran every script, checked that all objects compiled, ran the success, error and performance tests, took the screenshots, and prepared the repository. Both of us have gone through the code and can explain it, including the records, collections, cursors, bulk processing and exception handling.
