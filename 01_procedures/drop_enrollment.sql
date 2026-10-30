-- Removes an enrollment (implicit cursor with DELETE).
-- Enrollments that already have audit history cannot be deleted (ORA-02292).
CREATE OR REPLACE PROCEDURE drop_enrollment (
  p_student_id   IN  NUMBER,
  p_course_id    IN  NUMBER,
  p_rows_deleted OUT NUMBER
) IS
  e_has_history EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_has_history, -2292);   -- child record found
BEGIN
  DELETE FROM enrollments
   WHERE student_id = p_student_id AND course_id = p_course_id;

  p_rows_deleted := SQL%ROWCOUNT;

  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20051, 'No enrollment found for student ' || p_student_id
                                    || ' in course ' || p_course_id);
  END IF;
EXCEPTION
  WHEN e_has_history THEN
    RAISE_APPLICATION_ERROR(-20052, 'Cannot delete: this enrollment has grade audit history');
END drop_enrollment;
/
