const std = @import("std");
const print = @import("std").debug.print;
const expect = std.testing.expect;
const Position = @import("position.zig").Position;

const Player = struct {
    const Self = @This();

    world_position: Position,

    pub fn init() !Self {
        return Self{ .world_position = Position{ .x = 0, .y = 0 } };
    }

    pub fn move_up(self: *Self) void {
        self.world_position.y += 1;
    }

    pub fn move_down(self: *Self) void {
        self.world_position.y -= 1;
    }

    pub fn move_right(self: *Self) void {
        self.world_position.x += 1;
    }

    pub fn move_left(self: *Self) void {
        self.world_position.x -= 1;
    }
};

// pub fn testOutput() void {
//     print("\nOutput: {}\n", .{testNumbers(10)});
// }
// test "it prints" {
//     testOutput();
//     expect(testNumbers(10) == 12) catch {};
// }

test "simple player movement" {
    var player = try Player.init();
    player.move_up();
    player.move_up();
    expect(player.world_position.y == 2) catch {};
    player.move_down();
    player.move_down();
    player.move_down();
    expect(player.world_position.y == -1) catch {};
    player.move_right();
    player.move_right();
    expect(player.world_position.x == 2) catch {};
    player.move_left();
    player.move_left();
    player.move_left();
    expect(player.world_position.x == -1) catch {};
}
