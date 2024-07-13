const std = @import("std");
const SDL = @import("sdl2");

const allocator = std.heap.page_allocator;
const window_width: u32 = 800;
const window_height: u32 = 600;

var window: *SDL.SDL_Window = undefined;
var renderer: *SDL.SDL_Renderer = undefined;
var color_buffer_texture: *SDL.SDL_Texture  = undefined;

var is_running: bool = false;
var color_buffer: []u32 = undefined;


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
        window_width, 
        window_height, 
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

fn setup() !void {
    color_buffer = try allocator.alloc(u32, window_width * window_height);
    color_buffer_texture = SDL.SDL_CreateTexture(
        renderer, 
        SDL.SDL_PIXELFORMAT_ARGB8888, 
        SDL.SDL_TEXTUREACCESS_STREAMING, 
        window_width, 
        window_height
    ) orelse sdlPanic();
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

fn render_color_buffer() void  {
    const cb_raw_ptr: *u32 = &color_buffer[0];
    const cb_opaque_ptr: ?*const anyopaque = @as(?*const anyopaque, cb_raw_ptr);

    _ = SDL.SDL_UpdateTexture(
        color_buffer_texture,
        null, 
        cb_opaque_ptr, 
        window_width * @sizeOf(u32)
    );
    _ = SDL.SDL_RenderCopy(
        renderer, 
        color_buffer_texture, 
        null, 
        null
    );
}

fn clear_color_buffer(color: u32) void {
    for (0..(window_width * window_height)) |i| {
        color_buffer[i] = color;
    }
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

    render_color_buffer();
    clear_color_buffer(0xFFFFFF00);

    SDL.SDL_RenderPresent(renderer);
}

fn destroy_window() void  {
    _ = SDL.SDL_DestroyRenderer(renderer);
    _ = SDL.SDL_DestroyWindow(window);
    _ = SDL.SDL_Quit();
    allocator.free(color_buffer);
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    is_running = try initialize_window();
    try setup();
    defer destroy_window();

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
