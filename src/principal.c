/*****************************************************************************/
/*  El programa principal y de tratamiento de errores.                       */
/*                       Jose Miguel Benedi, 2012-2013 <jbenedi@dsic.upv.es> */
/*****************************************************************************/
#include <stdio.h>
#include <string.h>
#include "header.h"
int verbosidad=FALSE;
int verTDS=0;               /* Flag para saber si se desea una traza */
int numErrores=0;                   /* Contador del numero de errores        */
/*****************************************************************************/
void yyerror(const char * msg)
/*  Tratamiento de errores.                                                  */
{
  numErrores++;
  fprintf(stdout, "Error at line %d: %s\n", yylineno, msg);
}
/*****************************************************************************/
int main (int argc, char **argv) {
/* Gestiona la linea de comandos e invoca al analizador sintactico-semantico.*/
	int i, n = 0;
	char *nom_fich;

  for (i=0; i<argc; ++i) { 
    if (strcmp(argv[i], "-v")==0) {
			verbosidad = TRUE; n++; 
		}
		if (strcmp(argv[i], "-t")==0) {
			verTDS = TRUE; n++;
		}
  }
  --argc; n++;
  if (argc == n) {
    if ((yyin = fopen (argv[argc], "r")) == NULL)
      fprintf (stderr, "Fichero no valido %s\n", argv[argc]);      
    else {        
      if (verbosidad == TRUE) fprintf(stdout,"%3d.- ", yylineno);
			nom_fich = argv[argc];
      yyparse ();
      if (numErrores == 0)
				vuelcaCodigo(nom_fich);
			else
        fprintf(stdout,"\nNumero de errores:      %d\n", numErrores);
    }   
  }
  else fprintf (stderr, "Uso: cmc [-v] [-t] fichero\n");
} 
/*****************************************************************************/
