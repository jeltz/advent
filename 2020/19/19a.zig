const std = @import("std");

const parseU = std.fmt.parseUnsigned;

const R = struct { id: u64, t: u8, c: u8, x: []usize, y: []usize };

var letters: std.ArrayList(u8) = undefined;
var fact: std.ArrayList([2]usize) = undefined;

const Ret = struct { starts: []usize, ends: []usize };

fn nfa_concat(allocator: *std.mem.Allocator, rules: []R, ids: []usize) std.mem.Allocator.Error!Ret {
    var first = try nfa(allocator, rules, ids[0]);
    var last = first;

    for (ids[1..]) |id| {
        var this = try nfa(allocator, rules, id);
        for (last.ends) |e| {
            for (this.starts) |s| {
                try fact.append(.{e, s});
            }
        }
        last = this;
    }

    return Ret { .starts = first.starts, .ends = last.ends };
}

fn nfa(allocator: *std.mem.Allocator, rules: []R, id: usize) std.mem.Allocator.Error!Ret {
    var starts = std.ArrayList(usize).init(allocator);
    var ends = std.ArrayList(usize).init(allocator);

    for (rules) |r| {
        if (r.id == id) {
            if (r.t == 0) {
                try starts.append(letters.items.len);
                try ends.append(letters.items.len);
                try letters.append(r.c);
            } else {
                const left = try nfa_concat(allocator, rules, r.x);

                for (left.starts) |s| try starts.append(s);
                for (left.ends) |e| try ends.append(e);

                if (r.y.len == 0) continue;

                const right = try nfa_concat(allocator, rules, r.y);

                for (right.starts) |s| try starts.append(s);
                for (right.ends) |e| try ends.append(e);
            }
        }
    }

    return Ret { .starts = starts.items, .ends = ends.items };
}

fn match(node: usize, ends: []usize, s: []u8) bool {
    if (s[0] != letters.items[node]) return false;

    if (s.len == 1) {
        for (ends) |e| if (e == node) return true;
        return false;
    }

    for (fact.items) |f| {
        if (f[0] == node) {
            if (match(f[1], ends, s[1..])) return true;
        }
    }

    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{ .read = true });
    defer file.close();

    var rules = std.ArrayList(R).init(allocator);

    letters = std.ArrayList(u8).init(allocator);
    fact = std.ArrayList([2]usize).init(allocator);

    const reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        if (line.len == 0) break;

        const id = try parseU(u64, line[0..std.mem.indexOf(u8, line, ":").?], 10);

        var s = line[std.mem.indexOf(u8, line, ":").? + 2..];

        if (s[0] == '"') {
            try rules.append(.{ .id = id, .c = s[1], .t = 0, .x = undefined, .y = undefined });
        } else {
            var x = std.ArrayList(usize).init(allocator);

            while (s.len > 0 and s[0] != '|') {
                const z = try parseU(usize, s[0..std.mem.indexOf(u8, s, " ") orelse s.len], 10);
                s = s[(std.mem.indexOf(u8, s, " ") orelse s.len - 1) + 1..];
                try x.append(z);
            }

            var y = std.ArrayList(usize).init(allocator);

            if (s.len > 0) s = s[2..];

            while (s.len > 0) {
                const z = try parseU(usize, s[0..std.mem.indexOf(u8, s, " ") orelse s.len], 10);
                s = s[(std.mem.indexOf(u8, s, " ") orelse s.len - 1) + 1..];
                try y.append(z);
            }

            try rules.append(.{ .id = id, .c = 0, .t = 1, .x = x.items, .y = y.items });
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    const x = try nfa(allocator, rules.items, 0);

    var count: u64 = 0;

    while (reader.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
        defer allocator.free(line);

        for (x.starts) |s| {
            if (match(s, x.ends, line)) count += 1;
        }
    } else |err| {
        std.testing.expect(err == error.EndOfStream);
    }

    std.debug.print("{}\n", .{count});
}
