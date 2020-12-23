const std = @import("std");

const parseU = std.fmt.parseUnsigned;

const M: usize = 1000000;
const N: usize = 10000000;

const Foo = struct {
    next: usize,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    const reader = file.reader();

    var cc = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    var data = try allocator.alloc(Foo, M);

    for (cc) |_, i| {
        const x = std.mem.indexOfScalar(u8, cc, @intCast(u8, i) + '1').? + 1;

        if (x == cc.len) {
            data[i].next = cc.len;
        } else {
            data[i].next = cc[x] - '1';
        }
    }

    var ii: usize = cc.len;
    while (ii < M) : (ii += 1) {
        data[ii].next = ii + 1;
    }

    var cur: usize = cc[0] - '1';

    data[M - 1].next = cur;

    var r: usize = 0;
    while (r < N) : (r += 1) {
        const x1 = data[cur].next;
        const x2 = data[x1].next;
        const x3 = data[x2].next;

        var dest = (cur + M - 1) % M;

        while (dest == x1 or dest == x2 or dest == x3) dest = (dest + M - 1) % M;

        data[cur].next = data[x3].next;
        data[x3].next = data[dest].next;
        data[dest].next = x1;

        cur = data[cur].next;
    }

    std.debug.print("{}\n", .{(data[0].next + 1) * (data[data[0].next].next + 1)});
}
