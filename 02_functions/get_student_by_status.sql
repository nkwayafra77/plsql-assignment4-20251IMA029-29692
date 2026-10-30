-- Returns the id of the ONLY student with the given status.
-- Demonstrates NO_DATA_FOUND and TOO_MANY_ROWS.
CREATE OR REPLACE FUNCTION get_student_by_status (p_status IN VARCHAR2)
RETURN NUMBER
IS
  v_student_id students.student_id%TYPE;
BEGIN
  SELECT student_id INTO v_student_id FROM students WHERE status = UPPER(p_status);
  RETURN v_student_id;
EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20023, 'More than one student has status ' || p_status);
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20024, 'No student has status ' || p_status);
END get_student_by_status;
/
