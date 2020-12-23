const std = @import("std");

const parseU = std.fmt.parseUnsigned;

const N: usize = 100;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    const reader = file.reader();

    var cc = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    var cups = std.ArrayList(u8).init(allocator);
    try cups.appendSlice(cc);

    var rem = std.ArrayList(u8).init(allocator);

    var cur: usize  = 0;

    var r: usize = 0;
    while (r < N) : (r += 1) {
        try rem.resize(0);
        try rem.appendSlice(cups.items[1..4]);
        const x1 = cups.orderedRemove(1);
        const x2 = cups.orderedRemove(1);
        const x3 = cups.orderedRemove(1);

        var max: usize = 0;
        var dest: usize = 0;

        for (cups.items) |c, i| {
            if (c > cups.items[max]) max = i;
            if (c < cups.items[0] and (c > cups.items[dest] or dest == 0)) dest = i;
        }

        if (dest == 0) dest = max;

        try cups.insertSlice(dest + 1, rem.items);

        std.mem.rotate(u8, cups.items, 1);
    }

    std.mem.rotate(u8, cups.items, std.mem.indexOf(u8, cups.items, "1" ).?);

    std.debug.print("{}\n", .{cups.items[1..]});
}
