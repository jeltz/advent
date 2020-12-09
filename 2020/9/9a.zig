const std = @import("std");

const N: usize = 25;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var data = [_]u64{0} ** 26;
    var i: usize = 0;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        const n = try std.fmt.parseUnsigned(u64, line, 10);

        if (i >= N) {
            var ok = false;

            for (data) |x| {
                for (data) |y| {
                    if (x != y and x + y == n)
                    ok = true;
                }
            }

            if (!ok) {
                std.debug.print("{}\n", .{n});
                break;
            }
        }

        data[i % N] = n;
        i += 1;
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }
}
