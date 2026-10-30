-- Drop in reverse order (safe re-run)
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('GRADE_AUDIT','ENROLLMENTS','COURSES','STUDENTS')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/

CREATE TABLE students (
  student_id    NUMBER         PRIMARY KEY,
  first_name    VARCHAR2(50)   NOT NULL,
  last_name     VARCHAR2(50)   NOT NULL,
  email         VARCHAR2(100)  NOT NULL UNIQUE,
  status        VARCHAR2(10)   DEFAULT 'ACTIVE' NOT NULL,
  registered_on DATE           DEFAULT SYSDATE,
  CONSTRAINT chk_student_status CHECK (status IN ('ACTIVE','SUSPENDED','GRADUATED'))
);

CREATE TABLE courses (
  course_id    NUMBER         PRIMARY KEY,
  course_code  VARCHAR2(10)   NOT NULL UNIQUE,
  course_name  VARCHAR2(100)  NOT NULL,
  credits      NUMBER(1)      NOT NULL,
  CONSTRAINT chk_credits CHECK (credits BETWEEN 1 AND 6)
);

CREATE TABLE enrollments (
  enrollment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  student_id    NUMBER NOT NULL,
  course_id     NUMBER NOT NULL,
  marks         NUMBER(5,2),
  grade         VARCHAR2(2),
  enrolled_on   DATE DEFAULT SYSDATE,
  CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students(student_id),
  CONSTRAINT fk_enr_course  FOREIGN KEY (course_id)  REFERENCES courses(course_id),
  CONSTRAINT uq_student_course UNIQUE (student_id, course_id),
  CONSTRAINT chk_marks CHECK (marks BETWEEN 0 AND 100)
);

CREATE TABLE grade_audit (
  audit_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  enrollment_id NUMBER NOT NULL,
  old_grade     VARCHAR2(2),
  new_grade     VARCHAR2(2),
  changed_on    DATE DEFAULT SYSDATE,
  CONSTRAINT fk_audit_enr FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);
