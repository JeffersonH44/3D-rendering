const std = @import("std");
const SDL = @import("sdl2");
const Display = @import("display.zig");
const Vector = @import("vector.zig");

const allocator = std.heap.page_allocator;
const N_POINTS = 9 * 9 * 9;
const fov_factor: f32 = 640;

var cube_points:[N_POINTS]Vector.vec3_t = undefined;
var projected_points:[N_POINTS]Vector.vec2_t = undefined;
var is_running: bool = false;

var camera_position: Vector.vec3_t = .{
    .x = 0,
    .y = 0,
    .z = -5
};

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

    // start loading my array of vectors
    var point_count: usize = 0;
    var x: f32 = -1.0;
    while (x <= 1) : (x += 0.25) {
        var y: f32 = -1.0;
        while (y <= 1) : (y += 0.25) {
            var z: f32 = -1.0;
            while (z <= 1) : (z += 0.25) {
                const new_point: Vector.vec3_t = .{
                    .x = x,
                    .y = y,
                    .z = z
                };
                cube_points[point_count] = new_point;
                point_count += 1;
            }
        }
    }


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

fn project(point: Vector.vec3_t) Vector.vec2_t {
    const projected_point: Vector.vec2_t = .{
        .x = (fov_factor * point.x) / point.z,
        .y = (fov_factor * point.y) / point.z
    };

    return projected_point;
}

fn update() void {
    for (cube_points, 0..) |point, i| {
        // move the points away the camera
        const camera_point: Vector.vec3_t = .{
            .x = point.x,
            .y = point.y,
            .z = point.z - camera_position.z
        };
        // point.z -= camera_position.z;

        // project the current point
        const projected_point = project(camera_point);

        // save the projected 2D vector in the array of projected points
        projected_points[i] = projected_point;
    }
}



fn render() void {
    for (projected_points) |projected_point| {
        const casted_x: i32 = @intFromFloat(projected_point.x);
        const casted_y: i32 = @intFromFloat(projected_point.y);
        const translate_x: i32 = @intCast(Display.window_width / 2);
        const translate_y: i32 = @intCast(Display.window_height / 2);
        // std.debug.print("number {d}\n", .{translate_x});
        Display.draw_rect(
            casted_x + translate_x, 
            casted_y + translate_y, 
            4, 
            4, 
            0xFFFFFF00
        );
    }

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