const std = @import("std");
const Io = std.Io;
const Camera = @import("camera.zig");
const Sphere = @import("sphere.zig");
const Hittable = @import("hittable.zig");
const HittableList = @import("hittableList.zig");

pub fn main(init: std.process.Init) !void {
    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();
    const io = init.io;

    var prng = std.Random.DefaultPrng.init(1);
    const rng = prng.random();

    const rng_impl: std.Random.IoSource = .{ .io = io};
    const srand = rng_impl.interface();



    std.debug.print("{}\n", .{rng.float(f64)});
    std.debug.print("{}\n", .{srand.float(f64)});

    var cam: Camera = .{};
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 1024;
    cam.init();
    // World
    
    var world: HittableList = .{};
    defer world.deinit(arena);
    const hittable_world: Hittable = .init(HittableList, &world);

    var spheres = [_]Sphere{
        .init(.init(0.1,1,-2), 0.65),
        .init(.init(0,0,-3), 0.5),
        .init(.init(1,0,-2), 0.5),
        .init(.init(1,0,-15), 10.0),
        .init(.init(1,10,-10), 8.0),
        .init(.init(-5,2,-7), 2.0),
        .init(.init(-2,1,-2), 0.1),
        .init(.init(2.5,1,-3), 0.1),
        .init(.init(0,-100.5,-1), 100),
    };

    for (&spheres) |*s| {
        try world.add(arena, .init(Sphere, s));    
    }

    try cam.render(io, rng, hittable_world);
}

