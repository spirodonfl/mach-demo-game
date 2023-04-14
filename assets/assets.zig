const std = @import("std");

// Relative to root folder
// Use with std.fs.cwd().openFile(assets.some_file_path)
const root_path = "assets/";
const sprites_path = root_path ++ "sprites/";

const example_spritesheet_image_path = sprites_path ++ "sheet.png";
pub const example_spritesheet_image = @embedFile("sprites/sheet.png");
const example_spritesheet_red_image_path = sprites_path ++ "sheet-red.png";
pub const example_spritesheet_red_image = @embedFile("sprites/sheet-red.png");

pub const example_spritesheet_json_path = sprites_path ++ "sprites.json";

pub const fonts = struct {
    pub const roboto_medium = struct {
        pub const path = root_path ++ "fonts/Roboto-Medium.ttf";
        pub const bytes = @embedFile("fonts/Roboto-Medium.ttf");
    };

    pub const firasans_regular = struct {
        // Font part of Freetype lib
        pub const path = "libs/mach/libs/freetype/upstream/assets/FiraSans-Regular.ttf";
    };
};

pub const shaders = struct {
    pub const imgui = struct {
        pub const path = root_path ++ "shaders/imgui.wgsl";
        pub const bytes = @embedFile("shaders/imgui.wgsl");
    };
};
