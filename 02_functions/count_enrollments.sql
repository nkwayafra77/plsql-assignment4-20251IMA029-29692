-- Number of students enrolled in a course. Can be used directly inside SQL.
CREATE OR REPLACE FUNCTION count_enrollments (p_course_id IN NUMBER)
RETURN NUMBER
IS
  v_course_id courses.course_id%TYPE;
  v_count     NUMBER;
BEGIN
  SELECT course_id INTO v_course_id FROM courses WHERE course_id = p_course_id;
  SELECT COUNT(*) INTO v_count FROM enrollments WHERE course_id = p_course_id;
  RETURN v_count;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20025, 'Course ' || p_course_id || ' not found');
END count_enrollments;
/
