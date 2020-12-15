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

    var nums = std.ArrayList(usize).init(allocator);

    var bs = std.mem.split(line, ",");
    while (bs.next()) |b| {
        const n = try std.fmt.parseUnsigned(usize, b, 10);

        try nums.append(n);
    }

    var i: usize = nums.items.len; 

    while (i < 30000000) : (i += 1) {
        var n: usize = 1;
        while (n <= nums.items.len - 1 and nums.items[nums.items.len - 1 - n] != nums.items[nums.items.len - 1]) n += 1;

        if (n == nums.items.len) n = 0;

        try nums.append(n);   
    }

    std.debug.print("{}\n", .{nums.items[2020 - 1]});
}
