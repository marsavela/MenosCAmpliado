// Ejemplo de funciones, variables globales y locales
//----------------------------------------------------
int a[10];

int suma(int x, int y)
{ int a;
  a = x + y;
  return a;
}

int b[10];

int division(int x, int y)
{
  return x/y;
}

int x;
int y;

int main()
{ int i;
  i = 9;
  while (i >= 0) { 
    a[i] = i; b[i] = i; i--;
  }
  read(x); read(y);
  print(division(suma(a[x],b[y]),2));

  return 0;
}
