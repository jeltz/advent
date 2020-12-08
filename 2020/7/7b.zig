const std = @import("std");

const CE = struct { color: []const u8, num: usize };
const ColorMap = std.StringHashMap(std.ArrayList(CE));

pub fn count(map: *ColorMap, key: []const u8) usize {
    var cn: usize = 1;

    const vals = map.get(key);
    if (vals != null) {
        for (vals.?.items) |c| {
           cn += count(map, c.color) * c.num;
        }    
    }

    return cn;
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
                var num = try std.fmt.parseUnsigned(usize, s[0..std.mem.indexOf(u8, s, " ").?], 10);
                var old = map.getEntry(outer_color);
                if (old == null) {
                    var al = std.ArrayList(CE).init(allocator);
                    try al.append(.{ .color = inner_color, .num = num });
                    try map.put(outer_color, al);
                } else {
                    try old.?.value.append(.{ .color = inner_color, .num = num });
                }
            }
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{count(&map, "shiny gold") - 1});
}
