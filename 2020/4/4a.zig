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

        var j: u64 = 0;
        for (line) |c, i| {
            if (c == ':') {
                if (std.mem.eql(u8, line[j..i], "byr")) { byr = true; }
                if (std.mem.eql(u8, line[j..i], "iyr")) { iyr = true; }
                if (std.mem.eql(u8, line[j..i], "eyr")) { eyr = true; }
                if (std.mem.eql(u8, line[j..i], "hgt")) { hgt = true; }
                if (std.mem.eql(u8, line[j..i], "hcl")) { hcl = true; }
                if (std.mem.eql(u8, line[j..i], "ecl")) { ecl = true; }
                if (std.mem.eql(u8, line[j..i], "pid")) { pid = true; }
            }

            if (c == ' ') {
                j = i + 1;
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
