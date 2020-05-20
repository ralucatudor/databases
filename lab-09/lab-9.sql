--20.05.2020--
--Laborator 9
--1--
--a
create table ANGAJATI_rtu(
    cod_ang number(4), 
    nume varchar2(20), 
    prenume varchar2(20), 
    email char(15), 
    data_ang date, 
    job varchar2(10), 
    cod_sef number(4), 
    salariu number(8, 2),
    cod_dep number(2));

--b
drop table angajati_rtu;
create table ANGAJATI_rtu(
    cod_ang number(4) primary key, 
    nume varchar2(20) not null, 
    prenume varchar2(20), 
    email char(15), 
    data_ang date default sysdate, 
    job varchar2(10), 
    cod_sef number(4), 
    salariu number(8, 2) not null,
    cod_dep number(2));
    
desc angajati_rtu;
desc tab;
select * from tab;

desc user_constraints;
select constraint_name, constraint_type, table_name
from user_constraints
where lower(table_name) like '%rtu';

drop table angajati_rtu;
create table ANGAJATI_rtu(
    cod_ang number(4) constraint pk_angajati_rtu primary key, 
    nume varchar2(20) constraint nn_nume_ang_rtu not null, 
    prenume varchar2(20), 
    email char(15), 
    data_ang date default sysdate, 
    job varchar2(10), 
    cod_sef number(4), 
    salariu number(8, 2) constraint nn_sal_ang_rtu not null,
    cod_dep number(2));

--c
drop table angajati_rtu;
create table ANGAJATI_rtu(
    cod_ang number(4), 
    nume varchar2(20) constraint nn_nume_ang_rtu not null, 
    prenume varchar2(20), 
    email char(15), 
    data_ang date default sysdate, 
    job varchar2(15), 
    cod_sef number(4), 
    salariu number(8, 2) constraint nn_sal_ang_rtu not null,
    cod_dep number(2),
    constraint pk_angajati_rtu primary key(cod_ang));
    
--2--
insert into angajati_rtu(cod_ang, nume, prenume, data_ang, job, salariu, cod_dep) values(100, 'Nume1', 'Prenume1', Null, 'Director', 20000, 10);
insert into angajati_rtu values(101, 'Nume2', 'Prenume2', 'Nume2', to_date('02-02-2014', 'dd-mm-yyyy'), 'Inginer', 100, 10000, 10);
insert into angajati_rtu values(102, 'Nume3', 'Prenume3', 'Nume3', to_date('05-06-2010', 'dd-mm-yyyy'), 'Programator', 101, 5000, 20);
insert into angajati_rtu(cod_ang, nume, prenume, data_ang, job, cod_sef, salariu, cod_dep) values(103, 'Nume4', 'Prenume4', null, 'Inginer', 100, 9000, 20);
insert into angajati_rtu values(104, 'Nume5', 'Prenume5', 'Nume5', Null, 'Programator', 101, 3000, 30);

--3
create table angajati10_rtu as select * from angajati_rtu where cod_dep=10;
desc angajati10_rtu;
select * from angajati10_rtu;

--4
alter table angajati_rtu
add (comision number(4,2));

--5
alter table angajati_rtu
modify (salariu number(6,2));

desc angajati_rtu;

--6
alter table angajati_rtu
modify (salariu default 1000);

--7
alter table angajati_rtu
modify (salariu number(10,2), comision number(2,2));

--8
--Actualizati valoarea coloanei comision, setand-o la valoarea 0.1 pentru salariatii ai
--caror job incepe cu litera I. (UPDATE)

UPDATE angajati_rtu
SET comision = 0.1
WHERE UPPER(job) like 'I%';

-- LDD URILE AU EFECT IMEDIAT, NU FAC PARTE DIN TRANZACITE, CI DIMPOTRIVA, ELE INCHEIE TRANZACTIA
-- OBS - AVEM 1 TRANZACTIE CARE POATE AVEA MAI MULTE COMENZI, NU MAI MULTE TRANZACTII

--9
desc angajati_rtu;

alter table angajati_rtu
modify (email varchar2(20));

--10
alter table angajati_rtu
add(nr_telefon varchar2(15) default '021123456');

--11
select * from angajati_rtu;
alter table angajati_rtu
drop (nr_telefon);

--12
rename angajati_rtu to angajati3_rtu;

--13
select * from tab;
rename angajati3_rtu to angajati_rtu;

--14
select * from angajati10_rtu;

truncate table angajati10_rtu;

rollback;

--15
create table DEPARTAMENTE_rtu (cod_dep number(2), nume varchar2(15) not null, cod_director number(4));
desc DEPARTAMENTE_rtu;

--16
insert into DEPARTAMENTE_rtu values(10, 'Administrativ', 100);
insert into DEPARTAMENTE_rtu values(20, 'Proiectare', 101);
insert into DEPARTAMENTE_rtu values(30, 'Programare', Null);




