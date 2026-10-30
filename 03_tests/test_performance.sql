-- Row-by-row vs FORALL. Uses a scratch table that is dropped at the end.
SET SERVEROUTPUT ON SIZE UNLIMITED
CREATE TABLE perf_demo (id NUMBER, val NUMBER);

DECLARE
  c_rows CONSTANT PLS_INTEGER := 100000;
  TYPE t_num_tab IS TABLE OF NUMBER;
  v_ids  t_num_tab := t_num_tab();
  v_t0   NUMBER;
BEGIN
  v_ids.EXTEND(c_rows);
  FOR i IN 1 .. c_rows LOOP v_ids(i) := i; END LOOP;

  -- 1) row by row: one SQL call per row (context switch each time)
  v_t0 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1 .. c_rows LOOP
    INSERT INTO perf_demo (id, val) VALUES (v_ids(i), v_ids(i) * 2);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Row-by-row insert : ' || (DBMS_UTILITY.GET_TIME - v_t0) || ' hundredths of a second');
  ROLLBACK;

  -- 2) FORALL: one SQL call for all rows
  v_t0 := DBMS_UTILITY.GET_TIME;
  FORALL i IN 1 .. c_rows
    INSERT INTO perf_demo (id, val) VALUES (v_ids(i), v_ids(i) * 2);
  DBMS_OUTPUT.PUT_LINE('FORALL insert     : ' || (DBMS_UTILITY.GET_TIME - v_t0) || ' hundredths of a second');
  ROLLBACK;
END;
/
DROP TABLE perf_demo PURGE;
