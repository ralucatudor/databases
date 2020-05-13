--LAB 3--
-- Atentie! NULL nu este egal cu NULL
-- DISTINCT = UNIQUE => fara duplicate

--11.03.2020--
SELECT e.last_name, d.department_id, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id;

--sintaxa din standardul SQL3
SELECT last_name, department_id, department_name
FROM employees JOIN departments USING (department_id);

SELECT last_name, d.department_id, department_name
FROM employees e JOIN departments d ON (e.department_id = d.department_id);

-- nerecomandat
SELECT last_name, department_id, department_name
FROM employees NATURAL JOIN departments; -- nu prea folosit

--18.03.2020--

--1--
-- Operatia ceruta nu se bazeaza pe o relatie directa! In schimb, relatia este una
-- indirecta, ce ar putea fi exprimata ca "ANGAJAT este coleg cu ANGAJAT".
SELECT e1.last_name, TO_CHAR(e1.hire_date, 'MONTH') AS "Luna",
       EXTRACT(YEAR FROM e1.hire_date) as "An"
FROM employees e1, employees e2
WHERE e1.department_id = e2.department_id
      AND LOWER(e1.last_name) LIKE '%a%'
      AND LOWER(e1.last_name) != 'gates'
      AND LOWER(e2.last_name) = 'gates';
 
SELECT e1.last_name, TO_CHAR(e1.hire_date, 'MONTH') AS "Luna",
       EXTRACT(YEAR FROM e1.hire_date) as "An"
FROM employees e1
JOIN employees e2
ON (e1.department_id = e2.department_id)
WHERE LOWER(e1.last_name) LIKE '%a%'
      AND LOWER(e1.last_name) != 'gates'
      AND LOWER(e2.last_name) = 'gates';
 
SELECT e1.last_name, TO_CHAR(e1.hire_date, 'MONTH') AS "Luna",
       EXTRACT(YEAR FROM e1.hire_date) as "An"
FROM employees e1
JOIN employees e2
ON (e1.department_id = e2.department_id)
WHERE INSTR(LOWER(e1.last_name), 'a') != 0
      AND LOWER(e1.last_name) != 'gates'
      AND LOWER(e2.last_name) = 'gates';

SELECT e1.last_name, TO_CHAR(e1.hire_date, 'MONTH') AS "Luna",
       EXTRACT(YEAR FROM e1.hire_date) as "An"
FROM employees e1 JOIN employees e2 USING (department_id)
WHERE (INSTR(LOWER(e1.last_name), 'a') != 0
      AND LOWER(e1.last_name) != 'gates'
      AND LOWER(e2.last_name) = 'gates');
-- Coloanele referite in clauza USING trebuie sa nu contina calificatori 
-- (sa nu fie precedate de nume de tabele sau alias-uri).


 --2--
SELECT DISTINCT e1.employee_id,     -- DISTINCT!
                e1.last_name, 
                e1.department_id, 
                d.department_name
FROM employees e1, employees e2, departments d
WHERE e1.department_id = e2.department_id
      AND e1.department_id = d.department_id
      AND LOWER(e2.last_name) LIKE '%t%'
ORDER BY e1.last_name;
 
SELECT UNIQUE e1.employee_id, 
              e1.last_name, 
              e1.department_id,
              d.department_name
FROM employees e1
     JOIN employees e2 ON (e1.department_id = e2.department_id)
     JOIN departments d ON (e1.department_id = d.department_id)
WHERE LOWER(e2.last_name) LIKE '%t%'
ORDER BY e1.last_name;

 
 --3--
 -- Aceasta varianta de cerere:
SELECT e.last_name, 
       e.salary, 
       j.job_title, 
       l.city,
       c.country_name
FROM employees e
     JOIN employees m ON (e.manager_id = m.employee_id)
     JOIN jobs j ON (e.job_id = j.job_id)
     JOIN departments d ON (e.department_id = d.department_id)
     JOIN locations l ON (l.location_id = d.location_id)
     JOIN countries c ON (c.country_id = l.country_id)
WHERE m.last_name = 'Zlotkey';

-- va putea returna un rezultat diferit de urmatoarea 
-- (pe care o consideram solutia corecta a acestui exercitiu):
SELECT e.last_name, 
       e.salary, 
       j.job_title, 
       l.city,
       c.country_name
FROM employees e
     JOIN employees m ON (e.manager_id = m.employee_id)
     JOIN jobs j ON (e.job_id = j.job_id) --  job_id are constrangerea NOT NULL => nu este necesar LEFT
     LEFT JOIN departments d ON (e.department_id = d.department_id) -- LEFT JOIN = LEFT OUTER JOIN
     LEFT JOIN locations l ON (l.location_id = d.location_id)
     LEFT JOIN countries c ON (c.country_id = l.country_id)
WHERE m.last_name = 'Zlotkey';
-- Observatie: Left Join-urile se propaga la dreapta
-- (am null => urmatoarele coloane pe care le obtin vor avea valoarea si ele null)
-- aici, Grant nu are departament (null) => ultimele 2 left join-uri vor fi tot null

-- sau
SELECT e1.last_name, 
       e1.salary, 
       j.job_title, 
       l.city, 
       c.country_name
FROM employees e1, employees e2, jobs j, departments d, locations l, countries c
WHERE (e2.last_name = 'Zlotkey'
      AND e1.manager_id = e2.employee_id
      AND e1.job_id = j.job_id --  job_id are constrangerea NOT NULL => nu este necesar (+)
      AND e1.department_id = d.department_id (+)
      AND d.location_id = l.location_id (+)
      AND l.country_id = c.country_id (+));


--4--
SELECT d.department_id, 
       d.department_name, 
       e.last_name,
       j.job_title, 
       TO_CHAR(e.salary, '$99,999.00') AS Salariu
FROM departments d
     JOIN employees e ON (e.department_id = d.department_id)
     JOIN jobs j ON (e.job_id = j.job_id)
WHERE LOWER(d.department_name) LIKE '%ti%'
ORDER BY d.department_name, e.last_name;


--5--
SELECT e.last_name, 
       department_id, 
       department_name, 
       city,
       job_title
FROM employees e
     JOIN departments d USING (department_id)
     JOIN locations l USING (location_id)
     JOIN jobs j USING(job_id)
WHERE LOWER(l.city) = 'oxford';


--6--
SELECT UNIQUE e1.employee_id, e1.last_name, e1.salary
FROM employees e1
JOIN employees e2 ON (e2.department_id = e1.department_id)
JOIN jobs j ON (j.job_id = e1.job_id)
WHERE LOWER(e2.last_name) LIKE '%t%' -- INSTR(LOWER(e2.last_name), 't') != 0)
      AND e1.salary > (j.min_salary + j.max_salary) / 2
ORDER BY e1.last_name;


--7--
SELECT e.last_name, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id (+);

SELECT e.last_name, d.department_name
FROM employees e
LEFT OUTER JOIN departments d ON (e.department_id = d.department_id);


--8--
SELECT e.last_name, d.department_name
FROM employees e, departments d
WHERE e.department_id (+) = d.department_id;

SELECT e.last_name, d.department_name
FROM employees e
RIGHT OUTER JOIN departments d ON (e.department_id = d.department_id);


--9--
SELECT e.employee_id, e.last_name, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id (+)
UNION -- UNION elimin? duplicatele!
SELECT e.employee_id, e.last_name, d.department_name
FROM employees e, departments d
WHERE e.department_id (+) = d.department_id;
-- Metoda este echivalenta cu FULL OUTER JOIN
-- deoarece am introdus coloana employee_id care sa asigure unicitatea
-- ai sa nu se elimine duplicatele (last_name, department_name)

SELECT e.last_name, d.department_name
FROM employees e
FULL OUTER JOIN departments d ON (e.department_id = d.department_id);


--10--
SELECT D.DEPARTMENT_ID
FROM DEPARTMENTS D
WHERE LOWER(D.DEPARTMENT_NAME) LIKE '%re%'
UNION
SELECT DEPARTMENT_ID
FROM EMPLOYEES E
WHERE E.JOB_ID = 'SA_REP';

SELECT D.DEPARTMENT_ID
FROM DEPARTMENTS D
WHERE LOWER(D.DEPARTMENT_NAME) LIKE '%re%'
UNION ALL -- Duplicatele nu sunt eliminate!
SELECT DEPARTMENT_ID
FROM EMPLOYEES E
WHERE E.JOB_ID = 'SA_REP';
--  In cererile asupra carora se aplica UNION ALL nu se poate utiliza DISTINCT.


--11--
SELECT d.department_id
FROM departments d
MINUS
SELECT UNIQUE department_id
FROM employees;

SELECT department_id
FROM departments
WHERE department_id NOT IN
    (
    SELECT d.department_id
    FROM departments d
    --where department_id is not null
    JOIN employees e ON(d.department_id = e.department_id)
    );
-- Obs! NOT IN se evalueaza ca o disjunctie de conditii cu != 
-- x NOT IN {a, b, NULL} <=> x!=a si x!= b si x!=NULL. Dar x!=NULL este NULL
-- In final avem fie TRUE si NULL => NULL, fie FALSE si NULL => FALSE.
-- => necesitatea tratarii valorilor null in varianta utilizarii operatorului NOT IN
    
    
--12--
SELECT d.department_id
FROM departments d
WHERE LOWER(d.department_name) LIKE '%re%'
INTERSECT
SELECT e.department_id
FROM employees e
WHERE e.job_id = 'HR_REP';


--13--
SELECT e.employee_id, e.job_id, e.last_name
FROM employees e
WHERE (e.salary > 3000)
UNION
SELECT e.employee_id, e.job_id, e.last_name
FROM employees e
JOIN jobs j ON (j.job_id = e.job_id)
WHERE e.salary = (j.min_salary + j.max_salary) / 2;

SELECT e.employee_id, e.job_id, e.last_name
FROM employees e
JOIN jobs j ON (e.job_id = j.job_id)
WHERE e.salary > 3000 OR e.salary = (j.min_salary + j.max_salary) / 2;


--14--
SELECT DISTINCT 'Departamentul ' || d.department_name || 
                ' este condus de ' || NVL(TO_CHAR(d.manager_id), 'nimeni') 
                || ' si ' ||
                CASE NVL(e.employee_id, -1)
                    WHEN -1 THEN 'nu are salariati.'
                    ELSE 'are salariati.'
                END
FROM employees e 
RIGHT OUTER JOIN departments d ON (e.department_id = d.department_id);

SELECT DISTINCT 'Departamentul ' || d.department_name || 
                ' este condus de ' || NVL2(TO_CHAR(d.manager_id), TO_CHAR(d.manager_id), 'nimeni') 
                || ' si ' ||
                CASE
                    WHEN e.employee_id IS NOT NULL THEN 'are salariati.'
                    ELSE 'nu are salariati.'
                END
FROM departments d LEFT OUTER JOIN employees e ON (NVL(d.department_id, -1) = NVL(e.department_id, -1));


--15--
SELECT first_name, last_name, LENGTH(to_char(last_name))
FROM employees
WHERE NULLIF(LENGTH(TO_CHAR(last_name)), LENGTH(TO_CHAR(first_name))) IS NOT NULL;


--16--
SELECT last_name, hire_date, salary,
        CASE
            WHEN TO_CHAR(hire_date, 'YYYY') = '1989' THEN 
                salary * 1.2
            WHEN TO_CHAR(hire_date, 'YYYY') = '1990' THEN 
                 salary * 1.15
            WHEN TO_CHAR(hire_date, 'YYYY') = '1991' THEN 
                 salary * 1.1
            ELSE salary
        END "Salariu modificat"
FROM employees;
