-- Returns "First Last" for a student id (uses a %ROWTYPE record).
CREATE OR REPLACE FUNCTION get_student_name (p_student_id IN NUMBER)
RETURN VARCHAR2
IS
  r_student students%ROWTYPE;
BEGIN
  SELECT * INTO r_student FROM students WHERE student_id = p_student_id;
  RETURN r_student.first_name || ' ' || r_student.last_name;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20022, 'Student ' || p_student_id || ' not found');
END get_student_name;
/
