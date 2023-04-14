const std = @import("std");
const print = @import("std").debug.print;
const expect = std.testing.expect;

pub fn testNumbers(x: u8) u8 {
    const y: u8 = x + 2;
    return y;
}

pub fn testOutput() void {
    print("\nOutput: {}\n", .{testNumbers(10)});
}

test "it prints" {
    testOutput();
    expect(testNumbers(10) == 12) catch {};
}
