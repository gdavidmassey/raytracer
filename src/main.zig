const std = @import("std");
const Vec3 = @import("vec3.zig");
const color = @import("color.zig");
const Color = color.Color;
const Ray = @import("ray.zig");
const Point3 = Vec3;
const Io = std.Io;
const Sphere = @import("sphere.zig");
const Interval = @import("interval.zig");
const hit = @import("hittable.zig").hit;

const raytrace = @import("raytrace");

pub fn hit_sphere(center: Point3, radius: f64, r: Ray) f64 {
    const oc = center.sub(r.orig);
    //const oc = r.orig.sub(center);
    const a = r.dir.length_squared();
    //const b = r.dir.dot(oc) * -2.0;
    const h = r.dir.dot(oc);
    const c = oc.length_squared() - (radius * radius);
    const discriminant = h * h - a * c;

    if (discriminant < 0) {
        return -1.0;
    } else {
        return (h - @sqrt(discriminant)) / a;
    }
}

pub fn ray_color(r: Ray) Color {
    const spheres = [_]Sphere{
        .init(.init(0.1,1,-2), 0.65),
        .init(.init(0,0,-3), 0.5),
        .init(.init(1,0,-2), 0.5),
        .init(.init(0,-100.5,-1), 100),
    };
    
    var hit_anything: bool = false;
    var closest_so_far: f64 = std.math.inf(f64);
    var ray_col: Color = .init(1.0,0,1.0);

    for (spheres) |s| {
        const hit_result = hit(s,r,.init(0,std.math.inf(f64))) orelse continue;
        hit_anything = true;
        const t = hit_result.t;

        if (t > 0.0 and t < closest_so_far) {
            closest_so_far = t;
            const N_ = r.at(t).sub(.init(0,0,-1)).unit_vector();
            const N = hit_result.normal.lerp(N_,0.35).unit_vector();
            // Unit Vector range (-1.0)-1.0
            // Shift unit vector range to 0.0-1.0 and interpret as XYZ-RGB
            //return Color.init(N.x()+1, N.y()+1, N.z()+1).mulScalar(0.5);
            ray_col = N.rgb();
        }
    }

    if (!hit_anything) {
        const unit_direction: Vec3 = r.dir.unit_vector();
        const a: f64 = 0.5 * (unit_direction.y() + 1.0);
        ray_col = Color.init(1,1,1).lerp(.init(0.2,0.7,1.0),a);
    }

    return ray_col;
}

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();

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
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    try raytrace.printAnotherMessage(stdout_writer);

    try stdout_writer.flush(); // Don't forget to flush!
                               //
    // globals
    

    const aspect_ratio: f64 = 16.0 / 9.0;

    const image_width: usize = 1024;

    // Calculate the image height, and esure that it's at least 1.
    var image_height: usize = @intFromFloat(@as(f64,@floatFromInt(image_width)) / aspect_ratio);
    image_height = if (image_height < 1) 1 else image_height;

    // Camera
    // Viewport widths less than one are ok ther are real valued.
    const focal_length: f64 = 1.0;
    const viewport_height: f64 = 2.0;
    const viewport_width = viewport_height * @as(f64,@floatFromInt(image_width)) / @as(f64,@floatFromInt(image_height));
    const camera_center: Point3 = .init(0,0,0);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u: Vec3 = .init(viewport_width, 0,0);
    const viewport_v: Vec3 = .init(0,-viewport_height, 0);

    // Calculate the horizontal and vertical delta vecotrs from pixel to pixel.
    const pixel_delta_u = viewport_u.divScalar(@floatFromInt(image_width));
    const pixel_delta_v = viewport_v.divScalar(@floatFromInt(image_height));

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = camera_center.sub(
        Vec3.init(0,0,focal_length)
        ).sub(
        viewport_u.divScalar(2)
        ).sub(
        viewport_v.divScalar(2)
        );
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).mulScalar(0.5));
    // Render
    var buffer: [1024]u8 = undefined;
    const file = try std.Io.Dir.cwd().createFile(init.io, "./res/test_out.ppm", .{});
    defer file.close(init.io);
    const len = try file.realPath(init.io, &buffer);
    std.debug.print("The test begins\n", .{});
    std.debug.print("{s}\n",.{buffer[0..len]});
    var writer = file.writer(init.io, &buffer);
    const w = &writer.interface;
    defer w.flush() catch {};

    try w.print("P3\n{} {}\n255\n",.{image_width, image_height});


    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {}",.{image_height-j});
        for (0..image_width) |i| {
                
                const pixel_center = pixel00_loc.add(
                    pixel_delta_u.mulScalar(@floatFromInt(i))
                ).add(
                    pixel_delta_v.mulScalar(@floatFromInt(j))
                );
                const ray_direction = pixel_center.sub(camera_center);
                const ray: Ray = .init(camera_center, ray_direction);

                const pixel_color: Color = ray_color(ray);

                try color.write_color(w, &pixel_color);
        }

    }
    std.debug.print("\rDone.                          \n",.{});

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
