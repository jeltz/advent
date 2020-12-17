
const std = @import("std");

const N = 30;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var dim = try allocator.create([N][N][N][N]bool);

    for (dim) |r, i| {
        for (r) |c, j| {
            for (c) |x, k| {
                for (x) |_, l| {
                    dim[i][j][k][l] = false;
                }
            }
        }
    }

    var ii: usize = 0;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        for (line) |c, j| {
            if (c == '#') dim[ii + N / 2][j + N / 2][N / 2][N / 2] = true;
        }

        ii += 1;
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var gen: usize = 0;
    while (gen < 6) : (gen += 1) {
        var next = try allocator.create([N][N][N][N]bool);

        for (dim) |r, i| {
            for (r) |c, j| {
                for (c) |x, k| {
                    for (x) |_, l| {
                        var val = false;
                        if (i == 0 or i == N - 1 or j == 0 or j == N - 1 or k == 0 or k == N - 1 or l == 0 or l == N - 1) {
                            val = false;
                        } else {
                            var count: usize = 0;
                            for (dim[i - 1..i + 2]) |*rr| {
                                for (rr[j - 1..j + 2]) |*cc| {
                                    for (cc[k - 1..k + 2]) |*xx| {
                                        for (xx[l - 1..l + 2]) |*yy| {
                                            if (yy != &dim[i][j][k][l] and yy.*) count += 1;
                                        }
                                    }
                                }                           
                            }

                            if (dim[i][j][k][l]) {
                                val = count == 2 or count == 3;
                            } else {
                                val = count == 3;
                            }
                        }
                        next[i][j][k][l] = val;
                    }
                }
            }
        }

        dim = next;
    }

    var count: usize = 0;

    for (dim) |r| {
        for (r) |c| {
            for (c) |x| {
                for (x) |y| {
                    if (y) count += 1;
                }
            }
        }
    }

    std.debug.print("{}\n", .{count});
}
