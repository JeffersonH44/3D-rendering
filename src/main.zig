const std = @import("std");
const SDL = @import("sdl2");
const Display = @import("display.zig");

const allocator = std.heap.page_allocator;

var is_running: bool = false;

fn setup() !void {
    Display.color_buffer = try allocator.alloc(
        u32, 
        Display.window_width * Display.window_height
    );
    Display.color_buffer_texture = SDL.SDL_CreateTexture(
        Display.renderer, 
        SDL.SDL_PIXELFORMAT_ARGB8888, 
        SDL.SDL_TEXTUREACCESS_STREAMING, 
        @intCast(Display.window_width), 
        @intCast(Display.window_height)
    ) orelse Display.sdlPanic();
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
        Display.renderer,
        255, 
        0,
        0, 
        255
    );
    _ = SDL.SDL_RenderClear(Display.renderer);

    // draw_grid();
    Display.draw_pixel(1200, 1200, 0xFFFF0000);
    Display.draw_rect(20, 20, 500, 500, 0xFFFF0000);

    Display.render_color_buffer();
    Display.clear_color_buffer(0xFF000000);

    SDL.SDL_RenderPresent(Display.renderer);
}


pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    is_running = try Display.initialize_window();
    try setup();
    defer Display.destroy_window();

    while (is_running) {
        process_input();
        update();
        render();
    }

}