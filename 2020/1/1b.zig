const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var vals = std.ArrayList(u64).init(allocator);
    defer vals.deinit();

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        const val = try std.fmt.parseUnsigned(u64, line, 10);

        try vals.append(val);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    for (vals.items) |x, i| {
        for (vals.items[(i + 1)..]) |y, j| {
            for (vals.items[(i + j)..]) |z, k| {
                if (x + y + z == 2020) {
                    std.debug.print("{}\n", .{x * y * z});
                }
            }
        }
    }
}
