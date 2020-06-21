--lab 10
--1
create or replace view VIZ_EMP30_rtu as
  select employee_id, last_name, email, salary from emp_rtu where department_id = 30;

desc VIZ_EMP30_rtu;
select * from VIZ_EMP30_rtu;

insert into VIZ_EMP30_rtu values(300, 'Nume300', 'Nume300', 1234);

--2
create or replace view VIZ_EMP30_rtu as
  select employee_id, last_name, email, salary, hire_date, job_id from emp_rtu where department_id = 30;
  
select * from VIZ_EMPSAL50_rtu;


select * from emp_rtu;

select * from VIZ_EMP30_rtu;

--NOK
UPDATE viz_emp30_rtu
SET hire_date=hire_date-15
WHERE employee_id=300;

UPDATE emp_rtu
SET department_id=30
WHERE employee_id=300;

--OK
UPDATE viz_emp30_rtu
SET hire_date=hire_date-15
WHERE employee_id=300;

delete from viz_emp30_rtu where employee_id = 300;

(--7)
create or replace view VIZ_EMP30_rtu as
  select employee_id, last_name, email, salary, hire_date, job_id from emp_rtu where department_id = 30 
  with check option;
  
insert into VIZ_EMP30_rtu values(301, 'Nume301', 'Nume301', 123456, sysdate, 'IT_PROG');  

--3
create or replace view VIZ_EMPSAL50_rtu as
  select employee_id, last_name, email, salary * 12 sal_anual, hire_date, job_id from emp_rtu where department_id = 50; 

desc VIZ_EMPSAL50_rtu;
select * from VIZ_EMPSAL50_rtu;

--4
--a
insert into VIZ_EMPSAL50_rtu values(302, 'Nume302', 'Nume302', 12000, sysdate, 'IT_PROG');  

--b
desc USER_UPDATABLE_COLUMNS;
select * from USER_UPDATABLE_COLUMNS where TABLE_NAME = 'VIZ_EMPSAL50_RTU';

--c
insert into VIZ_EMPSAL50_rtu(employee_id, last_name, email, hire_date, job_id) values(302, 'Nume302', 'Nume302', sysdate, 'IT_PROG');  

--d
select * from emp_rtu where employee_id=302;
select * from VIZ_EMPSAL50_rtu where employee_id=302;


--5
--a
create or replace view VIZ_EMP_DEP30_rtu as
  select employee_id, last_name, email, salary, hire_date, job_id, e.department_id, department_name 
  from emp_rtu e join dept_rtu d on (e.department_id = d.department_id)
  where e.department_id = 30; 
 
SELECT uc.table_name, constraint_name, column_name, constraint_type, search_condition
FROM user_cons_columns ucc join user_constraints uc using (constraint_name)
WHERE LOWER(uc.table_name) IN ('emp_rtu'); 

--b  
insert into VIZ_EMP_DEP30_rtu values(303, 'Nume303', 'Nume303', 34567, sysdate, 'IT_PROG', 40, 'Testare');  

--c
insert into VIZ_EMP_DEP30_rtu(employee_id, last_name, email, salary, hire_date, job_id, department_id) 
values(303, 'Nume303', 'Nume303', 34567, sysdate, 'IT_PROG', 30);  


--d
select * from VIZ_EMP_DEP30_rtu;
 
select * from USER_UPDATABLE_COLUMNS where TABLE_NAME = 'VIZ_EMP_DEP30_RTU';
 
--d) Ce efect are o operatie de stergere prin intermediul vizualizarii
delete from VIZ_EMP_DEP30_rtu where employee_id=303;

--6
create or replace view VIZ_DEPT_SUM_rtu (coddep, minsal, maxsal, avgsal) as
select department_id, min(salary) , max(salary) , avg(salary) 
from emp_rtu
group by department_id;

select * from USER_UPDATABLE_COLUMNS where TABLE_NAME = 'VIZ_DEPT_SUM_RTU';

--9
SELECT view_name, text
FROM user_views
WHERE view_name LIKE '%RTU';

--13
CREATE OR REPLACE VIEW viz_emp_wx_rtu
AS SELECT *
 FROM emp_rtu
 WHERE UPPER(last_name) NOT LIKE 'WX%'
WITH CHECK OPTION CONSTRAINT ck_name_emp_rtu2;

UPDATE viz_emp_wx_rtu
SET last_name = 'Wxyz'
WHERE employee_id = 200;

