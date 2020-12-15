const std = @import("std");

const Rule = struct {
    bus: u64,
    offset: u64,
};

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

    const line = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);
    defer allocator.free(line);

    var rules = std.ArrayList(Rule).init(allocator);

    var i: u64 = 0;

    var bs = std.mem.split(line, ",");
    while (bs.next()) |b| {
        i += 1;

        if (b[0] == 'x') continue;

        const n = try std.fmt.parseUnsigned(u64, b, 10);

        try rules.append(.{ .bus = n, .offset = (n * 100 - (i - 1)) % n });
    }

    const s = (struct {
        fn s(context: void, a: Rule, b: Rule) bool {
            return a.bus > b.bus;
        }
    }).s;

    std.sort.sort(Rule, rules.items, {}, s);

    var x = rules.items[0].offset;
    var step = rules.items[0].bus;

    for (rules.items[1..]) |r| {
        while (x % r.bus != r.offset) x += step;
        step *= r.bus;
    }

    std.debug.print("{}\n", .{x});
}

///*
//x mod 17 == 0
//x mod 13 == 11
//x mod 19 == 16
//
//x * 13 * 19        == 0 mod 17 * 13 * 19
//(x - 11) * 17 * 19 == 0
//(x - 16) * 17 * 13 == 0 
//*/