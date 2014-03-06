// Calcula el m.c.d. de dos numeros naturales > 0
// Salida esperada para 42 y 56: 14
//------------------------------------------------
int max(int x, int y)
{ int z;
  if (x < y) z = y;
  else z = x;
  return z;
}

int min(int x, int y)
{ int z;
  if (x < y) z = x;
  else z = y;
  return z;
}

int mcd(int x, int y)
{ int z;
  if (x == y) z = x;
  else z = mcd(min(x,y-x),max(x,y-x));
  return z;
}

int main()
{ int x; int y;

  read(x); read(y);
  if (x < y) print(mcd(x,y));
  else print(mcd(y,x));
  return 0;
}
