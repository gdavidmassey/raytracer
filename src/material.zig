const std = @import("std");
const Vec3 = @import("vec3.zig");
const Point3 = Vec3;
const Ray = @import("ray.zig");
const Interval = @import("interval.zig");
const Hittable = @import("hittable.zig");
const Color = @import("color.zig");

obj: *anyopaque,
scatterFn: *const fn(*anyopaque, HitRecord) ?HitRecord,

pub fn init(comptime T: type, obj: *T) @This() {
    return .{.obj = obj, .scatterFn = scatterImp(T)};
}

fn scatterImp(comptime T: type) *const fn (*anyopaque, ) ?HitRecord {
    return struct {
        fn f(ptr: *anyopaque, r_in: Ray, rec: Hittable.HitRecord, attenuation: Color, scattered: Ray) bool {
            const self = @as(*T, @ptrCast(@alignCast(ptr)));
            return self.hit(r_in, rec, attenuation, scattered);
        }
    }.f;
}

pub fn scatter(self: @This(), r_in: Ray, rec: Hittable.HitRecord, attenuation: Color, scattered: Ray ) bool {
    return self.hitFn(self.obj, r_in, rec, attenuation, scattered);
}

