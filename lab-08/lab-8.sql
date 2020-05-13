--Lab 8
--06.05.2020--
--1--
CREATE TABLE EMP_rtu AS SELECT * FROM employees;
CREATE TABLE DEPT_rtu AS SELECT * FROM departments;

--2--
DESC EMP_rtu;
DESC DEPT_rtu;

--3--
SELECT *
FROM EMP_rtu;

SELECT * 
FROM DEPT_rtu;

--4--
ALTER TABLE emp_rtu
ADD CONSTRAINT pk_emp_rtu PRIMARY KEY(employee_id);
ALTER TABLE dept_rtu
ADD CONSTRAINT pk_dept_rtu PRIMARY KEY(department_id);
ALTER TABLE emp_rtu
ADD CONSTRAINT fk_emp_dept_rtu
    FOREIGN KEY(department_id) REFERENCES dept_rtu(department_id);

--5--
--a)
INSERT INTO DEPT_rtu
VALUES (300, 'Programare');

--b)
INSERT INTO DEPT_rtu (department_id, department_name)
VALUES (300, 'Programare');
ROLLBACK;
--c)
INSERT INTO DEPT_rtu (department_name, department_id)
VALUES (300, 'Programare');

--d)
INSERT INTO DEPT_rtu (department_id, department_name, location_id)
VALUES (300, 'Programare', null);
ROLLBACK;
--e)
INSERT INTO DEPT_rtu (department_name, location_id)
VALUES ('Programare', null);

--6--
DESC EMP_rtu;

INSERT INTO emp_rtu(employee_id, last_name, email, hire_date, job_id, department_id)
VALUES(250, 'Nume1', 'nume1@gmail.com', sysdate, 'IT_PROG', 300);

COMMIT;

--7--
DESC EMP_rtu;

INSERT INTO emp_rtu
VALUES(251, 'Prenume2', 'Nume2', 'nume2@gmail.com', '0212345', sysdate, 'IT_PROG', 3000, null, null, 300);
COMMIT;

--13.05.2020--
SELECT * 
FROM DEPT_rtu;

SELECT *
FROM EMP_rtu;

INSERT INTO emp_rtu
VALUES(252, 'Prenume3', 'Nume3', 'nume3@gmail.com', '0212345', sysdate, 'IT_PROG', 3000, null, null, 300);
COMMIT;

INSERT INTO emp_rtu
VALUES(254, 'Prenume5', 'Nume5', 'nume5@gmail.com', '0212345', sysdate, 'IT_PROG', 3000, null, null, 300);
ROLLBACK;
COMMIT;
--------------
--8--
INSERT INTO emp_rtu (employee_id, last_name, email, hire_date,
 job_id, salary, commission_pct)
VALUES (255, 'Nume255', 'nume255@emp.com', SYSDATE, 'SA_REP', 5000, NULL);
SELECT employee_id, last_name, email, hire_date, job_id, salary, commission_pct
FROM emp_rtu
WHERE employee_id=255;
ROLLBACK;

-- cu subcerere pe post de tabel
INSERT INTO
 (SELECT employee_id, last_name, email, hire_date, job_id, salary, commission_pct
 FROM emp_rtu)
VALUES (255, 'Nume255', 'nume255@emp.com', SYSDATE, 'SA_REP', 5000, NULL);
SELECT employee_id, last_name, email, hire_date, job_id, salary, commission_pct
FROM emp_rtu
WHERE employee_id=255;
ROLLBACK;

-- cu subcerere pe valoarea coloanei
INSERT INTO
 (SELECT employee_id, last_name, email, hire_date, job_id, salary, commission_pct
 FROM emp_rtu)
VALUES ((SELECT MAX(employee_id) + 1 FROM emp_rtu), 'Nume255', 'nume255@emp.com', SYSDATE, 'SA_REP', 5000, NULL);

--9--
-- Demonstram ca NU se poate cu WITH
WITH t AS (SELECT MAX(employee_id) + 1 cod FROM emp_rtu)
INSERT INTO
 (SELECT employee_id, last_name, email, hire_date, job_id, salary, commission_pct
 FROM emp_rtu)
VALUES ((SELECT cod FROM t), 'Nume255', 'nume255@emp.com', SYSDATE, 'SA_REP', 5000, NULL);

--10--
CREATE TABLE emp1_rtu AS SELECT * FROM employees WHERE 1=0;
--DELETE FROM emp1_rtu; --necesar daca nu aveam clauza WHERE de mai sus

INSERT INTO emp1_rtu
 SELECT *
 FROM employees
 WHERE commission_pct > 0.25;
 
SELECT employee_id, last_name, salary, commission_pct
FROM emp1_rtu;

ROLLBACK;

-- V2 
CREATE TABLE emp1_rtu AS SELECT * FROM employees;
DELETE FROM emp1_rtu; 

INSERT INTO emp1_rtu
 SELECT *
 FROM employees
 WHERE commission_pct > 0.25;
 
SELECT employee_id, last_name, salary, commission_pct
FROM emp1_rtu;

ROLLBACK;

-- 11 skip--
--12--
REM setari
SET VERIFY OFF
REM comenzi ACCEPT
ACCEPT p_cod PROMPT 'Introduceti codul'
ACCEPT p_nume PROMPT 'Introduceti numele'
ACCEPT p_prenume PROMPT 'Introduceti prenumele'
ACCEPT p_salariu PROMPT 'Introduceti salariul'
INSERT INTO emp_rtu
VALUES (&p_cod, '&p_prenume', '&p_nume', SUBSTR('&p_prenume', 1, 1) || SUBSTR('&p_nume', 1, 7), null, SYSDATE, 'IT_PROG', &p_salariu, null, null, null);
REM suprimarea variabilelor utilizate
REM anularea setarilor, prin stabilirea acestora la valorile implicite

-- Pentru a rula, selectam tot si F5

SELECT *
FROM EMP_rtu
WHERE employee_id >= 256;

--13--
SELECT * FROM EMP1_rtu;
CREATE TABLE emp2_rtu AS SELECT * FROM employees WHERE 1=0;
CREATE TABLE emp3_rtu AS SELECT * FROM employees WHERE 1=0;
-- DROP TABLE ...


INSERT ALL
 WHEN salary < 5000 THEN INTO emp1_rtu
 WHEN salary between 5000 and 10000 THEN INTO emp2_rtu
 ELSE INTO emp3_rtu
SELECT * FROM employees;

SELECT * FROM emp1_rtu;
SELECT * FROM emp2_rtu;
SELECT * FROM emp3_rtu;

DELETE FROM emp1_rtu;
DELETE FROM emp2_rtu;
DELETE FROM emp3_rtu;

--14--
CREATE TABLE emp0_rtu AS SELECT * FROM employees where 1=0;
INSERT FIRST
 WHEN department_id=80 THEN INTO emp0_rtu
 WHEN salary < 5000 THEN INTO emp1_rtu
 WHEN salary between 5000 and 10000 THEN INTO emp2_rtu
 ELSE INTO emp3_rtu
SELECT * FROM employees;
SELECT * FROM emp0_rtu;
SELECT * FROM emp1_rtu;
SELECT * FROM emp2_rtu;
SELECT * FROM emp3_rtu;


--UPDATE--
--15--
UPDATE emp_rtu
SET salary = salary * 1.05;
SELECT * FROM emp_rtu;

ROLLBACK;

--16--
UPDATE emp_rtu
SET job_id = 'SA_REP'
WHERE department_id = 80;
ROLLBACK;

--17--
select * from dept_rtu where department_id=20;
update dept_rtu
set manager_id = (select employee_id from emp_rtu where lower(first_name || ' ' || last_name) = 'douglas grant')
where department_id = 20;

update emp_rtu
set salary = salary +1000
where lower(first_name || ' ' || last_name) = 'douglas grant';

--18--
update emp_rtu e
set (salary, commission_pct) = (select salary, commission_pct
                                from emp_rtu 
                                where employee_id = e.manager_id)
where salary = (select min(salary) from emp_rtu);     

--19--
update emp_rtu e
set email = substr(last_name, 1, 1) || nvl(first_name, '.')
where salary = (select max(salary) from emp_rtu where department_id = e.department_id);

rollback;

--21--
--subcereri pe tupluri
update emp_rtu
set (job_id, department_id) = (select job_id, department_id from emp_rtu where employee_id = 205)
where employee_id=114;


--DELETE--
--23--
delete from dept_rtu; -- eroare
delete from emp_rtu where department_id is not null;
delete from dept_rtu;

select * from emp_rtu;
select * from dept_rtu;

rollback;






