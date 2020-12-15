const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var mask_set: u64 = 0;
    var mask_clr: u64 = 0;

    var map = std.AutoHashMap(u64, u64).init(allocator);

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        const l = line[0];

        if (line[1] == 'a') {
            mask_set = 0;
            mask_clr = 0;

            for (line[7..]) |c, i| {
                if (c == '0') mask_clr |= @as(u64, 1) << (35 - @intCast(u6, i));
                if (c == '1') mask_set |= @as(u64, 1) << (35 - @intCast(u6, i));
            }
        }

        if (line[1] == 'e') {
            const ind = try std.fmt.parseUnsigned(u64, line[4..std.mem.indexOf(u8, line, "]").?], 10);
            const val = try std.fmt.parseUnsigned(u64, line[std.mem.indexOf(u8, line, " = ").? + 3..], 10);

            try map.put(ind, val & ~mask_clr | mask_set);
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var count: u64 = 0;

    var it = map.iterator();
    while (it.next()) |kv| {
        count += kv.value;
    }

    std.debug.print("{}\n", .{count});
}
