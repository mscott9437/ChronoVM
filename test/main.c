#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_SIZE 65536
#define _NO_CRT_STDIO_INLINE 1

void main(int argc, char **argv)
{
   //FILE *in = fopen(argv[1], "r");
   FILE *in = fopen("bytes.json", "r");

   //FILE *out = fopen(argv[2], "w");
   FILE *out = fopen("json.class", "w");

   while(1) {
      int ch = fgetc(in);

      if (feof(in) == 1) {
         break;
      }

      fputc(ch, out);
      putchar(ch);
   }

   fclose(in);
   fclose(out);
   return;
}
