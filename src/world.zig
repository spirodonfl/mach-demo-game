const std = @import("std");
const expect = std.testing.expect;
const Position = @import("position.zig").Position;

const Size = struct {
    x: f32,
    y: f32,
};

pub const World = struct {
    const Self = @This();

    size: Size,
    blocked_positions: [128]Position,

    pub fn init() !Self {
        return Self{ .size = Size{ .x = 32, .y = 32 }, .blocked_positions = undefined };
    }

    pub fn add_blocked_position(self: *Self, index: usize, p: Position) void {
        self.blocked_positions[index] = p;
    }

    pub fn remove_blocked_position(self: *Self, index: usize) void {
        self.blocked_positions[index] = undefined;
    }

    pub fn is_blocked_position(self: *Self, p: Position) bool {
        for (self.blocked_positions) |blocked_position| {
            if (std.meta.eql(blocked_position, p)) {
                return true;
            }
        }

        return false;
    }
};

test "world blocked positions work" {
    var world = try World.init();
    expect(world.blocked_positions.len == 0) catch {};
    var a = Position{ .x = 1, .y = 1 };
    world.add_blocked_position(0, a);
    expect(world.blocked_positions.len == 1) catch {};
    expect(world.is_blocked_position(a) == true) catch {};
    world.remove_blocked_position(0);
    expect(world.blocked_positions.len == 0) catch {};
    expect(world.is_blocked_position(a) == false) catch {};
}