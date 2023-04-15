const std = @import("std");

pub fn get_rando(a: i64, b: i64) !i64 {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    return prng.random().intRangeAtMost(i64, a, b);
}
