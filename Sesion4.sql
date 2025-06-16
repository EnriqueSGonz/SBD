1. Se desea llevar un control de las actualizaciones que se realizan sobre una base dedatos que está compuesta por las siguientes tablas:
PROYECTO (COD_PROY, NOMBRE, PRESUPUESTO),DEPARTAMENTO (COD_DPTO, NOMBRE, DIRECCION, NUM_EMPLEADOS)
Para ello, se crea una tabla donde se registrará cada acción que se realice sobre las tablas anteriores. Dicha tabla tendrá el siguiente esquema:
REGISTRO (ID, FECHA, USUARIO, TABLA, COD_ITEM, ACCION)
En la tabla REGISTRO se incluirá una tupla por cada acción que se realice en las tablas anteriores y que contendrá los siguientes atributos:
    - ID. Será la clave de la tabla registro y se gestionará automáticamente mediante un disparador que obtenga el valor correspondiente a partir de una secuencia.
    - Fecha en la que se ha realizado la modificación
    - Usuario que ha realizado la acción
    - Nombre de la tabla modificada (PROYECTO o DEPARTAMENTO)
    - Clave de la tupla insertada, cambiada o borrada
    - Acción que se ha realizado (INSERT, UPDATE o DELETE)
    a)Crear las tres tablas indicadas y los disparadores necesarios para registrar los datos de modificación de las tablas.
        create table PROYECTO (COD_PROY integer not null primary key, NOMBRE varchar(20) not null, PRESUPUESTO decimal(8,2));

create table DEPARTAMENTO (COD_DPTO integer not null primary key, NOMBRE varchar (20) not null,DIRECCION varchar(30),NUM_EMPLEADOS integer default 0 not null);
 
create table REGISTRO(ID integer not null primary key, FECHA date default sysdate,USUARIO varchar(20) not null,TABLA varchar(20) not null check (TABLA='PROYECTO' or TABLA='DEPARTAMENTO'),
 COD_ITEM integer not null,ACCION char(1) check (ACCION='I' or ACCION='U' or ACCION='D') not null);
    
    create sequence CLAVE_REG;

    create trigger CLAVREGISTRO
    before insert on REGISTRO 
    for each row
    BEGIN
    select clave_reg.NEXTVAL into :NEW.ID from DUAL;
    END;
    /
    
    b) Insertar, modificar y borrar varias tuplas en las tablas PROYECTO y DEPARTAMENTO y consultar el contenido de la tabla REGISTRO para
    comprobar que los disparadores han funcionado correctamente.
create trigger INS_PROY
after insert on PROYECTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'PROYECTO', :new.cod_proy, 'I');
END;
/

create trigger DEL_PROY
after delete on PROYECTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'PROYECTO', :old.cod_proy, 'D');
END;
/

create trigger UPD_PROY
after update on PROYECTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'PROYECTO', :old.cod_proy, 'U');
END;
/

create trigger INS_DPT
after insert on DEPARTAMENTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'DEPARTAMENTO', :new.cod_dpto, 'I');
END;
/

create trigger DEL_DPT
after delete on DEPARTAMENTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'DEPARTAMENTO', :old.cod_dpto, 'D');
END;
/

create trigger UPD_DPT
after update on DEPARTAMENTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'DEPARTAMENTO', :old.cod_dpto, 'U');
END;
/
2. Crear una nueva tabla EMPLEADO (DNI, NOMBRE, APELLIDO, COD_DEPTO).
Crear los disparadores precisos para que el atributo derivado NUM_EMPLEADOS de la tabla DEPARTAMENTO se mantenga consistente con el contenido de la tabla
EMPLEADOS de modo automático. Comprobar el funcionamiento de los disparadores en los siguientes casos:
    - Se insertan varios empleados en distintos departamentos
    - Se cambia el departamento al que está asignado un empleado
    - Se elimina un usuario
    - Se eliminan varios usuarios
    - Se inserta un empleado sin departamentos asignado y posteriormente se modifica para asignarlo a un departamento existente
    - Se modifica un empleado asignado a un departamento para que deje de estar asignado a ninguno

create table EMPLEADO 
(DNI integer not null primary key, 
 NOMBRE varchar (20),
 APELLIDO varchar (30),
 COD_DEPTO integer references DEPARTAMENTO);
 
create trigger INS_EMP
after insert on EMPLEADO 
for each row
when (new.cod_depto is not null)
BEGIN
update DEPARTAMENTO set num_empleados=num_empleados+1 where cod_dpto=:new.cod_depto;
END;
/

create trigger DEL_EMP
after delete on EMPLEADO 
for each row
when (old.cod_depto is not null)
BEGIN
update DEPARTAMENTO set num_empleados=num_empleados-1 where cod_dpto=:old.cod_depto;
END;
/

create trigger UPD_EMP
after update of cod_depto on EMPLEADO 
for each row
when (new.cod_depto is not null or old.cod_depto is not null)
BEGIN
update DEPARTAMENTO set num_empleados=num_empleados+1 where cod_dpto=:new.cod_depto;
update DEPARTAMENTO set num_empleados=num_empleados-1 where cod_dpto=:old.cod_depto;
END;
/

3. Crear dos tablas con los mismos esquemas de las tablas DISPONE y la tabla PRESTAMO de la base de datos usada en las prácticas (no es necesario definir en
ellas las claves externas correspondientes al resto de las tablas de la base de datos de prácticas). Crear los disparadores necesarios para que el atributo derivado
NUM_DISPONIBLES de la tabla creada a imagen de DISPONE se mantenga consistente de manera automática.
Se desea impedir que en la tabla creada a imagen de PRESTAMO se realicen modificaciones sobre las columnas ISBN o COD_SUC. Crear un disparador que
garantice que no se producirán modificaciones de este tipo.

CREATE TABLE MI_DISPONE (
Cod_Suc integer not null ,  
ISBN varchar(10) not null, 
Num_Ejemplares integer, 
Num_Disponibles integer,
primary key (Cod_Suc, ISBN),
check (Num_Disponibles <= Num_Ejemplares AND Num_Disponibles >=0 AND Num_Ejemplares >=0)
);

CREATE TABLE MI_PRESTAMO (
Codigo integer not null primary key, 
Cod_Lector integer not null , 
ISBN varchar(10) not null, 
Cod_Suc integer not null, 
Fecha_Ini date not null, 
Fecha_Dev date,
foreign key (Cod_Suc, ISBN) references mi_dispone (Cod_Suc, ISBN)
);

insert into MI_DISPONE select * from dispone;
insert into MI_PRESTAMO select * from prestamo;

create or replace trigger INS_MIPRES
after insert on MI_PRESTAMO 
for each row
when (new.fecha_dev is null)
BEGIN
update MI_DISPONE set num_disponibles=num_disponibles-1 where ISBN=:new.ISBN and cod_suc=:new.cod_suc;
END;
/

create or replace trigger DEL_MIPRES
after delete on MI_PRESTAMO 
for each row
when (old.fecha_dev is null)
BEGIN
update MI_DISPONE set num_disponibles=num_disponibles+1 where ISBN=:old.ISBN and cod_suc=:old.cod_suc;
END;
/

create or replace trigger UPD_FDEV_MIPRES
after update of FECHA_DEV on MI_PRESTAMO 
for each row
when (old.fecha_dev is null and new.fecha_dev is not null)
BEGIN
update MI_DISPONE set num_disponibles=num_disponibles+1 where ISBN=:old.ISBN and cod_suc=:old.cod_suc;
END;
/

create or replace trigger UPD_MIPRES
after update of COD_SUC, ISBN on MI_PRESTAMO 
for each row
BEGIN
raise_application_error(-20000, 'OPERACION NO PERMITIDA');
END;
/

4. La biblioteca desea incentivar los hábitos de lectura de sus socios estableciendo una clasificación de los mismos en función del número de prestamos que han realizado.
Solo se incluirán en la clasificación aquellos lectores que hayan realizado como mínimo 10 préstamos. En el caso de que varios lectores coincidan con el mismo nº
de prestamos, se les asignarán números consecutivos en la clasificación sin importar el criterio. Para ello, se desea crear una tabla que contenga las siguientes columnas:
nº de orden en la clasificación a fecha de hoy, código del lector y nº de prestamos realizados.
    a. Crear la tabla anterior tomando como clave primaria el nº de orden en la clasificación.
    b. Crear una secuencia que se utilizará para obtener los valores de la clave primaria de la tabla anterior.
    c. Crear un trigger que genere de forma automática durante la inserción los valores para la clave de la tabla.
    d. Rellenar la tabla con los valores correspondientes a partir del contenido de la Base de Datos en el momento actual.

    create table clasificacion (
posicion integer not null primary key,
cod_lector integer not null references lector,
num_prestamos integer not null check (num_prestamos >=10));

create sequence seq_clas;

create or replace trigger TRIG_CLAS
before insert on clasificacion 
for each row
begin
select seq_clas.NEXTVAL into :NEW.posicion from DUAL;
end;
/

insert into clasificacion (cod_lector, num_prestamos)
select cod_lector, count(*) from prestamo
group by cod_lector
having count(*)>=10
order by 2 desc;

5. Eliminar todos los objetos de la base de datos creados a lo largo de esta sesión.
drop trigger CLAVREGISTRO;
drop trigger INS_PROY;
drop trigger DEL_PROY;
drop trigger UPD_PROY;
drop trigger INS_DPT;
drop trigger DEL_DPT;
drop trigger UPD_DPT;
drop table PROYECTO;
drop table DEPARTAMENTO;
drop table REGISTRO;
drop sequence CLAVE_REG;
drop trigger INS_EMP;
drop trigger DEL_EM;
drop trigger UPD_EM;
drop table EMPLEADO;
drop trigger INS_MIPRES;
drop trigger DEL_MIPRES;
drop trigger UPD_FDEV_MIPRES;
drop trigger UPD_MIPRES
drop table MI_DISPONE;
drop table MI_PRESTAMO;
drop trigger TRIG_CLAS;
drop table clasificacion;
drop sequence seq_clas;