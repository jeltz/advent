const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var data = std.ArrayList(u64).init(allocator);

    var max: u64 = 0;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        const n = try std.fmt.parseUnsigned(u64, line, 10);

        if (n > max) max = n;

        try data.append(n);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    try data.append(max + 3);

    std.sort.sort(u64, data.items, {}, comptime std.sort.asc(u64));

    var jolt: u64 = 0;
    var c1: u64 = 0;
    var c3: u64 = 0;

    for (data.items) |j| {
        if (j - jolt == 1) c1 += 1;
        if (j - jolt == 3) c3 += 1;
        jolt = j;
    }

    std.debug.print("{}\n", .{c1 * c3});
}
