const c = @cImport({
   @cInclude("stdlib.h");
   @cInclude("stdio.h");
   @cInclude("string.h");
   @cInclude("stdarg.h");

   @cDefine("MAX_SIZE", "65536");
   @cDefine("_NO_CRT_STDIO_INLINE", "1");
});

const std = @import("std");

pub fn main() void {
   //const args = try std.process.argsAlloc(std.heap.page_allocator);
   //defer std.process.argsFree(std.heap.page_allocator, args);

   //const in = c.fopen(args[1], "r");
   //const out = c.fopen(args[2], "w");

   const in = c.fopen("bytes.json", "r");
   const out = c.fopen("json.class", "w");

   while(true) {
      const ch = c.fgetc(in);

      if (c.feof(in) == 1) {
         _ = c.fclose(in);
         _ = c.fclose(out);
         return;
      }
      _ = c.fputc(ch, out);
      _ = c.printf("%c", ch);
   }
}

test {
   //const in = "\"value\"";
}
