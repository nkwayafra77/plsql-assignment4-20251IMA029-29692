-- Run in SQL Developer as a script (F5) or SQL*Plus. Ends with ROLLBACK so it can be re-run.
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === S1: add_student ===
DECLARE v_msg VARCHAR2(200);
BEGIN
  add_student(107, 'Grace', 'Uwera', 'grace@auca.ac.rw', v_msg);
  DBMS_OUTPUT.PUT_LINE(v_msg);
END;
/

PROMPT === S2: enroll_student ===
DECLARE v_id NUMBER;
BEGIN
  enroll_student(101, 3, v_id);
  DBMS_OUTPUT.PUT_LINE('New enrollment id: ' || v_id);
END;
/

PROMPT === S3: update_marks (single row, implicit cursor + audit) ===
DECLARE v_grade VARCHAR2(2);
BEGIN
  update_marks(103, 1, 91, v_grade);
  DBMS_OUTPUT.PUT_LINE('Grade returned: ' || v_grade);
END;
/

PROMPT === S4: bulk_grade_course (BULK COLLECT + FORALL) ===
BEGIN
  UPDATE enrollments SET marks = 58 WHERE student_id = 103 AND course_id = 4;
  UPDATE enrollments SET marks = 83 WHERE student_id = 104 AND course_id = 4;
END;
/
DECLARE v_graded NUMBER;
BEGIN
  bulk_grade_course(4, v_graded);
  DBMS_OUTPUT.PUT_LINE('Graded: ' || v_graded);
END;
/
SELECT e.student_id, e.course_id, e.marks, e.grade FROM enrollments e WHERE course_id = 4;
SELECT * FROM grade_audit ORDER BY audit_id;

PROMPT === S5: bulk_adjust_marks (+5 bonus, no failures) ===
DECLARE v_ok NUMBER; v_failed NUMBER;
BEGIN
  bulk_adjust_marks(1, 5, v_ok, v_failed);
  DBMS_OUTPUT.PUT_LINE('OK: ' || v_ok || ', failed: ' || v_failed);
END;
/

PROMPT === S6: student_transcript (explicit cursor OPEN/FETCH/CLOSE) ===
DECLARE v_credits NUMBER;
BEGIN
  student_transcript(101, v_credits);
  DBMS_OUTPUT.PUT_LINE('Credits returned: ' || v_credits);
END;
/

PROMPT === S7: course_summary (associative array, VARRAY, cursor FOR loop) ===
BEGIN course_summary; END;
/

PROMPT === S8: functions called from SQL ===
SELECT student_id, get_student_name(student_id) AS name, calculate_gpa(student_id) AS gpa
  FROM students WHERE student_id IN (101, 102);
SELECT course_code, count_enrollments(course_id) AS enrolled FROM courses;
SELECT get_letter_grade(85) AS g85, get_letter_grade(49.5) AS g49 FROM dual;
SELECT get_student_by_status('SUSPENDED') AS suspended_id FROM dual;

PROMPT === S9: functions called from an anonymous block ===
BEGIN
  DBMS_OUTPUT.PUT_LINE('GPA of 101: ' || calculate_gpa(101));
  DBMS_OUTPUT.PUT_LINE('Name of 104: ' || get_student_name(104));
END;
/

ROLLBACK;
