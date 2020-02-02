/// Some useful string related functions, ported from golang
const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const warn = @import("std").debug.warn;

// Lowercase a bstr inplace
pub fn toLowerInplace(input: []u8) void {
    for (input) |c, i| {
        if ('A' <= c and c <= 'Z') {
            const z = c + ('a' - 'A');
            input[i] = z;
        }
    }
}

// Upercase a bstr inplace
pub fn toUpperInplace(input: []u8) void {
    for (input) |c, i| {
        if ('a' <= c and c <= 'z') {
            const z = c - ('a' - 'A');
            input[i] = z;
        }
    }
}

/// Check if haystack contains needle
pub fn contains(haystack: []const u8, needle: []const u8) bool {
    if (index(haystack, needle)) |i| {
        return true;
    }
    return false;
}

// TODO: probably a simd version of this to make as well
// pub fn bstrEql(s1: []const u8, s2: []const u8) bool {
//     return mem.eql(u8, s1, s2);
// }

//TODO: make this simd aware, should really sit down and try this with simd
pub fn indexByte(haystack: []const u8, needle: u8) ?usize {
    for (haystack) |c, i| {
        if (c == needle) {
            return i;
        }
    } else {
        return null;
    }
}

/// Find the index of the first occurance of needle in haystack
/// https://golang.org/src/strings/strings.go , see func Index
pub fn index(haystack: []const u8, needle: []const u8) ?usize {
    const n = needle.len;
    // TODO revisit making this swich statement when non-comptime is allowed
    if (n == 0) {
        return 0;
    } else if (n == 1) {
        return indexByte(haystack, needle[0]);
    } else if (n > haystack.len) {
        return null;
    }
    // Brute force for now, but should drop into somthing more complex
    const c0 = needle[0];
    const c1 = needle[1];
    var i: usize = 0;
    const t = haystack.len - n + 1;
    //var fails = 0;
    while (i < t) {
        if (haystack[i] != c0) {
            const offset = indexByte(haystack[i..t], c0);
            if (offset) |o| {
                i += o;
            } else {
                return null;
            }
        }
        if ((haystack[i + 1] == c1) and mem.eql(u8, haystack[i .. i + n], needle)) { //{bstrEq(haystack[i .. i + n], needle)) {
            return i;
        }
        // fails += 1
        i += 1;
        // TODO: switch from IndexByte when fails hits a threhsold
    }
    return null;
}

/// Trim all trailing whitespace
pub fn chomp(input: []const u8) []const u8 {
    // look for the first ASCII non-space byte from the right
    const in_len = input.len;
    var start = in_len - 1;
    while (start >= 0) {
        const c = input[start];
        const isWhitepace = switch (c) {
            '\t' => true,
            '\n' => true,
            // '\v' => true, // vertical space, not recognized by zig
            // '\f' => true, // form feed, not recognized by zig
            '\r' => true,
            ' ' => true,
            else => false,
        };
        if (!isWhitepace) {
            return input[0 .. start + 1];
        }
        start -= 1;
    }
    return input[0..0];
}

pub const SplitIterator = struct {
    string: []const u8,
    index: ?usize,
    delim: u8,

    /// Returns a slice of the next field, or null if none
    pub fn next(self: *SplitIterator) ?[]const u8 {
        const start = self.index orelse return null;
        const end = if (indexByte(self.string[start..], self.delim)) |delim_idx| blk: {
            self.index = delim_idx + 1 + start;
            break :blk delim_idx + start;
        } else blk: {
            self.index = null;
            break :blk self.string.len;
        };
        return self.string[start..end];
    }
};

pub fn split(string: []const u8, delimiter: u8) SplitIterator {
    return SplitIterator{ .string = string, .index = 0, .delim = delimiter };
}

// const warn = @import("std").debug.warn;
test "basic index functinoality" {
    testing.expect(index("The dog ran away.", "dog").? == 4);
    testing.expect(index("The dog ran away.", "cat") == null);
}

test "basic indexByte functionality" {
    testing.expect(indexByte("The cat slept?", 't').? == 6);
    testing.expect(indexByte("The cat slept?", '@') == null);
}

test "toUpperInplace" {
    var string = "BIG BAD wolf";
    toUpperInplace(string[0..]);
    testing.expect(mem.eql(u8, string, "BIG BAD WOLF"));
}

test "toLowerInplace" {
    var string = "BIG BAD wolf";
    toLowerInplace(string[0..]);
    testing.expect(mem.eql(u8, string, "big bad wolf"));
}

test "chomp whitespace" {
    var string = "This is a gross ending\n\t\t    ";
    var result = chomp(string[0..]);
    testing.expect(mem.eql(u8, result, "This is a gross ending"));

    var niceString = "This is a nice string.";
    testing.expect(mem.eql(u8, niceString, chomp(niceString[0..])));
}

test "split iterator" {
    const eql = mem.eql;
    var it = split("abc|def||ghi", '|');
    testing.expect(eql(u8, it.next().?, "abc"));
    testing.expect(eql(u8, it.next().?, "def"));
    testing.expect(eql(u8, it.next().?, ""));
    testing.expect(eql(u8, it.next().?, "ghi"));
    testing.expect(it.next() == null);

    it = split("", '|');
    testing.expect(eql(u8, it.next().?, ""));
    testing.expect(it.next() == null);

    it = split("|", '|');
    testing.expect(eql(u8, it.next().?, ""));
    testing.expect(eql(u8, it.next().?, ""));
    testing.expect(it.next() == null);

    it = split("hello", ' ');
    testing.expect(eql(u8, it.next().?, "hello"));
    testing.expect(it.next() == null);
}
