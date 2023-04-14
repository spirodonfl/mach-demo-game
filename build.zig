const std = @import("std");
const mach = @import("libs/mach/build.zig");
const imgui = @import("libs/imgui/build.zig");
const zmath = @import("libs/zmath/build.zig");

// Needs to be able to return an error with mach so, void -> !void
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const options = mach.Options{ .core = .{
        .gpu_dawn_options = .{
            .from_source = b.option(bool, "dawn-from-source", "Build Dawn from source") orelse false,
            .debug = b.option(bool, "dawn-debug", "Use a debug build of Dawn") orelse false,
        },
    } };

    try ensureDependencies(b.allocator);

    const Dependency = enum {
        zmath,
        zigimg,
        model3d,
        imgui,
        assets,

        pub fn moduleDependency(
            dep: @This(),
            b2: *std.Build,
            target2: std.zig.CrossTarget,
            optimize2: std.builtin.OptimizeMode,
        ) std.Build.ModuleDependency {
            if (dep == .zmath) return std.Build.ModuleDependency{
                .name = @tagName(dep),
                .module = zmath.Package.build(b2, .{
                    .options = .{ .enable_cross_platform_determinism = true },
                }).zmath,
            };
            if (dep == .imgui) {
                const imgui_pkg = imgui.Package(.{
                    .gpu_dawn = mach.gpu_dawn,
                }).build(b2, target2, optimize2, .{
                    .options = .{ .backend = .mach },
                }) catch unreachable;
                return std.Build.ModuleDependency{
                    .name = @tagName(dep),
                    .module = imgui_pkg.zgui,
                };
            }
            const path = switch (dep) {
                .zmath => unreachable,
                .zigimg => "libs/zigimg/zigimg.zig",
                .model3d => "libs/mach/libs/model3d/src/main.zig",
                .imgui => "libs/imgui/src/main.zig",
                .assets => "assets/assets.zig",
            };
            return std.Build.ModuleDependency{
                .name = @tagName(dep),
                .module = b2.createModule(.{ .source_file = .{ .path = path } }),
            };
        }
    };

    var deps = std.ArrayList(std.Build.ModuleDependency).init(b.allocator);
    try deps.append(Dependency.moduleDependency(.zmath, b, target, optimize));
    try deps.append(Dependency.moduleDependency(.zigimg, b, target, optimize));
    try deps.append(Dependency.moduleDependency(.imgui, b, target, optimize));
    try deps.append(Dependency.moduleDependency(.assets, b, target, optimize));
    const exe = try mach.App.init(b, .{
        .name = "myapp",
        .src = "src/main.zig",
        .target = target,
        .deps = deps.items,
        .res_dirs = &.{"assets"},
        .optimize = optimize,
    });

    const imgui_pkg = try imgui.Package(.{
        .gpu_dawn = mach.gpu_dawn,
    }).build(b, target, optimize, .{
        .options = .{ .backend = .mach },
    });
    imgui_pkg.link(exe.step);

    //used to link options if needed
    try exe.link(options);

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

pub fn copyFile(src_path: []const u8, dst_path: []const u8) void {
    std.fs.cwd().makePath(std.fs.path.dirname(dst_path).?) catch unreachable;
    std.fs.cwd().copyFile(src_path, std.fs.cwd(), dst_path, .{}) catch unreachable;
}

fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("suffix must be an absolute path");
    return comptime blk: {
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}

fn ensureDependencies(allocator: std.mem.Allocator) !void {
    ensureGit(allocator);
    try ensureSubmodule(allocator, "libs/mach");
    try ensureSubmodule(allocator, "libs/zmath");
    try ensureSubmodule(allocator, "libs/zigimg");
}

fn ensureSubmodule(allocator: std.mem.Allocator, path: []const u8) !void {
    if (std.process.getEnvVarOwned(allocator, "NO_ENSURE_SUBMODULES")) |no_ensure_submodules| {
        defer allocator.free(no_ensure_submodules);
        if (std.mem.eql(u8, no_ensure_submodules, "true")) return;
    } else |_| {}
    var child = std.ChildProcess.init(&.{ "git", "submodule", "update", "--init", path }, allocator);
    child.cwd = sdkPath("/");
    child.stderr = std.io.getStdErr();
    child.stdout = std.io.getStdOut();

    _ = try child.spawnAndWait();
}

fn ensureGit(allocator: std.mem.Allocator) void {
    const result = std.ChildProcess.exec(.{
        .allocator = allocator,
        .argv = &.{ "git", "--version" },
    }) catch { // e.g. FileNotFound
        std.log.err("mach: error: 'git --version' failed. Is git not installed?", .{});
        std.process.exit(1);
    };
    defer {
        allocator.free(result.stderr);
        allocator.free(result.stdout);
    }
    if (result.term.Exited != 0) {
        std.log.err("mach: error: 'git --version' failed. Is git not installed?", .{});
        std.process.exit(1);
    }
}
