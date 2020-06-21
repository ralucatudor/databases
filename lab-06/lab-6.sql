--LAB 6
--08.04.2020--
--1--
--1a--
SELECT last_name, salary, department_id
FROM employees e
WHERE salary > (SELECT AVG(salary)
                FROM employees
                WHERE department_id = e.department_id);
                
--1b--
SELECT last_name, salary, e.department_id, d.department_name, ROUND(avg_sal, 2), nr
FROM employees e, (SELECT department_id, department_name, avg(salary) avg_sal, count(*) nr
                   FROM employees JOIN departments USING (department_id)
                   GROUP BY department_id, department_name) d
WHERE e.department_id = d.department_id 
and salary > (SELECT AVG(salary)
              FROM employees
              WHERE department_id = e.department_id);


--metoda 2
SELECT last_name, salary, e.department_id, 
       (SELECT department_name FROM departments WHERE department_id = e.department_id) "Departament", 
       ROUND((SELECT AVG(salary) FROM employees WHERE department_id = e.department_id), 2) "Medie",
       (SELECT COUNT(*) FROM employees WHERE department_id = e.department_id) "Numar"
FROM employees e
WHERE salary > (SELECT AVG(salary)
                FROM employees
                WHERE department_id = e.department_id);


--2--
-- v1 (cu all)
SELECT e.first_name, e.salary 
FROM employees e 
WHERE e.salary > ALL (SELECT AVG(salary) 
                      FROM employees 
                      GROUP BY department_id);

-- v2 (cu max)
SELECT e.first_name, e.salary 
FROM employees e 
WHERE e.salary > (SELECT MAX(AVG(salary)) 
                  FROM employees 
                  GROUP BY department_id);


--3--
-- corect
SELECT e.first_name, e.salary 
FROM employees e
WHERE salary = (SELECT MIN(salary) 
                FROM employees 
                WHERE department_id = e.department_id); 

-- gresit
SELECT e.first_name, e.salary 
FROM employees e
WHERE salary IN (SELECT MIN(salary) 
                 FROM employees 
                 GROUP BY department_id);
-- !!!! mi-i da pe cei care castiga salariu poate din alt departament - deci NU E BINE

-- corect
SELECT e.first_name, e.salary 
FROM employees e
WHERE (department_id, salary) IN (SELECT department_id, -- fac asa cu tupluri!!!!
                                         MIN(salary) 
                                  FROM employees 
                                  GROUP BY department_id);

-- tot corect
SELECT e.first_name, e.salary 
FROM employees e
WHERE salary IN (SELECT MIN(salary) 
                 FROM employees 
                 WHERE department_id = e.department_id);
                 --GROUP BY department_id);

--4--
SELECT d.department_name, e.last_name
FROM departments d, employees e
WHERE d.department_id = e.department_id
      AND e.hire_date = (SELECT MIN(hire_date)
                         FROM employees
                         WHERE employees.department_id = e.department_id)
ORDER BY d.department_name; 

--6--
SELECT last_name, salary
FROM employees e
WHERE (SELECT COUNT(*)
       FROM employees
       WHERE salary > e.salary) <= 2;
--nu pot sa pun EXISTS ca nu ma intereseaza cel putin 1, ma intereseaza cel putin 2

--SAU primele 3 distincte asa
SELECT last_name, salary
FROM employees e
WHERE (SELECT COUNT(DISTINCT salary)
       FROM employees
       WHERE salary > e.salary) <=2;
       
--7--
SELECT e.last_name
FROM employees e
WHERE (SELECT COUNT(1)
       FROM employees
       WHERE manager_id = e.employee_id) >= 2;
--sau
SELECT e.employee_id, e.first_name, e.last_name 
FROM employees e
WHERE (SELECT COUNT(*)
       FROM employees
       WHERE manager_id = e.employee_id) >= 2;

--8--
SELECT city
FROM locations l
WHERE EXISTS (SELECT 1 -- sau WHERE 1 IN (SELECT...)
              FROM departments
              WHERE location_id = l.location_id); 
              
SELECT city
FROM locations l
WHERE location_id IN (SELECT location_id
                      FROM departments);

SELECT city
FROM locations l
WHERE (SELECT COUNT(1) 
       FROM departments 
       WHERE location_id = l.location_id) > 0;

--9--
SELECT department_name
FROM departments d  
WHERE NOT EXISTS (SELECT 1
                  FROM employees
                  WHERE department_id = d.department_id);

--22.04.2020--
--Clauza WITH--

WITH val_dep AS (...),
val_medie AS (...)  -- pot sa folosesc val_dep aici
-- pot sa folosesc un bloc in celalalt cu conditia sa fie definit anterior, 
-- avand grija sa pun alias la coloana pe care o folosesc
SELECT *
FROM val_dep
WHERE total > (SELECT medie
               FROM val_medie)
ORDER BY department_name;

--10--
WITH val_dep AS (SELECT department_name, SUM(salary) total
                 FROM employees JOIN departments USING (department_id)
                 GROUP BY department_id, department_name),
val_medie AS (SELECT AVG(total) medie
              FROM val_dep)
SELECT *
FROM val_dep
WHERE total > (SELECT medie
               FROM val_medie)
ORDER BY department_name;

--11--
WITH steven_id AS (SELECT employee_id
                   FROM employees
                   WHERE first_name = 'Steven' AND last_name = 'King'),
subalterni_steven AS (SELECT *
                      FROM employees
                      WHERE manager_id = (SELECT employee_id
                                          FROM steven_id)),
vechime_max AS (SELECT MIN(hire_date) minh
                FROM subalterni_steven)
SELECT employee_id, first_name, last_name, job_id, hire_date
FROM employees 
WHERE manager_id = (SELECT employee_id 
                    FROM subalterni_steven, vechime_max -- eroare fara vechime_max!!
                    WHERE hire_date = minh);


--Analiza top-n--
-- reamintire problema lab. trecute = pb.12--
SELECT first_name, salary
FROM employees e
WHERE (SELECT COUNT(*)
       FROM employees
       WHERE salary > e.salary) < 10
ORDER BY salary DESC;

--12--
-- solutie cu ROWNUM
SELECT first_name, salary 
FROM (SELECT first_name, salary 
      FROM employees 
      ORDER BY salary DESC) 
WHERE ROWNUM <= 10; -- obtin primele 10 linii din al doilea select care sigur sunt ordonate cum trebuie!

-- NU PUNEM ORDER BY DUPA ROWNUM!!!

--13--
SELECT job_title 
FROM (SELECT job_title 
      FROM jobs j 
      ORDER BY (SELECT AVG(salary) 
                FROM employees 
                WHERE job_id = j.job_id) ASC) 
WHERE ROWNUM <=3;

-- sau facem cu WITH
WITH tab_medie AS (SELECT job_id, AVG(salary) medie 
                   FROM employees 
                   GROUP BY job_id)
SELECT job_title
FROM (SELECT job_title
      FROM jobs j JOIN tab_medie USING (job_id)
      ORDER BY medie ASC)
WHERE ROWNUM <= 3;

-- sau facem cu group by si apoi cu order by

--14--
SELECT
    job_id,
    CASE
        WHEN LOWER(job_id) LIKE 's%' THEN
            (SELECT SUM(salary)
             FROM employees
             WHERE job_id = e.job_id)
        WHEN job_id IN (SELECT job_id
                        FROM employees
                        WHERE salary = (SELECT MAX(salary)
                                        FROM employees)) THEN AVG(salary)
        ELSE (SELECT MIN(salary)
              FROM employees
              WHERE job_id = e.job_id)
    END "Calcul"
FROM employees e
GROUP BY job_id;




                  
                  