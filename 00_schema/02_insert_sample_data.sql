-- STUDENTS (105 is SUSPENDED, 106 is GRADUATED: used for error tests)
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (101, 'Alice',  'Uwase',    'alice@auca.ac.rw',  'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (102, 'Brian',  'Mugisha',  'brian@auca.ac.rw',  'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (103, 'Chantal','Ineza',    'chantal@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (104, 'David',  'Nkusi',    'david@auca.ac.rw',  'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (105, 'Esther', 'Mukamana', 'esther@auca.ac.rw', 'SUSPENDED');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (106, 'Frank',  'Habimana', 'frank@auca.ac.rw',  'GRADUATED');

-- COURSES
INSERT INTO courses (course_id, course_code, course_name, credits) VALUES (1, 'INSY8311', 'Database Development with PL/SQL', 4);
INSERT INTO courses (course_id, course_code, course_name, credits) VALUES (2, 'INSY8212', 'Systems Analysis and Design',       3);
INSERT INTO courses (course_id, course_code, course_name, credits) VALUES (3, 'CSC8101',  'Data Structures',                   4);
INSERT INTO courses (course_id, course_code, course_name, credits) VALUES (4, 'MAT8102',  'Discrete Mathematics',              3);

-- ENROLLMENTS (some marks are NULL so they can be graded later)
INSERT INTO enrollments (student_id, course_id, marks, grade) VALUES (101, 1, 88, 'A');
INSERT INTO enrollments (student_id, course_id, marks, grade) VALUES (101, 2, 74, 'B');
INSERT INTO enrollments (student_id, course_id, marks, grade) VALUES (102, 1, 65, 'C');
INSERT INTO enrollments (student_id, course_id, marks, grade) VALUES (102, 3, NULL, NULL);
INSERT INTO enrollments (student_id, course_id, marks, grade) VALUES (103, 1, NULL, NULL);
INSERT INTO enrollments (student_id, course_id, marks, grade) VALUES (103, 2, NULL, NULL);
INSERT INTO enrollments (student_id, course_id, marks, grade) VALUES (103, 4, NULL, NULL);
INSERT INTO enrollments (student_id, course_id, marks, grade) VALUES (104, 3, 52, 'D');
INSERT INTO enrollments (student_id, course_id, marks, grade) VALUES (104, 4, NULL, NULL);

COMMIT;
