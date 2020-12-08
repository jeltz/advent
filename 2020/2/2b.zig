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

        const pos1 = (try std.fmt.parseUnsigned(u64, line[0..i], 10)) - 1;

        var j: u64 = i + 1;
        while (std.ascii.isDigit(line[j])) { j += 1; }

        const pos2 = (try std.fmt.parseUnsigned(u64, line[(i + 1)..j], 10)) - 1;

        const char = line[j + 1];

        const pwd = line[(j + 4)..];

        if (@boolToInt(pos1 < pwd.len and pwd[pos1] == char) ^ @boolToInt(pos2 < pwd.len and pwd[pos2] == char) == 1)  {
            valid += 1;            
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{valid});
}
