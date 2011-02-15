******************************************************************
****     DEPARTAMENTO DE SEGURIDAD EN COMPUTO / UNAM-CERT     ****
****        PLAN DE BECARIOS DE SEGURIDAD EN COMPUTO          ****
****             CURSO DE PROGRAMACION EN PERL                ****
****							      ****
****			  PROYECTO FINAL		      ****
******************************************************************

******************************************************************
****    GENERADOR DE ESTADISTICAS DE URLS SOBRE CORREO SPAM   ****
****							      ****
****			     SPAMSTATE			      ****
******************************************************************

*************************************************
****	Javier Ulises Santillan Arenas       ****
***	bec_jsantillan@seguridad.unam.mx     ****
*************************************************


******
INDICE

1) Requisitos del Programa
2) Funcionamiento del programa
	2.1) Especificacione de las versiones
3) Ejemplos de ejecucion





**************************
1) REQUISITOS DEL PROGRAMA

Version 0.1
	- Perl instalado
	- Modulo Net::Nslookup
	- Conexion a Internet

Version 0.2
	- Perl instalado
	- Modulo Net::Nlookup
	- Modulo perlchartdir (ChartDirector)
	- Modulo Mail::MboxParser
	- Modulo Mail::MboxParser::Mail
	- Modulo Mail::MboxParser::Mail::Body
	- Conexion a Internet


******************************
2) FUNCIONAMIENTO DEL PROGRAMA

La herramienta recibe 6 posibles argumentos de entrada:

[ -p  ]  : 	Indica la ruta al archivo /etc/passwd o uno con formato similar	Ej. /etc/passwd
[ -o  ]  :	Indica la lista de los usuarios a omitir del archivo anterior 	Ej. [usr1, usr2,]
[ -c  ]  :	Indica la ruta a un archivo de configuracion alternativo al default (spamstate.conf)
[ -r  ]  :  	Indica la ruta del directorio en donde se generaran los archivos de reportes de salida.
[ -fi ]  :	Para el caso de los reportes, indica la fecha inicial a partir del cual se generara el mismo.
[ -ff ]  :	Para el caso de los reportes, indica la fecha final a partir del cual se generara el mismo.


La herramienta hace la validacion para cada argumento ingresado. Es importante menciona que se lee informacion
tanto de un archivo de configuracion como de los argumentos ingresados. Estos ultimos tienen una mayor precedencia.

Existen dos modos de ejecucion: Procesamiento [-p] y Reporte [-r]. Solo se puede ejecutar un tipo a la vez, por lo
que se debe tener en cuenta que si en los parametros leidos en el archivo y en los argumentos de entrada se 
especifican los dos, el programa mandara un error especificando que solo se debe ejecutar de un tipo.


2.1) ESPECIFICACIONES DE LAS VERSIONES

VERSION 0.1

	En esta Version de la herramienta, no se utilizan modulo para la lectura de los correos en el buzon.
	En un principio, tomando como patron la estructura del formato de los archivos mbox  (Cabeceras,Body),
	se programaron las subrutinas correspondientes para hacer un filtrado de cada uno de los campos de la
	cabecera de los correos, asi como para el cuerpo del mensaje. sin embargo, se cuenta con una limitacion
	ya que no siempre extrae integro el cuerpo del mensaje debido a cambio en la posicion de las cabeceras.
	Es una forma muy rudimentaria de leer los correos en un buzon mbox, sin embargo llega a dar resultados,
	aunque no del todo correctos, del contenido de los mensajes.

	NOTA** : En esta version no se hace la validacion de que se ejecute la herramienta en modo de
	procesamiento [-p] o modo Reporte [-r]. Se puede o no especificar la opcion de Reporte, pero siempre
	hara el procesamiento agregando informacion al archivo de datos.

VERSION 0.2
	En esta version, se utilizan las mismas subrutinas de la version 0.1 para el procesamiento de los correos,
	sin embargo la forma en la que se leen los mismos cambia. En esta version se utilizan los modulos
	Mail::MboxParser para extraer las partes de cada mensaje (subject, from, body, etc) por lo que se tienen
	los resultados correctos para la generacion de las estadisticas de URL.
	En esta version tambien se agrega la funcionalidad de que en la parte de los reportes se crea una grafica
	para el TOP 10 de ASN, utilizando el modulo de CharDirector.



***********************
3)EJEMPLOS DE EJECUCION


	$ ./spamstate.pl -p /etc/passwd -o lp,games,bin,irc,proxy,sshd,news,haldaemon,www-data,gdm,backup,uucp,sys,sync,gnats,mysql,man,daemon,mail,list,messagebus,nobody,root
	
		Realiza el procesamiento omitiendo a todos los usuario especificados en la opcion -o

	$ ./spamstate.pl -r /home/javier

		Realiza un reporte y los archivos de salida (datos de reporte, reporte con formato y grafica ) los guarda en /home/javier

	$ ./spamstate.pl -r /home/javier -fi 06-10 -ff 08-10

		Realiza un reporte y los archivos de salida (datos de reporte, reporte con formato y grafica ) los guarda en /home/javier
		El reporte solo lo generara de las ejecuciones del 10 de Junio al 10 Agosto.


****
NOTA
	Dentro de la carpeta de EJEMPLOS/ejemplobuzon/ , se encuentra los archivos generados para el archivo "ejemplobuzon" proporcionado

