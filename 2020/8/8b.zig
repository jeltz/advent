const std = @import("std");

const CmdTag = enum {
    nop,
    acc,
    jmp,
};
const Cmd = union(CmdTag) {
    nop: isize,
    acc: isize,
    jmp: isize,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var prog = std.ArrayList(Cmd).init(allocator);

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (std.mem.startsWith(u8, line, "nop")) {
            try prog.append(.{ .nop = try std.fmt.parseInt(isize, line[4..], 10) });
        }

        if (std.mem.startsWith(u8, line, "acc")) {
            try prog.append(.{ .acc = try std.fmt.parseInt(isize, line[4..], 10) });
        }

        if (std.mem.startsWith(u8, line, "jmp")) {
            try prog.append(.{ .jmp = try std.fmt.parseInt(isize, line[4..], 10) });
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var ran = try allocator.alloc(bool, prog.items.len);
    defer allocator.free(ran);

    for (prog.items) |item, i| {
        if (item == .acc) continue;

        for (ran) |*r| r.* = false;

        var acc: isize = 0;
        var ptr: isize = 0;

        while (ptr >= 0 and ptr < prog.items.len and !ran[@intCast(usize, ptr)]) {
            ran[@intCast(usize, ptr)] = true;

            switch (prog.items[@intCast(usize, ptr)]) {
                .nop => |value| if (ptr == i) { ptr += value; } else { ptr += 1; },
                .acc => |value| { acc += value; ptr += 1; },
                .jmp => |value| if (ptr == i) { ptr += 1; } else { ptr += value; },
            }

            if (ptr == prog.items.len)
                std.debug.print("{}\n", .{acc});
        }
    }
}
