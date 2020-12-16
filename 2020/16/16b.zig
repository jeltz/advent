const std = @import("std");

const Range = struct { lo: u64, hi: u64, lo2: u64, hi2: u64 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var vals = std.ArrayList(Range).init(allocator);
    defer vals.deinit();

    var deps = std.ArrayList(usize).init(allocator);

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (line.len == 0) break;

        if (std.mem.indexOf(u8, line, "departure") != null) try deps.append(vals.items.len);

        const r11 = try std.fmt.parseUnsigned(u64, line[(std.mem.indexOf(u8, line, ": ").? + 2)..(std.mem.indexOf(u8, line, "-").?)], 10);
        const r12 = try std.fmt.parseUnsigned(u64, line[(std.mem.indexOf(u8, line, "-").? + 1)..(std.mem.indexOf(u8, line, " or ").?)], 10);

        const s = line[std.mem.indexOf(u8, line, " or ").? + 4..];
        const r21 = try std.fmt.parseUnsigned(u64, s[0..std.mem.indexOf(u8, s, "-").?], 10);
        const r22 = try std.fmt.parseUnsigned(u64, s[std.mem.indexOf(u8, s, "-").? + 1..], 10);

        try vals.append(.{ .lo = r11, .hi = r12, .lo2 = r21, .hi2 = r22 });
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var tickets = std.ArrayList(std.ArrayList(u64)).init(allocator);
    var our = std.ArrayList(u64).init(allocator);

    const l1 = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    const ourline = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    var obs = std.mem.split(ourline, ",");
    while (obs.next()) |b| {
        const n = try std.fmt.parseUnsigned(u64, b, 10);

        try our.append(n);
    }

    try tickets.append(our);

    const l3 = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    const l4 = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    b: while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        var t = std.ArrayList(u64).init(allocator);

        var bs = std.mem.split(line, ",");
        while (bs.next()) |b| {
            const n = try std.fmt.parseUnsigned(u64, b, 10);

            var found = false;
            for (vals.items) |v| { if (n >= v.lo and n <= v.hi or n >= v.lo2 and n <= v.hi2) found = true; }

            if (!found) continue :b;

            try t.append(n);
        }

        try tickets.append(t);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    const n = vals.items.len;

    var map = std.ArrayList(usize).init(allocator);
    for (vals.items) |_| { try map.append(n); }
    var count: usize = 0;

    while (count < n) {
        b1: for (vals.items) |v, j| {
            if (std.mem.indexOfScalar(usize, map.items, j) != null) continue;

            var ind = n;

            for (our.items) |_, i| {
                if (map.items[i] != n) continue;

                var ok = true;
                for (tickets.items) |t| {
                    if (!(t.items[i] >= v.lo and t.items[i] <= v.hi or t.items[i] >= v.lo2 and t.items[i] <= v.hi2))
                        ok = false;
                }

                if (ok) {
                    if (ind != n) continue :b1;
                    ind = i;
                }
            }

            std.testing.expect(ind != n);

            map.items[ind] = j;
            count += 1;
        }
    }

    var sum: u64 = 1;

    for (our.items) |v, i| { if (std.mem.indexOfScalar(usize, deps.items, map.items[i]) != null)  sum *= v; }

    std.debug.print("{}\n", .{sum});
}
