const std = @import("std");

const parseU = std.fmt.parseUnsigned;

const M: usize = 1000000;
const N: usize = 10000000;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    const reader = file.reader();

    var cc = try reader.readUntilDelimiterAlloc(allocator, '\n', 10000);

    var data = try allocator.alloc(usize, M);

    for (cc) |_, i| {
        const x = std.mem.indexOfScalar(u8, cc, @intCast(u8, i) + '1').? + 1;

        if (x == cc.len) {
            data[i] = cc.len;
        } else {
            data[i] = cc[x] - '1';
        }
    }

    var ii: usize = cc.len;
    while (ii < M) : (ii += 1) {
        data[ii] = ii + 1;
    }

    var cur: usize = cc[0] - '1';

    data[M - 1] = cur;

    var r: usize = 0;
    while (r < N) : (r += 1) {
        const x1 = data[cur];
        const x2 = data[x1];
        const x3 = data[x2];

        var dest = (cur + M - 1) % M;

        while (dest == x1 or dest == x2 or dest == x3) dest = (dest + M - 1) % M;

        data[cur] = data[x3];
        data[x3] = data[dest];
        data[dest] = x1;

        cur = data[cur];
    }

    std.debug.print("{}\n", .{(data[0] + 1) * (data[data[0]] + 1)});
}
