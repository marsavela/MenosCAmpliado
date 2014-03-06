// Criba de Eratostenes: calcula los numeros primos menores 
// que un cierto numero  1< n < 150.
//---------------------------------------------------------
int a[150];
int max;

int divisor (int d, int n)
{ int divi;

  if (n < d) divi = 0;
  else {
    while (n >= d) n = n - d;
    if (n == 0) divi = 1;
    else divi = 0;
    }

  return divi;
}

int main()
{ int n; int m; int ok;

  read(max); ok = 0;

  while (ok != 1) {
    if (max > 1) 
      if (max < 150) ok = 1; else read(max);
    else read(max);
  }

  n = 2;
  while (n <= max) { a[n] = 1; n = n + 1; }
  n = 3;
  while (n <= max) {
    if (divisor(2, n) == 1) a[n] = 0; 
    else {
      m = 3; 
      while ((m * m) <= n) {
	if (divisor(m, n) == 1) {
	  a[n] = 0; m = n;
	}
	else m = m + 2;
      }
    }
    n = n + 1;
  }

  n = 2;
  while (n <= max) {
    if (a[n] == 1) print(n);
    else {}
    n = n + 1;
  }

  return 0;
}
