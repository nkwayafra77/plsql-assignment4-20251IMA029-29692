-- Converts marks to a letter grade. Raises an error for invalid marks (never guesses).
CREATE OR REPLACE FUNCTION get_letter_grade (p_marks IN NUMBER)
RETURN VARCHAR2 DETERMINISTIC
IS
BEGIN
  IF p_marks IS NULL OR p_marks < 0 OR p_marks > 100 THEN
    RAISE_APPLICATION_ERROR(-20010, 'Marks must be between 0 and 100 (received: '
                                    || NVL(TO_CHAR(p_marks), 'NULL') || ')');
  END IF;

  RETURN CASE
           WHEN p_marks >= 80 THEN 'A'
           WHEN p_marks >= 70 THEN 'B'
           WHEN p_marks >= 60 THEN 'C'
           WHEN p_marks >= 50 THEN 'D'
           ELSE 'F'
         END;
END get_letter_grade;
/
