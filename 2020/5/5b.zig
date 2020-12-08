const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var seats = [_]bool{false} ** 1024;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        var id: u64 = 0;

        for (line) |c| {
            id <<= 1;
            if (c == 'B' or c == 'R') id |= 1;
        }

        seats[id] = true;
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    for (seats) |s, i| {
        if (!s) std.debug.print("{}\n", .{i});        
    }
}
