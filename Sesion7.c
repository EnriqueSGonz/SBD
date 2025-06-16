1. Obtener el nombre y apellidos de un lector a partir de su código, que es introducido por el usuario.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char nombre[20],apellidos[40];
        char oracleid[]="/";
        int codigo;
    EXEC sql END DECLARE SECTION
    
    printf("Introduzca el codigo del lector a consultar: ");
    scanf("%d",&codigo);
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql select nombre,ape_1 into :nombre,:apellidos from lector where codigo=:cod;
    //Comprobación de errores
    EXEC sql commit work release;
}

2. Obtener el número de autores pertenecientes a una nacionalidad a partir del código de nacionalidad introducido por el usuario.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        int numAutores,codNac;
    EXEC sql END DECLARE SECTION
    
    printf("Introduzca el codigo de la nacionalidad a consultar: ");
    scanf("%d",&codNac);
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql select count(*) into :numAutores from autor where cod_nacion=:codNac;
    //Comprobación de errores
    EXEC sql commit work release;
}

3. Obtener el número de autores pertenecientes a una nacionalidad a partir de la nacionalidad introducida por el usuario.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        char nacionalidad[15];
        int numAutores;
    EXEC sql END DECLARE SECTION
    
    printf("Introduzca el codigo de la nacionalidad a consultar: ");
    scanf("%s",nacionalidad);
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql select count(*) into :numAutores from autor a, nacionalidad n where a.cod_nacion = n.codigo and n.nombre=upper(:nom_nacion);
    //Comprobación de errores
    EXEC sql commit work release;
}

4. Obtener la localidad en la que está ubicada una sucursal a partir del código que es introducido por el usuario.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        char problacion[15];
        int codSuc;
    EXEC sql END DECLARE SECTION
    
    printf("Introduzca el codigo de la nacionalidad a consultar: ");
    scanf("%d",&codSuc);
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql select problacion into :poblacion from sucursal where codigo=:codSuc;
    //Comprobación de errores
    EXEC sql commit work release;
}

5. Obtener toda la información de un autor a partir del código de éste, introducido por el usuario.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        char nombre[20],apellido[40];
        int codAutor,codNacion,anioNac,aniFac;
    EXEC sql END DECLARE SECTION
    
    printf("Introduzca el codigo del autor a consultar: ");
    scanf("%d",&codAutor);
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql select nombre,apellidos,aniNac,anioFac,cod_nacion into :nombre,:apellido,:anioNac,:anioFac,:codNacion from autor where codigo=:codAutor;
    //Comprobación de errores
    EXEC sql commit work release;
}

6. Obtener el número de préstamos en un año concreto contabilizados para una sucursal a partir del código de la sucursal y el año elegido.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        int numPrestamos,codSuc,anio;
    EXEC sql END DECLARE SECTION
    
    printf("Introduzca el codigo del autor a consultar: ");
    scanf("%d",&codSuc);
    printf("Introduzca el año a consultar: ");
    scanf("%d",&anio);
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql select count(*) into :numPrestamos from prestamos where codigo=:codSuc and to_char(fecha_ini,'yyyy')=:anio;
    //Comprobación de errores
    EXEC sql commit work release;
}

7. Obtener el número de préstamos no finalizados contabilizados para una sucursal a partir del código de la sucursal.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        int numPrestamos,codSuc;
    EXEC sql END DECLARE SECTION
    
    printf("Introduzca el codigo del autor a consultar: ");
    scanf("%d",&codSuc);
    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);

    EXEC sql select count(*) into :numPrestamos from prestamos where codigo=:codSuc and to_char(fecha_fin,'yyyy') is null;
    //Comprobación de errores
    EXEC sql commit work release;
}

8. Codificar un programa que utilizando SQL inmerso en C permita modificar la dirección, población y provincia de un lector.
El programa, inicialmente, debe pedir al usuario el código del lector. Si dicho lector no existe mostrará un mensaje de error
indicando que no existe y por tanto no se puede modificar, en caso contrario pedirá al usuario los nuevos valores para los atributos 
dirección, población y provincia y actualizará dichos datos para el lector especificado. Si el usuario no proporciona
valor para alguno de los atributos, estos deben actualizarse con valor nulo.

#include <stdio.h>
EXEC sql INCLUDE sqlca
int main(){
    EXEC sql BEGIN DECLARE SECTION
        char oracleid[]="/";
        char dirección,poblacion,provincia;
        int codLector;
    EXEC sql END DECLARE SECTION

    exec sql connect :oracleid;
    printf ("CONEXION: %d, %s\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);
    
    printf("Introduzca el codigo del autor a consultar: ");
    scanf("%d",&codLector);
    Exec sql select * from lector where codigo=:codLector;
    //Si existe modificamos los valores sino error
    printf("Introduzca nueva direccion: ");
    scanf("%s",direccion);
    printf("Introduzca nueva población: ");
    scanf("%s",poblacion);
    printf("Introduzca nueva provincia: ");
    scanf("%s", provincia);

    EXEC sql update lector set direccion=:direccion, poblacion=:poblacion, provincia=:provincia where codigo=:codLector;
    //Comprobación de errores
    EXEC sql commit work release;
}
