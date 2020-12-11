const std = @import("std");

const G: u64 = 127; // TODO: Change to correct num

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var data = std.ArrayList([]u8).init(allocator);

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        try data.append(line);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var n = std.ArrayList([]u8).init(allocator);

    var first = try allocator.alloc(u8, data.items[0].len + 2);
    try n.append(first);
    std.mem.set(u8, first, '.');

    for (data.items) |line, i| {
        var x = try allocator.alloc(u8, line.len + 2);
        try n.append(x);

        x[0] = '.';
        std.mem.copy(u8, x[1..line.len + 1], line);
        x[x.len - 1] = '.';
    }

    var last = try allocator.alloc(u8, data.items[0].len + 2);
    try n.append(last);
    std.mem.set(u8, first, '.');

    data = n;

    while (true) {
        var next = std.ArrayList([]u8).init(allocator);

        var changed = false;

        for (data.items) |line, i| {
            var x = try allocator.alloc(u8, line.len);
            try next.append(x);

            for (line) |s, j| {
                if (i == 0 or i == data.items.len - 1 or j == 0 or j == line.len - 1) {
                    next.items[i][j] = s;
                    continue;
                }

                const o = @as(u8, @boolToInt(data.items[i - 1][j - 1] == '#')) +
                          @as(u8, @boolToInt(data.items[i - 1][j + 0] == '#')) +
                          @as(u8, @boolToInt(data.items[i - 1][j + 1] == '#')) +
                          @as(u8, @boolToInt(data.items[i - 0][j - 1] == '#')) +
                          @as(u8, @boolToInt(data.items[i - 0][j + 1] == '#')) +
                          @as(u8, @boolToInt(data.items[i + 1][j - 1] == '#')) +
                          @as(u8, @boolToInt(data.items[i + 1][j + 0] == '#')) +
                          @as(u8, @boolToInt(data.items[i + 1][j + 1] == '#'));

                if (s == 'L' and o == 0) {
                    next.items[i][j] = '#';
                    changed = true;
                } else if (s == '#' and o >= 4) {
                    next.items[i][j] = 'L';
                    changed = true;
                } else {
                    next.items[i][j] = s;
                }
            }
        }

        data = next;

        if (!changed) break;
    }

    var occupied: u64 = 0;

    for (data.items) |line, i| {
        for (line) |s, j| {
            if (s == '#') occupied += 1;
        }
    }

    std.debug.print("{}\n", .{occupied});
}
