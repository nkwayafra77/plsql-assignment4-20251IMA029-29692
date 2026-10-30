-- Prints a student's transcript. User-defined record + parameterized explicit cursor
-- with OPEN / FETCH / CLOSE.
CREATE OR REPLACE PROCEDURE student_transcript (
  p_student_id    IN  NUMBER,
  p_total_credits OUT NUMBER
) IS
  TYPE t_line IS RECORD (                      -- user-defined record
    course_code courses.course_code%TYPE,
    course_name courses.course_name%TYPE,
    credits     courses.credits%TYPE,
    marks       enrollments.marks%TYPE,
    grade       enrollments.grade%TYPE
  );
  r_line    t_line;
  r_student students%ROWTYPE;                  -- %ROWTYPE record
  v_lines   PLS_INTEGER := 0;

  CURSOR c_lines (cp_student_id NUMBER) IS
    SELECT c.course_code, c.course_name, c.credits, e.marks, e.grade
      FROM enrollments e
      JOIN courses c ON c.course_id = e.course_id
     WHERE e.student_id = cp_student_id
     ORDER BY c.course_code;
BEGIN
  p_total_credits := 0;

  BEGIN
    SELECT * INTO r_student FROM students WHERE student_id = p_student_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20062, 'Student ' || p_student_id || ' not found');
  END;

  DBMS_OUTPUT.PUT_LINE('TRANSCRIPT: ' || r_student.first_name || ' ' || r_student.last_name
                       || ' [' || r_student.status || ']');

  OPEN c_lines(p_student_id);
  LOOP
    FETCH c_lines INTO r_line;
    EXIT WHEN c_lines%NOTFOUND;
    v_lines := v_lines + 1;
    p_total_credits := p_total_credits + r_line.credits;
    DBMS_OUTPUT.PUT_LINE('  ' || RPAD(r_line.course_code, 10) || RPAD(r_line.course_name, 36)
      || ' cr=' || r_line.credits
      || ' marks=' || NVL(TO_CHAR(r_line.marks), '-')
      || ' grade=' || NVL(r_line.grade, '-'));
  END LOOP;
  CLOSE c_lines;

  DBMS_OUTPUT.PUT_LINE('  Courses: ' || v_lines || ', total credits: ' || p_total_credits);
EXCEPTION
  WHEN OTHERS THEN
    IF c_lines%ISOPEN THEN CLOSE c_lines; END IF;
    RAISE;
END student_transcript;
/
