const std = @import("std");
const print = std.debug.print;

const Server = struct {
   stream_server: std.net.Server,

   pub fn init() !Server {
      const address = std.net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, 3000);
      const server = try std.net.Address.listen(address, .{ .reuse_address = true });

      return Server{.stream_server = server };
   }

   pub fn deinit(self: *Server) void {
      self.stream_server.deinit();
   }

   pub fn accept(self: *Server) !void {
      var in_file = try std.fs.cwd().openFile("bytes.json", .{ });
      defer in_file.close();

      const reader = in_file.reader();

      const conn = try self.stream_server.accept();
      defer conn.stream.close();

      var out_file = try std.fs.cwd().createFile("json.class", .{ });
      defer out_file.close();

      const writer = out_file.writer();

      var dat: [1000]u8 = undefined;
      const len = try conn.stream.read(dat[0..]);

      var buf: [1000]u8 = undefined;

      var pos: usize = 0;
      while (true) : (pos += 1){
         buf[pos] = reader.readByte() catch {
            _ = try conn.stream.write(buf[0..pos]);
            _ = try conn.stream.write(dat[0..len]);
            print("{s}//EOF\n", .{ dat[0..len] });
            break;
         };

         _ = try writer.writeByte(buf[pos]);
         print("{c}", .{ buf[pos] });
      }
   }
};

pub fn main() !void {
   var server = try Server.init();
   defer server.deinit();

   print("localhost:{d}\n", .{ 3000 });

   while (true) {
      try server.accept();
   }
}
