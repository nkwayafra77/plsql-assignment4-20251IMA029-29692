-- Enrolls an ACTIVE student in a course and returns the new enrollment id.
CREATE OR REPLACE PROCEDURE enroll_student (
  p_student_id    IN  NUMBER,
  p_course_id     IN  NUMBER,
  p_enrollment_id OUT NUMBER
) IS
  r_student     students%ROWTYPE;
  v_course_code courses.course_code%TYPE;
  e_not_active  EXCEPTION;                    -- user-defined exception
BEGIN
  BEGIN
    SELECT * INTO r_student FROM students WHERE student_id = p_student_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20012, 'Student ' || p_student_id || ' does not exist');
  END;

  BEGIN
    SELECT course_code INTO v_course_code FROM courses WHERE course_id = p_course_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20013, 'Course ' || p_course_id || ' does not exist');
  END;

  IF r_student.status <> 'ACTIVE' THEN
    RAISE e_not_active;
  END IF;

  INSERT INTO enrollments (student_id, course_id)
  VALUES (p_student_id, p_course_id)
  RETURNING enrollment_id INTO p_enrollment_id;

  DBMS_OUTPUT.PUT_LINE('Enrolled ' || r_student.first_name || ' in ' || v_course_code
                       || ' (rows inserted: ' || SQL%ROWCOUNT || ')');
EXCEPTION
  WHEN e_not_active THEN
    RAISE_APPLICATION_ERROR(-20011, 'Student ' || p_student_id || ' is ' || r_student.status
                                    || ' and cannot enroll');
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20014, 'Student ' || p_student_id || ' is already enrolled in course '
                                    || p_course_id);
END enroll_student;
/
