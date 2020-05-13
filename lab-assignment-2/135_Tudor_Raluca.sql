--Tema de Laborator #2--

-- Exercitii diagrama HR
--1--
SELECT COUNT(1)
FROM employees
WHERE UPPER(last_name) LIKE 'K%';

--2--
SELECT employee_id, last_name, first_name, salary
FROM employees
WHERE salary = (SELECT MIN(salary)
                FROM employees);

--3--
SELECT employee_id, last_name Nume, first_name
FROM employees
WHERE employee_id IN (SELECT DISTINCT manager_id
                      FROM employees
                      WHERE department_id = 30)
ORDER BY Nume;
--sau
SELECT DISTINCT employee_id, last_name Nume, first_name
FROM employees
WHERE employee_id IN (SELECT manager_id
                      FROM employees
                      WHERE department_id = 30)
ORDER BY Nume;
-- Ambele variante genereaza managerii distincti.
                      
--4--            
SELECT employee_id, last_name, first_name, (SELECT COUNT(1)
                                            FROM employees
                                            WHERE manager_id = e.employee_id) "Nr. subalterni"
FROM employees e;

--5--
SELECT e1.employee_id, e1.last_name, e1.first_name
FROM employees e1, employees e2
WHERE e1.last_name = e2.last_name AND e1.employee_id != e2.employee_id;
-- sau
SELECT employee_id, last_name, first_name
FROM employees e
WHERE (SELECT COUNT(1)
       FROM employees
       WHERE last_name = e.last_name) >= 2;
-- sau
SELECT employee_id, last_name, first_name
FROM employees e
WHERE EXISTS (SELECT employee_id
              FROM employees
              WHERE last_name = e.last_name AND employee_id != e.employee_id);

--6--
SELECT department_id, department_name
FROM departments d
WHERE (SELECT COUNT(DISTINCT job_id)
       FROM employees
       WHERE department_id = d.department_id) >= 2;

-- Exercitii diagrama ORDERS
--7--
SELECT qty, prod_desc
FROM orders_tbl JOIN products_tbl USING (prod_id)
WHERE LOWER(prod_desc) LIKE '%plastic%';
-- sau
SELECT qty, prod_desc
FROM orders_tbl o, products_tbl p
WHERE o.prod_id = p.prod_id
      AND LOWER(p.prod_desc) LIKE '%plastic%';
      
--8--
SELECT cust_name, 'client'
FROM customer_tbl
UNION
SELECT last_name || ' ' || first_name, 'angajat'
FROM employee_tbl;

--9--
SELECT DISTINCT prod_desc
FROM products_tbl JOIN orders_tbl USING (prod_id)
WHERE sales_rep IN (SELECT sales_rep
                    FROM orders_tbl JOIN products_tbl USING (prod_id)
                    WHERE UPPER(prod_desc) LIKE '% P%');
                         
--10--
SELECT cust_name
FROM customer_tbl c
WHERE EXISTS (SELECT *
              FROM orders_tbl
              WHERE cust_id = c.cust_id
                    AND TO_CHAR(ord_date, 'DD') = 17);
-- sau
SELECT DISTINCT cust_name
FROM customer_tbl JOIN orders_tbl USING (cust_id)
WHERE TO_CHAR(ord_date, 'DD') = 17;

--11--
SELECT last_name, first_name, salary, bonus
FROM employee_pay_tbl p, employee_tbl e
WHERE e.emp_id = p.emp_id
      AND salary < 32000 AND bonus * 17 < 32000;
-- sau
SELECT last_name, first_name, salary, bonus
FROM employee_pay_tbl JOIN employee_tbl USING (emp_id)
WHERE salary < 32000 AND bonus * 17 < 32000;

--12--
SELECT last_name, first_name, NVL(SUM(o.qty), 0)
FROM employee_tbl e LEFT JOIN orders_tbl o ON (o.sales_rep = e.emp_id)
GROUP BY e.emp_id, e.last_name, e.first_name
HAVING SUM(o.qty) > 50 OR NVL(SUM(o.qty), 0) = 0;

--13--
SELECT last_name, first_name, salary, MAX(ord_date)--, e.emp_id
FROM employee_tbl e JOIN employee_pay_tbl p ON (e.emp_id = p.emp_id) JOIN orders_tbl o ON (e.emp_id = o.sales_rep)
GROUP BY e.emp_id, last_name, first_name, salary
HAVING COUNT(ord_num) >= 2;

--Verificare
--SELECT sales_rep FROM orders_tbl;

--14--
SELECT prod_desc
FROM products_tbl
WHERE cost > (SELECT AVG(cost)
              FROM products_tbl);
              
--15--
SELECT last_name, first_name, salary, bonus, 
       (SELECT SUM(salary) FROM employee_pay_tbl) "Salariu total din firma",
       (SELECT SUM(bonus) FROM employee_pay_tbl) "Bonusul total din firma"
FROM employee_tbl JOIN employee_pay_tbl USING (emp_id);

--16--
SELECT DISTINCT city
FROM employee_tbl e
WHERE (SELECT COUNT(1)
       FROM orders_tbl
       WHERE sales_rep = e.emp_id) = (SELECT MAX(COUNT(1))
                                      FROM orders_tbl
                                      GROUP BY sales_rep);

--17--
SELECT emp_id, last_name, first_name,
       COUNT(DECODE(TO_CHAR(ord_date, 'MM'), 9, 1)) "#september orders",
       COUNT(DECODE(TO_CHAR(ord_date, 'MM'), 10, 1)) "#october orders"
FROM employee_tbl e LEFT JOIN orders_tbl o ON (emp_id = sales_rep)
GROUP BY emp_id, last_name, first_name;

--18--
SELECT cust_name, cust_city
FROM customer_tbl c
WHERE cust_id NOT IN (SELECT cust_id 
                      FROM orders_tbl)
AND REGEXP_LIKE(cust_address, '^[0-9]'); 

--19--
SELECT DISTINCT e.emp_id, last_name, city, c.cust_id, cust_name, cust_city
FROM employee_tbl e, customer_tbl c
WHERE EXISTS (SELECT 1 -- sau *
              FROM orders_tbl
              WHERE sales_rep = e.emp_id AND cust_id = c.cust_id)
AND city != cust_city;

--20--
SELECT AVG(NVL(salary, 0))
FROM employee_pay_tbl;

--21--
-- Sunt corecte urmatoarele cereri?
--a.
SELECT CUST_ID, CUST_NAME           -- CORECT
FROM CUSTOMER_TBL
WHERE CUST_ID = (SELECT CUST_ID
                 FROM ORDERS_TBL
                 WHERE ORD_NUM = '16C17');
--b.
SELECT EMP_ID, SALARY               -- GRESIT
FROM EMPLOYEE_PAY_TBL
WHERE SALARY BETWEEN '20000' AND (SELECT SALARY 
                                  FROM EMPLOYEE_ID -- linie incorecta
                                  WHERE SALARY = '40000');

--22--
SELECT last_name, first_name, pay_rate
FROM employee_tbl JOIN employee_pay_tbl USING (emp_id) 
WHERE pay_rate > (SELECT MAX(pay_rate)
                  FROM employee_tbl JOIN employee_pay_tbl USING (emp_id)
                  WHERE UPPER(last_name) LIKE '%LL%');

