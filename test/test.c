#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_SIZE 65536
#define _NO_CRT_STDIO_INLINE 1

void main(int argc, char **argv)
{
   char in_array[] = { '"', 'v', 'a', 'l', 'u', 'e', '"', '\0' };

   for (int i = 0; i < sizeof(in_array); i++)
   {
      putchar(in_array[i]);
   }

   char *in_literal = "\"value\"";

   for (int i = 0; i < sizeof(in_literal); i++)
   {
      putchar(in_literal[i]);
   }

   return;
}
