// Ejemplo sin sentido con 5 errores semanticos simples
//-----------------------------------------------------
int A[0];                          // talla inapropiada  
int x;

int B(int x)
{ int x;                      // identificador repetido
  return  A[x];
}

int C(int x, int y)
{
  return B(x,y);      // error en el dominio parametros
}

int main()            
{ int y;

  read(x);
  read(z);                       // objeto no declarado

  if (x < y) print(C(x,y));
  else print(C(y,x));
  return (x==y);           // expresion debe ser entera
}
