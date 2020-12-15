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
    var dir: i64 = 90;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        const l = line[0];
        const n = try std.fmt.parseInt(i64, line[1..], 10);

        switch (l) {
            'N' => { y += n; },
            'E' => { x += n; },
            'S' => { y -= n; },
            'W' => { x -= n; },
            'L' => { dir -= n; },
            'R' => { dir += n; },
            'F' => {
                switch (@mod(dir, 360)) {
                    0   => { y += n; },
                    90  => { x += n; },
                    180 => { y -= n; },
                    270 => { x -= n; },
                    else => {}
                }
            },
            else => {}
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{(try std.math.absInt(x)) + try std.math.absInt(y)});
}
