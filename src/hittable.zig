const std = @import("std");
const Vec3 = @import("vec3.zig");
const Point3 = Vec3;
const Ray = @import("ray.zig");
const Color = @import("color.zig").Color;
const Interval = @import("interval.zig");
const Material = @import("material.zig");

pub const HitRecord = struct {
    const this = @This();
    t: f64,
    p: Point3,
    normal: Vec3,
    front_face: bool = undefined,
    material: *const Material = undefined,

    pub fn set_face_normal(self: *this, r: Ray, outward_normal: Vec3) void {
        self.front_face = r.dir.dot(outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.inv();
    }
};

obj: *anyopaque,
hitFn: *const fn(*anyopaque, Ray, Interval) ?HitRecord,

pub fn init(comptime T: type, obj: *T) @This() {
    return .{.obj = obj, .hitFn = hitImp(T)};
}

fn hitImp(comptime T: type) *const fn (*anyopaque, Ray, Interval) ?HitRecord {
    return struct {
        fn f(ptr: *anyopaque, r: Ray, ray_t: Interval) ?HitRecord {
            const self = @as(*T, @ptrCast(@alignCast(ptr)));
            return self.hit(r, ray_t);
        }
    }.f;
}

pub fn hit(self: @This(), r: Ray, ray_t: Interval) ?HitRecord {
    return self.hitFn(self.obj, r, ray_t);
}



