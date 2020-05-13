-- Lab 1
------ 19.02.2020 ------
SELECT job_title, (min_salary + max_salary) / 2 AS "salariu mediu", 2*2
FROM grupa135.jobs
-- ORDER BY "salariu mediu" DESC; -- alias
ORDER BY 2 DESC, 1; -- coloana

SELECT 1+1 calcul, POWER(2,3) AS putere
FROM DUAL;

-- 3
-- DESC[RIBE]
DESCRIBE employees;
DESC departments;
DESC jobs;
DESC job_history;
DESC locations;
DESC countries;
DESC regions;

-- 4
SELECT * 
FROM employees;

-- 5
SELECT employee_id, last_name, hire_date, job_id 
FROM employees;

-- 6
-- expression [AS] alias
-- If an alias contains blank spaces, it is mandatory to be written between "".
SELECT employee_id AS cod, last_name AS nume, hire_date AS "data angajarii", job_id AS "cod job" 
FROM employees;

SELECT employee_id cod, last_name nume, job_id "cod job", hire_date "Data angajarii"
FROM employees;

-- 7
SELECT DISTINCT job_id 
FROM employees;

-- 8
SELECT last_name || ', ' || job_id AS "Angajat si titlu" 
FROM employees;

------ 26.02.2020 ------
-- NOTE: How do we add a column that isn't in the table?
SELECT e.*, SYSDATE
FROM employees e; -- works only if we add an alias (e.g. e)

-- 9
SELECT employee_id || ', ' || first_name || ', ' || last_name || ', ' || job_id || ', ' || hire_date AS "Informatii complete" 
FROM employees;

-- 10
SELECT last_name, salary -- selectie(restrang rez pe orizontala) si proiectie(restrang rezultatul pe verticala)
FROM employees
WHERE salary > 2850; -- conditie

-- 11
SELECT last_name, department_id
FROM employees
WHERE employee_id = 104;

-- 12
SELECT last_name, salary
FROM employees
WHERE salary NOT BETWEEN 4400 AND 17000 -- between se refera la intervalul inchis
ORDER BY 2;

-- 13
SELECT last_name, job_id, hire_date
FROM employees
WHERE hire_date BETWEEN '20-feb-1987' AND '1-may-1989'
ORDER BY hire_date;

-- 14
SELECT last_name, department_id
FROM employees
WHERE department_id IN (10, 30, 50) -- apartenenta la o multime finita de valori
ORDER BY last_name;

-- 15
SELECT last_name, salary, department_id
FROM employees
WHERE department_id IN (10, 30, 50) AND salary > 1500
ORDER BY last_name;

-- 16
SELECT SYSDATE
FROM DUAL;

SELECT TO_CHAR(SYSDATE, 'DD.MM.YYYY MI:SS') AS "Today"
FROM DUAL;

SELECT TO_CHAR(SYSDATE, 'DAY, MON ''YY hh24:MI:SS') AS "Today" -- atentie dublez '' ca sa pot afisa '
FROM DUAL; -- ORA SERVERULUI - exista decalaje intre ora serverului cu ora normala

-- 17
SELECT last_name, hire_date
FROM employees
WHERE hire_date LIKE ('%87%');

-- sau
SELECT last_name, hire_date
FROM employees
WHERE TO_CHAR(hire_date, 'yyyy') = 1987; -- se formateaza data
-- merge fara sa fie sir pt ca se face conversie automat

--sau
SELECT last_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 1987;

-- 18
SELECT last_name, first_name, hire_date
FROM employees
WHERE TO_CHAR(hire_date, 'DD') = TO_CHAR(SYSDATE, 'DD');

-- 19
SELECT last_name, job_id
FROM employees
WHERE manager_id IS NULL;

-- 20
SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct IS NOT NULL;

-- 21
SELECT last_name, salary, commission_pct
FROM employees
ORDER BY 2 DESC, 3 DESC;

-- 22
SELECT last_name
FROM employees
WHERE last_name LIKE ('___a%');

-- 23
SELECT last_name
FROM employees
WHERE LOWER(last_name) LIKE ('%l%l%') AND 
      (department_id = 30 OR manager_id = 103);    

-- 24
SELECT last_name, job_id, salary
FROM employees
WHERE (job_id LIKE '%CLERK%' OR job_id LIKE '%REP%') AND 
      salary NOT IN (1000, 2000, 3000);

-- 25
SELECT department_id
FROM departments
WHERE manager_id IS NULL;
