const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    const reader = file.reader();

    const l = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    defer allocator.free(l);

    const ts = try std.fmt.parseUnsigned(u64, l, 10);

    var min: u64 = ts;
    var bus: u64 = 0;

    const line = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    defer allocator.free(line);

    var bs = std.mem.split(line, ",");
    while (bs.next()) |b| {
        if (b[0] == 'x') continue;

        const n = try std.fmt.parseUnsigned(u64, b, 10);

        const wait = (ts + n - 1) / n * n - ts;

        if (wait < min) {
            min = wait;
            bus = n;
        }
    }

    std.debug.print("{}\n", .{bus * min});
}
