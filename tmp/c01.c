// Expresion aritmetica con vectores: (3*n)^2 para n = 0..9
// Salida esperada:  729, 576, 441, 324, 225, 144, 81, 36, 9, 0.
//-------------------------------------------------------------- 
int cuadrado(int x)
{
  return x*x;
} 

int doble(int x)
{
  return x+x;
}

int triple(int x)
{
  return x+doble(x);
}

int main()
{ int i;
  int a[10];

  i = 9;
  while (i >= 0){ 
    a[i] = cuadrado(triple(i));
    print(a[i]);
    i--;
  }

  return 0;
}
