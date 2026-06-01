const std = @import("std");
const Vec3 = @import("vec3.zig");
const Camera = @import("camera.zig");
const color = @import("color.zig");
const Color = color.Color;
const Ray = @import("ray.zig");
const Point3 = Vec3;
const Io = std.Io;
const Sphere = @import("sphere.zig");
const Interval = @import("interval.zig");
const Hittable = @import("hittable.zig");
const HittableList = @import("hittableList.zig");

const raytrace = @import("raytrace");

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();
    //const gpa = init.gpa;

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    // In order to do I/O operations need an `Io` instance.
    const io = init.io;

    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024 * 1024 * 10]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    try raytrace.printAnotherMessage(stdout_writer);

    try stdout_writer.flush(); // Don't forget to flush!
                               //
    // globals
    
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

    try cam.render(io, hittable_world);
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "ray test" {
    const ray: Ray = .init(.init(0,0,0), .init(1,1,1));
    try std.testing.expectEqual(ray.dir.x(), 1);
    const at: Point3 = ray.at(5);
    try std.testing.expectEqual(at.x(), 5);
}

test "fuzz example" {
    try std.testing.fuzz({}, testOne, .{});
}

fn testOne(context: void, smith: *std.testing.Smith) !void {
    _ = context;
    // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!

    const gpa = std.testing.allocator;
    var list: std.ArrayList(u8) = .empty;
    defer list.deinit(gpa);
    while (!smith.eos()) switch (smith.value(enum { add_data, dup_data })) {
        .add_data => {
            const slice = try list.addManyAsSlice(gpa, smith.value(u4));
            smith.bytes(slice);
        },
        .dup_data => {
            if (list.items.len == 0) continue;
            if (list.items.len > std.math.maxInt(u32)) return error.SkipZigTest;
            const len = smith.valueRangeAtMost(u32, 1, @min(32, list.items.len));
            const off = smith.valueRangeAtMost(u32, 0, @intCast(list.items.len - len));
            try list.appendSlice(gpa, list.items[off..][0..len]);
            try std.testing.expectEqualSlices(
                u8,
                list.items[off..][0..len],
                list.items[list.items.len - len ..],
            );
        },
    };
}
