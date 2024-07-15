const std = @import("std");

const Area = enum {
   query,
   end,
   variable,
   invalid,
   dump,
   quit,
   empty,
   equals,
   value,
};

const State = struct {
   map: []const Area,
   chars: []const []const u8,

   fn init(map: *std.ArrayList(Area), chars: *std.ArrayList([]const u8)) !State {
      return State {
         .map = map.items,
         .chars = chars.items,
      };
   }

   fn exec(self: State, writer: anytype, store: *std.StringHashMap(Value)) !void {
      var query: usize = undefined;
      for (self.map, 0..) |a, i| {
         switch (a) {
            .query => {
               query = i;
               try writer.print("{s}", .{ self.chars[i] });
            },
            .end => {
               try writer.print("{s}", .{ self.chars[i] });
            },
            .variable => {
               try writer.print("{s}", .{ self.chars[i] });
            },
            .invalid => {
               try writer.print("{s}", .{ self.chars[i] });
               //try writer.print("INVALID::{s}", .{ self.chars[i] });
            },
            .dump => {
               try writer.print("{s}", .{ self.chars[i] });
            },
            .quit => {
               try writer.print("{s}", .{ self.chars[i] });
               //return;
            },
            .empty => {
               try writer.print("{s}", .{ self.chars[i] });
            },
            .equals => {
               try writer.print("{s}", .{ self.chars[i] });
            },
            .value => {
               try store.put(self.chars[query], Value{ .string = self.chars[i] });
               try writer.print("{s}", .{ self.chars[i] });
            },
         }
      }
   }
};

const Value = union {
   null: void,
   bool: bool,
   integer: i64,
   float: f64,
   string: []const u8,
   array: std.ArrayList(Value),
   object: std.StringArrayHashMap(Value),
};

test {
   const stdin = std.io.getStdIn();
   var reader = stdin.reader();

   const stdout = std.io.getStdOut();
   var writer = stdout.writer();

   try writer.print("\n~\n", .{ });

   const allocator = std.testing.allocator;

   var bytes = std.ArrayList(u8).init(allocator);
   defer bytes.deinit();

   try bytes.ensureTotalCapacity(1000);

   var map = std.ArrayList(Area).init(allocator);
   defer map.deinit();

   var chars = std.ArrayList([]const u8).init(allocator);
   defer chars.deinit();

   var store = std.StringHashMap(Value).init(allocator);
   defer store.deinit();

   var length: usize = 0;
   try writer.print("> ", .{ });

   while (reader.streamUntilDelimiter(bytes.writer(), '\n', 1000) != error.EndOfStream) {
      if (bytes.items.len > 0 and bytes.items[bytes.items.len - 1] == '\r') {
         bytes.shrinkRetainingCapacity(bytes.items.len - 1);
      }

      try bytes.append('\n');
      try scan(&length, &bytes, &map, &chars);

      if (bytes.items.len - length == 1) {
         var s = try State.init(&map, &chars);
         try s.exec(writer, &store);

         var it = store.iterator();

         while (it.next()) |kv| {
            std.debug.print("{s}:{s}\n", .{ kv.key_ptr.*, kv.value_ptr.*.string });
         }

         bytes.clearRetainingCapacity();
         map.clearRetainingCapacity();
         chars.clearRetainingCapacity();
         store.clearRetainingCapacity();
      }

      length = bytes.items.len;
      try writer.print("> ", .{ });
   }

   try writer.print("//EOF\n", .{ });
}

fn scan(length: *usize, bytes: *std.ArrayList(u8), map: *std.ArrayList(Area), chars: *std.ArrayList([]const u8)) !void {
   var pos: usize = length.*;
   while (pos < bytes.items.len) : (pos += 1) {
      switch (bytes.items[pos]) {
         '\n' => {
            try map.append(.empty);
            try chars.append(bytes.items[pos..pos + 1]);
         },
         '$' => {
            try map.append(.variable);
            try chars.append(bytes.items[pos..pos + 1]);
            pos += 1;
            var start = pos;
            while (pos < bytes.items.len) : (pos += 1) {
               switch (bytes.items[pos]) {
                  '\n' => {
                     try map.append(.end);
                     try chars.append(bytes.items[pos..pos + 1]);
                  },
                  '=' => {
                     try map.append(.query);
                     try chars.append(bytes.items[start..pos]);
                     try map.append(.equals);
                     try chars.append(bytes.items[pos..pos + 1]);
                     pos += 1;
                     start = pos;
                     while (pos < bytes.items.len) : (pos += 1) {
                        switch (bytes.items[pos]) {
                           '\n' => {
                              try map.append(.value);
                              try chars.append(bytes.items[start..pos]);
                              try map.append(.end);
                              try chars.append(bytes.items[pos..pos + 1]);
                           },
                           else => { },
                        }
                     }
                  },
                  else => { },
               }
            }
         },
         else => {
            try map.append(.invalid);
            try chars.append(bytes.items[pos..pos + 1]);
            pos += 1;
            while (pos < bytes.items.len) : (pos += 1) {
               switch (bytes.items[pos]) {
                  '\n' => {
                     try map.append(.quit);
                     try chars.append(bytes.items[pos..pos + 1]);
                  },
                  else => {
                     try map.append(.dump);
                     try chars.append(bytes.items[pos..pos + 1]);
                  },
               }
            }
         },
      }
   }
}
