const std = @import("std");

const G: u64 = 127; // TODO: Change to correct num

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var data = std.ArrayList(u64).init(allocator);

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        const n = try std.fmt.parseUnsigned(u64, line, 10);

        try data.append(n);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    for (data.items) |_, i| {
        var acc: u64 = 0;
        var min: u64 = G;
        var max: u64 = 0;
        var size: usize = 0;

        for (data.items[i..]) |x| {
            acc += x;
            size += 1;

            if (x > max) max = x;
            if (x < min) min = x;

            if (acc == G and size > 1) {
                std.debug.print("{}\n", .{min + max});
            }
        }        
    }
}
