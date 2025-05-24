1. Mandar los resultados de realizar la siguiente consulta a un fichero de cola al que daremos el nombre que estimemos. Devolver el nombre y los apellidos de todos los lectores que vivan en
Salamanca y hayan realizado préstamos en el 2011. Para ello será necesario en SQL*Plus
    a. Mandar el Spool al fichero de cola identificado con el nombre elegido
            spool lectoresSalamanca
    b. Realizar la consulta
        select distinct nombre, ape_1, ape_2 from lector l, prestamo p where l.codigo=p.cod_lector and to_char(fecha_ini,'yyyy')=2011 and poblacion = 'Salamanca';
    c. Cerrar el Spool y comprobar que ha sido cerrado
            spool off
    d. Verificar que tenemos un archivo *.lst generado
            show lectoresSalamanca

2. Generar un fichero de comandos que realice un listado de todos los préstamos ordenados por sucursales y para cada sucursal ordenar dichos préstamos cronológicamente.
        spool ej2
        set echo off
        select * from prestamo order by cod_suc, fecha_ini;
        spool off

3. Guardar en un fichero de comandos a través del comando save la siguiente consulta: mostrar la información de todos los autores de los que o bien no se conoce 
su fecha de nacimiento o de muerte. Para ello será necesario
    a. Realizar la consulta en el entorno de SQL*Plus
        select * from autor where ano_nac is null or ano_fac is null;
    b. Salvar el contenido del buffer indicando el nombre del fichero save nombre
        save ej3
    c. Verificar que se ha creado correctamente el archivo generado nombre.sql

4. Volver a cargar el fichero de comandos del ejercicio anterior y ejecutarlo activando la visualización del contenido a través del comando echo
    set echo on; @ej3

5. Volver a realizar un archivo de comandos que saque el listado de todos los libros con los que cuenta la sucursal 1, 2 y 3 ordenados por ISBN y por sucursal,
estableciendo pausas para su mejor visualización a través del comando pause.
    set pause on
    select l.isbn, cod_suc as Sucursal, Titulo from libro l, sucursal where cod_suc in (1,2,3) order by 1,2: 

6. Volver a realizar un archivo de comandos que saque el listado de todos los libros con los que cuenta una sucursal, cuyo código se pasará como parámetro, ordenados
por ISBN, estableciendo pausas para su mejor visualización a través del comando pause.
    set pause on
    select l.isbn, titulo from libro l, dispone d where l.isbn=d.isbn and cod_suc=&1 order by 1;

7. Sacar la información de todos los autores de los que o bien no se conoce su fecha de nacimiento o de muerte indicando además su nacionalidad y no el código de ésta.
    select a.nombre,a.ape_1,a.ape_2, nacionalidad.nombre from autor a , nacionalidad n where a.cod_nacion = n.cod_nacion and ano_nac is null or ano_fac is null;

8. Ejecutaremos la consulta anterior con un formato que genere una salida más legible:
    a. Seleccione un tamaño de página igual a 50
        set pagesize 50
    b. Seleccione un tamaño de línea igual a 80
        set linesize 80
    c. Añada un título en la parte superior de la página con el texto ‘Informe de autores’ y ‘con fechas no conocidas’ en dos líneas separadas.
        ttilte 'INFORME DE AUTORES|CON FECHAS NO CONOCIDAS'
    d. Añada un pie de página con el texto ‘SERVICIO DE BIBLIOTECAS’
        btitle 'SERVIVIO DE BIBLIOTECAS'
    e. Formatee el apellido para que ocupe exactamente 12 caracteres.
        column nombre format a12
        column apellido format a12
    f. Formatee el nombre de las columnas ANO_NAC y ANO_FALL para que se muestre en cada caso el título ANO NACIMIENTO o ANO MUERTE en dos líneas separadas.
        column ano_nac wrap heading 'ANO|NACIMIENTO'
        column ano_fac wrap heading 'ANO|MUERTE'
    g. Formatee la nacionalidad empleando NACION como título y fijando la longitud de los datos en 15 caracteres.
        column nombre format a15 heading 'NACION'

9. Volver a realizar la consulta anterior insertando ‘???’ en los lugares donde no se conoce la fecha de nacimiento o defunción de los autores.

    set pagesize 50
    set linesize 80
    ttitle 'INFORME DE AUTORES|CON FECHAS NO CONOCIDAS'
    btitle 'SERVICIO DE BIBLIOTECAS'
    column nombre format a12
    column apellido format a12
    column ano_nac wrap heading 'ANO|NACIMIENTO' NULL '????'
    column ano_fall wrap heading 'ANO|MUERTE' NULL '????'
    set pause 'Una tecla...'
    set pause on
    column nombre format a15 heading 'NACION'
    Select a.nombre, apellido, ano_nac, ano_fall, n.nombre
    from univ.autor a, univ.nacionalidad n where a.cod_nacion=n.codigo
    and (ano_fall is null or ano_nac is null);
    ttitle off
    btitle off
    clear columns
    set pause off