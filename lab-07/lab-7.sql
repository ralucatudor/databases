--22.04.2020--
--LAB 7--
--1--
-- metoda 1
SELECT DISTINCT employee_id, last_name
FROM employees a
WHERE NOT EXISTS
    (SELECT 1
     FROM project p
     WHERE to_char(start_date, 'YYYY') = 2006 and to_char(start_date, 'MM') <= 6
     AND NOT EXISTS
        (SELECT 'x'
         FROM works_on b
         WHERE p.project_id = b.project_id
         AND b.employee_id = a.employee_id));

-- metoda 2
SELECT employee_id
FROM works_on
WHERE project_id IN
    (SELECT project_id
     FROM project
     WHERE to_char(start_date, 'YYYY') = 2006 and to_char(start_date, 'MM') <= 6)
GROUP BY employee_id
HAVING COUNT(project_id)=
    (SELECT COUNT(*)
     FROM project
     WHERE to_char(start_date, 'YYYY') = 2006 and to_char(start_date, 'MM') <= 6);
-- Obs! nu pot avea un group by evaluat inainte de clauza where
-- asa ca fac cu subcereri

-- metoda 3
SELECT employee_id
FROM works_on
MINUS
SELECT employee_id from
 (SELECT employee_id, project_id
  FROM (SELECT DISTINCT employee_id FROM works_on) t1,
       (SELECT project_id FROM project WHERE to_char(start_date, 'YYYY') = 2006 and to_char(start_date, 'MM') <= 6) t2
  MINUS
  SELECT employee_id, project_id
  FROM works_on
 ) t3;
 
-- metoda 4
SELECT DISTINCT employee_id
FROM works_on a
WHERE NOT EXISTS (
    (SELECT project_id
     FROM project p
     WHERE to_char(start_date, 'YYYY') = 2006 and to_char(start_date, 'MM') <= 6)
     MINUS
    (SELECT p.project_id
     FROM project p, works_on b
     WHERE p.project_id=b.project_id
     AND b.employee_id=a.employee_id));


--2--
-- metoda 4
SELECT *
FROM project p
WHERE NOT EXISTS (SELECT employee_id
                  FROM job_history
                  GROUP BY employee_id 
                  HAVING COUNT(job_id) = 2
                 
                  MINUS
                  
                  SELECT employee_id
                  FROM works_on
                  WHERE project_id = p.project_id);

-- metoda 1
SELECT *
FROM project p
WHERE NOT EXISTS
    (SELECT 1
     FROM employees e
     WHERE employee_id IN (SELECT employee_id
                           FROM job_history
                           GROUP BY employee_id
                           HAVING COUNT(job_id) = 2)
     AND NOT EXISTS
        (SELECT 'x'
         FROM works_on b
         WHERE p.project_id = b.project_id
               AND b.employee_id = e.employee_id));

-- metoda 2
SELECT project_id, project_name
FROM works_on JOIN project USING (project_id)   -- JOIN pt project_name
WHERE employee_id IN
    (SELECT employee_id
     FROM job_history
     GROUP BY employee_id
     HAVING COUNT(job_id) = 2)
GROUP BY project_id, project_name   -- desigur adaugam si project_name ca sa il putem afisa
HAVING COUNT(employee_id)=
    (SELECT COUNT(COUNT(*)) -- ATENTIE COUNT(COUNT(..)) NU DOAR COUNT
     FROM job_history
     GROUP BY employee_id
     HAVING COUNT(job_id) = 2);

--29.04.2020
-- lab. 7 
--3--
-- Obs! UNION elimina duplicatele
-- => nu punem DISTINCT
SELECT COUNT (*)
FROM employees e
WHERE (SELECT COUNT (*)
       FROM (SELECT employee_id, job_id
             FROM job_history
             UNION
             SELECT employee_id, job_id
             FROM employees)
       WHERE employee_id = e.employee_id) >= 3;
        
-- sa rezolvam cu NULL-ul
select COUNT (*)
FROM employees e
WHERE (SELECT COUNT (job_id)
       FROM (SELECT employee_id, job_id
            FROM job_history
            UNION
            SELECT employee_id, job_id
            FROM employees)
       WHERE employee_id = e.employee_id) >= 3;
        
--4--
SELECT c.country_name, COUNT(e.employee_id), COUNT(DISTINCT department_id)
FROM employees e RIGHT OUTER JOIN departments d USING (department_id) 
                 RIGHT JOIN locations l USING (location_id) 
                 RIGHT JOIN countries c USING (country_id)
GROUP BY country_id, c.country_name;

--5--
--angajatii care au lucrat la cel putin doua proiecte nelivrate la termen
WITH nelivrate AS (SELECT project_id
                   FROM project
                   WHERE NVL(delivery_date, sysdate) > deadline)
SELECT *
FROM employees e
WHERE (SELECT COUNT(*) 
       FROM works_on
       WHERE employee_id = e.employee_id 
             AND project_id IN (SELECT * 
                                FROM nelivrate)) > 1;

-- a doua varianta
WITH nelivrate AS (SELECT project_id
                   FROM project
                   WHERE NVL(delivery_date, sysdate) > deadline)
SELECT e.employee_id, e.last_name, e.first_name
FROM employees e JOIN works_on w ON (e.employee_id = w.employee_id)
WHERE project_id IN (SELECT * FROM nelivrate)
GROUP BY e.employee_id, e.last_name, e.first_name
HAVING COUNT(w.project_id) > 1;

-- a treia varianta
SELECT e.employee_id,  e.last_name, e.first_name
FROM employees e JOIN works_on w ON (e.employee_id = w.employee_id) 
                 JOIN project p ON (w.project_id = p.project_id)
WHERE NVL(delivery_date, sysdate) > deadline
GROUP BY e.employee_id, e.last_name, e.first_name
HAVING COUNT(w.project_id) > 1;

--6--
SELECT e.employee_id, w.project_id
FROM employees e LEFT JOIN works_on w ON (e.employee_id = w.employee_id);

--7--
WITH manageri AS (SELECT project_manager FROM project),
    dep_manageri AS (SELECT department_id 
                     FROM employees 
                     WHERE employee_id IN (SELECT * FROM manageri))
SELECT * 
FROM employees
WHERE department_id IN (SELECT * FROM dep_manageri);

--8-- 
with manageri as(select project_manager from project),
dep_manageri as(select nvl(department_id,-1) from employees where employee_id in (select * from manageri))
select * 
from employees
where department_id not in (select* from dep_manageri) or department_id is NULL;
-- sau ca sa rezolvam cu NULL, punem cu nvl cu -1

-- atentie Kimberly Grant cu dep_id null!!

--- ex 7 & 8 cu cereri sincronizate
--7
WITH manageri AS (SELECT project_manager FROM project),
    dep_manageri AS (SELECT department_id   
                     FROM employees 
                     WHERE employee_id IN (SELECT * FROM manageri))
SELECT * 
FROM employees e
WHERE EXISTS (SELECT *
              FROM dep_manageri
              WHERE e.department_id = department_id);

--8 
WITH manageri AS (SELECT project_manager FROM project),
    dep_manageri AS (SELECT nvl(department_id,-1) department_id 
                     FROM employees 
                     WHERE employee_id IN (SELECT * FROM manageri))
SELECT * 
FROM employees e
WHERE NOT EXISTS (SELECT *
                  FROM dep_manageri
                  WHERE e.department_id = department_id) OR e.department_id IS NULL;


--9
select department_id
from employees
group by department_id
having avg(salary) > &p;

--10
select e.first_name, e.last_name, e.salary, (select count(*) 
                                             from works_on 
                                             where employee_id = e.employee_id) + 
                                            (select count(*) 
                                             from project 
                                             where e.employee_id = project_manager 
                                                   and project_id not in (select project_id 
                                                                          from works_on 
                                                                          where employee_id = e.employee_id)) as nr_proiecte
from employees e
where 2 = (select count(*) 
           from project 
           where e.employee_id = project_manager);

--v2 facem union ca sa scapam de not in ca union elimina duplicatele
-- !!! union ia prima coloana deci e ok employee_id cu manager
SELECT e.first_name, e.last_name, e.salary, count(project_id)
from employees e join (select employee_id, project_id 
                       from works_on 
                       
                       union 
                       
                       select project_manager, project_id 
                       from project) t 
                 on (e.employee_id = t.employee_id)
where (select count(*) from project where e.employee_id = project_manager) = 2
group by e.first_name, e.last_name, e.salary;

--11
-- Sa se afiseze lista angajatilor care au lucrat NUMAI pe proiecte conduse de managerul
-- de proiect avand codul 102.
SELECT DISTINCT a.employee_id, e.last_name, e.first_name
FROM works_on a JOIN employees e ON (a.employee_id = e.employee_id)
WHERE NOT EXISTS ( 
    (SELECT w.project_id 
     FROM works_on w 
     WHERE w.employee_id = a.employee_id) 
     
     MINUS 
     
     (SELECT p.project_id 
     FROM project p
     WHERE p.project_manager = 102));

--12 a
-- Sa se obtina numele angajatilor care au lucrat CEL PUTIN pe aceleasi proiecte ca
-- angajatul avand codul 200.

with projects_200 as (select project_id
                      from works_on
                      where employee_id = 200)
select last_name
from employees e
where not exists
       (select project_id
        from projects_200
        
        minus
        
        select project_id
        from works_on w
        where w.employee_id = e.employee_id);

--12 b
-- Sa se obtina numele angajatilor care au lucrat CEL MULT pe aceleasi proiecte ca angajatul
-- avand codul 200.
with projects_200 as (select project_id
                      from works_on
                      where employee_id = 200)
select last_name
from employees e
where not exists
       (select project_id
        from works_on w
        where w.employee_id = e.employee_id
        
        minus
        
        select project_id
        from projects_200);

--13
-- Sa se obtina angajatii care au lucrat pe aceleasi proiecte ca angajatul avand codul 200.
with projects_200 as (select project_id
                      from works_on
                      where employee_id = 200)
select last_name
from employees e
where not exists
       (select project_id
        from works_on w
        where w.employee_id = e.employee_id
        
        minus
        
        select project_id
        from projects_200)
    and
    not exists
       (select project_id
        from projects_200
        
        minus
        
        select project_id
        from works_on w
        where w.employee_id = e.employee_id);

--14
--select * from job_grades;

select first_name, last_name, salary, (select grade_level 
                                       from job_grades
                                       where e.salary>lowest_sal and e.salary<highest_sal) 
from employees e;

select first_name, last_name, salary, grade_level
from employees e, job_grades
where salary between lowest_sal and highest_sal;

select first_name, last_name, salary, grade_level
from employees e join job_grades on (salary between lowest_sal and highest_sal);


--IV. [SQL*Plus]
--18
--v1
DEFINE id_job = IT_PROG;
select first_name, department_id, salary from employees where job_id = '&id_job';

--v2
ACCEPT id_job_2 PROMPT 'cod= ';
select first_name, department_id, salary from employees where job_id = '&id_job_2';

--19
ACCEPT given_date DATE format 'YYYY-MM-DD' PROMPT 'date= ';
select first_name, department_id, salary, hire_date from employees
where hire_date > to_date('&given_date', 'YYYY-MM-DD');

--20
ACCEPT p_coloana PROMPT 'coloana= ';
ACCEPT p_tabel PROMPT 'tabel= ';
ACCEPT p_where PROMPT 'where= ';
SELECT &p_coloana FROM &p_tabel WHERE &p_where ORDER BY '&p_coloana';

--21
ACCEPT min_date DATE format 'MM/DD/YYYY' PROMPT 'min date= ';
ACCEPT max_date DATE format 'MM/DD/YYYY' PROMPT 'max date= ';
select first_name || ',' || job_id as "Angajati", hire_date from employees 
where hire_date > to_date('&min_date', 'MM/DD/YYYY') and

hire_date < to_date('&max_date', 'MM/DD/YYYY')

ACCEPT min_date DATE format 'MM/DD/RR' PROMPT 'min date= ';
ACCEPT max_date DATE format 'MM/DD/RR' PROMPT 'max date= ';
select first_name || ',' || job_id as "Angajati", hire_date from employees 
where hire_date between to_date('&min_date', 'MM/DD/RR') and to_date('&max_date', 'MM/DD/RR');

-- 22
accept var_location prompt 'Locatie = ';
define var_location;
select e.last_name, e.job_id, e.salary, d.department_name
from employees e, departments d, locations l
where e.department_id = d.department_id and
    d.location_id = l.location_id and
    lower(l.city) = lower('&var_location');

ACCEPT city PROMPT 'city= ';
select first_name, job_id, salary, department_name from employees
join departments using (department_id) join locations using (location_id) where lower(city) = lower('&city');
