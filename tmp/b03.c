// Ejemplo sintactico-semantico (absurdo. 
// Comprobad el resultado con la funcion "mostraTDS"
//--------------------------------------------------
int a;
int c[27];

int A(int x, int y)
{ 
  int c[27];  int a;

  return y-x;
}

int d[27];
int e;

int main()
{
  int z[27]; int x;

  read(x); read(e);
  if (x < e) print(A(x,e));
  else print(A(e,x));

  return 0;
}
