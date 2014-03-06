// Ejemplo sin sentido con 5 errores semanticos simples
//-----------------------------------------------------
int  b[20];
int  a;

int ProgPrincipal()  // el programa debe tener `main'
{ int i;                        
  b = b[2];          // error de tipos en la asignacion
  while (a = 0)  {   // expresion no es de tipo logico
    b[a]=0; a++;
  }    
  a[i] = 1 ;         // la variable no es un array
  a = (a == 2);      // expresion no es de tipo entera
  return 0;  
}           

