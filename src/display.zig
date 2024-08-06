const std = @import("std");
const SDL = @import("sdl2");
const Vector = @import("vector.zig");

const allocator = std.heap.page_allocator;

pub var window_width: u32 = undefined;
pub var window_height: u32 = undefined;
pub var color_buffer: []u32 = undefined;

pub var window: *SDL.SDL_Window = undefined;
pub var renderer: *SDL.SDL_Renderer = undefined;
pub var color_buffer_texture: *SDL.SDL_Texture = undefined;


pub fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, SDL.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}

pub fn initialize_window()!bool {
    if (SDL.SDL_Init(SDL.SDL_INIT_EVERYTHING) != 0) {
        sdlPanic();
    }
    // defer SDL.SDL_Quit();

    // Use SDL to query what is the fullscreen max. width and height
    var display_mode: SDL.SDL_DisplayMode = undefined;
    _ = SDL.SDL_GetCurrentDisplayMode(
        0, 
        &display_mode
    );
    
    window_width = @intCast(display_mode.w);
    window_height = @intCast(display_mode.h);

    // Create a window
    window = SDL.SDL_CreateWindow(
        null, 
        SDL.SDL_WINDOWPOS_CENTERED, 
        SDL.SDL_WINDOWPOS_CENTERED, 
        @bitCast(window_width), 
        @bitCast(window_height), 
        SDL.SDL_WINDOW_BORDERLESS
    ) orelse sdlPanic();
    // defer _ = SDL.SDL_DestroyWindow(window);

    renderer = SDL.SDL_CreateRenderer(
        window, 
        -1, 
        0
    ) orelse sdlPanic();
    // defer _ = SDL.SDL_DestroyRenderer(renderer);
    _ = SDL.SDL_SetWindowFullscreen(
        window, 
        SDL.SDL_WINDOW_FULLSCREEN
    );  
    return true;
}

pub fn clear_color_buffer(color: u32) void {
    for (0..(window_width * window_height)) |i| {
        color_buffer[i] = color;
    }
}

pub fn draw_rect(x: i32, y:i32, width:u32, height: u32, color: u32) void {
    const c_height: usize = @intCast(height);
    const c_width: usize = @intCast(width);
    for(0..c_width) |i| {
        for(0..c_height) |j| {
            const cast_i: i32 = @intCast(i);
            const cast_j: i32 = @intCast(j);
            draw_pixel(x + cast_i, y + cast_j, color);
        }
    }
}

pub fn draw_grid() void {
    for (0..window_height) |y| {
        for(0..window_width) |x| {
            if((y % 10 == 0) or (x % 10 == 0)) {
                color_buffer[(window_width * y) +  x] = 0xFFFF0000;
            }
        }
    }
}

pub fn draw_pixel(x: i32, y: i32, color: u32) void {
    if (x >= 0 and y >= 0 and x < window_width and y < window_height) {
        const casted_x: u32 = @intCast(x);
        const casted_y: u32 = @intCast(y);
        color_buffer[(window_width * casted_y) + casted_x] = color;
    }
}


pub fn destroy_window() void  {
    _ = SDL.SDL_DestroyRenderer(renderer);
    _ = SDL.SDL_DestroyWindow(window);
    _ = SDL.SDL_Quit();
    allocator.free(color_buffer);
}

pub fn render_color_buffer() void  {
    const cb_raw_ptr: *u32 = &color_buffer[0];
    const cb_opaque_ptr: ?*const anyopaque = @as(?*const anyopaque, cb_raw_ptr);

    _ = SDL.SDL_UpdateTexture(
        color_buffer_texture,
        null, 
        cb_opaque_ptr, 
        @intCast(window_width * @sizeOf(u32))
    );
    _ = SDL.SDL_RenderCopy(
        renderer, 
        color_buffer_texture, 
        null, 
        null
    );
}