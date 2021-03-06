const std = @import("std");

const parseU = std.fmt.parseUnsigned;

const R = struct { val: u64, rest: []u8 };

fn f(s: []u8, level: u64) std.fmt.ParseIntError!R {
    var rest = s;
    var val: u64 = 0;

    while (rest.len > 0) {
        if (rest[0] == '(') {
            const x = try f(rest[1..], 0);
            val += x.val;
            rest = x.rest;
        } else if (rest[0] == ')') {
            if (level > 0) break;
            rest = rest[1..];
            break;
        } else if (rest[0] == '+') {
            rest = rest[1..];
        } else if (rest[0] == '*') {
            const x = try f(rest[1..], level + 1);
            val *= x.val;
            rest = x.rest;
        } else if (rest[0] == ' ') {
            rest = rest[1..];
        } else {
            var y = std.mem.indexOfAny(u8, rest, " )") orelse rest.len;

            const x = try parseU(u8, rest[0..y], 10);
            val += x;
            rest = rest[y..];
        }
    }

    return R { .val = val, .rest = rest };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var sum: u64 = 0; 

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        sum += (try f(line, 0)).val;
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{sum});
}
