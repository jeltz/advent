const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var total: u64 = 0;
    var qs = [_]bool{false} ** 26;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        for (line) |c| {
            qs[c - 'a'] = true;
        }

        if (line.len == 0) {
            for (qs) |q| { if (q) total += 1; }
            qs = [_]bool{false} ** 26;
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    for (qs) |q| { if (q) total += 1; }

    std.debug.print("{}\n", .{total});
}
