const std = @import("std");
const print = @import("std").debug.print;
const expect = std.testing.expect;
const Position = @import("position.zig").Position;
const Vec2 = @import("vec2.zig").Vec2;

pub const NPC = struct {
    const Self = @This();

    world_position: Vec2,
    sprite_index: usize,

    pub fn init() !Self {
        return Self{ .world_position = Vec2{ 0, 0 }, .sprite_index = 0 };
    }

    pub fn move_up(self: *Self) void {
        self.world_position[1] += 32;
    }

    pub fn move_down(self: *Self) void {
        self.world_position[1] -= 32;
    }

    pub fn move_right(self: *Self) void {
        self.world_position[0] += 32;
    }

    pub fn move_left(self: *Self) void {
        self.world_position[0] -= 32;
    }
};

test "simple NPC movement" {
    var npc = try NPC.init();
    npc.move_up();
    npc.move_up();
    expect(npc.world_position[1] == 2) catch {};
    npc.move_down();
    npc.move_down();
    npc.move_down();
    expect(npc.world_position[1] == -1) catch {};
    npc.move_right();
    npc.move_right();
    expect(npc.world_position[0] == 2) catch {};
    npc.move_left();
    npc.move_left();
    npc.move_left();
    expect(npc.world_position[0] == -1) catch {};
}
