const std = @import("std");

const parseU = std.fmt.parseUnsigned;

var h2: std.StringHashMap(i64) = undefined;

fn play(p1: *std.ArrayList(u8), p2: *std.ArrayList(u8), allocator: *std.mem.Allocator) std.mem.Allocator.Error!i64 {
    var a = std.ArrayList(u8).init(allocator);
    defer a.deinit();
    try a.appendSlice(p1.items);
    try a.appendSlice(p2.items);
    std.sort.sort(u8, a.items, {}, comptime std.sort.asc(u8));
    var a2 = std.ArrayList(u8).init(allocator);
    defer a2.deinit();
    try a2.appendSlice(a.items);

    var min = std.mem.min(u8, a.items);

    var ii: u8 = 0;
    for (a2.items) |*z| {
        if (z.* + min >= a2.items.len) {
            z.* = @intCast(u8, a2.items.len + ii);
            ii += 1;
        }
    }

    var s2 = std.ArrayList(u8).init(allocator);
    for (p1.items) |z| { try s2.append(a2.items[std.mem.indexOfScalar(u8, a.items, z).?]); }
    try s2.append(255);
    for (p2.items) |z| { try s2.append(a2.items[std.mem.indexOfScalar(u8, a.items, z).?]); }

    var x = h2.get(s2.items);
    if (x != null) {
        return x.?;
    }

    var h = std.StringHashMap(void).init(allocator);
    defer h.deinit(); // Does not free keys

    while (p1.items.len > 0 and p2.items.len > 0) {
        var s = std.ArrayList(u8).init(allocator);
        try s.appendSlice(p1.items);
        try s.append(255);
        try s.appendSlice(p2.items);

        var x1 = p1.orderedRemove(0);
        var x2 = p2.orderedRemove(0);

        if (h.get(s.items) != null) {
            return 1;
        } else if (p1.items.len >= x1 and p2.items.len >= x2) {
            var pp1 = std.ArrayList(u8).init(allocator);
            defer pp1.deinit();
            try pp1.appendSlice(p1.items[0..x1]);
            var pp2 = std.ArrayList(u8).init(allocator);
            defer pp2.deinit();
            try pp2.appendSlice(p2.items[0..x2]);

            if ((try play(&pp1, &pp2, allocator)) > 0) {
                try p1.append(x1);
                try p1.append(x2);
            } else {
                try p2.append(x2);
                try p2.append(x1);
            }
        } else if (x1 > x2){
            try p1.append(x1);
            try p1.append(x2);
        } else {
            try p2.append(x2);
            try p2.append(x1);
        }

        try h.put(s.items, {});
    }

    var s: i64 = 0;

    if (p1.items.len > 0) {
        std.mem.reverse(u8, p1.items);
        for (p1.items) |p, i| {
            s += @intCast(i64, (i + 1) * p);
        }
    } else {
        std.mem.reverse(u8, p2.items);
        for (p2.items) |p, i| {
            s -= @intCast(i64, (i + 1) * p);
        }
    }

    try h2.put(s2.items, s);

    return s;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    h2 = std.StringHashMap(i64).init(allocator);
    var p1 = std.ArrayList(u8).init(allocator);
    var p2 = std.ArrayList(u8).init(allocator);

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    const reader = file.reader();

    const f = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (line.len == 0) break;

        const n = try parseU(u8, line, 10);

        try p1.append(n);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    const g = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        const n = try parseU(u8, line, 10);

        try p2.append(n);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{std.math.absInt(try play(&p1, &p2, allocator))});
}
