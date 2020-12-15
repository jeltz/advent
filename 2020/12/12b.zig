const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var x: i64 = 0;
    var y: i64 = 0;
    var wx: i64 = 10;
    var wy: i64 = 1;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        const l = line[0];
        const n = try std.fmt.parseInt(i64, line[1..], 10);

        switch (l) {
            'N' => { wy += n; },
            'E' => { wx += n; },
            'S' => { wy -= n; },
            'W' => { wx -= n; },
            'L' => {
                switch (@mod(n, 360)) {
                    90  => { const tmp = wx; wx = -wy; wy = tmp; },
                    180 => { wx = -wx; wy = -wy; },
                    270 => { const tmp = wx; wx = wy; wy = -tmp; },
                    else => {}
                }
            },
            'R' => {
                switch (@mod(n, 360)) {
                    90  => { const tmp = wx; wx = wy; wy = -tmp; },
                    180 => { wx = -wx; wy = -wy; },
                    270 => { const tmp = wx; wx = -wy; wy = tmp; },
                    else => {}
                }
            },
            'F' => {
                x += wx * n;
                y += wy * n;
            },
            else => {}
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{(try std.math.absInt(x)) + try std.math.absInt(y)});
}
