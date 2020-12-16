const std = @import("std");

const Range = struct { lo: u64, hi: u64 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var vals = std.ArrayList(Range).init(allocator);
    defer vals.deinit();

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (line.len == 0) break;

        const r11 = try std.fmt.parseUnsigned(u64, line[(std.mem.indexOf(u8, line, ": ").? + 2)..(std.mem.indexOf(u8, line, "-").?)], 10);
        const r12 = try std.fmt.parseUnsigned(u64, line[(std.mem.indexOf(u8, line, "-").? + 1)..(std.mem.indexOf(u8, line, " or ").?)], 10);

        try vals.append(.{ .lo = r11, .hi = r12 });

        const s = line[std.mem.indexOf(u8, line, " or ").? + 4..];
        const r21 = try std.fmt.parseUnsigned(u64, s[0..std.mem.indexOf(u8, s, "-").?], 10);
        const r22 = try std.fmt.parseUnsigned(u64, s[std.mem.indexOf(u8, s, "-").? + 1..], 10);

        try vals.append(.{ .lo = r21, .hi = r22 });
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    const l1 = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    const l2 = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    const l3 = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    const l4 = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    var invalid: u64 = 0;

    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        var bs = std.mem.split(line, ",");
        while (bs.next()) |b| {
            const n = try std.fmt.parseUnsigned(usize, b, 10);

            var found = false;
            for (vals.items) |v| { if (n >= v.lo and n <= v.hi) found = true; }

            if (!found) invalid += n;
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{invalid});
}
