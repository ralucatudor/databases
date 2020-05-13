--04.03.2020--
SELECT TO_CHAR(SYSDATE, 'DAY, MON ''YY HH24:MI:SS') AS "Today" -- atentie: dublez '' ca sa pot afisa '
FROM DUAL; -- ORA SERVERULUI - pot exista decalaje intre ora serverului si ora normala

SELECT ADD_MONTHS(TO_DATE('30/01/2019', 'dd/mm/yyyy'), 2)
FROM DUAL;

--Lab 2--
--1--
SELECT CONCAT(last_name, CONCAT(' ',first_name)) ||  ' castiga ' || salary || ' lunar dar doreste ' || salary * 3  
AS "Salariu ideal"
FROM employees;

SELECT first_name || ' ' || last_name || ' castiga ' || salary || ' dar doreste ' || (salary * 3) || '.'
AS "Salariu Ideal"
FROM Employees;

--2--
SELECT INITCAP(first_name), UPPER(last_name), LENGTH(last_name) AS Lg
FROM employees
WHERE SUBSTR(first_name, 1, 1) IN ('J', 'M') AND 
      first_name LIKE ('___a%')
ORDER BY Lg DESC;

--3--
SELECT first_name, employee_id, last_name, department_id
FROM employees
WHERE TRIM(LOWER(first_name)) = 'steven';

--4--
SELECT employee_id AS cod, last_name, LENGTH(last_name), INSTR(LOWER(last_name), 'a') AS pozitie
FROM employees
WHERE last_name LIKE '%e';

SELECT employee_id AS cod, last_name, LENGTH(last_name), INSTR(LOWER(last_name), 'a') AS pozitie
FROM employees
WHERE SUBSTR(last_name, length(last_name)) = 'e';

SELECT employee_id AS cod, last_name, LENGTH(last_name), INSTR(LOWER(last_name), 'a') AS pozitie
FROM employees
WHERE SUBSTR(last_name, -1) = 'e';

--5--
SELECT employee_id AS cod, last_name, first_name
FROM employees
WHERE TO_CHAR(hire_date, 'D') = TO_CHAR(SYSDATE, 'D');

SELECT * 
FROM employees 
WHERE MOD(ROUND(SYSDATE - hire_date), 7) = 0;

SELECT *
FROM employees
WHERE MOD(FLOOR((SYSDATE - hire_date)), 7) = 0;

--6--
SELECT employee_id, first_name, last_name, ROUND(salary * 1.15,2) AS "salariu marit"
FROM employees
WHERE MOD(salary, 1000) != 0;

SELECT employee_id, 
       last_name, 
       department_id, 
       salary, 
       ROUND(salary + 15 * salary / 100, 2) AS "salariu marit", 
       ROUND((salary + 15 * salary / 100) / 100, 2) AS "Numar sute"
FROM EMPLOYEES
WHERE MOD(salary, 1000) != 0;

--7--
SELECT last_name AS "Nume angajat", hire_date AS "Data initiala", RPAD(hire_date, 20) AS "Data angajarii"
FROM employees
WHERE commission_pct IS NOT NULL;

--8--
SELECT to_char(sysdate + 30, 'DAY, MON ''YY HH24:MI:SS') 
FROM DUAL;

--9--
SELECT FLOOR(TO_DATE(CONCAT('31/12/', TO_CHAR(SYSDATE, 'YY')), 'DD/MM/YY') - SYSDATE) + 1
FROM DUAL;

SELECT TO_DATE(CONCAT('31-DEC-', TO_CHAR(SYSDATE, 'YY')), 'DD-MON-YY') - TRUNC(SYSDATE)
FROM DUAL;

--10--
SELECT TO_CHAR(SYSDATE + 1 / 2, 'DAY, MON ''YY HH24:MI:SS')
FROM DUAL;

SELECT TO_CHAR(SYSDATE + 1 / 24 / 60 * 5, 'DAY, MON ''YY HH24:MI:SS')
FROM DUAL;

--11.03.2020--
--12--
SELECT last_name, ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS "Luni lucrate"
FROM employees
--order by "Luni lucrate";
ORDER BY 2;

--13--
SELECT last_name, hire_date, TO_CHAR(hire_date, 'DAY') AS "Zi"
FROM employees
ORDER BY TO_CHAR(hire_date, 'D');

SELECT * FROM nls_session_parameters;
ALTER SESSION SET nls_territory='AMERICA';

SELECT TO_CHAR(SYSDATE, 'D')
FROM DUAL;

--13
SELECT last_name, 
       hire_date, 
       TO_CHAR(hire_date, 'DAY') AS "Zi"
FROM employees
ORDER BY TO_CHAR(hire_date - 1, 'D');
--order by MOD(TO_NUMBER(TO_CHAR(hire_date, 'D')) + 5, 7)

--14--
SELECT last_name, 
       NVL(TO_CHAR(commission_pct), 'Fara comision') AS Comision
FROM employees;

--15--
SELECT last_name, salary, commission_pct
FROM employees
WHERE salary + (commission_pct * salary) > 10000;

SELECT last_name, salary, commission_pct
FROM employees
WHERE salary + (NVL(commission_pct, 0) * salary) > 10000;

--CASE/ DECODE--
--16--
SELECT last_name, 
       job_id, 
       salary, 
       DECODE(job_id, 
             'IT_PROG', salary * 1.2,
             'SA_REP', salary * 1.25,
             'SA_MAN', salary * 1.35,
             salary) "Salariu actualizat"
FROM employees;

SELECT last_name, 
       job_id, 
       salary, 
       CASE job_id 
            WHEN 'IT_PROG' THEN 
                 salary * 1.2
            WHEN 'SA_REP' THEN 
                 salary * 1.25
            WHEN 'SA_MAN' THEN 
                 salary * 1.35
            ELSE salary
       END "Salariu actualizat"
FROM employees;

--JOIN--
--17-- 
SELECT employees.last_name, employees.department_id, departments.department_name
FROM employees, departments
WHERE employees.department_id = departments.department_id;

--sau
SELECT e.last_name, e.department_id, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id;

--18--
SELECT DISTINCT e.job_id, job_title
FROM employees e, jobs j
WHERE e.job_id = j.job_id AND department_id = 30;

SELECT DISTINCT job_id, job_title
FROM employees e JOIN jobs j USING (job_id)
WHERE department_id = 30;

--19--
SELECT last_name, department_name, city
FROM employees e, departments d, locations l
WHERE e.department_id = d.department_id AND 
      d.location_id = l.location_id AND 
      commission_pct IS NOT NULL;
--sau
select last_name, department_name, city
FROM employees e JOIN departments d USING (department_id) JOIN locations l USING (location_id)
WHERE commission_pct > 0;

--20--
SELECT last_name, department_name
FROM employees JOIN departments USING (department_id)
WHERE UPPER(last_name) LIKE ('%A%');

--21--
select e.last_name, j.job_title, d.department_name
FROM employees e, jobs j, departments d, locations l
WHERE e.job_id = j.job_id AND 
      e.department_id = d.department_id AND
      d.location_id = l.location_id AND 
      l.city = 'Oxford';

--22--
SELECT e.employee_id AS Angajat#, 
       e.last_name AS Angajat, 
       e.manager_id AS Manager#, 
       m.last_name AS Manager
FROM employees e, employees m
WHERE e.manager_id = m.employee_id;

--23--
SELECT e.employee_id AS Angajat#, 
       e.last_name AS Angajat, 
       e.manager_id AS Manager#, 
       m.last_name AS Manager
FROM employees e, employees m
WHERE e.manager_id = m.employee_id (+);
-- Realizam operatia de outer-join, indicata în SQL prin “(+)” 
-- plasat la dreapta coloanei deficitare în informatie.

--sintaxa SQL3
SELECT e.employee_id AS Angajat#, 
       e.last_name AS Angajat, 
       e.manager_id AS Manager#, 
       m.last_name AS Manager
FROM employees e LEFT OUTER JOIN employees m ON (e.manager_id = m.employee_id);

--24--
SELECT e1.last_name AS Nume, e1.department_id AS "Cod dep", e2.last_name AS Colegi 
FROM employees e1, employees e2 
WHERE e1.department_id = e2.department_id(+) 
      AND e1.employee_id != e2.employee_id 
ORDER BY e1.employee_id;
------
SELECT e.employee_id, e.last_name, c.employee_id, c.last_name
FROM employees e, employees c
WHERE e.department_id = c.department_id 
      AND e.employee_id < c.employee_id;

SELECT e.employee_id, e.last_name, c.employee_id, c.last_name
FROM employees e 
JOIN employees c 
ON (e.department_id = c.department_id 
   AND e.employee_id < c.employee_id);

--25--
SELECT e.last_name, e.job_id, j.job_title, d.department_name, e.salary 
FROM employees e, departments d, jobs j 
WHERE e.job_id = j.job_id 
      AND e.department_id = d.department_id (+);

SELECT e.last_name, e.job_id, j.job_title, d.department_name, e.salary
FROM employees e 
LEFT JOIN departments d ON (e.department_id = d.department_id) 
JOIN jobs j ON (e.job_id = j.job_id);

--26--
SELECT e1.last_name, e1.hire_date 
FROM employees e1, employees e2 
WHERE LOWER(e2.last_name) = 'gates' 
      AND e1.hire_date > e2.hire_date;

SELECT e1.last_name, e1.hire_date 
FROM employees e1 
JOIN employees e2 ON (LOWER(e2.last_name) = 'gates' AND e1.hire_date > e2.hire_date);

--27--
SELECT e1.last_name AS Angajat, e1.hire_date AS Data_ang, e1.manager_id AS Manager, e2.hire_date AS Data_mgr 
FROM employees e1, employees e2 
WHERE e1.manager_id = e2.employee_id AND e1.hire_date < e2.hire_date;

SELECT e.last_name Angajat, e.hire_date Data_ang, m.last_name Manager, m.hire_date Data_mgr
FROM employees e 
JOIN employees m ON (e.manager_id = m.employee_id AND e.hire_date < m.hire_date);

SELECT e1.last_name AS Angajat, e1.hire_date AS Data_ang, e1.manager_id AS Manager, e2.hire_date AS Data_mgr 
FROM employees e1 
JOIN employees e2 ON (e1.manager_id = e2.employee_id)
WHERE e1.hire_date < e2.hire_date;
