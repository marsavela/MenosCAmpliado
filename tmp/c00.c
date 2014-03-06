// Ejemplo operadores de incremento y expresiones de asignación
// Salida esperada:  4, 4, 4, 4, 7.
//-------------------------------------------------------------
int a;
 
int suma(int x, int y) 
{ 
  return x+y;
}

int main ()
{ int b; 
  
  print(a=4);   print(a++); 
  print(--a); print(a);

  print(suma(a,b=3));
  return 0;
} 
