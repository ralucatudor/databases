-- Tema nr. 4 --
--01--
SELECT s.s_first, s.s_last
FROM student s
WHERE NOT EXISTS (SELECT *
                  FROM enrollment e
                  WHERE s.s_id = e.s_id AND grade IS NULL);

--02--
WITH not_in_course_sec AS
    (SELECT bldg_code
     FROM location
     WHERE loc_id NOT IN (SELECT DISTINCT loc_id FROM course_section))
SELECT bldg_code
FROM location
WHERE bldg_code NOT IN (SELECT * FROM not_in_course_sec);

--03--
SELECT f.f_first, f.f_last
FROM faculty f
WHERE EXISTS (SELECT s_id -- sau *
              FROM student s
              WHERE f.f_id = s.f_id AND
                    EXISTS (SELECT *
                            FROM enrollment e
                            WHERE s.s_id = e.s_id AND grade = 'A')
             ) 
      AND 
      EXISTS (SELECT c_sec_id
              FROM course_section cs
              WHERE f.f_id = cs.f_id AND
                    EXISTS (SELECT course_no
                            FROM course c
                            WHERE c.course_no = cs.course_no AND LOWER(c.course_name) LIKE '%database%')
             );

--04--
WITH prof_loc_max_cap AS (SELECT DISTINCT f.f_id   -- profesorul caruia ii corespune cursul care se desfasoara in locatia cu capacitatea maxima
                          FROM faculty f JOIN course_section cs ON (f.f_id = cs.f_id) JOIN location l ON (l.loc_id = cs.loc_id)
                          WHERE l.capacity = (SELECT MAX(capacity) -- locatia cu capacitatea maxima
                                              FROM location)),
     prof_course_max_students AS -- profesorul caruia ii corespune cursul cu numar maxim de studenti
                         (SELECT f.f_id 
                          FROM enrollment e JOIN course_section cs ON (e.c_sec_id = cs.c_sec_id) JOIN faculty f ON (f.f_id = cs.f_id)
                          GROUP BY e.c_sec_id, f.f_id
                          HAVING COUNT(e.s_id) = (SELECT MAX(COUNT(e2.s_id))
                                                  FROM enrollment e2
                                                  GROUP BY e2.c_sec_id))           
SELECT DISTINCT f_first, f_last
FROM faculty
WHERE f_id IN (SELECT * FROM prof_loc_max_cap)

UNION

SELECT DISTINCT f_first, f_last
FROM faculty
WHERE f_id IN (SELECT * FROM prof_course_max_students);

--05--
--Sa se gaseasca profesorii care au biroul intr-o locatie cu capacitate minima si au
--predat cursul cu numarul minim de locuri dintre cursurile desfasurate in locatia cu
--capacitate maxima.
SELECT f_first, f_last 
FROM faculty 
WHERE loc_id IN (SELECT loc_id 
                 FROM location 
                 WHERE capacity = (SELECT MIN(capacity) 
                                   FROM location))
      AND f_id IN (SELECT f_id 
                   FROM course_section 
                   WHERE max_enrl IN (SELECT MIN(max_enrl) 
                                      FROM course_section 
                                      WHERE loc_id = (SELECT loc_id 
                                                      FROM location 
                                                      WHERE capacity = (SELECT MAX(capacity) 
                                                                        FROM location))));

--06--
SELECT AVG(loc_Marx.capacity) "Capacitatea salilor", AVG(course_Jones.max_enrl) "Nr. locuri la curs"
FROM (SELECT DISTINCT capacity
      FROM location JOIN course_section USING (loc_id)
      WHERE f_id = (SELECT f_id FROM faculty WHERE f_last = 'Marx' AND f_first = 'Teresa')
     ) loc_Marx,
    (SELECT max_enrl
     FROM course_section JOIN enrollment USING (c_sec_id)
     WHERE s_id = (SELECT s_id FROM student WHERE s_last = 'Jones' AND s_first = 'Tammy')
    ) course_Jones;

--07--
SELECT bldg_code, ROUND(AVG(capacity), 2) as "Avg capacity" 
FROM location
WHERE bldg_code IN (SELECT DISTINCT bldg_code 
                    FROM course_section JOIN course USING (course_no) JOIN location USING (loc_id) 
                    WHERE LOWER(course_name) LIKE '%systems%')
GROUP BY bldg_code;

--08--
-- extindere problema 7
SELECT bldg_code, ROUND(AVG(capacity), 2) as "Avg capacity" 
FROM location
WHERE bldg_code IN (SELECT DISTINCT bldg_code 
                    FROM course_section JOIN course USING (course_no) JOIN location USING (loc_id) 
                    WHERE LOWER(course_name) LIKE '%systems%')
GROUP BY bldg_code
UNION
SELECT 'Medie', ROUND(AVG(capacity), 2)
FROM location 
WHERE bldg_code IN (SELECT DISTINCT bldg_code 
                    FROM course_section JOIN course USING (course_no) JOIN location USING (loc_id)  
                    WHERE LOWER(course_name) LIKE '%systems%');

-- Scopul acestei probleme era utilizarea unei extensii a lui GROUP BY (numita GROUPING SETS) - se simuleaza foarte bine cu UNION.

--09--
SELECT course_no, course_name
FROM course
WHERE LOWER(course_name) LIKE '%java%' OR (SELECT Count(*)
                                           FROM course
                                           WHERE LOWER(course_name) LIKE '%java%') = 0;
                                    
--10--
SELECT c.course_name 
FROM course c 
WHERE decode((SELECT count(1) 
              FROM course_section JOIN location USING (loc_id) 
              WHERE course_no = c.course_no AND capacity = 42), 0, 0, 1) +
      decode((SELECT count(1) 
              FROM faculty JOIN course_section USING (f_id) 
              WHERE course_no = c.course_no AND f_last = 'Brown'), 0, 0, 1) +
      decode((SELECT count(1) 
              FROM student JOIN enrollment USING (s_id) JOIN course_section USING (c_sec_id) 
              WHERE course_no = c.course_no AND s_last = 'Jones' AND s_first = 'Tammy'), 0, 0, 1) +
      decode((SELECT count(1) 
              FROM course
              WHERE course_no = c.course_no AND course_name LIKE '%Database%'), 0, 0, 1) +
      decode((SELECT count(1) 
              FROM course_section JOIN term USING (term_id) 
              WHERE course_no = c.course_no AND extract(year FROM start_date) = 2007), 0, 0, 1) >= 3;

--11--
SELECT t.term_desc, count(c.course_no) "No. of Database courses"
FROM course_section cs JOIN course c ON (cs.course_no = c.course_no) JOIN term t ON (t.term_id = cs.term_id)
WHERE c.course_name LIKE '%Database%'
GROUP BY t.term_desc
HAVING COUNT(c.course_no) = (SELECT MAX(COUNT(c.course_no))
                             FROM course_section cs JOIN course c ON (cs.course_no = c.course_no) JOIN term t ON (t.term_id = cs.term_id)
                             WHERE c.course_name LIKE '%Database%'
                             GROUP BY t.term_id);

--12--
SELECT grade, count_students 
FROM (SELECT grade, COUNT(DISTINCT s_id) count_students 
      FROM enrollment 
      WHERE grade IS NOT NULL 
      GROUP BY grade 
      ORDER BY COUNT(DISTINCT s_id) DESC)
WHERE ROWNUM = 1;

--13--
SELECT id, term, count_courses 
FROM (SELECT term_id AS id, term_desc AS term, COUNT(course_no) AS count_courses 
      FROM course_section JOIN term USING (term_id) JOIN course USING (course_no)
      WHERE credits = 3 
      GROUP BY term_id, term_desc 
      ORDER BY 2 DESC)
WHERE ROWNUM = 1;

--14--
SELECT DISTINCT loc_id
FROM course_section JOIN course USING (COURSE_NO)
WHERE LOWER(COURSE_NAME) LIKE '%database%' AND LOWER(COURSE_NAME) LIKE '%c++%';

--15--
SELECT bldg_code
FROM location
GROUP BY bldg_code
HAVING COUNT(loc_id) = 1;
--sau
SELECT DISTINCT bldg_code
FROM location l
WHERE (SELECT COUNT(*) FROM location WHERE bldg_code = l.bldg_code) = 1;
