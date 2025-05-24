/*1. Obtener el listado de los prestamos de un libro cuyo ISBN se introducirá porteclado.
En el listado se incluirá un encabezado en el que aparecerán los datos del libro y, a continuación,
se mostrarán todos los préstamos que ha tenido el libro, agrupados por sucursales y, para cada sucursal ordenado por fecha de inicio del
préstamo. Si el préstamo no ha finalizado, en la columna correspondiente a la fecha de devolución se mostrará el texto “PENDIENTE”.
A continuación se muestra un ejemplo de ejecución del programa.*/

#include <stdio.h>
EXEC sql INCLUDE sqlca;

int main(){
    EXEC sql BEGIN declare section;
        short v_ind;
        int isbn,anoEdicion,codEditorial,codSuc;
        char titulo[40],nombreA[21],apellidosA[50],fechaIni[10],fechaDev[10],nombreL[21],ape_1[21],ape_2[21];
        char oracleid[]="/";
    EXEC sql END declare section;

    EXEC sql connect :oracleid;

    printf("Introduzca el isbn del libro a consultar: ");
    scanf("%d",&isbn);

    EXEC sql select a.nombre,a.apellidos,l.titulo into :nombreA,:apellidosA,:titulo from autor a, escribe e, libro l where a.codigo=e.cod_autor and e.isbn=l.isbn and e.isbn=:isbn;

    EXEC sql DECLARE cur1 CURSOR for select cod_suc,l.nombre,l.ape_1,l.ape_2, fecha_ini, fecha_dev from prestamo p, lector l where p.cod_lector=l.codigo and isbn=:isbn order by 1,3,4,2;

    EXEC sql OPEN cur1;

    EXEC sql fetch cur1 into :codSuc,:nombreL,:ape_1,:ape_2,:fechaIni,:fechaDev:v_ind;
    while(sqlca.sqlcode == 0){
        //imprimir Info Libro
        //Imprimir info por sucursal
        if(v_ind==-1){
            //imprimimos campo fechaDev como PENDIENTE
        }else{
            //imprimimos campo fechaDev normal
        }
        EXEC sql fetch cur1 into :codSuc,:nombreL,:ape_1,:ape_2,:fechaIni,:fechaDev:v_ind;
    }
        EXEC sql CLOSE cur1;
        EXEC sql commit work release;
}



/*2. Escribir un programa que permita solicite la entrada por teclado de los datos de un nuevo autor y haga la inserción correspondiente en la tabla AUTOR. 
Se tendrá en cuenta que el año de fallecimiento será nulo para autores vivos.*/

#include <stdio.h>
EXEC sql INCLUDE sqlca;

int main(){
    exec sql begin declare section;
        char oracleid[]="/";
        char nom[51], ape[51];
        int cod, anac, afall, codnac;
        short vind;
    exec sql end declare section;

    EXEC sql connect :oracleid;

    printf ("Introduzca nombre autor: ");
        scanf (" %s", nom);
        printf ("Introduzca apellido autor: ");
        scanf (" %s", ape);
        printf ("Introduzca agno nacimiento del autor: ");
        scanf (" %d", &anac);
        printf ("El autor ha fallecido? (S/N)");
        scanf (" %c", &respuesta);
        if (respuesta=='s' || respuesta=='S')
        {
                vind=0;
                printf ("Introduzca agno muerte del autor: ");
                scanf (" %d", &afall);

        }
        else vind=-1;
        printf ("Introduzca codigo de nacion del autor: ");
        scanf (" %d", &codnac);

        exec sql select max(codigo) + 1 into :cod from autor;
        exec sql insert into autor
          values (:cod, :nom, :ape, :anac, :afall:vind, :codnac);
        exec sql commit;
        EXEC sql commit work release;
}

/*3. Escribir un programa en el que se obtenga un listado de todos los libros existentes en la biblioteca mostrando el ISBN y el título. 
Para el título se mostrarán solo los 30 primeros caracteres, seguidos de puntos suspensivos (…) en el caso en que el título
no pueda mostrarse completo. La siguiente imagen muestra un fragmento de la salida del programa.*/

#include <stdio.h>

exec sql include sqlca;

void main ()
{
exec sql begin declare section;
char oracleid []="/";
char isbn[11];
short v_ind;
char titulo[31];
exec sql end declare section;

exec sql declare micur cursor for
select isbn, titulo
from univ.libro ;

exec sql connect :oracleid;
if (sqlca.sqlcode!=0) printf ("CONEXION: %d, %s", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

exec sql open micur;
if (sqlca.sqlcode!=0) printf ("OPEN: %d, %s", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

exec sql fetch micur into :isbn, :titulo:v_ind;

if (sqlca.sqlcode!=0) printf ("FETCH 1: %d, %s", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

printf ("ISBN   \tTITULO\n\n");
while (sqlca.sqlcode==0) {
	if (v_ind) 
		printf ("%s\t %s...\n", isbn, titulo);
	else    printf ("%s\t %s\n", isbn, titulo);

	exec sql fetch micur into :isbn, :titulo:v_ind;

	if (sqlca.sqlcode!=0 && sqlca.sqlcode!=100) 
		printf ("FETCH 2: %d, %s", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

	}

exec sql close micur;
exec sql commit work release;
}

	
	
