const std = @import("std");

const parseU = std.fmt.parseUnsigned;

const N: usize = 10;

const T = struct { id: usize, dir: usize, flip: bool };

pub fn rotate(comptime S: usize, m: [S][S]u8) [S][S]u8 {
    var new: [S][S]u8 = undefined;

    for (m) |r, i| {
        for (r) |c, j| {
            new[j][S - 1- i] = c;
        }        
    }

    return new;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var ids = std.ArrayList(u64).init(allocator);
    var tiles = std.ArrayList([N][N]u8).init(allocator);

    var i: usize = 0;
    var tile: [N][N]u8 = undefined;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        if (line.len == 0) {
            try tiles.append(tile);
            i = 0;
            continue;
        }

        if (line[0] == 'T') {
            try ids.append(try parseU(u64, line[5..line.len - 1], 10));
        } else {
            for (line) |c, j| {
                tile[i][j] = c;
            }
            i += 1;
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    var nlists = std.ArrayList([4]?T).init(allocator);

    var img: [100][100]u8 = undefined;

    for (img) |*r| {
        for (r) |*c| {
            c.* = '~';
        }
    }

    for (tiles.items) |*t1, ii| {
        var x: usize = 0;
        var n: [4]?T = .{ null, null, null, null };

        while (x < 4): (x += 1) {
            var border1: [N]u8 = undefined;
            if (x == 0) {
                border1 = t1[0];
            } else if (x == 1) {
                for (border1) |_ , j| {
                    border1[j] = t1[N - 1 - j][0];
                }
            } else if (x == 2) {
                for (border1) |_ , j| {
                    border1[j] = t1[N - 1][N - 1 - j];
                }
            } else if (x == 3) {
                for (border1) |_ , j| {
                    border1[j] = t1[j][N - 1];
                }
            }

            q: for (tiles.items) |*t2, jj| {
                if (t1 == t2) continue;

                var y: usize = 0;
                while (y < 4): (y += 1) {
                    var border2: [N]u8 = undefined;
                    if (y == 0) {
                        border2 = t2[0];
                    } else if (y == 1) {
                        for (border2) |_ , j| {
                            border2[j] = t2[N - 1 - j][0];
                        }
                    } else if (y == 2) {
                        for (border2) |_ , j| {
                            border2[j] = t2[N - 1][N - 1 - j];
                        }
                    } else if (y == 3) {
                        for (border2) |_ , j| {
                            border2[j] = t2[j][N - 1];
                        }
                    }

                    if (std.mem.eql(u8, border1[0..], border2[0..])) { n[x] = .{ .id = jj, .dir = y, .flip = true }; break :q; }
                    std.mem.reverse(u8, border2[0..]);
                    if (std.mem.eql(u8, border1[0..], border2[0..])) { n[x] = .{ .id = jj, .dir = y, .flip = false }; break :q; }
                }
            }
        }

        try nlists.append(n);
    }

    var start: usize = 0;

    for (nlists.items) |n, j| {
        var count: usize = 0;
        for (n) |e| {
            if (e != null) count += 1;
        }

        if (count == 2) { start = j; break; }
    }

    const rot: usize = 0;

    while (!(nlists.items[start][0] == null and nlists.items[start][1] == null)) {
        std.mem.rotate(?T, nlists.items[start][0..], 1);
        tiles.items[start] = rotate(N, tiles.items[start]);
    }

    var cury = start;
    var y: usize = 0;
    var x: usize = 0;
    var yflip = false;

    var h: usize = 0;
    while (true) {
        var curx = cury; 
        var xflip = false;
        x = 0;

        while (true) {
            for (tiles.items[curx][1..N - 1]) |r, ii| {
                for (r[1..N - 1]) |c, jj| {
                    if (xflip and yflip and x == 0) {
                        img[y + 7 - ii][x + 7 - jj] = c;
                    } else if (yflip and x == 0) {
                        img[y + ii][x + 7 - jj] = c;
                    } else if (xflip) {
                        img[y + 7 - ii][x + jj] = c;
                    } else {
                        img[y + ii][x + jj] = c;
                    }
                }
            }
            x += N - 2;

            if (nlists.items[curx][3] == null) break;

            const next = nlists.items[curx][3].?;
            curx = next.id;

            var r = next.dir;
            while (r != 1): (r = (r -% 1) % 4) {
                std.mem.rotate(?T, nlists.items[curx][0..], 1);
                tiles.items[curx] = rotate(N, tiles.items[curx]);
            }

            if (next.flip) xflip = !xflip;
        }

        y += N - 2;

        if (nlists.items[cury][2] == null) break;

        const next = nlists.items[cury][2].?;
        cury = next.id;

        var r = next.dir;
        while (r != 0): (r = (r -% 1) % 4) {
            std.mem.rotate(?T, nlists.items[cury][0..], 1);
            tiles.items[cury] = rotate(N, tiles.items[cury]);
        }

        if (next.flip) yflip = !yflip;

        if (yflip) {
            nlists.items[cury][3] = nlists.items[cury][1];
            nlists.items[cury][3].?.flip = !nlists.items[cury][3].?.flip;
        }
    }

    var rr: usize = 0;
    while (rr < 4) : (rr += 1) {
        var img2: [100][100]u8 = undefined;

        for (img) |*r, ii| {
            for (r) |c, jj| {
                img2[ii][jj] = c;
            }
        }

        std.debug.print("{}\n", .{count2(&img2)});

        for (img) |*r, ii| {
            for (r) |c, jj| {
                img2[99 - ii][jj] = c;
            }
        }

        std.debug.print("{}\n", .{count2(&img2)});

        for (img) |*r, ii| {
            for (r) |c, jj| {
                img2[ii][99 - jj] = c;
            }
        }

        std.debug.print("{}\n", .{count2(&img2)});

        for (img) |*r, ii| {
            for (r) |c, jj| {
                img2[99 - ii][99 - jj] = c;
            }
        }

        std.debug.print("{}\n", .{count2(&img2)});

        img = rotate(100, img);
    }
}

fn count2(img: *[100][100]u8) usize {
    const mon: [3][]const u8 = .{
        "                  # ",
        "#    ##    ##    ###",
        " #  #  #  #  #  #   ",
    };

    var c1: usize = 0;
    var c2: usize = 0;

    for (img) |r| { for (r) |c| { if (c == '#') c1 += 1; } }
    for (mon) |r| { for (r) |c| { if (c == '#') c2 += 1; } }

    var count: usize = 0;

    for (img[0..img.len - mon.len + 1]) |r, i| {
        for (r[0..img.len - mon[0].len + 1]) |_, j| {
            var found = true;

            for (mon) |m, x| {
                for (m) |c, y| {
                    if (c == '#' and img[i + x][j + y] != '#') found = false;
                }
            }

            if (found) count += 1;
        }
    }

    return c1 - count * c2;
}
