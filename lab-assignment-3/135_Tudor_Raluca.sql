--Tema 3--
--1--
SELECT s_id "Cod", s_last || ' ' || s_first "Student sau curs", 'Student' "Tip"
FROM student
WHERE f_id = (SELECT f_id           -- presupun ca exista un singur profesor cu numele Brown (= si nu IN)
              FROM faculty 
              WHERE f_last = 'Brown') 
UNION
SELECT course_no "Cod", course_name "Student sau curs", 'Curs'
FROM course
WHERE course_no IN (SELECT course_no
                    FROM course_section
                    WHERE f_id = (SELECT f_id           -- presupun ca exista un singur profesor cu numele Brown (= si nu IN)
                                  FROM faculty 
                                  WHERE f_last = 'Brown'));

--2--
SELECT s.s_id, s.s_last, s.s_first
FROM student s
WHERE (SELECT COUNT(1)
       FROM enrollment
            JOIN course_section USING ( c_sec_id )
            JOIN course USING ( course_no )
       WHERE s_id = s.s_id
             AND course_name = 'Programming in C++'
      ) = 0
      AND 
      (SELECT COUNT(1)
       FROM enrollment
            JOIN course_section USING ( c_sec_id )
            JOIN course USING ( course_no )
       WHERE s_id = s.s_id
             AND course_name = 'Database Management'
      ) > 0;

--3--
SELECT s.s_id, s.s_last, s.s_first
FROM student s
WHERE
    (
        SELECT COUNT(1)
        FROM enrollment
        WHERE
            ( ( grade = 'C' )
              OR grade = NULL )
            AND s_id = s.s_id
    ) > 0;

--4--
SELECT l.loc_id, l.bldg_code, l.capacity
FROM location l
WHERE
    (
        SELECT COUNT(*)
        FROM location
        WHERE capacity > l.capacity
    ) = 0;

--5--
CREATE TABLE t (id NUMBER PRIMARY KEY); 
INSERT INTO t VALUES(1);
INSERT INTO t VALUES(2); 
INSERT INTO t VALUES(4); 
INSERT INTO t VALUES(6);
INSERT INTO t VALUES(8); 
INSERT INTO t VALUES(9);

SELECT MIN(id) + 1 "Min"
FROM T
WHERE id + 1 NOT IN (SELECT id FROM t);

SELECT MAX(id) - 1 "Max"
FROM T
WHERE id - 1 NOT IN (SELECT id FROM t);
       
--6--
-- v1
SELECT
    f.f_id "Cod profesor",
    f.f_last || ' ' || f.f_first "Nume Profesor",
    decode((SELECT COUNT(1)
            FROM student s
            WHERE s.f_id = f.f_id
            ), 0, 'Nu', 'Da (' || (SELECT COUNT(1)
                                   FROM student s
                                   WHERE s.f_id = f.f_id) || ')') "Student",
    decode((SELECT COUNT(DISTINCT course_no)
            FROM course_section c
            WHERE c.f_id = f.f_id
            ), 0, 'Nu', 'Da (' || (SELECT COUNT(DISTINCT course_no)
                                   FROM course_section c
                                   WHERE c.f_id = f.f_id) || ')') "Curs"
FROM faculty f
GROUP BY f.f_id, f.f_last || ' ' || f.f_first;

-- v2 (obtin acelasi rezultat cu v1)
SELECT
    f.f_id "Cod profesor",
    f.f_last || ' ' || f.f_first "Nume Profesor",
    decode(nvl(s.nr, 0), 0, 'Nu', 'Da (' || s.nr || ')') "Student",
    decode(nvl(c.nr, 0), 0, 'Nu', 'Da (' || c.nr || ')') "Curs" 
FROM
    faculty f,
    (SELECT
     COUNT(1) AS nr, f_id
     FROM student
     GROUP BY f_id
    ) s,
    (SELECT
     COUNT(DISTINCT course_no) nr, f_id
     FROM course_section
     GROUP BY f_id
    ) c
WHERE s.f_id (+) = f.f_id
      AND c.f_id (+) = f.f_id;

--testare
--SELECT DISTINCT f_last
--FROM student RIGHT OUTER JOIN faculty USING (f_id);

--7--
SELECT t1.term_desc, t2.term_desc
FROM term t1, term t2              -- CROSS JOIN
WHERE SUBSTR(t1.term_desc, 0, LENGTH(t1.term_desc) - 1) = SUBSTR(t2.term_desc, 0, LENGTH(t2.term_desc) - 1)
      AND t1.term_desc != t2.term_desc
      AND t1.term_desc < t2.term_desc;  -- pt. a nu selecta perechile de 2 ori
      
--8--
-- daca cele doua cursuri difera pe al cincilea caracter
WITH curs AS (
    SELECT *
    FROM student s JOIN enrollment e USING ( s_id ) JOIN course_section c1 USING ( c_sec_id )
)
SELECT DISTINCT
    c1.s_id "Cod Student", c1.s_last "Nume", c1.s_first "Prenume",
    c1.course_no "Curs 1",
    c2.course_no "Curs 2"
FROM curs c1 JOIN curs c2 ON ( c1.s_id = c2.s_id )
WHERE
    ( SUBSTR(c1.course_no, 5, 1) != SUBSTR(c2.course_no, 5, 1) )
    AND ( c1.course_no != c2.course_no )
    AND ( c1.course_no < c2.course_no );

-- daca cele doua cursuri difera DOAR pe al cincilea caracter
WITH curs AS (
    SELECT *
    FROM student s JOIN enrollment e USING ( s_id ) JOIN course_section c1 USING ( c_sec_id )
)
SELECT DISTINCT
    c1.s_id "Cod Student", c1.s_last "Nume", c1.s_first "Prenume",
    c1.course_no "Curs 1",
    c2.course_no "Curs 2"
FROM curs c1 JOIN curs c2 ON ( c1.s_id = c2.s_id )
WHERE
   ( SUBSTR(c1.course_no, 1, 4) || SUBSTR(c1.course_no, 6, 10) ) = ( SUBSTR(c2.course_no, 1, 4) || SUBSTR(c2.course_no, 6, 10) )
    AND ( c1.course_no != c2.course_no )
    AND ( c1.course_no < c2.course_no );

--9--
SELECT
    c1.course_no,
    c2.course_no
FROM
    course_section   c1
    JOIN course_section   c2 USING ( term_id )
WHERE
    c1.course_no > c2.course_no;

--10--
SELECT c_sec_id "Cod", course_no "Numele cursului", term_desc "Denumirea semestrului", max_enrl "Nr. locuri"
FROM course_section JOIN term USING (term_id)
WHERE max_enrl < (SELECT MIN(max_enrl) 
                  FROM course_section 
                  WHERE loc_id = 1);

--11--
SELECT DISTINCT course_name, cs.max_enrl
FROM course_section cs JOIN course USING (course_no)
WHERE (SELECT COUNT(*)
       FROM Course_section 
       WHERE max_enrl < cs.max_enrl) = 0;

--12--
SELECT f_last, f_first, ROUND(AVG(max_enrl), 2) "Nr. mediu de locuri"
FROM faculty JOIN course_section USING (f_id)
GROUP BY f_last, f_first;

--13--
-- v1
SELECT f.f_id, f.f_last, f.f_first, COUNT(1) "Nr studenti coordonati"
FROM faculty f JOIN student s ON (s.f_id = f.f_id)
GROUP BY f.f_id, f.f_last, f.f_first
HAVING COUNT(1) >= 3;

-- v2
SELECT f.f_id, f.f_last, f.f_first, (SELECT COUNT(1)
                                     FROM STUDENT
                                     WHERE f_id = f.f_id) "Nr studenti coordonati"
FROM faculty f
WHERE (SELECT COUNT(1)
       FROM STUDENT
       WHERE f_id = f.f_id) >= 3;

-- v3
SELECT f.f_id, f.f_last, f.f_first, s.nr "Nr studenti coordonati"
FROM faculty f, (SELECT COUNT(1) nr, f_id 
                 FROM student 
                 GROUP BY f_id) s
WHERE s.f_id = f.f_id AND s.nr >= 3;

--14--
-- v1
SELECT c.course_name, l.capacity "Capacitatea maxima", cs.loc_id "Codul locatiei"
FROM course c JOIN course_section cs ON (c.course_no = cs.course_no) JOIN location l ON (cs.loc_id = l.loc_id)
GROUP BY c.course_no, c.course_name, cs.loc_id, l.capacity
HAVING (SELECT COUNT(1) 
        FROM location l2 JOIN course_section c2 USING (loc_id)
        WHERE l2.capacity > l.capacity AND c2.course_no = c.course_no) = 0
ORDER BY 1, 2;

--v2
SELECT DISTINCT c.course_name, l.capacity, l.loc_id
FROM course c JOIN course_section cs ON (c.course_no = cs.course_no) JOIN location l ON (cs.loc_id = l.loc_id)
WHERE l.capacity = (SELECT max(capacity)
                    FROM course_section JOIN location USING (loc_id)
                    GROUP BY course_no
                    HAVING course_no = cs.course_no)
ORDER BY 1, 2;

-- sau
-- Atentie, varianta de mai jos afiseaza capacitatea maxima pt toate locatiile unde s-a desfasurat cursul
--v3
SELECT c.course_name, MAX(l.capacity) "Capacitatea maxima", cs.loc_id "Codul locatiei"
FROM course c JOIN course_section cs ON (c.course_no = cs.course_no) JOIN location l ON (cs.loc_id = l.loc_id)
GROUP BY c.course_no, c.course_name, cs.loc_id, l.capacity
ORDER BY 1, 2;

-- v4, echivalenta cu v3
SELECT DISTINCT c.course_name, l.max_cap as "Capacitatea maxima", cs.loc_id "Codul locatiei"
FROM course c join course_section cs ON (c.course_no = cs.course_no),
    (SELECT MAX(capacity) max_cap, loc_id 
     FROM location 
     GROUP BY loc_id) l
WHERE l.loc_id = cs.loc_id
ORDER BY 1, 2;

--15--
SELECT t.term_desc, ROUND(AVG(cs.max_enrl),2) "Medie locuri cursuri"
FROM term t JOIN course_section cs ON (t.term_id = cs.term_id)
WHERE t.term_desc LIKE '%2007%'
GROUP BY t.term_desc;
