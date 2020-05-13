--LAB 5--
--01.04.2020--
--1--
SELECT department_id, job_id, SUM(salary)
FROM employees
GROUP BY department_id, job_id
ORDER BY department_id, job_id;

--2--
SELECT department_id, department_name, job_id, job_title, SUM(salary)
FROM employees JOIN departments USING (department_id) JOIN jobs USING (job_id)
GROUP BY department_id, job_id, department_name, job_title
ORDER BY department_id, job_id;

--3--
SELECT department_name, 
       MIN(salary)
FROM employees JOIN departments USING (department_id)
GROUP BY department_id,
         department_name
HAVING AVG(salary) = (SELECT MAX(AVG(salary))
                      FROM employees
                      GROUP BY department_id);
                      
--4--
--a)
SELECT e.department_id, d.department_name, COUNT(*)
FROM employees e, departments d
WHERE e.department_id = d.department_id
GROUP BY e.department_id, d.department_name
HAVING COUNT(*) < 4;
-- sau
SELECT e.department_id, d.department_name, COUNT(*)
FROM employees e JOIN departments d ON (e.department_id = d.department_id)
GROUP BY e.department_id, d.department_name
HAVING COUNT(*) < 4;

--b)
SELECT e.department_id, d.department_name, COUNT(*)
FROM employees e, departments d
WHERE e.department_id = d.department_id
GROUP BY e.department_id, d.department_name
HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                   FROM employees
                   GROUP BY department_id);
-- sau
SELECT e.department_id, d.department_name, COUNT(*)
FROM employees e JOIN departments d ON (e.department_id = d.department_id)
GROUP BY e.department_id, d.department_name
HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                   FROM employees
                   GROUP BY department_id);

--5--
SELECT *
FROM employees
WHERE TO_CHAR(hire_date, 'DD') IN ( -- pot fi mai multe, deci IN si nu =
    SELECT TO_CHAR(hire_date, 'DD')
    FROM employees
    GROUP BY TO_CHAR(hire_date, 'DD')
    HAVING COUNT(*) = (
        SELECT MAX(COUNT(*))
        FROM employees
        GROUP BY to_char(hire_date, 'DD')
    )
);

--6--
SELECT COUNT(COUNT(*)) -- functie grup imbricata!!!
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 15;

--7--
SELECT department_id, SUM(salary) "Suma salariilor"
FROM employees
GROUP BY department_id
HAVING COUNT(employee_id) > 10 AND department_id != 30 -- nu se supara ca e pe linii
ORDER BY SUM(salary);
-- (Cine stie sa verifice la nivel de grup, stie sa verifice si la nivel de linii.)

-- Insa, daca vb de planurile de executie:
-- mai intai se face filtrarea pe linii si pe liniile ramase se aplica filtrarea pe grupuri
-- => e mai bine ca conditia de linie sa fie in where
-- ca dupa intra in group by cu mai putine linii!!

-- deci mai intai se EVALUAEZA (nu executa) WHERE
SELECT department_id, SUM(salary) "Suma salariilor"
FROM employees
WHERE department_id != 30
GROUP BY department_id
HAVING COUNT(employee_id) > 10 -- sau COUNT(*)
ORDER BY SUM(salary); -- order by e mereu ultima clauza!!! SI ESTE SI ULTIMA EVALUARE/ EXECUTARE

--8--
-- Folosim tabelul employees de 2 ori cu alias diferite
-- 1 data pt date individuale, 1 data pt grup
SELECT d.department_id, 
       d.department_name,
       COUNT(e.employee_id), 
       AVG(e.salary),
       e2.first_name, e2.salary, e2.job_id -- informatia la nivel de linie
FROM departments d LEFT OUTER JOIN employees e ON (e.department_id = d.department_id) 
     LEFT JOIN employees e2 ON (e2.department_id = d.department_id)
GROUP BY d.department_id, d.department_name, e2.first_name, e2.salary, e2.job_id;
-- se propaga, ce castig se pierde
-- hai ca lasam si angajatii fara departament deci full outer join

-- ambele join-uri left!


SELECT department_id, department_name,
       COUNT(e.employee_id), AVG(e.salary),
       e2.first_name, e2.salary, e2.job_id 
FROM departments LEFT OUTER JOIN employees e USING (department_id) 
     LEFT JOIN employees e2 USING (department_id)
GROUP BY department_id, department_name, e2.first_name, e2.salary, e2.job_id;

--sau
SELECT e.department_id, d.department_name,
       (SELECT COUNT(employee_id) FROM employees WHERE department_id = e.department_id) "Employees",
       (SELECT AVG(salary) FROM employees WHERE department_id = e.department_id) "Avg Salary",
       e.first_name, e.salary, e.job_id
FROM employees e RIGHT OUTER JOIN departments d ON (e.department_id = d.department_id);


--9--
SELECT l.city, d.department_name, SUM(e.salary)
FROM departments d JOIN locations l USING (location_id) LEFT JOIN employees e USING (department_id)
WHERE department_id > 80
GROUP BY department_id, d.department_name, l.city;

SELECT d.department_id, l.city, d.department_name, NVL(SUM(e.salary), 0)
FROM departments d, locations l, employees e
WHERE e.department_id(+) = d.department_id 
      AND d.location_id=l.location_id(+)
      AND department_id > 80
GROUP BY department_id, d.department_name, l.city;

--08.04.2020--

--10-- modificat
--Pb 10 completata: informatii despre angajatii care au avut cel putin 3 job-uri (inclusiv cel curent), fara a considera duplicatele.
SELECT e.employee_id, e.first_name 
FROM employees e JOIN job_history j ON (j.employee_id = e.employee_id AND j.job_id != e.job_id)
GROUP BY e.employee_id, e.first_name
HAVING COUNT(DISTINCT j.job_id) >= 2;

--11--
-- Gresit:
SELECT AVG(commission_pct) -- Functiile grup ignora valorile null
FROM employees;
-- prin urmare, instructiunea va returna media valorilor pe baza liniilor 
-- din tabel pentru care exista o valoare diferita de null. 

-- Corect:
SELECT AVG(NVL(commission_pct, 0))
FROM employees;
-- sau
SELECT SUM(commission_pct) / COUNT(*)
FROM employees;

--12--
SELECT job_id,
       SUM(DECODE(department_id, 30, salary)) "Dep30",
       SUM(DECODE(department_id, 50, salary)) "Dep50",
       SUM(DECODE(department_id, 80, salary)) "Dep80",
       SUM(salary) Total
FROM employees
GROUP BY job_id;
-- salary, null sau doar salary ca oricum group by ignora null urile

SELECT job_id, job_title "Job",
       NVL(SUM(CASE department_id WHEN 30 THEN salary END), 0) "Dep30",
       NVL(SUM(CASE department_id WHEN 50 THEN salary END), 0) "Dep50",
       NVL(SUM(CASE department_id WHEN 80 THEN salary END), 0) "Dep80",
       SUM(salary) Total
FROM jobs JOIN employees USING (job_id)
GROUP BY job_id, job_title;

--13--
SELECT COUNT(employee_id),
       COUNT(DECODE(TO_CHAR(hire_date, 'yyyy'), 1997, employee_id)) "1997",
       COUNT(DECODE(TO_CHAR(hire_date, 'yyyy'), 1998, employee_id)) "1998",
       COUNT(DECODE(TO_CHAR(hire_date, 'yyyy'), 1999, employee_id)) "1999",
       COUNT(DECODE(TO_CHAR(hire_date, 'yyyy'), 2000, employee_id)) "2000"
FROM employees;

SELECT COUNT(employee_id), 
       COUNT(DECODE(TO_CHAR(hire_date, 'yyyy'), '1997', 1)) "1997",
       COUNT(DECODE(TO_CHAR(hire_date, 'yyyy'), '1998', 1)) "1998",
       COUNT(DECODE(TO_CHAR(hire_date, 'yyyy'), '1999', 1)) "1999",
       COUNT(DECODE(TO_CHAR(hire_date, 'yyyy'), '2000', 1)) "2000"
FROM employees;
-- e mai bine cu constanta


--14--
SELECT d.department_id, department_name, a.suma
FROM departments d, (SELECT department_id ,SUM(salary) suma
                     FROM employees
                     GROUP BY department_id) a
WHERE d.department_id = a.department_id (+); -- neaparat sa am grija sa am coloana pt ca sa fac join 

-- sau
SELECT department_id, department_name, NVL(a.suma, 0)
FROM departments d LEFT JOIN (SELECT department_id ,SUM(salary) suma
                              FROM employees
                              GROUP BY department_id) a USING (department_id); 

--15--
SELECT DISTINCT j.job_title, tb.avg_sal, (j.max_salary + j.min_salary) / 2 - tb.avg_sal
FROM jobs j, (SELECT e.job_id, AVG(e.salary) AS avg_sal
              FROM employees e
              GROUP BY e.job_id) tb
WHERE j.job_id = tb.job_id (+);

--16--
SELECT DISTINCT j.job_title, tb.avg_sal, (j.max_salary + j.min_salary) / 2 - tb.avg_sal, tb.nr
FROM jobs j, (SELECT e.job_id, AVG(e.salary) AS avg_sal, COUNT(*) as nr
              FROM employees e
              GROUP BY e.job_id) tb
WHERE j.job_id = tb.job_id (+);

--17--
SELECT department_name, last_name, min_sal
FROM departments d, employees e, (SELECT department_id, min(salary) min_sal
                                  FROM employees
                                  GROUP BY department_id) a
WHERE e.department_id (+) = d.department_id and d.department_id = a.department_id (+)
      AND nvl(e.salary, -1) = nvl(a.min_sal, -1);

