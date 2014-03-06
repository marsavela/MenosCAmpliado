/*###############################################################################*/
/*#  Fichero que contiene la definicion del analizador lexico.                  #*/
/*#                    Sergiu Daniel Marsavela, 2012-2013 <marsavela@gmail.com> #*/
/*###############################################################################*/

/* Analizador Lexico */
%{

#include <stdio.h>
#include "header.h"
#include "asin.h"
int MAX_LENGTH = 14;
void creaNombre();
void creaCentera();
void truncCreal();

%}

%option yylineno
delimitador [ \t]+
nlinea [\n]
entero [0-9]+
decimal {entero}"."{entero}
id [a-zA-Z][a-zA-Z0-9_]*
comentario "//"[^\n]+

%%
int 					{if (verbosidad) ECHO; return(INT_);}
struct 				{if (verbosidad) ECHO; return(STRUCT_);}
if 						{if (verbosidad) ECHO; return(IF_);}
else 					{if (verbosidad) ECHO; return(ELSE_);}
while 				{if (verbosidad) ECHO; return(WHILE_);}
for		 				{if (verbosidad) ECHO; return(FOR_);}
do		 				{if (verbosidad) ECHO; return(DO_);}
and						{if (verbosidad) ECHO; return(AND_);}
or	 					{if (verbosidad) ECHO; return(OR_);}
not		 				{if (verbosidad) ECHO; return(NOT_);}
true	 				{if (verbosidad) ECHO; return(VERD_);}
false	 				{if (verbosidad) ECHO; return(FALS_);}
read	 				{if (verbosidad) ECHO; return(READ_);}
return 				{if (verbosidad) ECHO; return(RETURN_);}
print 				{if (verbosidad) ECHO; return(PRINT_);}
{delimitador}	{if (verbosidad) ECHO; }
{nlinea}			{if (verbosidad) ECHO; fprintf(stdout,"%3d.- ", yylineno);}
{comentario}	{if (verbosidad) ECHO; }

{entero}			{if (verbosidad) ECHO; creaCentera(); return(CTE_);}
{decimal}     {if (verbosidad) ECHO; truncCreal(); return(CTE_);} 
{id}					{if (verbosidad) ECHO; creaNombre(); return(ID_);}

"{"		{if (verbosidad) ECHO; return(LLAVABR_);}
"}"		{if (verbosidad) ECHO; return(LLAVCER_);}
"["		{if (verbosidad) ECHO; return(CORABR_);}
"]"		{if (verbosidad) ECHO; return(CORCER_);}
"(" 	{if (verbosidad) ECHO; return(PARABR_);}
")" 	{if (verbosidad) ECHO; return(PARCER_);}
"."		{if (verbosidad) ECHO; return(PUNTO_);}
","		{if (verbosidad) ECHO; return(COMA_);}
";"		{if (verbosidad) ECHO; return(PUNTOCOMA_);}
"*"		{if (verbosidad) ECHO; return(MULT_);}
"/"		{if (verbosidad) ECHO; return(DIV_);}
"-"		{if (verbosidad) ECHO; return(MENOS_);}
"+"		{if (verbosidad) ECHO; return(MAS_);}
"--"	{if (verbosidad) ECHO; return(DECRE_);}
"++"	{if (verbosidad) ECHO; return(INCRE_);}
"<"		{if (verbosidad) ECHO; return(MENOR_);}
">="	{if (verbosidad) ECHO; return(MAYORIGUAL_);}
"<="	{if (verbosidad) ECHO; return(MENORIGUAL_);}
">"		{if (verbosidad) ECHO; return(MAYOR_);}
"="		{if (verbosidad) ECHO; return(ASIG_);}
"!="	{if (verbosidad) ECHO; return(DIST_);}
"=="	{if (verbosidad) ECHO; return(COMP_);}

. {printf("Caracter Desconocido");}

%%

/******************************************************************************/
/* Comprueba que el identificador no exceda la talla maxima (14), en ese*/
/* caso lo trunca.*/
void creaNombre()
{	char *t;
	if (yyleng > MAX_LENGTH) 
	{ 
		if(verbosidad) fprintf(stdout, "\n Warning at line %d: identificador truncado a longitud %d\n", yylineno, MAX_LENGTH);
			yyleng=MAX_LENGTH;
	}
	t = (char *)malloc(yyleng+1); strncpy(t, yytext, yyleng);
	t[yyleng] = '\0'; yylval.nombre = t;
}

/*****************************************************************************/
/* Transforma una subcadena a la constante entera que representa */
void creaCentera()
{ 
	yylval.entero = atoi(yytext); 
}

/*****************************************************************************/
/* Transforma una subcadena, que representa una constante real, a una */
/* constante entera truncandola. */
void truncCreal()
{	
	char *t;
	if(verbosidad) fprintf(stdout,"Warning at line %d: constante real truncada a entera\n", yylineno);
	yyleng = strcspn(yytext,".");
	t = (char *)malloc(yyleng+1); strncpy(t, yytext, yyleng);
	t[yyleng] = '\0'; yylval.entero = atoi(t);
}



