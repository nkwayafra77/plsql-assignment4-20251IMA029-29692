-- Grades ALL ungraded-but-marked enrollments of a course in bulk.
-- BULK COLLECT (nested table of records) + FORALL UPDATE + FORALL INSERT (audit).
CREATE OR REPLACE PROCEDURE bulk_grade_course (
  p_course_id IN  NUMBER,
  p_graded    OUT NUMBER
) IS
  TYPE t_enr_tab   IS TABLE OF enrollments%ROWTYPE;                  -- nested table of records
  TYPE t_id_tab    IS TABLE OF enrollments.enrollment_id%TYPE;       -- nested table
  TYPE t_grade_tab IS TABLE OF enrollments.grade%TYPE;               -- nested table

  v_enr    t_enr_tab;
  v_ids    t_id_tab    := t_id_tab();
  v_grades t_grade_tab := t_grade_tab();
  v_course_id courses.course_id%TYPE;
BEGIN
  SELECT course_id INTO v_course_id FROM courses WHERE course_id = p_course_id;

  -- ONE trip to the SQL engine for all rows
  SELECT * BULK COLLECT INTO v_enr
    FROM enrollments
   WHERE course_id = p_course_id AND marks IS NOT NULL AND grade IS NULL;

  p_graded := v_enr.COUNT;
  IF v_enr.COUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nothing to grade for course ' || p_course_id);
    RETURN;
  END IF;

  v_ids.EXTEND(v_enr.COUNT);
  v_grades.EXTEND(v_enr.COUNT);
  FOR i IN 1 .. v_enr.COUNT LOOP
    v_ids(i)    := v_enr(i).enrollment_id;
    v_grades(i) := get_letter_grade(v_enr(i).marks);
  END LOOP;

  -- ONE trip for all updates
  FORALL i IN 1 .. v_ids.COUNT
    UPDATE enrollments SET grade = v_grades(i) WHERE enrollment_id = v_ids(i);
  DBMS_OUTPUT.PUT_LINE('Bulk updated rows: ' || SQL%ROWCOUNT);

  -- ONE trip for all audit rows
  FORALL i IN 1 .. v_ids.COUNT
    INSERT INTO grade_audit (enrollment_id, old_grade, new_grade)
    VALUES (v_ids(i), NULL, v_grades(i));
  DBMS_OUTPUT.PUT_LINE('Bulk audit rows inserted: ' || SQL%ROWCOUNT);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20061, 'Course ' || p_course_id || ' not found');
END bulk_grade_course;
/
