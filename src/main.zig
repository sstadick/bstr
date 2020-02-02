/// Some useful string related functions, ported from golang
const std = @import("std");
const testing = std.testing;

// TODO: probably a simd version of this to make as well
pub fn bstrEq(s1: []const u8, s2: []const u8) bool {
    if (s1.len != s2.len) {
        return false;
    }
    for (s1) |c1, i| {
        if (c1 != s2[i]) {
            return false;
        }
    }
    return true;
}

//TODO: make this simd aware
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
        if ((haystack[i + 1] == c1) and bstrEq(haystack[i .. i + n], needle)) {
            return i;
        }
        // fails += 1
        i += 1;
        // TODO: switch from IndexByte when fails hits a threhsold
    }
    return null;
}

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

// const warn = @import("std").debug.warn;
test "basic Index functinoality" {
    testing.expect(index("The dog ran away.", "dog").? == 4);
    testing.expect(index("The dog ran away.", "cat") == null);
}

test "basic add functionality" {
    testing.expect(add(3, 7) == 10);
}
