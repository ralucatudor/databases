--20.05.2020--
--Laborator 9
--1--
--a) fara precizarea vreunei chei sau constrangeri:
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

--b) cu precizarea cheilor primare la nivel de coloana si a constrangerilor NOT NULL pentru coloanele nume si salariu;
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

--c) cu precizarea cheii primare la nivel de tabel si a constrangerilor NOT NULL pentru coloanele nume si salariu
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
insert into angajati_rtu(cod_ang, nume, prenume, data_ang, job, salariu, cod_dep) values(100, 'Nume1', 'Prenume1', null, 'Director', 20000, 10);
insert into angajati_rtu values(101, 'Nume2', 'Prenume2', 'Nume2', to_date('02-02-2014', 'dd-mm-yyyy'), 'Inginer', 100, 10000, 10);
insert into angajati_rtu values(102, 'Nume3', 'Prenume3', 'Nume3', to_date('05-06-2010', 'dd-mm-yyyy'), 'Programator', 101, 5000, 20);
insert into angajati_rtu(cod_ang, nume, prenume, data_ang, job, cod_sef, salariu, cod_dep) values(103, 'Nume4', 'Prenume4', null, 'Inginer', 100, 9000, 20);
insert into angajati_rtu values(104, 'Nume5', 'Prenume5', 'Nume5', null, 'Programator', 101, 3000, 30);

--3
create table angajati10_rtu as select * from angajati_rtu where cod_dep=10;

desc angajati10_rtu;

select * from angajati10_rtu;

--4
-- Introduceti coloana comision in tabelul ANGAJATI_pnu. 
alter table angajati_rtu
add (comision number(4,2));

--5
alter table angajati_rtu
modify (salariu number(6,2));

desc angajati_rtu;

--6
-- Setati o valoare DEFAULT pentru coloana salariu
alter table angajati_rtu
modify (salariu default 1000);

--7
-- Modificati tipul coloanei comision in NUMBER(2, 2) si al coloanei salariu in
-- NUMBER(10,2), in cadrul aceleiasi instructiuni.
alter table angajati_rtu
modify (salariu number(10,2), comision number(2,2));

--8
-- Actualizati valoarea coloanei comision, setand-o la valoarea 0.1 pentru salariatii ai
-- caror job incepe cu litera I. (UPDATE)

UPDATE angajati_rtu
SET comision = 0.1
WHERE UPPER(job) like 'I%';

-- LDD URILE AU EFECT IMEDIAT, NU FAC PARTE DIN TRANZACITE, CI DIMPOTRIVA, ELE INCHEIE TRANZACTIA.
-- OBS - AVEM 1 TRANZACTIE CARE POATE AVEA MAI MULTE COMENZI, NU MAI MULTE TRANZACTII.

--9
desc angajati_rtu;
-- Modificati tipul de date al coloanei email în VARCHAR2.
alter table angajati_rtu
modify (email varchar2(20));

--10
-- Adaugati coloana nr_telefon in tabelul ANGAJATI_pnu, setandu-i o valoare implicita.
alter table angajati_rtu
add(nr_telefon varchar2(15) default '021123456');

--11
-- Vizualizati inregistrarile existente.
select * from angajati_rtu;
-- Suprimati coloana nr_telefon.
alter table angajati_rtu
drop (nr_telefon);

--12
-- Redenumiti tabelul ANGAJATI_pnu in ANGAJATI3_pnu
rename angajati_rtu to angajati3_rtu;

--13
-- Consultati vizualizarea TAB din dictionarul datelor. 
select * from tab;
-- Redenumiti angajati3_pnu in angajati_pnu.
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


--17
alter table DEPARTAMENTE_rtu 
add constraint pk_dep_rtu primary key(cod_dep);

--18
--Sa se precizeze constrangerea de cheie externa pentru coloana cod_dep din
--ANGAJATI_pnu:
--a) fara suprimarea tabelului (ALTER TABLE);
alter table angajati_rtu 
add constraint fk_cod_dep_ang_rtu foreign key(cod_dep) references departamente_rtu(cod_dep);

--b) prin suprimarea si recrearea tabelului, cu precizarea noii constrangeri la nivel de
--coloana ({DROP, CREATE} TABLE). De asemenea, se vor mai preciza
--constrangerile (la nivel de coloana, in masura in care este posibil):
-- - PRIMARY KEY pentru cod_ang;
-- - FOREIGN KEY pentru cod_sef;
-- - UNIQUE pentru combinatia nume + prenume;
-- - UNIQUE pentru email;
-- - NOT NULL pentru nume;
-- - verificarea cod_dep > 0;
-- - verificarea ca salariul sa fie mai mare decât comisionul*100.

drop table angajati_rtu;
create table ANGAJATI_rtu(
    cod_ang number(4) constraint pk_angajati_rtu primary key, 
    nume varchar2(20) constraint nn_nume_ang_rtu not null, 
    prenume varchar2(20), 
    email char(15) constraint u_email_ang_rtu unique, 
    data_ang date default sysdate, 
    job varchar2(15), 
    cod_sef number(4) constraint fk_cod_sef_ang_rtu references angajati_rtu(cod_ang), 
    salariu number(8, 2) constraint nn_sal_ang_rtu not null,
    comision number(2,2),
    cod_dep number(2) constraint ck_cod_dep_0_ang_rtu check(cod_dep > 0)
                      constraint fk_cod_dep_ang_rtu references departamente_rtu(cod_dep),
    constraint u_nume_prenume_ang_rtu unique(nume, prenume),
    constraint ck_sal_com_ang_rtu check (salariu > comision *100)
    );

--19
--Suprimati si recreati tabelul, specificand toate constrangerile la nivel de tabel (in
--masura in care este posibil). 

drop table angajati_rtu;
create table ANGAJATI_rtu(
    cod_ang number(4) , 
    nume varchar2(20) constraint nn_nume_ang_rtu not null, 
    prenume varchar2(20), 
    email char(15) , 
    data_ang date default sysdate, 
    job varchar2(15), 
    cod_sef number(4) , 
    salariu number(8, 2) constraint nn_sal_ang_rtu not null,
    comision number(2,2),
    cod_dep number(2),
    constraint pk_angajati_rtu primary key (cod_ang),                      
    constraint u_nume_prenume_ang_rtu unique(nume, prenume),
    constraint ck_sal_com_ang_rtu check (salariu > comision *100),
    constraint u_email_ang_rtu unique(email),
    constraint fk_cod_sef_ang_rtu foreign key(cod_sef) references angajati_rtu(cod_ang), 
    constraint ck_cod_dep_0_ang_rtu check(cod_dep > 0),
    constraint fk_cod_dep_ang_rtu foreign key(cod_dep) references departamente_rtu(cod_dep)
    );

--20
insert into angajati_rtu(cod_ang, nume, prenume, data_ang, job, salariu, cod_dep) values(100, 'Nume1', 'Prenume1', Null, 'Director', 20000, 10);
insert into angajati_rtu values(101, 'Nume2', 'Prenume2', 'Nume2', to_date('02-02-2014', 'dd-mm-yyyy'), 'Inginer', 100, 10000, 0.2, 10);
insert into angajati_rtu values(102, 'Nume3', 'Prenume3', 'Nume3', to_date('05-06-2010', 'dd-mm-yyyy'), 'Programator', 101, 5000, null, 20);
insert into angajati_rtu(cod_ang, nume, prenume, data_ang, job, cod_sef, salariu, cod_dep) values(103, 'Nume4', 'Prenume4', null, 'Inginer', 100, 9000, 20);
insert into angajati_rtu values(104, 'Nume5', 'Prenume5', 'Nume5', Null, 'Programator', 101, 3000, 0.3, 30);    

commit;

--21
-- nu se poate
drop table departamente_rtu;

--22
desc user_tables;
desc tab;
desc user_constraints;

--Observatie: Pentru a afla informatii despre tabelele din schema curenta, sunt utile cererile:
SELECT * FROM tab;              -- apar si view-urile! (tabtype = view)
--sau
SELECT table_name FROM user_tables;
--sau
SELECT table_name FROM user_tables order by table_name;

--23
--a
SELECT constraint_name, constraint_type, table_name
FROM user_constraints
WHERE lower(table_name) IN ('angajati_rtu', 'departamente_rtu');

--b
desc user_cons_columns;

SELECT table_name, constraint_name, column_name
FROM user_cons_columns
WHERE LOWER(table_name) IN ('angajati_rtu', 'departamente_rtu');

SELECT uc.table_name, constraint_name, column_name, constraint_type, search_condition
FROM user_cons_columns ucc join user_constraints uc using (constraint_name)
WHERE LOWER(uc.table_name) IN ('angajati_rtu', 'departamente_rtu');

--24
-- nu merge not null(email) la add constraints dupa cum se poate observa
-- Cum rezolvam? putem face cu modify

desc angajati_rtu;

--NOK
alter table angajati_rtu
add constraint nn_email_ang_rtu not null(email);

-- modify
select * from angajati_rtu;

update angajati_rtu
set email = nume where email is null;

alter table angajati_rtu
modify (email not null);

-- add constraint 
alter table angajati_rtu
drop constraint SYS_C00351806;

alter table angajati_rtu
add constraint nn_email_ang_rtu check (email is not null);


--25
select * from departamente_rtu;
desc angajati_rtu;

insert into angajati_rtu (cod_ang, nume, salariu, email, cod_dep) values (200, 'Nume200', 1000, 'Nume200', 50);

--26
desc departamente_rtu;

insert into departamente_rtu values(60, 'Testare', null);

commit;

--27
delete from departamente_rtu where cod_dep=20;

--28
delete from departamente_rtu where cod_dep=60;
rollback;

--29
insert into angajati_rtu (cod_ang, nume, salariu, email, cod_dep, cod_sef) values (201, 'Nume201', 1000, 'Nume201', 10, 114); --NOK

--30
-- obs: mai intai sterg cheia externa, si dupa cheia primara

insert into angajati_rtu (cod_ang, nume, salariu, email, cod_dep, cod_sef) values (114, 'Nume114', 2000, 'Nume114', 10, null); --OK
insert into angajati_rtu (cod_ang, nume, salariu, email, cod_dep, cod_sef) values (201, 'Nume201', 1000, 'Nume201', 10, 114); --OK
rollback;

insert into angajati_rtu (cod_ang, nume, salariu, email, cod_dep, cod_sef) values (114, 'Nume201', 1000, 'Nume201', 10, 114); --OK

--31
delete from departamente_rtu where cod_dep=20;

SELECT uc.table_name, constraint_name, column_name, constraint_type, search_condition, r_constraint_name
FROM user_cons_columns ucc join user_constraints uc using (constraint_name)
WHERE LOWER(uc.table_name) IN ('angajati_rtu', 'departamente_rtu');

alter table angajati_rtu drop constraint FK_COD_DEP_ANG_RTU;

-- ON DELETE CASCADE 
alter table angajati_rtu add constraint FK_COD_DEP_ANG_RTU foreign key(cod_dep) references departamente_rtu(cod_dep) on delete cascade;

--32
delete from departamente_rtu where cod_dep=20;

select * from departamente_rtu;
select * from angajati_rtu;

rollback;

--33
desc departamente_rtu;


alter table departamente_rtu add constraint FK_COD_Director_DEP_ANG_rtu foreign key(cod_director) references angajati_rtu(cod_ang) on delete set null;

--34
update departamente_rtu
set cod_director=102
where cod_dep=30;
commit;
select * from departamente_rtu;

delete from angajati_rtu where cod_ang=102;

rollback;

delete from angajati_rtu where cod_ang=101;

--35
alter table angajati_rtu
add constraint ck_sal_30000_rtu check (salariu <=30000);

--36
--NOK
update angajati_rtu
set salariu=35000
where cod_ang=100;

--37
alter table angajati_rtu
disable constraint ck_sal_30000_rtu;

--OK
update angajati_rtu
set salariu=35000
where cod_ang=100;

--NOK
alter table angajati_rtu
enable constraint ck_sal_30000_rtu;

update angajati_rtu
set salariu=29000
where cod_ang=100;

--OK
alter table angajati_rtu
enable constraint ck_sal_30000_rtu;




