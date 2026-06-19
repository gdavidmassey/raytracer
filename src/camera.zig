const std = @import("std");
const Vec3 = @import("vec3.zig");
const color = @import("color.zig");
const Color = color.Color;
const Ray = @import("ray.zig");
const Point3 = Vec3;
const Io = std.Io;
const Sphere = @import("sphere.zig");
const Interval = @import("interval.zig");
const Hittable = @import("hittable.zig");
const HittableList = @import("hittableList.zig");

aspect_ratio: f64 = 1.0,
image_width: usize = 100,
samples_per_pixel: usize = 10,
max_depth: usize = 10,

image_height: usize = undefined,
pixel_samples_scale: f64 = undefined,
center: Point3 = undefined,
pixel00_loc: Point3 = undefined,
pixel_delta_u: Vec3 = undefined,
pixel_delta_v: Vec3 = undefined,


const this = @This();

pub fn init(self: *@This()) void {
    // Camera
    // Viewport widths less than one are ok ther are real valued.
    self.image_height = @intFromFloat(@as(f64,@floatFromInt(self.image_width)) / self.aspect_ratio);
    self.image_height = if (self.image_height < 1) 1 else self.image_height;
    
    self.pixel_samples_scale = 1.0 / @as(f64,@floatFromInt(self.samples_per_pixel));

    self.center = .init(0,0,0);

    // Determine viewport dimensions.
    const focal_length: f64 = 1.0;
    const viewport_height: f64 = 2.0;
    const viewport_width = viewport_height * @as(f64,@floatFromInt(self.image_width)) / @as(f64,@floatFromInt(self.image_height));
  
    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u: Vec3 = .init(viewport_width, 0,0);
    const viewport_v: Vec3 = .init(0,-viewport_height, 0);

    // Calculate the horizontal and vertical delta vecotrs from pixel to pixel.
    self.pixel_delta_u = viewport_u.divScalar(@floatFromInt(self.image_width));
    self.pixel_delta_v = viewport_v.divScalar(@floatFromInt(self.image_height));

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = self.center.sub(
        Vec3.init(0,0,focal_length)
        ).sub(
        viewport_u.divScalar(2)
        ).sub(
        viewport_v.divScalar(2)
        );
    self.pixel00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).mulScalar(0.5));
}

pub fn ray_color(rand: *std.Random, r: Ray, depth: usize, world: Hittable) Color {
    
    if (depth == 0) return .init(0,0,0);
    var ray_col: Color = .init(1.0,0,1.0);
    ray_col = if (world.hit(r, Interval.init(0.001, std.math.inf(f64)))) |hrc| t: {
        var hr = hrc;
        //const N_ = r.at(hr.t).sub(.init(0,0,-1)).unit_vector();
        //const N = hr.normal.lerp(N_,0.35).unit_vector();
        ////N.e[2] = 1.0;
        //break :t N.rgb();
        //const direction = Vec3.random_unit_vector(rand).add(hr.normal);
        //const direction = r.dir.sub(hr.normal.mulScalar(r.dir.dot(hr.normal) * 2));
        var scatter: Vec3 = undefined;
        var attenuation: Color = undefined;
        _ = hr.material.scatter(rand, r, &hr, &scatter, &attenuation);
        break :t ray_color(rand, .init(hr.p, scatter), depth - 1, world).mulElement(attenuation);
    } else f: {
        const unit_direction: Vec3 = r.dir.unit_vector();
        const a: f64 = 0.5 * (unit_direction.y() + 1.0);
        break :f Color.init(1,1,1).lerp(.init(0.2,0.7,1.0),a);
    };

    return ray_col;
}

fn get_ray(self: this, rand: *std.Random, i: usize, j: usize) Ray {
    // Construct a camera ray originating from the origin and directed at randomly sampled point around the pixel location i,j

    const offset: Vec3 = sample_square(rand);
    const pixel_sample: Point3 = self.pixel00_loc.add(
            self.pixel_delta_u.mulScalar(@as(f64,@floatFromInt(i)) + offset.x())
        ).add(
            self.pixel_delta_v.mulScalar(@as(f64,@floatFromInt(j)) + offset.y())
        );
        
    const ray_origin = self.center;
    const ray_direction = pixel_sample.sub(ray_origin);

    return .init(ray_origin, ray_direction);
}

fn sample_square(rand: *std.Random) Vec3 {
    // Returns the vector to a random point in the [-.5, -.5]-[.5,.5] unit square.
    return .init(rand.float(f64) - 0.5, rand.float(f64) - 0.5, 0);
}

pub fn render(self: this, io: std.Io, color_buffer: []Color, threads: []std.Thread, world: Hittable) !void {
    var buffer: [1024]u8 = undefined;
    const file = try std.Io.Dir.cwd().createFile(io, "./res/test_out.ppm", .{});
    defer file.close(io);
    const len = try file.realPath(io, &buffer);
    std.debug.print("The test begins\n", .{});
    std.debug.print("{s}\n",.{buffer[0..len]});
    var writer = file.writer(io, &buffer);
    const w = &writer.interface;
    defer w.flush() catch {};

    try w.print("P3\n{} {}\n255\n",.{self.image_width, self.image_height});
    
    var next_row: std.atomic.Value(usize) = .init(0);
    for (0..8) |j| {
            threads[j] = try std.Thread.spawn(
                .{}, 
                render_row,
                .{
                    self,
                    color_buffer,
                    &next_row,
                    world
                }
            );
        }
    for (threads) |t| {
            t.join();
    }
    for (color_buffer) |c| try color.write_color(w, c);
    std.debug.print("\rDone.                          \n",.{});
}

pub fn render_row(self: this, buffer: []Color, row: *std.atomic.Value(usize), world: Hittable) !void {
    while (true) {
        const next_row = row.fetchAdd(1, .monotonic);
        if (next_row >= self.image_height) break;
        var prng = std.Random.DefaultPrng.init(next_row);
        var rand = prng.random();
        for (0..self.image_width) |i| {
           var pixel_color: Color = .init(0,0,0);

           for (0..self.samples_per_pixel) |_| {
               const ray: Ray = self.get_ray(&rand, i, next_row);
               pixel_color.addEq(ray_color(&rand, ray, self.max_depth, world));
           }

            buffer[self.image_width * next_row + i] = pixel_color.mulScalar(self.pixel_samples_scale);
        }
        std.debug.print("\rScanlines remaining: {}",.{self.image_height - next_row});
    }
}
