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

	int i;
	i=0;

	for(;i<5;) {
		print(i);
		i++;
	}

	i=111;

	do {
		print(i);
		i--;
  } while(i!=100);

	if(false == not 1)
		print(100000);
	else
		print(55555);

  print(a=4);   print(a++); 
  print(--a); print(a);

  print(suma(a,b=3));
  return 0;
} 
