const std = @import("std");
const mach = @import("libs/mach/build.zig");

// Needs to be able to return an error with mach so, void -> !void
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //from:
    //const exe = b.addExecutable(.{
    //    .name = "myapp",
    //    .root_source_file = .{ .path = "src/main.zig" },
    //    .target = target,
    //    .optimize = optimize,
    //});
    //
    // to:
    const exe = try mach.App.init(b, .{
        .name = "myapp",
        .src = "src/main.zig",
        .target = target,
        .deps = &[_]std.build.ModuleDependency{},
        .optimize = optimize,
    });
    //used to link options if needed
    try exe.link(.{});

    //rest can stay the same
    exe.install();

    const run_cmd = exe.run();

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
