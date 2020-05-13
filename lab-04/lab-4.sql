-- lab 4
--25.03.2020--
--1--
SELECT last_name, hire_date
FROM employees
WHERE hire_date > (SELECT hire_date
                   FROM employees
                   WHERE INITCAP(last_name)='Gates');
--2--
SELECT last_name, salary
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM employees
                        WHERE LOWER(last_name)='gates')
AND LOWER(last_name) <> 'gates';
-- folosim = daca subcererea returneaza o singura linie 
-- altfel (cererea returneaza mai mult de o linie) folosim IN 

--3--
-- Daca am un singur angajat fara manager 
SELECT last_name, salary
FROM employees
WHERE manager_id = (SELECT employee_id
                    FROM employees  
                    WHERE manager_id IS NULL);
                            
SELECT last_name, salary
FROM employees e
WHERE e.manager_id IN (SELECT employee_id
                       FROM employees t
                       WHERE t.manager_id IS NULL);
                       
--4--
SELECT last_name, department_id, salary
FROM employees
WHERE (department_id, salary) IN (SELECT department_id, salary
                                  FROM employees
                                  WHERE commission_pct IS NOT NULL);

--5-- = problema 6 din lab-3
SELECT e.employee_id, e.last_name, e.salary
FROM employees e
WHERE e.salary > 
        (
        SELECT (j.min_salary + j.max_salary) / 2
        FROM jobs j
        WHERE j.job_id = e.job_id
        )
AND e.department_id IN
        (
        SELECT department_id
        FROM employees m
        WHERE LOWER(m.last_name) LIKE '%t%'
        );

--6--
SELECT *
FROM employees e
WHERE salary > ALL
        (
        SELECT salary
        FROM employees
        WHERE job_id LIKE '%CLERK'
        )
ORDER BY salary DESC;

--7--
SELECT e.last_name, d.department_name, e.salary
FROM employees e, departments d
WHERE (e.department_id = d.department_id)
      AND e.commission_pct IS NULL
      AND e.manager_id IN (SELECT e2.employee_id
                           FROM employees e2
                           WHERE e2.commission_pct IS NOT NULL);

--8--
SELECT last_name, department_id, salary, job_id
FROM employees
WHERE (salary, NVL(commission_pct, -1)) IN
        (
        SELECT salary, NVL(commission_pct, -1)
        FROM employees e, departments d, locations l
        WHERE e.department_id = d.department_id AND
              d.location_id = l.location_id AND
              LOWER(l.city) = 'oxford'
        );

--9--
SELECT last_name, department_id, job_id
FROM employees
WHERE department_id IN 
    (
    SELECT department_id
    FROM departments
    WHERE location_id IN
        (
        SELECT location_id
        FROM locations
        WHERE LOWER(city) = 'toronto'
        )
    );                      

--10--
-- a) Functiile grup includ valorile NULL in calcule? 
-- Raspuns: Toate functiile grup, cu exceptia lui COUNT(*), ignora valorile null.
-- b) Care este deosebirea dintre clauzele WHERE si HAVING? 
-- Raspuns: WHERE -> specifica o conditie ce se aplica pe linii <> HAVING -> pe grupuri

--11--
SELECT MAX(salary) "Maxim", MIN(salary) "Minim", SUM(salary) "Suma", ROUND(AVG(salary)) "Media", COUNT(*)
FROM employees;

SELECT MAX(salary) "Maxim", MIN(salary) "Minim", SUM(salary) "Suma", ROUND(AVG(salary)) "Media", COUNT(employee_id)
FROM employees;

--12 + 13--
SELECT job_id Job, MAX(salary) Maxim, MIN(salary) Minim, SUM(salary) Suma, ROUND(AVG(salary)) Media, COUNT(employee_id)
FROM employees
GROUP BY job_id;

--14--
SELECT COUNT(DISTINCT manager_id) 
FROM employees;

--15--
SELECT MAX(e.salary) - MIN(e.salary) AS "Diferenta"
FROM employees e;

--16--
SELECT d.department_name, l.city, COUNT(employee_id), ROUND(AVG(e.salary))
FROM employees e, departments d, locations l
WHERE e.department_id (+) = d.department_id AND
      d.location_id = l.location_id
GROUP BY department_name, city;

SELECT department_name, city, COUNT(employee_id), ROUND(AVG(NVL(salary, 0)))
FROM employees RIGHT JOIN departments USING (department_id) JOIN locations USING (location_id)
GROUP BY department_name, city;

SELECT d.department_name,
       l.city,
       COUNT(*) AS "Numar angajati",
       ROUND(AVG(e.salary)) AS "Medie"
FROM departments d
JOIN locations l ON l.location_id = d.location_id
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_name, l.city;

-- Atentie la COUNT(*) in contextul lui OUTER JOIN!!!

--17--
SELECT employee_id, last_name
FROM employees
WHERE salary > (SELECT ROUND(AVG(salary))
                FROM employees)
ORDER BY salary DESC;

--18-- 
SELECT manager_id, MIN(salary) 
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING MIN(salary) > 1000
ORDER BY MIN(salary) DESC;


--01.04.2020--
--19--
-- ASA NU:
SELECT department_name, MAX(salary)
FROM employees JOIN departments USING (department_id)
WHERE salary > 3000;

-- ASA DA:
SELECT e.department_id, d.department_name, MAX(e.salary)
FROM employees e JOIN departments d ON (e.department_id = d.department_id)
GROUP BY e.department_id, d.department_name -- punem si coloana department_name pt ca o vrem afisata
HAVING MAX(salary) > 3000;

-- atributele din SELECT care nu sunt fct grup treb sa reprezinte atribut de grupare
-- pt ca altfel nu stie ce e cu el

-- nu facem outer join pt ca avem conditie, deci nu avem valori null

--20--
SELECT MIN((SELECT AVG(salary) -- cereri sincronizate!
           FROM employees e
           WHERE e.job_id = j.job_id))
FROM jobs j;

--ASA!
SELECT MIN(AVG(salary))
FROM employees
GROUP BY job_id;

--21--
SELECT d.department_id, d.department_name, NVL(SUM(e.salary), 0)
FROM employees e RIGHT JOIN departments d ON (e.department_id = d.department_id)
GROUP BY d.department_id, d.department_name;

--22--
SELECT MAX(AVG(salary))
FROM employees
GROUP BY department_id;

--23--
SELECT job_id, 
       job_title, 
       AVG(salary)
FROM employees JOIN jobs USING (job_id)
GROUP BY job_id, 
         job_title
HAVING AVG(salary) = (SELECT MIN(AVG(salary))
                      FROM employees
                      GROUP BY job_id);


--24--
SELECT AVG(salary)
FROM employees
HAVING AVG(salary) > 2500;
-- nu am date agregate deci nu e nevoie de group by



