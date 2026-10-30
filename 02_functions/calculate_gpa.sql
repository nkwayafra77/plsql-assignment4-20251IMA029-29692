-- Credit-weighted GPA (A=4, B=3, C=2, D=1, F=0). Uses an explicit cursor and a %ROWTYPE record.
CREATE OR REPLACE FUNCTION calculate_gpa (p_student_id IN NUMBER)
RETURN NUMBER
IS
  v_student_id    students.student_id%TYPE;
  v_points        NUMBER;
  v_total_credits NUMBER := 0;
  v_weighted      NUMBER := 0;

  CURSOR c_grades IS
    SELECT c.credits, e.grade
      FROM enrollments e
      JOIN courses c ON c.course_id = e.course_id
     WHERE e.student_id = p_student_id
      AND e.grade IS NOT NULL;

  r_grade c_grades%ROWTYPE;   -- %ROWTYPE record based on a cursor
BEGIN
  -- Predefined exception NO_DATA_FOUND is raised here if the student does not exist
  SELECT student_id INTO v_student_id FROM students WHERE student_id = p_student_id;

  OPEN c_grades;
  LOOP
    FETCH c_grades INTO r_grade;
    EXIT WHEN c_grades%NOTFOUND;

    v_points := CASE r_grade.grade
                  WHEN 'A' THEN 4 WHEN 'B' THEN 3 WHEN 'C' THEN 2 WHEN 'D' THEN 1 ELSE 0
                END;
    v_weighted      := v_weighted + v_points * r_grade.credits;
    v_total_credits := v_total_credits + r_grade.credits;
  END LOOP;
  CLOSE c_grades;

  IF v_total_credits = 0 THEN
    RAISE_APPLICATION_ERROR(-20021, 'Student ' || p_student_id || ' has no graded courses yet');
  END IF;

  RETURN ROUND(v_weighted / v_total_credits, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20020, 'Student ' || p_student_id || ' not found');
  WHEN OTHERS THEN
    IF c_grades%ISOPEN THEN CLOSE c_grades; END IF;
    RAISE;   -- re-raise: unexpected errors are never hidden
END calculate_gpa;
/
