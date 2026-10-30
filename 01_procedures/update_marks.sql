-- Updates marks, sets the letter grade, and writes an audit row.
-- Implicit cursor attributes: SQL%NOTFOUND, SQL%FOUND, SQL%ROWCOUNT.
CREATE OR REPLACE PROCEDURE update_marks (
  p_student_id IN  NUMBER,
  p_course_id  IN  NUMBER,
  p_marks      IN  NUMBER,
  p_grade      OUT VARCHAR2
) IS
  v_enr_id    enrollments.enrollment_id%TYPE;
  v_old_grade enrollments.grade%TYPE;
BEGIN
  p_grade := get_letter_grade(p_marks);       -- raises -20010 for invalid marks

  BEGIN
    SELECT enrollment_id, grade INTO v_enr_id, v_old_grade
      FROM enrollments
     WHERE student_id = p_student_id AND course_id = p_course_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20041, 'Student ' || p_student_id || ' is not enrolled in course '
                                      || p_course_id);
  END;

  UPDATE enrollments
     SET marks = p_marks, grade = p_grade
   WHERE enrollment_id = v_enr_id;

  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20041, 'Enrollment disappeared during update');
  ELSIF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Marks updated, rows affected: ' || SQL%ROWCOUNT || ', new grade: ' || p_grade);
    INSERT INTO grade_audit (enrollment_id, old_grade, new_grade)
    VALUES (v_enr_id, v_old_grade, p_grade);
  END IF;
END update_marks;
/
