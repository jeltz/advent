const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var total: u64 = 0;
    var qs = [_]u64{0} ** 26;
    var group: u64 = 0;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (line.len != 0) {
            group += 1;
            for (line) |c| {
                qs[c - 'a'] += 1;
            }
        } else {
            for (qs) |q| { if (q == group) total += 1; }
            qs = [_]u64{0} ** 26;
            group = 0;
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    for (qs) |q| { if (q == group) total += 1; }

    std.debug.print("{}\n", .{total});
}
