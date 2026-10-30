#Implementation and Performance Notes

## Design in one paragraph
Four tables hold the data. Business rules live in stored functions (grading, GPA, lookups) and stored procedures (register, enroll, update marks, drop, bulk operations, reports). Procedures do **not** commit; the caller decides when to COMMIT or ROLLBACK, which keeps each operation atomic and testable.

## Records
- `%ROWTYPE` holds a whole table row (`r_student students%ROWTYPE`), and `INSERT INTO students VALUES r_student` inserts it in one statement.
- A user-defined record (`t_line` in `student_transcript`) holds one transcript line made of columns from two tables.

## Collections
| Type | Used for |
|---|---|
| Nested table | Holds rows fetched by BULK COLLECT (`t_enr_tab`) and drives FORALL |
| Associative array | Course averages keyed by course code; grade counts keyed by letter |
| VARRAY | Fixed list of the 5 grade labels |

## Cursors
- **Implicit:** `SQL%ROWCOUNT`, `SQL%FOUND`, `SQL%NOTFOUND` after INSERT / UPDATE / DELETE (`add_student`, `update_marks`, `drop_enrollment`).
- **Explicit:** parameterized cursor with OPEN / FETCH / CLOSE (`student_transcript`, `calculate_gpa`); cursor FOR loop (`course_summary`). Cursors are closed in the exception handler if still open.

## Bulk processing and performance
**Row-by-row** processing in a PL/SQL loop sends one SQL statement per row. Each statement causes a *context switch* between the PL/SQL engine and the SQL engine. For thousands of rows these switches dominate the run time.

**Bulk processing** removes most switches:
- `BULK COLLECT` fetches all rows into a collection in one switch.
- `FORALL` sends the whole collection to the SQL engine in one switch for INSERT / UPDATE / DELETE.

`03_tests/test_performance.sql` inserts 100,000 rows both ways and prints the timings (Result with 100,000 rows: row-by-row = 8.19 s, FORALL = 0.44 s. FORALL was about 18 times faster because it avoids 100,000 context switches. Screenshot: screenshots/07_test_performance_output.png

Caution: BULK COLLECT without LIMIT loads everything into memory. For very large tables, fetch in batches (`FETCH ... BULK COLLECT INTO ... LIMIT 1000`).

**Bulk errors:** `FORALL ... SAVE EXCEPTIONS` keeps going after a failing row and raises ORA-24381 at the end. `bulk_adjust_marks` catches it, reads `SQL%BULK_EXCEPTIONS` (row index and error code) and reports every failed row, while the good rows are still updated.

## Exception handling strategy
- Predefined: NO_DATA_FOUND, TOO_MANY_ROWS, DUP_VAL_ON_INDEX.
- User-defined: `e_invalid_email`, `e_not_active`, `e_has_history` (mapped to ORA-02292 with `PRAGMA EXCEPTION_INIT`), `e_bulk_errors` (ORA-24381).
- Every handler either raises a meaningful `RAISE_APPLICATION_ERROR` or re-raises (`RAISE`); no `WHEN OTHERS THEN NULL`. Functions raise errors instead of returning fake values such as `0` or `NULL` for a missing student.

## Error code table
| Code | Meaning |
|---|---|
| -20001 / -20002 | Duplicate student / invalid email |
| -20010 | Marks outside 0..100 |
| -20011 / -20012 / -20013 / -20014 | Enroll: not active / no student / no course / duplicate |
| -20020 / -20021 | GPA: student not found / no graded courses |
| -20022 | Student name lookup: not found |
| -20023 / -20024 | Status lookup: too many / none |
| -20025 | Course not found (count_enrollments) |
| -20041 | Not enrolled (update_marks) |
| -20051 / -20052 | Drop: not found / has audit history |
| -20061 / -20062 | Bulk: course not found / transcript: student not found |

## Known limitation
`bulk_adjust_marks` changes marks only; run `bulk_grade_course` logic or `update_marks` again if grades must be refreshed.
