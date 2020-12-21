const std = @import("std");

const parseU = std.fmt.parseUnsigned;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var ins = std.ArrayList([]const u8).init(allocator);
    var allergens = std.ArrayList([]const u8).init(allocator);

    var foods = std.ArrayList(std.ArrayList(usize)).init(allocator);
    var alls = std.ArrayList(std.ArrayList(usize)).init(allocator);
    var amap = std.ArrayList(std.ArrayList(usize)).init(allocator);

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        var food = std.ArrayList(usize).init(allocator);

        var iter = std.mem.split(line[0..std.mem.indexOf(u8, line, " (").?], " ");
        while (iter.next()) |x| {
            var i: usize = 0;
            while (i < ins.items.len and !std.mem.eql(u8, x, ins.items[i])) : (i += 1) {}
            if (i == ins.items.len) try ins.append(x);
            try food.append(i);
        }

        try foods.append(food);

        var all = std.ArrayList(usize).init(allocator);

        var iter2 = std.mem.split(line[std.mem.indexOf(u8, line, "(contains ").? + 10..std.mem.indexOf(u8, line, ")").?], ", ");
        while (iter2.next()) |x| {
            var i: usize = 0;
            while (i < allergens.items.len and !std.mem.eql(u8, x, allergens.items[i])) : (i += 1) {}
            if (i == allergens.items.len) {
                try allergens.append(x);
                try amap.append(food);
            }
            try all.append(i);
        }

        try alls.append(all);
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var known = try allocator.alloc(bool, ins.items.len);
    for (known) |*k| { k.* = false; }

    while (true) {
        for (foods.items) |food, i| {
            for (alls.items[i].items) |a| {
                var f2 = std.ArrayList(usize).init(allocator);
                for (amap.items[a].items) |f| {
                    var found = false;
                    for (food.items) |ff| {
                        if (f == ff and !known[f]) try f2.append(f);
                    }
                }
                if (f2.items.len == 1) {
                    known[f2.items[0]] = true;
                }
                amap.items[a] = f2;
            }
        }

        var done = true;
        for (amap.items) |a| {
            if (a.items.len > 0) done = false;
        }

        if (done) break;
    }

    var count: usize = 0;

    for (known) |k, i| {
        if (!k) {
            for (foods.items) |food| {
                if (std.mem.indexOfScalar(usize, food.items, i) != null) count += 1;            
            }
        }
    }

    std.debug.print("{}\n", .{count});
}
