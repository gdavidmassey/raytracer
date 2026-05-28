const std = @import("std");
const Vec3 = @import("vec3.zig");
const Point3 = Vec3;
const Ray = @import("ray.zig");
const Interval = @import("interval.zig");

pub const HitRecord = struct {
    const this = @This();
    t: f64,
    p: Point3,
    normal: Vec3,
    front_face: bool = undefined,


    pub fn set_face_normal(self: *this, r: Ray, outward_normal: Vec3) void {
        self.front_face = r.dir.dot(outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.inv();
    }
};

pub fn hit(obj: anytype, r: Ray, ray_t: Interval) ?HitRecord {
    return obj.hit(r,ray_t);
}
