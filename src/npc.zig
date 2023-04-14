const std = @import("std");
const print = @import("std").debug.print;
const expect = std.testing.expect;
const Position = @import("position.zig").Position;

const NPC = struct {
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

test "simple NPC movement" {
    var npc = try NPC.init();
    npc.move_up();
    npc.move_up();
    expect(npc.world_position.y == 2) catch {};
    npc.move_down();
    npc.move_down();
    npc.move_down();
    expect(npc.world_position.y == -1) catch {};
    npc.move_right();
    npc.move_right();
    expect(npc.world_position.x == 2) catch {};
    npc.move_left();
    npc.move_left();
    npc.move_left();
    expect(npc.world_position.x == -1) catch {};
}
