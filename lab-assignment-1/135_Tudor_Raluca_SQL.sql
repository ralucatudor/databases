--Tema de Laborator #1--

-- Inainte de a realiza exercitiile, am observat componenta tabelelor:
DESCRIBE customer_tbl;
DESCRIBE products_tbl;
SELECT *
FROM customer_tbl;
SELECT *
FROM orders_tbl;

--1--
SELECT cust_id AS ID, 
       cust_name AS Name
FROM customer_TBL
WHERE SUBSTR(LOWER(cust_name), 1, 1) IN ('a', 'b') 
      AND cust_state IN ('IN', 'OH', 'MI', 'IL')
ORDER BY Name;
--sau
SELECT cust_id AS ID, 
       cust_name AS Name
FROM customer_TBL
WHERE (LOWER(cust_name) LIKE ('a%') OR LOWER(cust_name) LIKE ('b%'))
      AND cust_state IN ('IN', 'OH', 'MI', 'IL')
ORDER BY Name;

--2--
--a)
SELECT prod_id, prod_desc, cost
FROM products_tbl
WHERE cost BETWEEN 1 AND 12.50;
--b)
SELECT prod_id, prod_desc, cost
FROM products_tbl
WHERE cost NOT BETWEEN 1 AND 12.50;

--3--
SELECT LOWER(first_name) || '.' || LOWER(last_name) || '@ittech.com' as "Mail address"
FROM employee_tbl
ORDER BY 1;

--4--
SELECT 'NAME = ' || last_name || ', ' || first_name || ' ' || 
       'EMP_ID = ' || SUBSTR(emp_id, 1, 3) || '-' || SUBSTR(emp_id, 4, 2) || '-' || SUBSTR(emp_id, 6, 4) || ' ' || 
       'PHONE = (' || SUBSTR(phone, 1, 3) || ')' || SUBSTR(phone, 4, 3) || '-' || SUBSTR(phone, 7, 4) || ' ' AS data
FROM employee_tbl;

--5--
SELECT emp_id, TO_CHAR(date_hire, 'YYYY') "Anul angajarii"
FROM employee_pay_tbl;

--6--
SELECT e.emp_id, e.last_name, p.salary, p.bonus
FROM employee_tbl e 
JOIN employee_pay_tbl p 
ON (e.emp_id = p.emp_id);
--sau
SELECT e.emp_id, e.last_name, p.salary, p.bonus
FROM employee_tbl e, employee_pay_tbl p 
WHERE e.emp_id = p.emp_id;

--7--
SELECT cust_name, ord_num, ord_date
FROM orders_tbl JOIN customer_tbl USING (cust_id)
WHERE LOWER(cust_state) LIKE 'i%';
--sau
SELECT c.cust_name, o.ord_num, o.ord_date
FROM orders_tbl o JOIN customer_tbl c ON (o.cust_id = c.cust_id)
WHERE LOWER(c.cust_state) LIKE 'i%';

--8--
SELECT o.ord_num, o.qty, e.last_name, e.first_name, e.city
FROM orders_tbl o JOIN employee_tbl e ON (o.sales_rep = e.emp_id);
--sau
SELECT o.ord_num, o.qty, e.last_name, e.first_name, e.city
FROM orders_tbl o, employee_tbl e
WHERE o.sales_rep = e.emp_id;

--9--
SELECT o.ord_num, o.qty, e.last_name, e.first_name, e.city
FROM orders_tbl o RIGHT OUTER JOIN employee_tbl e ON (o.sales_rep = e.emp_id);
--sau
SELECT o.ord_num, o.qty, e.last_name, e.first_name, e.city
FROM orders_tbl o, employee_tbl e
WHERE o.sales_rep (+) = e.emp_id;

--10--
SELECT *
FROM employee_tbl
WHERE middle_name IS NULL;

--11-- 
SELECT emp_id, 
       NVL(salary, 0) * 12 + NVL(bonus, 0)
FROM employee_pay_tbl;

--12--
-- metoda 1 -- folosind DECODE
SELECT last_name, 
       salary, 
       position,
       DECODE(LOWER(position), 
             'marketing', salary * 1.10,
             'salesman', salary * 1.15,
             salary) "Salariu modificat"
FROM employee_tbl JOIN employee_pay_tbl USING (emp_id);

-- metoda 2 -- folosind CASE
SELECT last_name, 
       salary, 
       position, 
       CASE LOWER(position)
            WHEN 'marketing' THEN 
                 salary * 1.10
            WHEN 'salesman' THEN 
                 salary * 1.15
            ELSE salary
       END "Salariu modificat"
FROM employee_tbl JOIN employee_pay_tbl USING (emp_id);
