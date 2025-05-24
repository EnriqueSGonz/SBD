1. Obtener el número de sucursal, la poblacion y provincia de las distintas sucursales de la biblioteca.
    set serveroutput on 
    declare 
        poblacion univ.sucursal.poblacion%TYPE;
        provincia univ.sucursal.provincia%TYPE;
        cod_suc univ.sucursal.cod_suc%TYPE;
        CURSOR C1 IS select codigo,poblacion,provincia from univ.sucursal;
    BEGIN
        OPEN C1;
        LOOP
            FETCH C! INTO cod_suc,poblacion,provincia;
            EXIT WHEN C1%NOTFOUND;
        END LOOP;
        CLOSE C1;
    END;
    /

2. Realizar un programa en el que dada una provincia se indique qué sucursales y poblaciones de dicha provincia existen para la biblioteca.
    set serveroutput on
    set verify on
    ACCEPT provincia PROMPT 'Introduzca la provincia: '
    declare 
        pobla_suc univ.sucursal.poblacion%TYPE;
        cod_suc univ.sucursal.codigo%TYPE;
        prov sucursal.provincia%TYPE := &provincia;
        CURSOR C1 IS SELECT codigo,poblacion from sucursal where provincia = prov;
    BEGIN
        OPEN C1;
        LOOP
            FETCH C1 INTO cod_suc,pobla_suc;
            EXIT WHEN C1%NOTFOUND;
        END LOOP;
        CLOSE C1;
    END;
    /


3. Obtener un listado de los lectores que tienen actualmente en préstamo el libro con identificado por su ISBN, desglosado por sucursales y ordenado alfabéticamente
dentro de cada sucursal.
CREATE OR REPLACE PROCEDURE PRESTAMOSLIBRO (L_ISBN IN libro.isbn%type) IS
suc univ.prestamo.cod_suc%type;
suc_actual univ.prestamo.cod_suc%type := 0;
nom lector.nombre%type;
ap1 lector.ape_1%type;
ap2 lector.ape_2%type;
CURSOR MICUR (miisbn libro.isbn%type) IS
select cod_suc, nombre, ape_1, ape_2 from univ.prestamo p, lector l
where isbn=miisbn and p.cod_lector=l.codigo and p.fecha_dev is null
order by cod_suc;
BEGIN
DBMS_OUTPUT.PUT_LINE(' ISBN: ' || L_isbn);
open MICUR(L_ISBN);
LOOP
fetch micur into suc, nom, ap1, ap2;
exit when micur%notfound;
if suc <> suc_actual
then
suc_actual:=suc;
DBMS_OUTPUT.PUT_LINE(chr(9)||'SUCURSAL: ' || suc );
end if;
DBMS_OUTPUT.PUT_LINE(chr(9)|| chr(9) ||nom||' ' ||ap1||' ' ||ap2);
END LOOP;
CLOSE MICUR;
END;
/
4. Obtener el expediente de préstamos realizados por un lector cualquiera del que se conoce su código. En el expediente debe aparecer el código y nombre del lector y a
continuación un listado de los libros tomados en préstamo por orden cronológico de la fecha en la que se inició dicho préstamo. El expediente mostrará el ISBN de
dichos libros, la fecha de devolución, si ha sido devuelto, y la sucursal en la que realizó dicho préstamo. Al final de dicho expediente se dará el número total de
préstamos realizados y pendientes.
CREATE OR REPLACE FUNCTION TOTALPRESTAMOSLECTOR (COD_L IN lector.codigo%type)
RETURN integer IS
n integer;
begin
select count (*) into n from prestamo where cod_lector=cod_l;
return n;
end;
/
CREATE OR REPLACE FUNCTION PRESTAMOSPENDIENTESLECTOR (COD_L IN
lector.codigo%type)
RETURN integer IS
n integer;
begin
select count (*) into n from prestamo where cod_lector=cod_l
and fecha_dev is null;
return n;
end;
/
CREATE OR REPLACE PROCEDURE PRESTAMOSLECTOR (COD_L IN lector.codigo%type) IS
suc univ.prestamo.cod_suc%type;
isbn univ.prestamo.isbn%type;
f_i univ.prestamo.fecha_ini%type;
f_d univ.prestamo.fecha_dev%type;
nom lector.nombre%type;
ap1 lector.ape_1%type;
ap2 lector.ape_2%type;
TotalPres integer;
PresPend integer;

CURSOR MICUR (lector lector.codigo%type) IS
select cod_suc, isbn, Fecha_ini, fecha_dev from univ.prestamo p
where cod_lector=lector
order by fecha_ini;
BEGIN
select nombre, ape_1, ape_2 into nom, ap1, ap2 from lector where codigo =
cod_l;
DBMS_OUTPUT.PUT_LINE(' CODIGO: ' || COD_L || chr(9) || ' NOMBRE: ' || nom ||
' ' || ap1|| ' ' || ap2);
DBMS_OUTPUT.PUT_LINE('SUCURSAL ' || 'ISBN'|| chr(9) || 'FECHA_INICIO'||
chr(9) ||'FECHA_DEVOLUCION');
open MICUR(COD_L);
LOOP
fetch micur into suc, isbn, f_i, f_d;
exit when micur%notfound;
DBMS_OUTPUT.PUT_LINE(suc || chr(9) || isbn || chr(9) || f_i|| chr(9) ||
f_d);
END LOOP;
CLOSE MICUR;
-- Escribimos los totales haciendo uso de las funciones antes creadas
TotalPres := TOTALPRESTAMOSLECTOR (COD_L);
PresPend := PRESTAMOSPENDIENTESLECTOR (COD_L);
DBMS_OUTPUT.PUT_LINE(' NUMERO TOTAL DE PRESTAMOS: '|| TotalPres|| chr(9) ||
' PENDIENTES: '|| PresPend );
END;
/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7
1. Consultas al CATALOGO.
    a. Tablas de datos que existen en la base de datos.
        select owner, table_name, num_rows from all_tables order by 1, 2;
    b. Campos de la tabla PRESTAMO.
        select column_name, data_type, data_length from all_tab_columns where table_name='PRESTAMO' and owner='UNIV';
    c. Tablas que incluyen el campo CODIGO.
        select t.owner, t.table_name from all_tab_columns c, all_tables t where t.table_name=c.table_name and t.owner=c.owner and column_name='CODIGO' order by 1, 2;
    d. Tipo del campo ANO_FALL de la tabla AUTOR.
        select data_type, data_length from all_tab_columns where column_name='ANO_FALL' and table_name='AUTOR' and owner='UNIV';
    e. Nombre de los índices creados y de las tablas a las que corresponden.
        select index_name, table_name, table_owner from all_indexes order by 2,3;
    f. Campos en que se basan las claves del apartado e.
        select i.owner, i.table_name, i.index_name, column_name from all_indexes i, all_ind_columns ic where i.index_name=ic.index_name and i.owner=ic.index_owner order by 1, 2, 3, 4;
2. Consultar el catálogo del sistema para obtener la siguiente información:
    a. Nombre de todas las tablas y vistas creadas por el usuario
        select object_name, object_type, created from user_objects where object_type in ('TABLE', 'VIEW');
    b. Características principales de estas tablas y vistas.
        select t.table_name, column_name, data_type from user_tables t, user_tab_columns c where t.table_name=c.table_name order by 1;
    c. Nombre y características de las vistas.
        select owner, view_name, text from all_views where owner=user order by 1, 2;
    d. Escriba algunos comentarios para las tablas/vistas y campos creados en las sesiones anteriores sobre tablas/vistas de las que seamos propietarios (OWNER). Verifique que han sido
    incluidos dichos comentarios.
    COMMENT ON TABLE PRESTAMOSACTIVOS IS 'Vista creada en los enunciados de la sesi�n de Vistas';
    select * from all_tab_comments where owner=user; 

    COMMENT ON COLUMN PRESTAMOSACTIVOS.COD_LECTOR IS 'Es el Codigo del Lector que ha hecho el prestamo';
    select * from all_col_comments where owner=user; 
    e. Elimine dichas vistas y verifique que lo ha hecho
        DROP view PRESTAMOSACTIVOS;
        select view_name from user_views;
    f. Descripción de los sinónimos definidos.
        select synonym_name, table_name from all_synonyms where owner=user;
    g. Elimine dichos sinónimos y verifique que lo ha hecho
        DROP synonym MIDISPONE;
        select synonym_name from user_synonyms;
    h. Elimine las tablas de las que es propietario y verifique que lo ha hecho
        DROP table AUTORESP;
        select table_name from user_tables;
3. Consultar el catálogo del sistema para obtener la siguiente información:
    a. Nombre de los disparadores creados por el usuario
        select trigger_name from user_triggers;
    b. Eliminar dichos disparadores
        drop trigger UPD_MIPRES;