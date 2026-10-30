-- Adds bonus marks to every marked enrollment of a course using FORALL ... SAVE EXCEPTIONS.
-- Rows that would break CHECK (marks <= 100) are reported; the other rows still succeed.
CREATE OR REPLACE PROCEDURE bulk_adjust_marks (
  p_course_id IN  NUMBER,
  p_bonus     IN  NUMBER,
  p_ok        OUT NUMBER,
  p_failed    OUT NUMBER
) IS
  TYPE t_id_tab    IS TABLE OF enrollments.enrollment_id%TYPE;
  TYPE t_marks_tab IS TABLE OF enrollments.marks%TYPE;
  v_ids   t_id_tab;
  v_marks t_marks_tab;
  v_course_id courses.course_id%TYPE;
  e_bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);   -- raised by SAVE EXCEPTIONS
BEGIN
  SELECT course_id INTO v_course_id FROM courses WHERE course_id = p_course_id;

  SELECT enrollment_id, marks BULK COLLECT INTO v_ids, v_marks
    FROM enrollments
   WHERE course_id = p_course_id AND marks IS NOT NULL;

  p_ok := 0;  p_failed := 0;
  IF v_ids.COUNT = 0 THEN RETURN; END IF;

  FOR i IN 1 .. v_marks.COUNT LOOP
    v_marks(i) := v_marks(i) + p_bonus;
  END LOOP;

  FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
    UPDATE enrollments SET marks = v_marks(i) WHERE enrollment_id = v_ids(i);

  p_ok := v_ids.COUNT;
EXCEPTION
  WHEN e_bulk_errors THEN
    p_failed := SQL%BULK_EXCEPTIONS.COUNT;
    p_ok     := v_ids.COUNT - p_failed;
    FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('  Failed row #' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX
        || ' (enrollment_id ' || v_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) || '): '
        || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
    END LOOP;
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20061, 'Course ' || p_course_id || ' not found');
END bulk_adjust_marks;
/
