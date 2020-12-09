const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var valid: u64 = 0;
    var trees: u64 = 0;

    var byr: bool = false;
    var iyr: bool = false;
    var eyr: bool = false;
    var hgt: bool = false;
    var hcl: bool = false;
    var ecl: bool = false;
    var pid: bool = false;

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (line.len == 0) {
            if (byr and iyr and eyr and hgt and hcl and ecl and pid) {
                valid += 1;

            }
            byr = false;
            iyr = false;
            eyr = false;
            hgt = false;
            hcl = false;
            ecl = false;
            pid = false;
        }

        var field: []u8 = undefined;
        var j: u64 = 0;
        for (line) |c, i| {
            if (c == ':') {
                field = line[j..i];
                j = i + 1;
            }

            if (c == ' ') {
                const val = line[j..i];

                if (std.mem.eql(u8, field, "byr")) {
                    const v = std.fmt.parseUnsigned(u64, val, 10) catch 0;
                    if (v >= 1920 and v <= 2002) {
                        byr = true;
                    }
                }
                if (std.mem.eql(u8, field, "iyr")) {
                    const v = std.fmt.parseUnsigned(u64, val, 10) catch 0;
                    if (v >= 2010 and v <= 2020) {
                        iyr = true;
                    }
                }
                if (std.mem.eql(u8, field, "eyr")) {
                    const v = std.fmt.parseUnsigned(u64, val, 10) catch 0;
                    if (v >= 2020 and v <= 2030) {
                        eyr = true;
                    }
                }
                if (std.mem.eql(u8, field, "hgt")) {
                    var k: u64 = 0;
                    while (k < val.len and std.ascii.isDigit(val[k])) { k += 1; }
                    const v = try std.fmt.parseUnsigned(u64, val[0..k], 10);
                    if (std.mem.eql(u8, val[k..], "cm") and v >= 150 and v <= 193) {
                        hgt = true;
                    }
                    if (std.mem.eql(u8, val[k..], "in") and v >= 59 and v <= 76) {
                        hgt = true;
                    }
                }
                if (std.mem.eql(u8, field, "hcl")) {
                    if (
                        val.len == 7 and
                        val[0] == '#' and
                        (val[1] >= '0' and val[1] <= '9' or val[1] >= 'a' and val[1] <= 'f') and
                        (val[2] >= '0' and val[2] <= '9' or val[2] >= 'a' and val[2] <= 'f') and
                        (val[3] >= '0' and val[3] <= '9' or val[3] >= 'a' and val[3] <= 'f') and
                        (val[4] >= '0' and val[4] <= '9' or val[4] >= 'a' and val[4] <= 'f') and
                        (val[5] >= '0' and val[5] <= '9' or val[5] >= 'a' and val[5] <= 'f') and
                        (val[6] >= '0' and val[6] <= '9' or val[6] >= 'a' and val[6] <= 'f')
                    ) {
                        hcl = true;
                    }
                }
                if (std.mem.eql(u8, field, "ecl")) {
                    if (
                        std.mem.eql(u8, val, "amb") or
                        std.mem.eql(u8, val, "blu") or
                        std.mem.eql(u8, val, "brn") or
                        std.mem.eql(u8, val, "gry") or
                        std.mem.eql(u8, val, "grn") or
                        std.mem.eql(u8, val, "hzl") or
                        std.mem.eql(u8, val, "oth")
                    ) {
                        ecl = true;
                    }
                }
                if (std.mem.eql(u8, field, "pid")) {
                    var allnum = true;
                    for (val) |c2| { if (!std.ascii.isDigit(c2)) { allnum = false; } }

                    if (val.len == 9 and allnum) {
                        pid = true;
                    }
                }

                j = i + 1;
            }
        }

        const val = line[j..];

        if (std.mem.eql(u8, field, "byr")) {
            const v = std.fmt.parseUnsigned(u64, val, 10) catch 0;
            if (v >= 1920 and v <= 2002) {
                byr = true;
            }
        }
        if (std.mem.eql(u8, field, "iyr")) {
            const v = std.fmt.parseUnsigned(u64, val, 10) catch 0;
            if (v >= 2010 and v <= 2020) {
                iyr = true;
            }
        }
        if (std.mem.eql(u8, field, "eyr")) {
            const v = std.fmt.parseUnsigned(u64, val, 10) catch 0;
            if (v >= 2020 and v <= 2030) {
                eyr = true;
            }
        }
        if (std.mem.eql(u8, field, "hgt")) {
            var k: u64 = 0;
            while (k < val.len and std.ascii.isDigit(val[k])) { k += 1; }
            const v = try std.fmt.parseUnsigned(u64, val[0..k], 10);
            if (std.mem.eql(u8, val[k..], "cm") and v >= 150 and v <= 193) {
                hgt = true;
            }
            if (std.mem.eql(u8, val[k..], "in") and v >= 59 and v <= 76) {
                hgt = true;
            }
        }
        if (std.mem.eql(u8, field, "hcl")) {
            if (
                val.len == 7 and
                val[0] == '#' and
                (val[1] >= '0' and val[1] <= '9' or val[1] >= 'a' and val[1] <= 'f') and
                (val[2] >= '0' and val[2] <= '9' or val[2] >= 'a' and val[2] <= 'f') and
                (val[3] >= '0' and val[3] <= '9' or val[3] >= 'a' and val[3] <= 'f') and
                (val[4] >= '0' and val[4] <= '9' or val[4] >= 'a' and val[4] <= 'f') and
                (val[5] >= '0' and val[5] <= '9' or val[5] >= 'a' and val[5] <= 'f') and
                (val[6] >= '0' and val[6] <= '9' or val[6] >= 'a' and val[6] <= 'f')
                ) {
                hcl = true;
            }
        }
        if (std.mem.eql(u8, field, "ecl")) {
            if (
                std.mem.eql(u8, val, "amb") or
                std.mem.eql(u8, val, "blu") or
                std.mem.eql(u8, val, "brn") or
                std.mem.eql(u8, val, "gry") or
                std.mem.eql(u8, val, "grn") or
                std.mem.eql(u8, val, "hzl") or
                std.mem.eql(u8, val, "oth")
            ) {
                ecl = true;
            }
        }
        if (std.mem.eql(u8, field, "pid")) {
            var allnum = true;
            for (val) |c2| { if (!std.ascii.isDigit(c2)) { allnum = false; } }

            if (val.len == 9 and allnum) {
                pid = true;
            }
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    if (byr and iyr and eyr and hgt and hcl and ecl and pid) {
        valid += 1;
    }

    std.debug.print("{}\n", .{valid});
}
