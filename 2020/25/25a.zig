const std = @import("std");

const parseU = std.fmt.parseUnsigned;

const N: usize = 20201227;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    const reader = file.reader();

    var line1 = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    var pub1 = try parseU(u64, line1, 10);

    var line2 = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    var pub2 = try parseU(u64, line2, 10);

    var sn: usize = 7;
    var i: usize = 0;
    var x: usize = 1;

    while (x != pub1) {
        x = x * sn % N;
        i += 1;
    }

    sn = pub2;
    var j: usize = 0;
    x = 1;

    while (j < i) {
        x = x * sn % N;
        j += 1;
    }

    std.debug.print("{}\n", .{x});
}
