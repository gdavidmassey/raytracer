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

pub fn init() void {
}

pub fn ray_color(r: Ray, world: Hittable) Color {
    
    var ray_col: Color = .init(1.0,0,1.0);
    ray_col = if (world.hit(r, Interval.init(0, std.math.inf(f64)))) |hr| t: {
        const N_ = r.at(hr.t).sub(.init(0,0,-1)).unit_vector();
        const N = hr.normal.lerp(N_,0.35).unit_vector();
        break :t N.rgb();
    } else f: {
        const unit_direction: Vec3 = r.dir.unit_vector();
        const a: f64 = 0.5 * (unit_direction.y() + 1.0);
        break :f Color.init(1,1,1).lerp(.init(0.2,0.7,1.0),a);
    };

    return ray_col;
}

