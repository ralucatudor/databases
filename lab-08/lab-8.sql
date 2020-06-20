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
-- Introducerea CONSTRANGERILOR DE INTEGRITATE:
ALTER TABLE emp_rtu
ADD CONSTRAINT pk_emp_rtu PRIMARY KEY(employee_id);

ALTER TABLE dept_rtu
ADD CONSTRAINT pk_dept_rtu PRIMARY KEY(department_id);

ALTER TABLE emp_rtu
ADD CONSTRAINT fk_emp_dept_rtu FOREIGN KEY(department_id) REFERENCES dept_rtu(department_id);

-- Ce constrangeri nu am implementat?
ALTER TABLE emp_rtu
ADD CONSTRAINT fk_emp_man_rtu FOREIGN KEY(manager_id) REFERENCES emp_rtu(emp_id);
-- ca sa nu pot sa pun la manager_id un id care nu exista

desc user_constraints;

--5--
--a)
INSERT INTO DEPT_rtu
VALUES (300, 'Programare');
-- nu e ok - nu se furnizeaza valori pt. fiecare atribuit al obiectului destinatie

--b)
INSERT INTO DEPT_rtu (department_id, department_name)
VALUES (300, 'Programare');
ROLLBACK;
-- este ok!

--c)
INSERT INTO DEPT_rtu (department_name, department_id)
VALUES (300, 'Programare');
-- nu e ok (nu se respecta ordinea)

--d)
INSERT INTO DEPT_rtu (department_id, department_name, location_id)
VALUES (300, 'Programare', null);
ROLLBACK;
-- este ok!

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
-- Demonstram ca NU se poate cu WITH!!!
WITH t AS (SELECT MAX(employee_id) + 1 cod FROM emp_rtu)
INSERT INTO
 (SELECT employee_id, last_name, email, hire_date, job_id, salary, commission_pct
 FROM emp_rtu)
VALUES ((SELECT cod FROM t), 'Nume255', 'nume255@emp.com', SYSDATE, 'SA_REP', 5000, NULL);

--10--
-- Creati un nou tabel, numit EMP1_PNU, care va avea aceeaai structura ca si EMPLOYEES, dar nicio inregistrare.
CREATE TABLE emp1_rtu AS SELECT * FROM employees WHERE 1=0;
--DELETE FROM emp1_rtu; --necesar daca nu aveam clauza WHERE de mai sus

-- Copiati in tabelul EMP1_PNU salariatii (din tabelul EMPLOYEES) al caror comision depaseste 25% din salariu.
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
 WHEN salary BETWEEN 5000 AND 10000 THEN INTO emp2_rtu
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

-- FIRST determina inserarea corespunzatoare primei clauze WHEN a carei conditie
-- este evaluata TRUE. Toate celelalte clauze WHEN sunt ignorate.

SELECT * FROM emp0_rtu;
SELECT * FROM emp1_rtu;
SELECT * FROM emp2_rtu;
SELECT * FROM emp3_rtu;


-----UPDATE-----
--15--
UPDATE emp_rtu
SET salary = salary * 1.05;
SELECT * FROM emp_rtu;

ROLLBACK;

--16--
UPDATE emp_rtu
SET job_id = 'SA_REP'
WHERE department_id = 80;   -- - daca nu apare clauza WHERE atunci sunt afectate toate liniile tabelului specificat
ROLLBACK;

--17--
SELECT * FROM dept_rtu WHERE department_id=20;

-- SA se promoveze Douglas Grant la functia de manager in departamentul 20...
UPDATE dept_rtu
SET manager_id = (SELECT employee_id FROM emp_rtu WHERE LOWER(first_name || ' ' || last_name) = 'douglas grant')
WHERE department_id = 20;

-- ...avand o crestere de salariu de 1000.
UPDATE emp_rtu
SET salary = salary +1000
WHERE LOWER(first_name || ' ' || last_name) = 'douglas grant';

--18--
-- Schimbati salariul si comisionul celui mai prost platit salariat din firma, astfel incat sa
-- fie egale cu salariul si comisionul sefului sau.
UPDATE emp_rtu e
SET (salary, commission_pct) = (SELECT salary, commission_pct
                                FROM emp_rtu 
                                WHERE employee_id = e.manager_id)
WHERE salary = (SELECT MIN(salary) FROM emp_rtu);     

--19--
UPDATE emp_rtu e
SET email = SUBSTR(last_name, 1, 1) || NVL(first_name, '.')  --  Daca nu are prenume atunci in loc de acesta apare caracterul '.'.
WHERE salary = (SELECT MAX(salary) FROM emp_rtu WHERE department_id = e.department_id);

ROLLBACK;

--21--
--subcereri pe tupluri
UPDATE emp_rtu
SET (job_id, department_id) = (SELECT job_id, department_id FROM emp_rtu WHERE employee_id = 205)
WHERE employee_id=114;


--DELETE--
-- DELETE FROM nume_tabel
-- [WHERE conditie];
-- Daca nu se specifica nicio conditie, atunci vor fi sterse toate liniile din tabel.
--23--
DELETE FROM dept_rtu; -- eroare
DELETE FROM emp_rtu WHERE department_id IS NOT NULL;
DELETE FROM dept_rtu;

SELECT * FROM emp_rtu;
SELECT * FROM dept_rtu;

ROLLBACK;

--20.05.2020--

--24
DELETE FROM emp_rtu WHERE commission_pct IS NULL;
ROLLBACK;

--25. Suprimati departamentele care un nu nici un angajat. Anulati modificarile.
ROLLBACK;

DELETE FROM dept_rtu
WHERE department_id NOT IN (SELECT NVL(department_id, -1) FROM emp_rtu);

ROLLBACK;

--26. Sa se creeze un fisier script prin care se cere un cod de angajat din tabelul EMP_PNU.
--Se va lista inregistrarea corespunzatoare acestuia, iar apoi linia va fi suprimata din tabel.
ACCEPT p_cod PROMPT 'Introduceti codul de angajat'
SELECT * FROM emp_rtu WHERE employee_id = &p_cod;

DELETE FROM emp_rtu
WHERE employee_id = &p_cod;


--27. Sa se stearga un angajat din tabelul EMP_PNU prin intermediul script-ului creat la pb. 26 
-- Modificarile vor deveni permanente.

--28. Sa se mai introduca o linie in tabel, ruland inca o data fisierul creat la ex. 12.
DESC emp_rtu;

INSERT INTO emp_rtu (employee_id, last_name, email, hire_date, job_id) VALUES (300, 'Nume300', 'nume300@email.com', sysdate, 'IT_PROG');

--29. Sa se marcheze un punct intermediar in procesarea tranzactiei.
SAVEPOINT p;

--30. Sa se stearga tot continutul tabelului. Listati continutul tabelului.
DELETE FROM emp_rtu;
SELECT * FROM emp_rtu;

--31. Sa se renunte la cea mai recenta operatie de stergere, fara a renunta la operatia
--precedenta de introducere.
ROLLBACK TO p;

--32. Listati continutul tabelului. Determinati ca modificarile sa devina permanente.
SELECT * FROM emp_rtu;

COMMIT;

---

DELETE FROM emp_rtu
WHERE employee_id = 300;

SAVEPOINT a;

DELETE FROM emp_rtu
WHERE employee_id = 152;

SAVEPOINT b;

ROLLBACK to a;
ROLLBACK to b;

COMMIT;
