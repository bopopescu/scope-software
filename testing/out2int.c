#include <stdio.h>

int main(int argc, char** argv)
{
  unsigned char c[2];
  while(fgets(c, 2, stdin))
  {
    unsigned char b = c[0];
    if(b == 0x0a)
      continue;
    signed char i = (signed char)b;
    float f = i * 3.3 * 1000 / 255;
    float fin = f / 11.02564103;
    //printf("%hhx, %hhi, %fmV, %fmV\n", b, i, f, fin);
    printf("%f\n",fin);
  }
  return 0;
}

