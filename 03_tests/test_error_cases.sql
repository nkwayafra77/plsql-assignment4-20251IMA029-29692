-- Every block below is EXPECTED to raise an error. The handler prints it so nothing is hidden.
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === E1: duplicate student (ORA-20001) ===
DECLARE v_msg VARCHAR2(200);
BEGIN add_student(101, 'Dup', 'User', 'dup@auca.ac.rw', v_msg);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E2: invalid email, user-defined exception (ORA-20002) ===
DECLARE v_msg VARCHAR2(200);
BEGIN add_student(108, 'No', 'Email', 'not-an-email', v_msg);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E3: suspended student cannot enroll (ORA-20011) ===
DECLARE v_id NUMBER;
BEGIN enroll_student(105, 1, v_id);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E4: duplicate enrollment (ORA-20014) ===
DECLARE v_id NUMBER;
BEGIN enroll_student(101, 1, v_id);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E5: unknown student (ORA-20012) and unknown course (ORA-20013) ===
DECLARE v_id NUMBER;
BEGIN enroll_student(999, 1, v_id);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
DECLARE v_id NUMBER;
BEGIN enroll_student(101, 99, v_id);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E6: marks out of range (ORA-20010) ===
DECLARE v_grade VARCHAR2(2);
BEGIN update_marks(101, 1, 150, v_grade);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E7: update marks for a student not enrolled (ORA-20041) ===
DECLARE v_grade VARCHAR2(2);
BEGIN update_marks(101, 4, 70, v_grade);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E8: drop enrollment that does not exist, SQL%NOTFOUND (ORA-20051) ===
DECLARE v_rows NUMBER;
BEGIN drop_enrollment(101, 4, v_rows);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E9: drop enrollment that has audit history, ORA-02292 mapped to ORA-20052 ===
DECLARE v_grade VARCHAR2(2); v_rows NUMBER;
BEGIN
  update_marks(101, 1, 90, v_grade);        -- creates an audit row
  drop_enrollment(101, 1, v_rows);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E10: GPA of unknown student (ORA-20020) and student without grades (ORA-20021) ===
BEGIN DBMS_OUTPUT.PUT_LINE(calculate_gpa(999));
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
BEGIN DBMS_OUTPUT.PUT_LINE(calculate_gpa(106));
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E11: TOO_MANY_ROWS (ORA-20023) and NO_DATA_FOUND (ORA-20024) inside a function ===
BEGIN DBMS_OUTPUT.PUT_LINE(get_student_by_status('ACTIVE'));
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
BEGIN DBMS_OUTPUT.PUT_LINE(get_student_by_status('EXPELLED'));
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E12: raw predefined exceptions caught directly ===
DECLARE v_id students.student_id%TYPE;
BEGIN
  SELECT student_id INTO v_id FROM students WHERE student_id = 999;
EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Caught NO_DATA_FOUND');
END;
/
DECLARE v_id students.student_id%TYPE;
BEGIN
  SELECT student_id INTO v_id FROM students WHERE status = 'ACTIVE';
EXCEPTION WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('Caught TOO_MANY_ROWS');
END;
/
PROMPT === E13: bulk DML errors with SAVE EXCEPTIONS (marks above 100) ===
DECLARE v_ok NUMBER; v_failed NUMBER;
BEGIN
  bulk_adjust_marks(1, 15, v_ok, v_failed);   -- any mark above 100 after the bonus breaks CHK_MARKS
  DBMS_OUTPUT.PUT_LINE('OK rows: ' || v_ok || ', failed rows: ' || v_failed);
END;
/
PROMPT === E14: bulk procedures with an unknown course (ORA-20061) ===
DECLARE v_graded NUMBER;
BEGIN bulk_grade_course(99, v_graded);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/
PROMPT === E15: transcript of unknown student (ORA-20062) ===
DECLARE v_credits NUMBER;
BEGIN student_transcript(999, v_credits);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/

ROLLBACK;
