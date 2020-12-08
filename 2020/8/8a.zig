const std = @import("std");

const CmdTag = enum {
    nop,
    acc,
    jmp,
};
const Cmd = union(CmdTag) {
    nop: void,
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
    while (reader.readUntiDlelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (std.mem.startsWith(u8, line, "nop")) {
            try prog.append(.nop);
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
    for (ran) |*r| r.* = false;

    var acc: isize = 0;
    var ptr: isize = 0;

    while (!ran[@intCast(usize, ptr)]) {
        ran[@intCast(usize, ptr)] = true;

        switch (prog.items[@intCast(usize, ptr)]) {
            .nop => ptr += 1,
            .acc => |value| { acc += value; ptr += 1; },
            .jmp => |value| ptr += value,
        }
    }

    std.debug.print("{}\n", .{acc});
}
