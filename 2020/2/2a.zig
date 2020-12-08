const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var valid: u64 = 0;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        var i: u64 = 0;
        while (std.ascii.isDigit(line[i])) { i += 1; }

        const from = try std.fmt.parseUnsigned(u64, line[0..i], 10);

        var j: u64 = i + 1;
        while (std.ascii.isDigit(line[j])) { j += 1; }

        const to = try std.fmt.parseUnsigned(u64, line[(i + 1)..j], 10);

        const char = line[j + 1];

        const pwd = line[(j + 4)..];

        var count: u64 = 0;
        for (pwd) |c| {
            if (c == char) { count += 1; }
        }

        if (count >= from and count <= to)  {
            valid += 1;            
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{valid});
}
