/*****************************************************************************/
/**  Definiciones de las constantes y estructuras auxiliares usadas en      **/
/**  la librería <<libtds>>, asi como el perfil de las funciones de         **/
/**  manipulación de la  TDS y la TDB.                                      **/
/**                     Jose Miguel Benedi, 2012-2013 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
/*****************************************************************************/
#ifndef _LIBTDS_H
#define _LIBTDS_H

/******************************************* Tipos para la Tabla de Simbolos */
#define T_VACIO       0
#define T_ENTERO      1
#define T_LOGICO      2
#define T_ARRAY       3
#define T_ERROR       4
/************************************** Categorias para la Tabla de Simbolos */
#define NULO          0
#define VARIABLE      1
#define FUNCION       2
#define PARAMETRO     3
/*************************** Variables globales de uso en todo el compilador */
int dvar;                     /* Desplazamiento en el Segmento de Variables  */
/*****************************************************************************/
typedef struct simb /* Estructura para la informacion obtenida de la TDS     */
{
  int   categoria;                /* Categoria del objeto                    */
  int   tipo;                     /* Tipo del objeto                         */
  int   desp;                     /* Desplazamiento relativo en el segmento  */
  int   nivel;                    /* nivel del bloque                        */
  int   ref;                      /* Campo de referencia de usos multiples   */
} SIMB;
typedef struct dim  /* Estructura para la informacion obtenida de la TDArray */
{
  int   telem;                                      /* Tipo de los elementos */
  int   nelem;                                      /* Numero de elementos   */
} DIM;
typedef struct inf  /* Estructura para las funciones                         */
{
  char *nombre;                          /* Nombre de la funcion             */
  int   tipo;                            /* Tipo del rango de la funcion     */
  int   tparam;                          /* Talla del segmento de parametros */
}INF;
/************************************* Operaciones para la gestion de la TDS */
void cargaContexto (int n);
/* Crea el contexto necesario asi como las inicializaciones de la TDS y 
   la TDB para un nuevo bloque con nivel de anidamiento "n". Si "n=0" 
   corresponde a los objetos globales y si "n=1" a los objetos locales 
   a las funciones.                                                          */
void descargaContexto (int n);
/* Libera en la TDB y la TDS el contexto asociado con el bloque "n".         */
void mostrarTDS (int n);
/* Muestra en pantalla toda la informacion de la TDS asociada con el bloque
   definido por "n".                                                         */
int  insertaSimbolo(char *nom, int clase, int tipo, int desp, int n, int ref);
/* Inserta en la TDS toda la informacion asociada con un simbolo de: nombre 
   "nom", clase "clase", tipo "tipo", desplazamiento relativo en el segmento 
   correspondiente (variables, parametros o instrucciones) "desp", nivel del 
   bloque "n" y referencia a posibles subtablas "ref" (-1 si no referencia a 
   otras subtablas). Si el identificador ya existe en el bloque actual, 
   devuelve el valor "FALSE=0" ("TRUE=1" en caso contrario).                 */
int  insertaInfoArray (int telem, int nelem);
/* Inserta en la Tabla de Arrays la informacion de un array cuyos elementos 
   son de tipo "telem" y el numero de elementos es "nelem". Devuelve su 
   referencia en la Tabla de Arrays.                                         */
int  insertaInfoDominio (int refe, int tipo);
/* Para un dominio existente referenciado por "refe", inserta en la Tabla 
   de Dominios la informacion del "tipo" del parametro. Si "refe= -1" entonces
   crea una nueva entrada en la tabla de dominios para el tipo de este 
   parametro y devuelve su referencia.  Si la funcion no tiene parametros, 
   debe crearse un dominio vacio con: "refe = -1" y "tipo = T_VACIO".       */
SIMB obtenerSimbolo (char *nom);
/* Obtiene toda la informacion asociada con un objeto de nombre "nom" y la
   devuelve en una estructura de tipo "SIMB". Si el objeto no está declarado,
   en el campo "categoria" devuelve el valor "NULO".                         */
DIM  obtenerInfoArray (int ref);
/* Devuelve toda la informacion asociada con un array referenciado por "ref" 
   en la Tabla de Arrays.                                                    */
INF  obtenerInfoFuncion (int ref);
/* Devuelve la informacion del nombre de la función, el tipo del rango y el 
   numero (talla) del segmento de parametros de una función cuyo dominio 
   esta referenciado por "ref" en la TDS. Si "ref<0" entonces devuelve la 
   informacion de la funcion actual.                                         */
int  comparaDominio (int refx, int refy);
/* Si los dominios referenciados por "refx" y "refy" no coinciden devuelve 
   "FALSE=0" ("TRUE=1" si son iguales).                                      */

#endif  /* _LIBTDS_H */
/*****************************************************************************/
