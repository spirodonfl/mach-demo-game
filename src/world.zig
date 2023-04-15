const std = @import("std");
const expect = std.testing.expect;
const Vec2 = @import("vec2.zig").Vec2;

pub const World = struct {
    const Self = @This();

    size: Vec2,
    blocked_positions: std.ArrayList(Vec2),

    pub fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .size = Vec2{ 32, 32 },
            .blocked_positions = std.ArrayList(Vec2).init(allocator),
        };
    }

    pub fn add_blocked_position(self: *Self, p: Vec2) !void {
        try self.blocked_positions.append(p);
    }

    pub fn remove_blocked_position(self: *Self, index: usize) void {
        self.blocked_positions[index] = undefined;
    }

    pub fn is_blocked_position(self: *Self, p: Vec2) bool {
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
    var a = Vec2{ 1, 1 };
    world.add_blocked_position(a);
    expect(world.blocked_positions.len == 1) catch {};
    expect(world.is_blocked_position(a) == true) catch {};
    world.remove_blocked_position(0);
    expect(world.blocked_positions.len == 0) catch {};
    expect(world.is_blocked_position(a) == false) catch {};
}
