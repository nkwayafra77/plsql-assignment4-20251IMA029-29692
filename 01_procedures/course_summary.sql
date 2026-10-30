-- Course averages (associative array indexed by course code) and grade distribution
-- (VARRAY of labels + associative array of counts). Uses cursor FOR loops.
CREATE OR REPLACE PROCEDURE course_summary IS
  TYPE t_avg_tab    IS TABLE OF NUMBER INDEX BY VARCHAR2(10);        -- associative array
  TYPE t_count_tab  IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(2);    -- associative array
  TYPE t_label_arr  IS VARRAY(5) OF VARCHAR2(2);                     -- VARRAY

  v_labels t_label_arr := t_label_arr('A', 'B', 'C', 'D', 'F');
  v_avg    t_avg_tab;
  v_counts t_count_tab;
  v_key    VARCHAR2(10);

  CURSOR c_avg IS
    SELECT c.course_code, AVG(e.marks) AS avg_marks
      FROM courses c
      LEFT JOIN enrollments e ON e.course_id = c.course_id
     GROUP BY c.course_code;
BEGIN
  FOR r IN c_avg LOOP                                  -- cursor FOR loop
    IF r.avg_marks IS NOT NULL THEN
      v_avg(r.course_code) := ROUND(r.avg_marks, 1);
    END IF;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Average marks per course:');
  v_key := v_avg.FIRST;
  WHILE v_key IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE('  ' || RPAD(v_key, 10) || v_avg(v_key));
    v_key := v_avg.NEXT(v_key);
  END LOOP;

  FOR i IN 1 .. v_labels.COUNT LOOP
    v_counts(v_labels(i)) := 0;
  END LOOP;

  FOR r IN (SELECT grade, COUNT(*) AS cnt FROM enrollments
             WHERE grade IS NOT NULL GROUP BY grade) LOOP
    v_counts(r.grade) := r.cnt;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Grade distribution:');
  FOR i IN 1 .. v_labels.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('  ' || v_labels(i) || ': ' || v_counts(v_labels(i)));
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('course_summary failed: ' || SQLERRM);
    RAISE;
END course_summary;
/
