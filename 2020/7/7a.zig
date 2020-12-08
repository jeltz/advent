const std = @import("std");

const AllocationError = error {
    OutOfMemory,
};

const ColorMap = std.StringHashMap(std.ArrayList([]const u8));
const ResMap = std.StringHashMap(bool);

pub fn count(res: *ResMap, map: *ColorMap, key: []const u8) AllocationError!void {
    res.*.put(key, true) catch return error.OutOfMemory;

    const vals = map.get(key);
    if (vals != null) {
        for (vals.?.items) |c| {
            try count(res, map, c);
        }    
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var map = ColorMap.init(allocator);
    defer map.deinit();

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        const outer_color = line[0..(std.mem.indexOf(u8, line, " bag").?)];
        const rest = line[(std.mem.indexOf(u8, line, " contain ").? + " contain ".len)..];

        var si = std.mem.split(rest, ", ");

        while (si.next()) |s| {
            const inner_color = s[(std.mem.indexOf(u8, s, " ").? + 1)..(std.mem.indexOf(u8, s, " bag").?)];
            if (!std.mem.eql(u8, inner_color, "other")) {
                var old = map.getEntry(inner_color);
                if (old == null) {
                    var al = std.ArrayList([]const u8).init(allocator);
                    try al.append(outer_color);
                    try map.put(inner_color, al);
                } else {
                    try old.?.value.append(outer_color);
                }
            }
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var res = ResMap.init(allocator);
    defer res.deinit();

    try count(&res, &map, "shiny gold");

    std.debug.print("{}\n", .{res.count() - 1});
}
