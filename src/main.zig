const std = @import("std");
const SDL = @import("sdl2");

var window: *SDL.SDL_Window = undefined;
var renderer: *SDL.SDL_Renderer = undefined;
var is_running: bool = false;

fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, SDL.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}

fn initialize_window()!bool {
    if (SDL.SDL_Init(SDL.SDL_INIT_EVERYTHING) != 0) {
        sdlPanic();
    }
    // defer SDL.SDL_Quit();

    // Create a window
    window = SDL.SDL_CreateWindow(
        null, 
        SDL.SDL_WINDOWPOS_CENTERED, 
        SDL.SDL_WINDOWPOS_CENTERED, 
        800, 
        600, 
        SDL.SDL_WINDOW_BORDERLESS
    ) orelse sdlPanic();
    // defer _ = SDL.SDL_DestroyWindow(window);

    renderer = SDL.SDL_CreateRenderer(
        window, 
        -1, 
        0
    ) orelse sdlPanic();
    // defer _ = SDL.SDL_DestroyRenderer(renderer);
    return true;
}

fn setup() void {
}

fn process_input() void {
    var ev: SDL.SDL_Event = undefined;
    _ = SDL.SDL_PollEvent(&ev);

    switch (ev.type) {
        SDL.SDL_QUIT => is_running = false,
        SDL.SDL_KEYDOWN =>  {
            switch (ev.key.keysym.sym)  {
                SDL.SDLK_ESCAPE => is_running = false,
                else => {},
            }
        }, 
        else => {},
    }
}

fn update() void {
}

fn render() void {
    _ = SDL.SDL_SetRenderDrawColor(
        renderer,
        255, 
        0,
        0, 
        255
    );
    _ = SDL.SDL_RenderClear(renderer);
    SDL.SDL_RenderPresent(renderer);
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    is_running = try initialize_window();
    defer SDL.SDL_Quit();
    defer _ = SDL.SDL_DestroyWindow(window);
    defer _ =  SDL.SDL_DestroyRenderer(renderer);
    setup();

    while (is_running) {
        process_input();
        update();
        render();
    }

}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
