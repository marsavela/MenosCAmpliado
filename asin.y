/*###############################################################################*/
/*#  Fichero que contiene la definicion del analizador semantico y sintactico.  #*/
/*#                    Sergiu Daniel Marsavela, 2012-2013 <marsavela@gmail.com> #*/
/*###############################################################################*/

%{
#include <stdio.h>
#include <string.h>
#include "header.h"

%}

%union {	
	char* 		nombre;
	int				entero;
	tipo_exp	exp;	
}

%error-verbose
/*valor semantico para terminales
%token <nombre interno definido en %union> token*/
%token <entero>CTE_
%token <nombre> ID_
%token 	INT_ STRUCT_ IF_ WHILE_ ELSE_ READ_ RETURN_ PRINT_ LLAVABR_ LLAVCER_ CORABR_ CORCER_
				PARABR_ PARCER_ PUNTO_ COMA_ PUNTOCOMA_ COMEN_ ASIG_ FOR_ DO_ AND_ OR_ NOT_ VERD_ FALS_
%left <entero>MENOR_
%left <entero>MAYORIGUAL_
%left <entero>MENORIGUAL_
%left <entero>MAYOR_
%left <entero>DIST_
%left <entero>COMP_
%left <entero>MENOS_
%left <entero>MAS_
%left <entero>MULT_
%left <entero>DIV_
%left <entero>INCRE_
%left <entero>DECRE_

%type <nombre>	declaracionVariable

%type <exp>			expresion expresionRelacional expresionAditiva expresionMultiplicativa 
								expresionSufija expresionUnaria expresionLogica
%type <entero>	bloque operadorRelacional
								operadorAditivo operadorMultiplicativo operadorIncremento
								operadorUnario listaParametrosFormales parametrosFormales parametrosActuales
								listaParametrosActuales

%%

programa
	: {contexto = GLOBAL;
		dvar=0; /*Iniciamos el desplazamiento*/
		si=0; /*y el contador de instrucciones*/
		cargaContexto(contexto);
		/*Creamos una lista de argumentos no satisfechos para las variables globales.*/
		$<entero>$ = creaLans(si);
		emite(INCTOP, crArgNulo(), crArgNulo(), crArgEntero(0));
	}
	{	/*Creamos una lista de argumentos no satisfechos para el "main".*/
		$<entero>$ = creaLans(si);
		emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta(0)); /*Vamos al "main"*/
	}
	secuenciaDeclaraciones
	{ SIMB sim;
		completaLans($<entero>1, crArgEntero(dvar) ); /*apilar var. globales*/
		sim = obtenerSimbolo("main");
  	if(sim.categoria==NULO)
  		yyerror("No se ha encontrado la función 'main'");
		else 
			completaLans($<entero>2, crArgEtiqueta(sim.desp) ); /*Apilar las variables del "main"		*/
		if (verTDS)
			mostrarTDS(contexto);		
		descargaContexto(contexto);

	}
	;

secuenciaDeclaraciones
	: declaracion
	| secuenciaDeclaraciones declaracion
	;

declaracion
	: declaracionVariable
	| declaracionFuncion
	;

declaracionVariable
	: INT_ ID_ PUNTOCOMA_
	{ if(!insertaSimbolo($2, VARIABLE, T_ENTERO, dvar, contexto, -1))
		/* -1 por que es dato simple, es una variable.*/
			yyerror("Identificador repetido");
		else dvar+= TALLA_ENTERO;	/*desplazamos la talla de un entero.*/
	}

	| INT_ ID_ CORABR_ CTE_ CORCER_ PUNTOCOMA_
	{ int numelem = $4;
		if ($4 <= 0) {
			yyerror("Talla inapropiada del array ");
			numelem = 0;
		}  
		if (!insertaSimbolo($2, VARIABLE, T_ARRAY, dvar, contexto, insertaInfoArray(T_ENTERO, numelem)))
			yyerror ("Identificador repetido");
		dvar += numelem * TALLA_ENTERO; /*desplazamos tantos enteros como hayamos definido el vector*/
	}
	;

declaracionFuncion
	: cabeceraFuncion
	{ $<entero>$ = dvar; /*Guardamos el desplazamiento actual*/
  dvar = 0;
	}
	bloque	
	{
		if (verTDS)
			mostrarTDS(contexto);
		descargaContexto(contexto);
		contexto=GLOBAL;
		dvar=$<entero>2; /*Volvemos al desplazamiento anterior*/
	}
	;

cabeceraFuncion
	: INT_ ID_ 
	{ contexto = LOCAL;
		cargaContexto(contexto);
		despp = TALLA_SEGENLACES;   /*Desplazamiento parametros*/
	}
	PARABR_ parametrosFormales PARCER_
	{	/*Guardamos con la referencia obtenida*/
		if(!insertaSimbolo($2, FUNCION, T_ENTERO, si, GLOBAL, $5)) { 
			yyerror("Indentificador repetido");
			if(strcmp("main", $2)==0)
				yyerror("MAIN repetido.");
		}		
	}
	;

parametrosFormales
	:{/*No guardamos nada si no se le pasan parametros*/
		$$ = insertaInfoDominio(-1, T_VACIO);} 

	| listaParametrosFormales
	{	/*Se pasa la referencia a la lista de parametros*/
		$$ = $1;}									
	;

listaParametrosFormales
	: INT_ ID_
	{	/*Insertamos la variable (solo hay una) y devolvemos la referencia*/
		$$ = insertaInfoDominio(-1, T_ENTERO); 
  	despp+= TALLA_ENTERO;
		/*Como la pila va hacia abajo, guardamos el desplazamiento negativamente*/
		if(!insertaSimbolo($2, PARAMETRO, T_ENTERO, -despp, contexto, -1))
			/*Comprobamos que no se haya guardado antes*/
  		yyerror("Parámetro repetido");
	}

	| INT_ ID_ COMA_
	{	despp+= TALLA_ENTERO;
		if(!insertaSimbolo($2, PARAMETRO, T_ENTERO, -despp, contexto, -1))
			/*Comprobamos que no se haya guardado antes*/
			yyerror("Parámetro repetido");
	}
	 listaParametrosFormales
	{	/*Devolvemos la referencia a la lista de todos los parametros de la funcion*/
		$$ = insertaInfoDominio($5, T_ENTERO);}
	;

bloque
	: { /*Apila el frame pointer*/
		emite(PUSHFP, crArgNulo(), crArgNulo(), crArgNulo());
		/*El frame pointer apunta a la posicion apuntada por el tope de la pila*/
		emite(FPTOP, crArgNulo(), crArgNulo(), crArgNulo());
		$<entero>$ = creaLans(si); /*Para las variables locales del bloque*/
		/*Incrementa el tope de la pila*/
		emite(INCTOP, crArgNulo(), crArgNulo(), crArgEntero(0));
	}
	LLAVABR_ declaracionVariableLocal listaInstrucciones RETURN_ expresion PUNTOCOMA_ LLAVCER_
	{	INF inf = obtenerInfoFuncion (-1);
		/*Cerramos la lista para las variables locales*/
		completaLans($<entero>1, crArgEntero(dvar)); 
		if ($6.tipo!=T_ENTERO)
			yyerror("La funcion no devuelve un ENTERO.");

		/*Guardamos el "return", ya que aqui terminan las funciones.*/
		emite(EASIG, $6.pos, crArgNulo(), crArgPosicion(contexto, -(inf.tparam + TALLA_SEGENLACES + 1)));

		/*El tope de la pila apunta a la posicion apuntada por el frame pointer*/
		emite(TOPFP, crArgNulo(), crArgNulo(), crArgNulo());
		/*Desapila la cima y la deposita en el frame pointer*/
		emite(FPPOP, crArgNulo(), crArgNulo(), crArgNulo()); /**/

		if(strcmp(inf.nombre, "main"))
			/*Desapila la direccion de retorno y transfiere el control a dicha direccion*/
			emite(RET, crArgNulo(), crArgNulo(), crArgNulo());
		else
			/*Fin del programa si la funcion que acaba es el "main"*/
			emite(FIN, crArgNulo(), crArgNulo(), crArgNulo()); 

	}
	;
	
declaracionVariableLocal
	: 
	| declaracionVariableLocal declaracionVariable
	;

listaInstrucciones
	:
	| listaInstrucciones instruccion
	;

instruccion
	:	LLAVABR_ listaInstrucciones LLAVCER_
	| instruccionExpresion
	| instruccionEntradaSalida
	| instruccionSeleccion
	| instruccionIteracion
	;

instruccionExpresion
	: PUNTOCOMA_
	| expresion PUNTOCOMA_
	;
	
instruccionEntradaSalida
	: READ_ PARABR_ ID_ PARCER_ PUNTOCOMA_
	{ SIMB sim = obtenerSimbolo($3);
		if (sim.categoria==NULO)
			yyerror("Objeto no declarado");
		else if (sim.tipo!=T_ENTERO)
			yyerror("Error. Hay que leer un entero.");
		/*Lee un entero y lo guarda en la posición del ID_*/
		emite(EREAD, crArgNulo(), crArgNulo(), crArgPosicion(sim.nivel, sim.desp));
	}
	| PRINT_ PARABR_ expresion PARCER_ PUNTOCOMA_
		/*Escribe lo que haya en la posición de $3 "expresion"*/
	{ emite(EWRITE, crArgNulo(), crArgNulo(), $3.pos);
	}
	; 

instruccionSeleccion
	:	instruccionSeleccionIfElse
	;

instruccionSeleccionIfElse
	: IF_ PARABR_ expresion PARCER_
	{ if ($3.tipo!=T_LOGICO)
			yyerror("Error. El IF no contiene una expresión lógica.");
		$<entero>$ = creaLans(si);
		emite(EIGUAL, $3.pos, crArgEntero(0), crArgNulo());
	}
	instruccion
	{	$<entero>$ = creaLans(si);
		emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta(si));
		completaLans($<entero>5, crArgEtiqueta(si));
	}
	ELSE_ instruccion
	{	completaLans($<entero>7, crArgEtiqueta(si));
	}
	;

instruccionIteracion
	:	instruccionIteracionFor
	|	instruccionIteracionWhile
	|	instruccionIteracionDoWhile
	;

instruccionIteracionFor
	: FOR_ PARABR_ expresionOpcional PUNTOCOMA_
	{	$<entero>$ = si;
	}
	expresion PUNTOCOMA_
	{ if ($6.tipo!=T_LOGICO)
			yyerror("Error. El IF no contiene una expresión lógica.");
		$<entero>$ = creaLans(si);
		emite(EIGUAL, $6.pos, crArgEntero(1), crArgNulo());
	}
	{	$<entero>$ = creaLans(si);
		emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta(si));
	}
	{	$<entero>$ = si;
	}
	expresionOpcional PARCER_
	{	emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta($<entero>5));
		completaLans($<entero>8, crArgEtiqueta(si));
	}
	instruccion
	{	emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta($<entero>10));
		completaLans($<entero>9, crArgEtiqueta(si));
	}
	;

instruccionIteracionWhile
	: WHILE_
	{	$<entero>$ = si;
	}
	PARABR_ expresion PARCER_
	{ 	if ($4.tipo!=T_LOGICO)
			yyerror("Error. El WHILE no contiene una expresión lógica.");
		$<entero>$ = creaLans(si);
		emite(EIGUAL, $4.pos, crArgEntero(0), crArgNulo());
	}
	instruccion
	{	emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta($<entero>2));
		completaLans($<entero>6, crArgEtiqueta(si));
	}
	;

instruccionIteracionDoWhile
	: DO_
	{	$<entero>$ = si;
	}
	instruccion WHILE_ PARABR_ expresion PARCER_ PUNTOCOMA_
	{ if ($6.tipo!=T_LOGICO)
			yyerror("Error. El WHILE no contiene una expresión lógica.");
		emite(EIGUAL, $6.pos, crArgEntero(1), crArgEtiqueta($<entero>2));
	}
	;

expresionOpcional
	:
	|	expresion
	;
	
expresion
	: expresionRelacional
	{ $$=$1;}

	| ID_ ASIG_ expresion
	{ SIMB sim = obtenerSimbolo($1);
		$$.tipo = T_ERROR;
		if (sim.categoria==NULO)
			yyerror("Objeto no declarado");
		else if (($3.tipo!=T_ENTERO)||(sim.tipo!=T_ENTERO))
			yyerror("Error de tipos en la asignacion de la 'expresion'");
		else {
			/*Despues de todas las comprobaciones*/
			/*Asignamos, en la posicón de ID_ en valor de "expresion"*/
			emite(EASIG, $3.pos, crArgNulo(), crArgPosicion(sim.nivel, sim.desp));
			/*Creamos una nueva posicion y le asignamos "expresion" para devolverla hacia arriba*/
			$$.tipo = sim.tipo;
			$$.pos = crArgPosicion(contexto, creaVarTemp());
			emite(EASIG, $3.pos, crArgNulo(), $$.pos);
		}
	}

	| ID_ CORABR_ expresion CORCER_ ASIG_ expresion
	{ SIMB sim = obtenerSimbolo($1);
		$$.tipo = T_ERROR;
		if (sim.categoria==NULO)
			yyerror("Objeto no declarado");
		else if (($3.tipo!=T_ENTERO)||($6.tipo!=T_ENTERO)||(sim.tipo!=T_ARRAY))
			yyerror("Error de tipos en la asignacion de la 'expresion'");
		else {
			DIM dim = obtenerInfoArray(sim.ref);
			if(dim.telem!=T_ENTERO)
				yyerror("El tipo del Array no es del tipo entero.");
			/*Despues de todas las comprobaciones*/
			$$.tipo = sim.tipo;
			$$.pos = crArgPosicion(sim.nivel, sim.desp);
			/*Asigna una variable a un elemento de un vector: arg1[arg2] := res*/
			emite(EVA, $$.pos, $3.pos, $6.pos);
			}
	}
	;

expresionRelacional
	: expresionLogica
	{ $$=$1;}

	| VERD_
	{	$$.tipo = T_LOGICO;
		$$.pos=crArgPosicion(contexto, creaVarTemp());
		/*Devolvemos un 1*/
		emite(EASIG, crArgEntero(1), crArgNulo(), $$.pos);
	}

	|	FALS_
	{/*Despues de todas las comprobaciones*/
		$$.tipo = T_LOGICO;
		$$.pos=crArgPosicion(contexto, creaVarTemp());
		/*Un 0 en primer lugar, en caso de uqe no se cumpla la condicion*/
		emite(EASIG, crArgEntero(0), crArgNulo(), $$.pos);
	}
	
	| expresionRelacional operadorRelacional expresionLogica
	{ $$.tipo = T_ERROR;  /*Preguntar si puede comparar dos logicos*/
		if ((($1.tipo!=T_ENTERO)&&($1.tipo!=T_LOGICO))||(($3.tipo!=T_ENTERO)&&($3.tipo!=T_LOGICO))) 
			yyerror("Error de tipos en la asignacion de la 'expresion' RELACIONAL");
		/*Despues de todas las comprobaciones*/
		$$.tipo = T_LOGICO;
		$$.pos=crArgPosicion(contexto, creaVarTemp());
		/*Devolvemos un 1*/
		emite(EASIG, crArgEntero(1), crArgNulo(), $$.pos);
		/*Salta dos instrucciones si la condicion se cumple*/
		emite($2, $1.pos, $3.pos, crArgEtiqueta(si+2));
		/*Sobreescribimos el 1 y devolvemos un 0 si la condicion no se cumple*/
		emite(EASIG, crArgEntero(0), crArgNulo(), $$.pos);
	}
	;

expresionLogica
	:	expresionAditiva
	{ $$=$1;}
	
	| expresion AND_ expresion
	{	$$.tipo = T_ERROR;
		if (($1.tipo!=T_LOGICO)||($3.tipo!=T_LOGICO)) 
			yyerror("Error de tipos en la asignacion de la 'expresion' AND");
		/*Despues de todas las comprobaciones*/
		$$.tipo = T_LOGICO;
		$$.pos=crArgPosicion(contexto, creaVarTemp());
		/*Un 0 en primer lugar, en caso de uqe no se cumpla la condicion*/
		emite(EASIG, crArgEntero(0), crArgNulo(), $$.pos);
		/*Saltamos 3 instrucciones si la primera expresion es falsa*/
		emite(EIGUAL, $1.pos, crArgEntero(1), crArgEtiqueta(si+3));
		/*Saltamos 2 instrucciones si la segunda expresion es falsa*/
		emite(EIGUAL, $3.pos, crArgEntero(1), crArgEtiqueta(si+2));
		/*Un 1. La condicion se cumple*/
		emite(EASIG, crArgEntero(1), crArgNulo(), $$.pos);
	}

	|	expresion OR_ expresion /*Es simetrica a la anterior*/
	{	$$.tipo = T_ERROR;
		if (($1.tipo!=T_LOGICO)||($3.tipo!=T_LOGICO)) 
			yyerror("Error de tipos en la asignacion de la 'expresion' OR");
		/*Despues de todas las comprobaciones*/
		$$.tipo = T_LOGICO;
		$$.pos=crArgPosicion(contexto, creaVarTemp());
		/*Un 1 en primer lugar, en caso de uqe no se cumpla la condicion*/
		emite(EASIG, crArgEntero(1), crArgNulo(), $$.pos);
		/*Saltamos 3 instrucciones si la primera expresion es falsa*/
		emite(EIGUAL, $1.pos, crArgEntero(1), crArgEtiqueta(si+3));
		/*Saltamos 2 instrucciones si la segunda expresion es falsa*/
		emite(EIGUAL, $3.pos, crArgEntero(1), crArgEtiqueta(si+2));
		/*Un 0. La condicion se cumple*/
		emite(EASIG, crArgEntero(0), crArgNulo(), $$.pos);
	}

	|	NOT_ expresion
	{	$$.tipo = T_ERROR;
		if (($2.tipo!=T_LOGICO)) 
			yyerror("Error de tipos en la asignacion de la 'expresion' NOT");
		/*Despues de todas las comprobaciones*/
		$$.tipo = T_LOGICO;
		$$.pos=crArgPosicion(contexto, creaVarTemp());
		/*Un 0 en primer lugar, en caso de que no se cumpla la condicion*/
		emite(EASIG, crArgEntero(0), crArgNulo(), $$.pos);
		/*Saltamos 2 instrucciones si la expresion es falsa*/
		emite(EIGUAL, $2.pos, crArgEntero(1), crArgEtiqueta(si+2));
		/*Un 1. La condicion se cumple*/
		emite(EASIG, crArgEntero(1), crArgNulo(), $$.pos);
	}
	;

expresionAditiva
	: expresionMultiplicativa
	{$$=$1;}
	
	| expresionAditiva operadorAditivo expresionMultiplicativa
	{ $$.tipo = T_ERROR;
		if (($1.tipo!=T_ENTERO)||($3.tipo!=T_ENTERO))
			yyerror("Esta intentando sumar algo que no es un ENTERO..");
		else {
			/*Despues de todas las comprobaciones*/
			$$.tipo = T_ENTERO;
			$$.pos = crArgPosicion(contexto, creaVarTemp());
			/*Sumamos o restamos y lo pasamos hacia arriba*/
			emite($2, $1.pos, $3.pos, $$.pos);
		}
	}
	;

expresionMultiplicativa
	: expresionUnaria
	{$$=$1;}
	
	| expresionMultiplicativa operadorMultiplicativo expresionUnaria
	{ $$.tipo = T_ERROR;
		if (($1.tipo!=T_ENTERO)||($3.tipo!=T_ENTERO))
			yyerror("Esta intentando multiplicar algo que no es un ENTERO.");
		else {
			/*Despues de todas las comprobaciones*/
			$$.tipo = T_ENTERO;
			$$.pos = crArgPosicion(contexto, creaVarTemp());
			/*Multiplicamos o dividimos y lo pasamos hacia arriba*/
			emite($2, $1.pos, $3.pos, $$.pos);
		}
	}
	;
	
expresionUnaria
	: expresionSufija
	{$$=$1;}

	| operadorUnario expresionUnaria
	{	$$=$2;
		$$.pos = crArgPosicion(contexto, creaVarTemp());
		emite($1, $2.pos, crArgNulo(), $$.pos);
	}
	
	| operadorIncremento ID_
	{ SIMB sim = obtenerSimbolo($2);
		$$.tipo = T_ERROR;
		if (sim.categoria==NULO)
			yyerror("Objeto no declarado");
		else if (sim.tipo!=T_ENTERO)
			yyerror("Esta intentando incrementar algo que no es un ENTERO.");
		else { 
			/*Despues de todas las comprobaciones*/
			/*Hacemos la operacion de primero incrementar y luego asignar*/
			$$.tipo = sim.tipo;
			$$.pos = crArgPosicion(contexto, creaVarTemp());
			/************************************** INCREMENTA o DECREMENTA 1 */
			emite($1, crArgPosicion(sim.nivel, sim.desp), crArgEntero(1), crArgPosicion(sim.nivel, sim.desp));
			/***************************************************** Asignacion */
			emite(EASIG, crArgPosicion(sim.nivel, sim.desp), crArgNulo(), $$.pos);
		}
	}
	;
	
expresionSufija
	: ID_ CORABR_ expresion CORCER_
	{ SIMB sim = obtenerSimbolo($1);
		$$.tipo = T_ERROR;
		if (sim.categoria==NULO)
			yyerror("Objeto no declarado");
		else if (($3.tipo!=T_ENTERO) || (sim.tipo!=T_ARRAY))
			yyerror("Expresion no corresponde a ARRAY");
		else { 
			DIM dim = obtenerInfoArray(sim.ref);
			if(dim.telem!=T_ENTERO)
				yyerror("El tipo del Array no es del tipo entero.");
			else {
				/*Despues de todas las comprobaciones*/
				/*Devolvemos el valor de esa posicion del vector*/
				$$.tipo = T_ENTERO;
				$$.pos = crArgPosicion(contexto, creaVarTemp());
				/*Asigna un elemento de un vector a una variable: res := arg1[arg2]*/
				emite(EAV, crArgPosicion(sim.nivel, sim.desp), $3.pos, $$.pos);
			}
		}
	}

	| ID_ operadorIncremento
	{ SIMB sim = obtenerSimbolo($1);
		$$.tipo = T_ERROR;
		if (sim.categoria == NULO)
			yyerror("Objeto no declarado");
		else if (sim.tipo!=T_ENTERO)
			yyerror("Error de tipos en la asignacion de la 'expresion'");
		else {
			/*Despues de todas las comprobaciones*/
			/*Hacemos la operacion de primero asignar y luego incrementar*/
			$$.tipo = sim.tipo;
			$$.pos = crArgPosicion(contexto, creaVarTemp());
			/***************************************************** Asignacion */
			emite(EASIG, crArgPosicion(sim.nivel, sim.desp), crArgNulo(), $$.pos);
			/************************************** INCREMENTA o DECREMENTA 1 */
			emite($2, crArgPosicion(sim.nivel, sim.desp), crArgEntero(1), crArgPosicion(sim.nivel, sim.desp));
		}
	}

	| ID_
	{	/*Apila un elemento en la cima de la pila*/
		emite(EPUSH, crArgNulo(), crArgNulo(), crArgEntero(0));
	}
	PARABR_ parametrosActuales PARCER_
	{	SIMB sim = obtenerSimbolo($1);
		INF inf=obtenerInfoFuncion(sim.ref);
		$$.tipo = T_ERROR;
		if (sim.categoria == NULO)
			yyerror("Funcion no declarada");
		else if (sim.categoria!=FUNCION)
			yyerror("No es una FUNCION");
		else if (!comparaDominio(sim.ref, $4))
			yyerror("No concuerdan los parametros de la FUNCION");

		if(inf.tipo!=T_ENTERO)
			yyerror("Error de tipo de rango.");

		/*Despues de todas las comprobaciones*/
		/*Proceso de llamada y resolucion de una funcion*/
		$$.tipo=inf.tipo;
		$$.pos = crArgPosicion(contexto, creaVarTemp());
		/*Apila la direccion de retorno y llama a la funcion*/
		emite(CALL, crArgNulo(), crArgNulo(), crArgEtiqueta(sim.desp));
		/*Incrementa el tope de la pila en tantas posiciones como parametros tiene la funcion*/
		emite(DECTOP, crArgNulo(), crArgNulo(), crArgEntero (inf.tparam));
		/*Desapilamos la pila, devolviendo lo que devuelva la funcion por posicion*/
		emite(EPOP, crArgNulo(), crArgNulo(), $$.pos);
	}

	| PARABR_ expresion PARCER_
	{	$$ = $2;}

	| ID_
	{ SIMB sim = obtenerSimbolo($1);
		$$.tipo = T_ERROR;
		if (sim.categoria==NULO)
			yyerror("Objeto no declarado");
		else if (sim.tipo!=T_ENTERO)
			yyerror("La variable no es del tipo entero.");
		else {
			/*Despues de todas las comprobaciones*/
			$$.pos = crArgPosicion(sim.nivel, sim.desp);
			$$.tipo = sim.tipo;
		}
	}

	| CTE_
	{	/*Cargamos la constante directamente*/
		$$.tipo = T_ENTERO;
		$$.pos = crArgEntero($1);
	}
	;

parametrosActuales
	:{/*Si no se le pasan parametros*/
		$$ = insertaInfoDominio(-1, T_VACIO);}
	
	| listaParametrosActuales
	{$$ = $1;}
	;

listaParametrosActuales
	: expresion
	{	/*Si es el ultimo parametro que pasa la funcion*/
		$$ = insertaInfoDominio(-1, $1.tipo);
		/*Apila*/
		emite(EPUSH, crArgNulo(), crArgNulo(), $1.pos);
	}

	| expresion COMA_ listaParametrosActuales
	{	$$ = insertaInfoDominio($3, $1.tipo);
		/*Apila (En orden inverso)*/
		emite(EPUSH, crArgNulo(), crArgNulo(), $1.pos);
	}
	;
	
/*Asignamos cada variable con su comando*/

operadorRelacional
	: MENOR_ 			{ $$ = EMEN; }
	| MAYORIGUAL_ { $$ = EMAYEQ; }
	| MENORIGUAL_ { $$ = EMENEQ; }
	| MAYOR_			{ $$ = EMAY; }
	| DIST_				{ $$ = EDIST; }
	| COMP_				{ $$ = EIGUAL; }
	;
	
operadorAditivo
	: MAS_ 		{ $$ = ESUM; }
	| MENOS_ 	{ $$ = EDIF; }
	;
	
operadorMultiplicativo
	: MULT_ { $$ = EMULT; }
	| DIV_ 	{ $$ = EDIVI; }
	;

operadorIncremento
	: INCRE_ { $$ = ESUM; }
	| DECRE_ { $$ = EDIF; }
	;

operadorUnario
	: MAS_ { $$ = ESUM; }
	| MENOS_ { $$ = ESIG; }
	;

%%

