1. Obtener un listado de los lectores que tienen actualmente en préstamo el libro con ISBN 5024728 desglosado por sucursales y ordenado alfabéticamente 
dentro de cada sucursal.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        int isbn, codigosuc;
        char nombre[21], ape_1[21], ape_2[21];
    EXEC sql END DECLARE SECTION
    
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql DECLARE cur1 CURSOR for select nombre,ape_1,ape_2,cod_suc 
    from prestamo p, lector l 
    where isbn=5024728 and fecha_dev is null and l.codigo=p.cod_lector
    order by 4,1,2,3;

    EXEC sql OPEN cur1;

    EXEC sql fetch cur1 into :nombre,:ape_1,:ape_2,:cod_suc;

    while(sqlca.sqlcode == 0){
        //Imprimir informacion
        EXEC sql fetch cur1 into :nombre,:ape_1,:ape_2,:cod_suc;
    }
    //Comprobación de errores
    EXEC sql close cur1;
    EXEC sql commit work release;
}

2. Obtener un listado de autores agrupados por nacionalidades y ordenados por su primer y segundo apellido, que aparezca de la forma siguiente:

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        int cod_nac, ano_nac, contador;
        char nombre[51], apellidos[51], nom_nac[21];
    EXEC sql END DECLARE SECTION
    
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql DECLARE cur1 CURSOR for select a.nombre,apellidos,n.codigo,n.nombre,ano_nac 
    from autor a, nacionalidad n 
    where n.codigo=a.cod_nacion
    order by 2,1,3,4,5;

    EXEC sql OPEN cur1;

    EXEC sql fetch cur1 into :nombre,:apellidos,:cod_nac,:nom_nac,:ano_nac;

    while(sqlca.sqlcode == 0){
        //Imprimir informacion
        nacactual = cod_nac;
		exec sql select count(*) into :contador from univ.autor where cod_nacion=:cod_nac;

       EXEC sql fetch cur1 into :nombre,:apellidos,:cod_nac,:nom_nac,:ano_nac;
    }
    //Comprobación de errores
    EXEC sql close cur1;
    EXEC sql commit work release;
}

3. Aumentar el número de ejemplares en 2 unidades disponibles para las sucursales 1 y 2 en aquellos libros de los que dispongan de menos de 3 ejemplares 
(prestados o noprestados). Mostrar un mensaje por cada sucursal y libro actualizado, mostrando su ISBN y el número de ejemplares finales tras la actualización.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        int codSuc, ISBN,numEjemplares,numDisponibles;
    EXEC sql END DECLARE SECTION

    int actSuc = 0;
    
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql DECLARE cur1 CURSOR for select Cod_Suc, ISBN, Num_Ejemplares, Num_Disponibles from Dispone where Cod_Suc in (1, 2) AND Num_Ejemplares < 3 order by Cod_Suc;

    EXEC sql OPEN cur1;

    EXEC sql fetch cur1 into :codSuc,:ISBN,:numEjemplares,:numDisponibles;

    while(sqlca.sqlcode == 0){
        //Imprimir informacion
        if(actSuc != codSuc) {
            printf("\nSUCURSAL %d\n", codSuc);
            actSuc = codSuc;
        }
        
        exec sql update Dispone set Num_Disponibles = :disponibles+2, Num_Ejemplares = :ejemplares+2 where current of micursor;

       EXEC sql fetch cur1 into :codSuc,:ISBN,:numEjemplares,:numDisponibles;
    }
    //Comprobación de errores
    EXEC sql close cur1;
    EXEC sql commit work release;
}

4. La biblioteca ha cerrado la sucursal 3, por tanto todos los registros correspondientes a sus datos deberán ser eliminados de la base de datos.
Estudie previamente cuáles han de ser las tablas en las que deben hacerse las modificaciones y añada al final del programa unas instrucciones que indiquen
el número de registros borrados en cada una de ellas teniendo en cuenta los criterios de integridad referencial.
#include <stdio.h>
EXEC SQL INCLUDE sqlca;

int main() {
    EXEC SQL BEGIN DECLARE SECTION;
        char oracleid[] = "/";
        int registros_borrados;
    EXEC SQL END DECLARE SECTION;

    // Conectar a Oracle
    EXEC SQL CONNECT :oracleid;
    printf("Conexión: %d - %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    // Borrar registros de PRESTAMO
    EXEC SQL DELETE FROM PRESTAMO WHERE Cod_Suc = 3;
    registros_borrados = sqlca.sqlerrd[2];
    printf("Registros borrados en PRESTAMO: %d\n", registros_borrados);

    // Borrar registros de DISPONE
    EXEC SQL DELETE FROM DISPONE WHERE Cod_Suc = 3;
    registros_borrados = sqlca.sqlerrd[2];
    printf("Registros borrados en DISPONE: %d\n", registros_borrados);

    // Borrar la SUCURSAL
    EXEC SQL DELETE FROM SUCURSAL WHERE Codigo = 3;
    registros_borrados = sqlca.sqlerrd[2];
    printf("Registros borrados en SUCURSAL: %d\n", registros_borrados);

    // Confirmar y cerrar conexión
    EXEC SQL COMMIT WORK RELEASE;

    return 0;
}


5. Obtener el expediente de préstamos realizados de un lector cualquiera conociendo su código. En el expediente debe aparecer el código y nombre del lector y a
continuación un listado de los libros tomados en préstamo por orden cronológico de la fecha en la que se inició dicho préstamo.
El expediente mostrará el nombre de dichos libros, la fecha de devolución si ha sido devuelto y la sucursal en la que realizó dicho préstamo.
Al final de dicho expediente se dará el número total de préstamos realizados y pendientes.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        int codLector,codSuc,ISBN,numPrestamos,numPendientes;
        char nombre[21],titulo[35],fechaDev[10],fechaIni[10];
    EXEC sql END DECLARE SECTION

    
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    printf("Introduzca el codigo del lector: ");
    scanf("%d",&codLector);

    EXEC sql DECLARE cur1 CURSOR for select Cod_Suc, ISBN, Fecha_Ini, Fecha_Dev from Prestamo where Cod_Lector = :codLector order by Fecha_Ini;

    EXEC sql OPEN cur1;

    exec sql select nombre into :nombre from lector where codigo=:codLector;

    EXEC sql fetch cur1 into :codSuc,:ISBN,:fechaIni,:fechaDev;

    while(sqlca.sqlcode == 0){
        //Imprimir informacion

       EXEC sql fetch cur1 into :codSuc,:ISBN,:fechaIni,:fechaDev;
    }
    exec sql select count(*) into :numPrestamos from prestamo where cod_Lector = :codLector;

    exec sql select count(*) into :numPendientes from prestamo where cod_Lector = :codLector AND Fecha_Dev is null;
    EXEC sql close cur1;
    EXEC sql commit work release;
}

6. Obtener un listado de los títulos distintos que tiene cada una de las sucursales que incluya 
el código de la sucursal, número de títulos distintos y número de ejemplares total de cada sucursal, ordenado por sucursales,
como se observa en la siguiente figura.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        int codSuc,numLibros,numEjemplares;
    EXEC sql END DECLARE SECTION

    
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    printf("Introduzca el codigo del lector: ");
    scanf("%d",&codLector);

    EXEC sql DECLARE cur1 CURSOR for select Cod_Suc,count(distinct(ISBN)),sum(Num_Ejemplares) from dispone group by cod_suc order by 1;

    EXEC sql OPEN cur1;

    EXEC sql fetch cur1 into :codSuc,:numLibros,:numEjemplares;

    while(sqlca.sqlcode == 0){
        //Imprimir informacion

       EXEC sql fetch cur1 into :codSuc,:numLibros,:numEjemplares;
    }

    EXEC sql close cur1;
    EXEC sql commit work release;
}

7. Obtener un listado de los libros más prestados en cada sucursal y para cada uno de ellos el nombre del título, ISBN y el número de préstamos contabilizados,
ordenado por código de sucursal.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        int codSuc,isbn,numPrestamos;
        char titulo[41];
    EXEC sql END DECLARE SECTION

    
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql DECLARE cur1 CURSOR for SELECT p.Cod_Suc, p.ISBN, l.Titulo, COUNT(*) AS Num_Prestamos
    FROM PRESTAMO p, libro l where p.isbn0l.isbn
    GROUP BY p.Cod_Suc, p.ISBN, l.Titulo
    HAVING COUNT(*) = (
    SELECT MAX(COUNT(*))
    FROM PRESTAMO p2
    WHERE p2.Cod_Suc = p.Cod_Suc
    GROUP BY p2.ISBN
)
ORDER BY p.Cod_Suc;

    EXEC sql OPEN cur1;

    exec sql fetch micursor into :codSuc, :isbn, :titulo, :numPrestamos;

    while(sqlca.sqlcode == 0){
        //Imprimir informacion

       exec sql fetch micursor into :codSuc, :isbn, :titulo, :numPrestamos;
    }

    EXEC sql close cur1;
    EXEC sql commit work release;
}