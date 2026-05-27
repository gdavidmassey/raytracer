const std = @import("std");
const Vec3 = @import("vec3.zig");
const Point3 = Vec3;
const Ray = @import("ray.zig");
const Interval = @import("interval.zig");

pub const HitRecord {
    t: f64,
    p: Point3,
    normal: Vec3,
};


pub fn hit(obj: anytype, r: Ray, ray_t: Interval) ?HitRecord {
    return obj.hit(r,ray_t);
}
