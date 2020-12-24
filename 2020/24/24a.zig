const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var h = std.AutoHashMap([2]isize, bool).init(allocator);

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        var tile = [2]isize{0, 0};

        var i: usize = 0;

        while (i < line.len) {
            if (line[i] == 'n' and line[i + 1] == 'w') {
                tile[0] += 1;
                tile[1] -= tile[0] & 1;
                i += 2;
            } else if (line[i] == 'n' and line[i + 1] == 'e') {
                tile[0] += 1;
                tile[1] += (tile[0] + 1) & 1;
                i += 2;
            } else if (line[i] == 'e') {
                tile[1] += 1;
                i += 1;
            } else if (line[i] == 's' and line[i + 1] == 'e') {
                tile[0] -= 1;
                tile[1] += (tile[0] + 1) & 1;
                i += 2;
            } else if (line[i] == 's' and line[i + 1] == 'w') {
                tile[0] -= 1;
                tile[1] -= tile[0] & 1;
                i += 2;
            } else {
                tile[1] -= 1;
                i += 1;
            }
        }

        if (h.get(tile) != null and h.get(tile).?) {
            try h.put(tile, false);
        } else {
            try h.put(tile, true);
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var count: usize = 0;

    var iter = h.iterator();
    while (iter.next()) |c| {
        if (c.value) count += 1;
    }

    std.debug.print("{}\n", .{count});
}
