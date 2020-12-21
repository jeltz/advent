const std = @import("std");

const parseU = std.fmt.parseUnsigned;

const N: usize = 10;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var ids = std.ArrayList(u64).init(allocator);
    var tiles = std.ArrayList([N][N]u8).init(allocator);

    var h = std.StringHashMap(usize).init(allocator);

    var i: usize = 0;
    var tile: [N][N]u8 = undefined;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        if (line.len == 0) {
            try tiles.append(tile);
            i = 0;
            continue;
        }

        if (line[0] == 'T') {
            try ids.append(try parseU(u64, line[5..line.len - 1], 10));
        } else {
            for (line) |c, j| {
                tile[i][j] = c;
            }
            i += 1;
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var mul: u64 = 1;

    for (tiles.items) |*t1, ii| {
        var x: usize = 0;
        var count: usize = 0;

        while (x < 4): (x += 1) {
            var border1: [N]u8 = undefined;
            if (x == 0) {
                border1 = t1[0];
            } else if (x == 1) {
                for (border1) |_ , j| {
                    border1[j] = t1[j][0];
                }
            } else if (x == 2) {
                border1 = t1[N - 1];
            } else if (x == 3) {
                for (border1) |_ , j| {
                    border1[j] = t1[j][N - 1];
                }
            }

            q: for (tiles.items) |*t2| {
                if (t1 == t2) continue;

                var y: usize = 0;
                while (y < 4): (y += 1) {
                    var border2: [N]u8 = undefined;
                    if (y == 0) {
                        border2 = t2[0];
                    } else if (y == 1) {
                        for (border2) |_ , j| {
                            border2[j] = t2[j][0];
                        }
                    } else if (y == 2) {
                        border2 = t2[N - 1];
                    } else if (y == 3) {
                        for (border2) |_ , j| {
                            border2[j] = t2[j][N - 1];
                        }
                    }

                    if (std.mem.eql(u8, border1[0..], border2[0..])) { count += 1; break :q; }
                    std.mem.reverse(u8, border2[0..]);
                    if (std.mem.eql(u8, border1[0..], border2[0..])) { count += 1; break :q; }
                }
            }
        }

        if (count == 2) mul *= ids.items[ii];
    }


    std.debug.print("{}\n", .{mul});
}
