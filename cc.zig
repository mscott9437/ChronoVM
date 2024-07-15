const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
   while (true) {
      const stdin = std.io.getStdIn();
      const address = std.net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, 3000);

      var buf: [1000]u8 = undefined;
      var len = try stdin.read(buf[0..]);

      const conn = try std.net.tcpConnectToAddress(address);
      defer conn.close();

      _ = try conn.write(buf[0..len]);

      len = try conn.read(buf[0..]);
      print("{s}//EOF\n", .{ buf[ 0..len ] });
   }
}
