const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var pos_r1d1: u64 = 0;
    var trees_r1d1: u64 = 0;
    var pos_r3d1: u64 = 0;
    var trees_r3d1: u64 = 0;
    var pos_r5d1: u64 = 0;
    var trees_r5d1: u64 = 0;
    var pos_r7d1: u64 = 0;
    var trees_r7d1: u64 = 0;
    var pos_r1d2: u64 = 0;
    var trees_r1d2: u64 = 0;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (line[pos_r1d1 % line.len] == '#') {
            trees_r1d1 += 1;
        }

        pos_r1d1 += 1;

        if (line[pos_r3d1 % line.len] == '#') {
            trees_r3d1 += 1;
        }

        pos_r3d1 += 3;

        if (line[pos_r5d1 % line.len] == '#') {
            trees_r5d1 += 1;
        }

        pos_r5d1 += 5;

        if (line[pos_r7d1 % line.len] == '#') {
            trees_r7d1 += 1;
        }

        pos_r7d1 += 7;

        if (pos_r1d1 % 2 == 1) {
            if (line[pos_r1d2 % line.len] == '#') {
                trees_r1d2 += 1;
            }

            pos_r1d2 += 1;
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{
        trees_r1d1 * trees_r3d1 * trees_r5d1 * trees_r7d1 * trees_r1d2
    });
}
