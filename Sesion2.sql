1. Aumentar en 3 el número de ejemplares del libro con ISBN 5025496 para la sucursal 9. Comprobar que la actualización ha sido correcta.
    update dispone set num_ejemplares = num_ejemplares+3 and num_disponibles = num_disponibles+3 where isbn=5025496 and cod_suc=9;

2. El lector con código 7395860 ha cambiado su dirección a la C/Sevilla, 1 de Aldeadávila en la provincia de Salamanca. Actualice sus datos en la base de datos.
    update lector set direccion='C\Sevilla 1', poblacion='Aldeavila', provincia='Salamanca' where codigo=7395860;

3. Actualizar la tabla SUCURSAL la sucursal con código 15 para que pase a estar ubicada en la ciudad de SEGOVIA con dirección en C/ SAN AGUSTÍN, 10.
    update sucursal set poblacion='Segovia', direccion='C\San Agustin 10' where cod_suc=15;

4. Actualizar la dirección de los lectores con códigos 71259836 y 94246322 a Av. de Alemania, 49, Miajadas, Cáceres y Daoiz y Velarde, 24, Benavente, Zamora,respectivamente.
    update lector set direccion='Av. de Alemania 49'. poblacion='Mijadas',provincia='Caceres' where codigo=71259836;

5. Se acaban de comprar 15 ejemplares, 1 para cada una de las 15 sucursales, del premio Planeta 2001 titulada ‘EL PREMIO ERES TÚ’ con ISBN 8408104829
escrita por de Javier Moro (Madrid, 1955) y publicada por la editorial Planeta en el 2001. Realizar su inserción en el sistema añadiendo los datos correspondientes en
todas las tablas que sea necesario.
    insert into autor (codigo, nombre, apellido, ano_nac, cod_nacion) values (159, 'JAVIER', 'MORO', 1955, ,9);
    insert into escribe values (159, �8408104829�);
    insert into editorial values (12, ' PLANETA ');
    insert into libro values (�8408104829�, ' EL PREMIO ERES T� ', 2011, 12);
    insert into dispone values (1, �8408104829�, 1, 1);
    insert into dispone values (2, �8408104829�, 1, 1);
    .
    .
    .
    insert into dispone values (15, �8408104829�, 1, 1);

6. Añadir una nueva sucursal en la ciudad de Soria, en la dirección “Calle de los Caballeros, 32”. Esta sucursal tendrá asociado el código 16.
    insert into sucursal (cod_suc, direccion, poblacion, provincia) values (16, 'C\ de los Caballeros 32','Soria','Soria');

7. La nueva sucursal creada en la ciudad de Soria en el ejercicio anterior, se dota con los mismos ejemplares que tiene la sucursal 2.
    insert into dispone (select codigo,isbn,num_ejemplares,num_disponibles from dispone where cod_suc=2;)

8. El lector Francisco Roldán se ha dado de baja en la biblioteca, por tanto debe ser dado de baja en la base de datos. (Atención, deberá dar de baja todos los registros
que tengan que ver con ese alumno en todas las tablas y además en el orden adecuado).
    delete from prestamo where codigo = (select codigo from lector where nombre='Francisco' and ape_1='Roldan');
    delete from lector where nombre='Francisco' and ape_1='Roldan';

9. Incrementar en dos unidades disponibles por sucursal el libro del que más préstamos se realizan.
    update dispone set num_ejemplares=num_ejemplares+2, num_disponibles = num_disponibles+2 where isbn in (select isbn from prestamo p group by isbn having count(*)=max(count(*)) group by isbn);

10. Realizar un incremento en 1 ejemplar en todas las sucursales de aquellos libros para los se han contabilizado más de 4 préstamos.
    UPDATE dispone set num_ejemplares= num_ejemplares+1,  num_disponibles= num_disponibles+1 where ISBN IN (select ISBN from prestamo p group by cod_suc, ISBN having count(*)>4);

11. Eliminar todos los préstamos de los lectores de la provincia de Zamora.
    delete from prestamo where codigo in (select codigo from lector where provincia='Zamora');