const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    const reader = file.reader();

    const line = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    defer allocator.free(line);

    var nums = std.AutoHashMap(usize, usize).init(allocator);

    var i: usize = 0;
    var last: usize = 0;

    var bs = std.mem.split(line, ",");
    while (bs.next()) |b| {
        const n = try std.fmt.parseUnsigned(usize, b, 10);

        if (i > 0) try nums.put(last, i);
        last = n;
        i += 1;
    }

    while (i < 30000000) : (i += 1) {
        var l = nums.get(last);

        var n: usize = 0;
        if (l != null) n = i - l.?;

        try nums.put(last, i);   
        last = n;
    }

    std.debug.print("{}\n", .{last});
}
