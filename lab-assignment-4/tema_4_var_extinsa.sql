-- Tema 4 - varianta extinsa - mai multe metode de rezolvare
--01--
-- Vrem studentii care au toate notele diferite de null
-- Se rezuma la - vrem id-urile studentilor care au orice grade != null (din tabela enrollment)

SELECT S_FIRST || ' ' || S_LAST AS NUME
FROM student s
WHERE NOT EXISTS (SELECT *
                  FROM enrollment e
                  WHERE s.S_ID = e.S_ID AND GRADE IS NULL);
--sau
select s.s_last 
from student s 
where '(null)' not in (select grade from enrollment where s_id = s.s_id);

--sau
select distinct s.*
from student s
where s.s_id not in (select distinct s_id
                     from enrollment e
                     where e.grade is null);

--02--
select bldg_code 
from location 
where bldg_code not in (select bldg_code 
                        from location 
                        where loc_id not in (select distinct loc_id from course_section));
--sau
with filter as
    (select bldg_code
     from location
     where loc_id not in (select distinct loc_id from course_section))
select bldg_code
from location
where bldg_code not in (select * from filter);
--sau
SELECT BLDG_CODE
FROM location
GROUP BY BLDG_CODE
HAVING COUNT(CASE WHEN LOC_ID NOT IN (SELECT DISTINCT LOC_ID 
                                      FROM course_section) 
                              THEN 1 END) = 0;
                              
--03--
select f.f_id, f.f_last from faculty f
where (select count(1) from student s where s.f_id = f.f_id and (select count(1) from enrollment where grade = 'A' and s_id = s.s_id)>0) > 0
and (select count(1) from course_section where f_id = f.f_id  and course_no = 'MIS 441') > 0;
--sau
SELECT F_ID, F_FIRST || ' ' || F_LAST AS NUME
FROM faculty f
WHERE EXISTS (SELECT *
              FROM student s
              WHERE s.F_ID = f.F_ID AND
                    EXISTS (SELECT *
                            FROM enrollment e
                            WHERE e.s_id = s.s_id AND grade = 'A')
             ) 
      AND 
      EXISTS (SELECT *
              FROM course_section cs
              WHERE cs.F_ID = f.F_ID AND
                    EXISTS (SELECT * 
                            FROM course c
                            WHERE c.COURSE_NO = cs.COURSE_NO AND c.COURSE_NAME LIKE '%Database%')
             );
--sau
--varianta aceasta are rezultat diferit de cele de sus (2 linii in loc de 1) 
--pentru ca face union!!!
select distinct f.f_id, f.f_last
from faculty f, student s, enrollment e
where s.f_id = f.f_id and
    e.s_id = s.s_id and
    e.grade = 'A'
union
select distinct f.f_id, f.f_last
from faculty f, course_section cs
where f.f_id = cs.f_id and
    cs.course_no = 'MIS 441';

--04--
SELECT DISTINCT F_FIRST || ' ' || F_LAST
FROM faculty f JOIN course_section cs ON(f.F_ID=cs.F_ID)
WHERE cs.C_SEC_ID IN (SELECT cs.C_SEC_ID
                      FROM course_section cs JOIN enrollment e ON(e.C_SEC_ID=cs.C_SEC_ID)
                      GROUP BY cs.C_SEC_ID
                      HAVING COUNT(e.S_ID) = (SELECT MAX(COUNT(e.S_ID)) c
                                                    FROM course_section cs JOIN enrollment e ON(e.C_SEC_ID=cs.C_SEC_ID)
                                                    GROUP BY cs.C_SEC_ID
                                              )
                     )
UNION
SELECT DISTINCT F_FIRST || ' ' || F_LAST
FROM faculty f JOIN course_section cs ON(f.F_ID=cs.F_ID)
WHERE cs.C_SEC_ID IN (SELECT cs.C_SEC_ID
                      FROM course_section cs
                      JOIN location l
                      ON(l.LOC_ID=cs.LOC_ID)
                      WHERE l.CAPACITY = (SELECT MAX(CAPACITY)
                                          FROM location
                                         )
                      );
--sau
with cap_max as (select max(capacity) from location),
    prof_curs_cap_max as (select distinct f.f_id
                        from faculty f, course_section cs, location l
                        where f.f_id = cs.f_id and
                        cs.loc_id = l.loc_id and
                        l.capacity = (select * from cap_max)),
    curs_stud_max as (select e.c_sec_id
                    from enrollment e
                    group by e.c_sec_id
                    having count(e.s_id) = (
                        select max(count(e2.s_id))
                        from enrollment e2
                        group by e2.c_sec_id))           
select distinct f_last
from faculty
where f_id in (select * from prof_curs_cap_max)
union
select f.f_last
from faculty f, course_section cs
where f.f_id = cs.f_id and
    cs.c_sec_id = (select * from curs_stud_max);
--sau
--asa nu!
(select nume from (select f.f_last as nume from faculty f order by 
(select max((select count(s_id) from enrollment where c_sec_id = cs.c_sec_id)) from course_section cs where cs.f_id = f.f_id)) where rownum =1)
union
(select nume from (select f.f_last as nume from faculty f order by
(select max((select capacity from location where loc_id = cs.loc_id)) from course_section cs where cs.f_id = f.f_id)) where rownum = 1);

--05--
select f.f_last as nume 
from faculty f 
where f.loc_id in (select loc_id 
                   from location 
                   where capacity = (select min(capacity) 
                                     from location))
      and f.f_id in (select f_id 
                     from course_section 
                     where max_enrl in (select min(max_enrl) 
                                        from course_section 
                                        where loc_id = (select loc_id 
                                                        from location 
                                                        where capacity = (select max(capacity) 
                                                                          from location))));
--sau
with filter as (select cs.c_sec_id
                from course_section cs, location l
                where cs.loc_id = l.loc_id and
                    l.capacity = (select max(l2.capacity) from location l2)),
    filter2 as (select min(cs.max_enrl)
                from course_section cs, filter f
                where cs.c_sec_id = f.c_sec_id),
    filter_ids as (select f.c_sec_id
                from filter f, course_section cs
                where f.c_sec_id = cs.c_sec_id and
                    cs.max_enrl = (select * from filter2))
select f.f_id, f.f_last
from faculty f, course_section cs
where cs.c_sec_id in (select * from filter_ids) and
    cs.f_id = f.f_id
intersect
select f.f_id, f.f_last
from faculty f, location l
where f.loc_id = l.loc_id and
    l.capacity = (select min(l2.capacity) from location l2);
--sau
SELECT F_FIRST || ' ' || F_LAST AS NUME
FROM faculty f
WHERE LOC_ID IN (SELECT LOC_ID
                 FROM location
                 WHERE CAPACITY = (SELECT MIN(CAPACITY)
                                   FROM location)) AND
      EXISTS (SELECT *
              FROM course_section cs
              WHERE cs.F_ID = f.F_ID AND 
                    MAX_ENRL = (SELECT MIN(MAX_ENRL)
                                FROM course_section
                                WHERE LOC_ID IN (SELECT LOC_ID
                                                 FROM location
                                                 WHERE CAPACITY = (SELECT MAX(CAPACITY)
                                                                   FROM location))
                               )
              );

--06--
select round(avg(loc.capacity),2) as "Capacitatea salilor", round(avg(enrl.max_enrl),2) as "Numarul de locuri" 
from 
(select distinct l.loc_id, l.capacity 
 from faculty f join course_section cs on (f.f_id=cs.f_id) 
                join location l on (l.loc_id=cs.loc_id) where f.f_last = 'Marx') loc,
(select cs.max_enrl 
from student s join enrollment e on (s.s_id = e.s_id) join course_section cs on (e.c_sec_id=cs.c_sec_id) 
where s.s_last='Jones') enrl;

--sau
select round(avg(sali.capacity), 2) "Capacitatea salilor", round(avg(enrl.max_enrl), 2) "Locuri la curs"
from (select distinct l.loc_id, l.capacity 
      from course_section cs, location l
    where cs.loc_id = l.loc_id and cs.f_id = 1) sali,
    (select distinct cs.c_sec_id, cs.max_enrl from course_section cs, enrollment e
    where e.s_id = 'JO100' and e.c_sec_id = cs.c_sec_id) enrl;
--sau
SELECT AVG(loc_Marx.capacity) "Capacitatea salilor", AVG(course_Jones.max_enrl) "Nr. locuri la curs"
FROM (SELECT DISTINCT capacity
      FROM location
      WHERE loc_id IN (SELECT DISTINCT loc_id
                       FROM course_section
                       WHERE F_ID = (SELECT F_ID
                                     FROM faculty
                                     WHERE F_LAST = 'Marx' AND F_FIRST = 'Teresa')
                       )
      ) loc_Marx,
      (SELECT MAX_ENRL
      FROM course_section
      WHERE C_SEC_ID IN (SELECT C_SEC_ID
                         FROM ENROLLMENT
                         WHERE S_ID = (SELECT S_ID
                                       FROM STUDENT
                                       WHERE S_LAST = 'Jones' AND S_FIRST = 'Tammy')
                        )
     ) course_Jones;
--sau
--enunt inteles altfel... cu union si avg peste cele 2 nr., nu separat
SELECT AVG(x)
FROM (
      SELECT DISTINCT capacity as x
      FROM location
      WHERE loc_id IN (SELECT DISTINCT loc_id
                       FROM course_section
                       WHERE F_ID = (SELECT F_ID
                                     FROM faculty
                                     WHERE F_LAST = 'Marx' AND F_FIRST = 'Teresa')
                       )
      UNION ALL
      SELECT MAX_ENRL as x
      FROM course_section
      WHERE C_SEC_ID IN (SELECT C_SEC_ID
                         FROM ENROLLMENT
                         WHERE S_ID = (SELECT S_ID
                                       FROM STUDENT
                                       WHERE S_LAST = 'Jones' AND S_FIRST = 'Tammy')
                        )
     );

--07--
select l.bldg_code, round(avg(l.capacity), 2)
from location l
where l.bldg_code in (select l2.bldg_code
    from location l2, course c, course_section cs
    where lower(c.course_name) like '%systems%' and
        c.course_no = cs.course_no and
        cs.loc_id = l2.loc_id)
group by l.bldg_code;
--sau
select bldg_code as "Codul cladirii", round(avg(capacity), 2) as "Media capacitatilor" 
from location
where bldg_code in (select distinct l.bldg_code 
                    from course_section cs join course c using (course_no) join location l on (cs.loc_id=l.loc_id) 
                    where c.course_name like '%Systems%')
group by bldg_code;
--sau
SELECT BLDG_CODE, AVG(CAPACITY)
FROM location
WHERE BLDG_CODE IN (SELECT DISTINCT BLDG_CODE
                    FROM location l
                    WHERE EXISTS (SELECT *
                                  FROM course_section cs
                                  WHERE cs.LOC_ID = l.LOC_ID AND EXISTS (SELECT *
                                                                         FROM course c
                                                                         WHERE c.COURSE_NO = cs.COURSE_NO AND c.course_name LIKE '%Systems%')
                                 )
                    )
GROUP BY BLDG_CODE;

--08--
select l.bldg_code as "Codul cladirii", round(avg(l.capacity), 2) as "Media capacitatilor" 
from location l
where l.bldg_code in (select distinct l2.bldg_code
                    from course_section cs, location l2, course c
                    where lower(c.course_name) like '%systems%' and
                        c.course_no = cs.course_no and
                        cs.loc_id = l2.loc_id)
group by l.bldg_code 
union
select 'Total' as "Codul cladirii", round(avg(l.capacity), 2) as "Media capacitatilor" 
from location l
where l.bldg_code in (select distinct l2.bldg_code
                    from course c, course_section cs, location l2
                    where lower(c.course_name) like '%systems%' and
                        c.course_no = cs.course_no and
                        cs.loc_id = l2.loc_id);
--sau
SELECT BLDG_CODE, AVG(CAPACITY)
FROM location
WHERE BLDG_CODE IN (SELECT DISTINCT BLDG_CODE
                    FROM location l
                    WHERE EXISTS (SELECT *
                                  FROM course_section cs
                                  WHERE cs.LOC_ID = l.LOC_ID AND EXISTS (SELECT *
                                                                         FROM course c
                                                                         WHERE c.COURSE_NO = cs.COURSE_NO AND c.course_name LIKE '%Systems%')
                                 )
                    )
GROUP BY BLDG_CODE
UNION
SELECT 'Medie', AVG(CAPACITY) 
FROM location 
WHERE BLDG_CODE IN (SELECT DISTINCT BLDG_CODE
                    FROM location l
                    WHERE EXISTS (SELECT *
                                  FROM course_section cs
                                  WHERE cs.LOC_ID = l.LOC_ID AND EXISTS (SELECT *
                                                                         FROM course c
                                                                         WHERE c.COURSE_NO = cs.COURSE_NO AND c.course_name LIKE '%Systems%')
                                 )
                    );

--09--
select course_no, course_name
from course
where (select count(*) from course where course_name like '%Java%') = 0 or
    course_name like '%Java%';

--sau
SELECT course_no, course_name
FROM course
WHERE course_name LIKE '%JAVA%' OR (SELECT Count(*)
                                    FROM course
                                    WHERE course_name LIKE '%Java%') = 0;

--10--
SELECT course_name
FROM course c
WHERE (CASE (SELECT COUNT(*)
             FROM location l JOIN course_section cs USING(LOC_ID)
             WHERE l.CAPACITY = 42 AND cs.COURSE_NO = c.COURSE_NO
            ) WHEN 0 THEN 0 ELSE 1 END) +
      (CASE (SELECT COUNT(*) 
             FROM faculty f JOIN course_section cs USING(F_ID)
             WHERE f.F_LAST = 'Brown' AND cs.COURSE_NO = c.COURSE_NO
             ) WHEN 0 THEN 0 ELSE 1 END) +
      (CASE (SELECT COUNT(*)
             FROM student s JOIN enrollment e USING(S_ID) JOIN course_section cs USING(C_SEC_ID)
             WHERE s.S_FIRST = 'Tammy' AND s.S_LAST = 'Jones' AND cs.COURSE_NO = c.COURSE_NO
            ) WHEN 0 THEN 0 ELSE 1 END) + 
      (CASE (SELECT COUNT(*)
             FROM course c2
             WHERE c2.course_name LIKE '%Database%' AND c2.COURSE_NO = c.COURSE_NO
             ) WHEN 0 THEN 0 ELSE 1 END) +
      (CASE (SELECT COUNT(*)
             FROM course_section cs JOIN term t USING(TERM_ID)
             WHERE EXTRACT(YEAR FROM t.START_DATE) = 2007
            ) WHEN 0 THEN 0 ELSE 1 END) >= 3;

--11--
SELECT t.TERM_DESC, COUNT(c.COURSE_NO)
FROM term t JOIN course_section cs USING(TERM_ID) JOIN course c ON(c.COURSE_NO=cs.COURSE_NO)
WHERE c.COURSE_NAME LIKE '%Database%'
GROUP BY t.TERM_DESC
HAVING COUNT(c.COURSE_NO) = (SELECT MAX(nr)
                             FROM (SELECT t.TERM_DESC d, COUNT(c.COURSE_NO) nr
                                   FROM term t JOIN course_section cs USING(TERM_ID) JOIN course c ON(c.COURSE_NO=cs.COURSE_NO)
                                   WHERE c.COURSE_NAME LIKE '%Database%'
                                   GROUP BY t.TERM_DESC
                                  )
                            );
--sau
with nr_max as
    (select max(count(c.course_no))
    from course_section cs join course c on (cs.course_no=c.course_no) join term t on (t.term_id=cs.term_id)
    where c.course_name like '%Database%'
    group by t.term_id)
select t.term_desc, count(c.course_no) "Numar cursuri"
from course_section cs join course c on (cs.course_no=c.course_no) join term t on (t.term_id=cs.term_id)
where c.course_name like '%Database%'
group by t.term_id, t.term_desc
having count(c.course_no) = (select * from nr_max);

--12--
SELECT GRADE, COUNT(S_ID)
FROM enrollment
WHERE GRADE IS NOT NULL
GROUP BY GRADE
HAVING COUNT(S_ID) = (SELECT MAX(st)
                      FROM (SELECT DISTINCT GRADE, COUNT(S_ID) st -- cu/ fara distinct la count?
                      FROM enrollment
                      WHERE GRADE IS NOT NULL
                      GROUP BY GRADE
                           )
                      );
--sau
with nr_max as
    (select max(count(distinct s_id))
    from enrollment
    where grade is not null
    group by grade)
select grade as Nota, count(distinct s_id) "Numar studenti"
from enrollment
group by grade
having count(distinct s_id) = (select * from nr_max);
--sau
select grade, NR_STUDENTI 
from (select grade, count(distinct s_id) as NR_STUDENTI 
      from enrollment 
      where grade is not null 
      group by grade 
      order by count(distinct s_id) desc)
where rownum = 1;

--13--
select id, term, count_courses 
from (select t.term_id id, t.term_desc as term, count(cs.course_no) as count_courses 
      from course_section cs join term t on (t.term_id=cs.term_id) join course c on (c.course_no=cs.course_no)
      where c.credits=3 
      group by t.term_id, t.term_desc 
      order by 2 desc)
where rownum = 1;
--sau
with nr_max as
    (select max(count(distinct c.course_no))
    from term t, course_section cs, course c
    where t.term_id = cs.term_id and
        cs.course_no = c.course_no and
        c.credits = 3
    group by t.term_id)
select t.term_id, t.term_desc, count(distinct c.course_no) "Numar materii"
from term t, course_section cs, course c
where t.term_id = cs.term_id and
    cs.course_no = c.course_no and
    c.credits = 3
group by t.term_id, t.term_desc
having count(distinct c.course_no) = (select * from nr_max);
--sau
SELECT t.TERM_DESC, COUNT(c.COURSE_NO)
FROM term t
JOIN course_section cs ON t.TERM_ID=cs.TERM_ID JOIN course c ON cs.COURSE_NO=c.COURSE_NO
WHERE c.CREDITS = 3
GROUP BY t.TERM_DESC
HAVING COUNT(c.COURSE_NO) = (SELECT MAX(courses)
                             FROM (SELECT t.TERM_DESC, COUNT(c.COURSE_NO) courses
                                   FROM term t
                                   JOIN course_section cs
                                   ON t.TERM_ID=cs.TERM_ID
                                   JOIN course c
                                   ON cs.COURSE_NO=c.COURSE_NO
                                   WHERE c.CREDITS = 3
                                   GROUP BY t.TERM_DESC
                                  )
                            );

--14--
SELECT DISTINCT cs.loc_id
FROM course_section cs JOIN course c ON (c.COURSE_NO = cs.COURSE_NO)
WHERE c.COURSE_NAME LIKE '%Database%' AND c.COURSE_NAME LIKE '%C++%';
--sau
select distinct l.*
from location l, course_section cs, course c
where l.loc_id = cs.loc_id and
    cs.course_no = c.course_no and
    c.course_name like '%C++%'
intersect
select distinct l.*
from location l, course_section cs, course c
where l.loc_id = cs.loc_id and
    cs.course_no = c.course_no and
    c.course_name like '%Database%';
--sau
select l.loc_id, l.bldg_code 
from location l join course_section cs on (cs.loc_id=l.loc_id)
join course c on (c.course_no=cs.course_no) 
where lower(c.course_name) like '%c++%' and lower(c.course_name) like '%database%';

--15--
select bldg_code 
from location l 
where (select count(*) from location where bldg_code = l.bldg_code) = 1 
group by bldg_code;
--sau
select bldg_code
from location
group by bldg_code
having count(loc_id) = 1;
--sau
SELECT DISTINCT BLDG_CODE
FROM location l
WHERE (SELECT COUNT(*)
       FROM location l2
       WHERE l.BLDG_CODE = l2.BLDG_CODE
       ) = 1;
