const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var dim: [100][100][100]bool = undefined;

    for (dim) |r, i| {
        for (r) |c, j| {
            for (c) |_, k| {
                dim[i][j][k] = false;
            }
        }
    }

    var ii: usize = 0;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        for (line) |c, j| {
            if (c == '#') dim[ii + 50][j + 50][50] = true;
        }

        ii += 1;
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var gen: usize = 0;
    while (gen < 6) : (gen += 1) {
        var next: [100][100][100]bool = undefined;

        for (dim) |r, i| {
            for (r) |c, j| {
                for (c) |_, k| {
                    var val = false;
                    if (i == 0 or i == 99 or j == 0 or j == 99 or k == 0 or k == 99) {
                        val = false;
                    } else {
                        var count: usize = 0;
                        for (dim[i - 1..i + 2]) |*rr| {
                            for (rr[j - 1..j + 2]) |*cc| {
                                for (cc[k - 1..k + 2]) |*xx| {
                                    if (xx != &dim[i][j][k] and xx.*) count += 1;
                                }
                            }                           
                        }

                        if (dim[i][j][k]) {
                            val = count == 2 or count == 3;
                        } else {
                            val = count == 3;
                        }
                    }
                    next[i][j][k] = val;
                }
            }
        }

        dim = next;
    }

    var count: usize = 0;

    for (dim) |r, i| {
        for (r) |c, j| {
            for (c) |_, k| {
                if (dim[i][j][k]) count += 1;
            }
        }
    }

    std.debug.print("{}\n", .{count});
}
