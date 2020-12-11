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
    std.mem.set(u8, first, 'L');

    for (data.items) |line, i| {
        var x = try allocator.alloc(u8, line.len + 2);
        try n.append(x);

        x[0] = 'L';
        std.mem.copy(u8, x[1..line.len + 1], line);
        x[x.len - 1] = 'L';
    }

    var last = try allocator.alloc(u8, data.items[0].len + 2);
    try n.append(last);
    std.mem.set(u8, last, 'L');

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

                var o: u64 = 0;

                var ii: u64 = 0;
                var jj: u64 = 0;

                ii = i - 1;
                jj = j - 1;
                while (data.items[ii][jj] == '.') { ii -= 1; jj -= 1; }
                o += @boolToInt(data.items[ii][jj] == '#');

                ii = i - 1;
                jj = j;
                while (data.items[ii][jj] == '.') { ii -= 1; }
                o += @boolToInt(data.items[ii][jj] == '#');

                ii = i - 1;
                jj = j + 1;
                while (data.items[ii][jj] == '.') { ii -= 1; jj += 1; }
                o += @boolToInt(data.items[ii][jj] == '#');

                ii = i;
                jj = j - 1;
                while (data.items[ii][jj] == '.') { jj -= 1; }
                o += @boolToInt(data.items[ii][jj] == '#');

                ii = i;
                jj = j + 1;
                while (data.items[ii][jj] == '.') { jj += 1; }
                o += @boolToInt(data.items[ii][jj] == '#');

                ii = i + 1;
                jj = j - 1;
                while (data.items[ii][jj] == '.') { ii += 1; jj -= 1; }
                o += @boolToInt(data.items[ii][jj] == '#');

                ii = i + 1;
                jj = j;
                while (data.items[ii][jj] == '.') { ii += 1; }
                o += @boolToInt(data.items[ii][jj] == '#');

                ii = i + 1;
                jj = j + 1;
                while (data.items[ii][jj] == '.') { ii += 1; jj += 1; }
                o += @boolToInt(data.items[ii][jj] == '#');

                if (s == 'L' and o == 0) {
                    next.items[i][j] = '#';
                    changed = true;
                } else if (s == '#' and o >= 5) {
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
