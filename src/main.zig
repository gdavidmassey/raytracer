const std = @import("std");
const Io = std.Io;
const Camera = @import("camera.zig");
const Sphere = @import("sphere.zig");
const Triangle = @import("triangle.zig");
const Cube = @import("cube.zig");
const Color = @import("color.zig").Color;
const Hittable = @import("hittable.zig");
const HittableList = @import("hittableList.zig");

pub fn main(init: std.process.Init) !void {
    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();
    const io = init.io;

    //var prng = std.Random.DefaultPrng.init(1);
    //var rng = prng.random();

    const rng_impl: std.Random.IoSource = .{ .io = io};
    const srand = rng_impl.interface();

    //std.debug.print("{}\n", .{rng.float(f64)});
    std.debug.print("{}\n", .{srand.float(f64)});

    var cam: Camera = .{};
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 3840; //3840;
    cam.samples_per_pixel = 255;
    cam.max_depth = 50;
    cam.init();
    // World
    
    var world: HittableList = .{};
    defer world.deinit(arena);
    const hittable_world: Hittable = .init(HittableList, &world);

    var spheres = [_]Sphere{
        .init(.init(0.1,1,-2), 0.65),
        .init(.init(0,0,-1), 0.5),
        .init(.init(1,0,-2), 0.5),
        .init(.init(1,0,-15), 10.0),
        .init(.init(1,10,-10), 8.0),
        .init(.init(-5,2,-7), 2.0),
        .init(.init(-2,1,-2), 0.1),
        .init(.init(1.4,0.1,-1.4), 0.2),
        .init(.init(0,-250.5,-1), 250),
    };

    var triangles = [_]Triangle{
        //.init(.init(-4,2,-1), .init(1,0,0), .init(-8,2,-8)),
        .init(.init(-7,-2,-1), .init(0,1,-0.5), .init(-8,2,-8)),
        .init(.init(6,-2,-4), .init(0,0,-0.2), .init(3,2,-8)),
        .init(.init(-2,-0.5,-1), .init(-1,-0.25,-0.4), .init(3,-0.1,-0.6)),
    };

    var cubes = [_]Cube{
        .init(.init(-5,3.6,-7), 4.0),
        .init(.init(9.6,4.5,-8.5), 5.5),
        .init(.init(0,0,2), 4.99),
    };

    for (&spheres) |*s| {
        try world.add(arena, .init(Sphere, s));    
    }

    for (&triangles) |*t| {
        try world.add(arena, .init(Triangle, t));    
    }

    for (&cubes) |*t| {
        try world.add(arena, .init(Cube, t));    
    }

    const color_buffer = try arena.alloc(Color,cam.image_height * cam.image_width);
    const thread_buffer = try arena.alloc(std.Thread,8); 
    defer arena.free(color_buffer);
    defer arena.free(thread_buffer);
    try cam.render(io, color_buffer, thread_buffer, hittable_world);
}

