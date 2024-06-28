const std = @import("std");
const SDL = @import("sdl2");

fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, SDL.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}

fn initialize_window()!void {
    if (SDL.SDL_Init(SDL.SDL_INIT_EVERYTHING) != 0) {
        sdlPanic();
    }

    // Create a window
    const window = SDL.SDL_CreateWindow(
        null, 
        SDL.SDL_WINDOWPOS_CENTERED, 
        SDL.SDL_WINDOWPOS_CENTERED, 
        800, 
        600, 
        SDL.SDL_WINDOW_BORDERLESS
    ).?;

    const renderer = SDL.SDL_CreateRenderer(
        window, 
        -1, 
        0).?;

}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    initialize_window();
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
