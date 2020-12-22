const std = @import("std");

const parseU = std.fmt.parseUnsigned;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var p1 = std.ArrayList(u64).init(allocator);
    var p2 = std.ArrayList(u64).init(allocator);

    const reader = file.reader();

    const f = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (line.len == 0) break;

        const n = try parseU(usize, line, 10);

        try p1.append(n);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    const g = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        const n = try parseU(u64, line, 10);

        try p2.append(n);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    while (p1.items.len > 0 and p2.items.len > 0) {
        var x1 = p1.orderedRemove(0);
        var x2 = p2.orderedRemove(0);

        if (x1 > x2) {
            try p1.append(x1);
            try p1.append(x2);
        } else {
            try p2.append(x2);
            try p2.append(x1);
        }
    }

    var s: u64 = 0;

    if (p1.items.len > 0) {
        std.mem.reverse(u64, p1.items);
        for (p1.items) |p, i| {
            s += (i + 1) * p;
        }
    } else {
        std.mem.reverse(u64, p2.items);
        for (p2.items) |p, i| {
            s += (i + 1) * p;
        }
    }

    std.debug.print("{}\n", .{s});
}
