const std = @import("std");

const Map = enum {
   invalid,
   dump,
};

pub fn main() !void {
   const args = try std.process.argsAlloc(std.heap.page_allocator);
   defer std.process.argsFree(std.heap.page_allocator, args);

   //const in = try std.fs.cwd().openFile(args[1], .{ });
   const in = try std.fs.cwd().openFile("bytes.json", .{ });
   defer in.close();

   var reader = in.reader();

   //const out = try std.fs.cwd().createFile(args[2], .{ });
   const out = try std.fs.cwd().createFile("json.class", .{ });
   defer out.close();

   var writer = out.writer();

   while (true) {
      const ch = reader.readByte() catch {
         break;
      };

      _ = try writer.writeByte(ch);
      std.debug.print("{c}", .{ ch });
   }

   return;
}

test {
   const in_array = [_:0]u8{ '"', 'v', 'a', 'l', 'u', 'e', '"' };

   for (in_array) |ch| {
      std.debug.print("{c}", .{ ch });
   }

   const in_literal: []const u8 = "\"value\"";

   for (in_literal) |ch| {
      std.debug.print("{c}", .{ ch });
   }

   std.debug.print("\n", .{ });
}
