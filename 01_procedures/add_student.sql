-- Registers a new student. Uses a %ROWTYPE record + implicit cursor (SQL%ROWCOUNT).
CREATE OR REPLACE PROCEDURE add_student (
  p_student_id IN  NUMBER,
  p_first_name IN  VARCHAR2,
  p_last_name  IN  VARCHAR2,
  p_email      IN  VARCHAR2,
  p_message    OUT VARCHAR2
) IS
  r_student        students%ROWTYPE;
  e_invalid_email  EXCEPTION;                 -- user-defined exception
BEGIN
  IF p_email IS NULL OR INSTR(p_email, '@') = 0 THEN
    RAISE e_invalid_email;
  END IF;

  r_student.student_id    := p_student_id;
  r_student.first_name    := p_first_name;
  r_student.last_name     := p_last_name;
  r_student.email         := p_email;
  r_student.status        := 'ACTIVE';
  r_student.registered_on := SYSDATE;

  INSERT INTO students VALUES r_student;      -- insert a whole record

  IF SQL%ROWCOUNT = 1 THEN
    p_message := 'Student ' || p_student_id || ' registered (' || SQL%ROWCOUNT || ' row inserted)';
  END IF;
EXCEPTION
  WHEN e_invalid_email THEN
    RAISE_APPLICATION_ERROR(-20002, 'Invalid email address: ' || NVL(p_email, 'NULL'));
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20001, 'Student ID ' || p_student_id || ' or email already exists');
END add_student;
/
