const std = @import("std");
const Vec3 = @import("vec3.zig");
const Point3 = Vec3;
const Ray = @import("ray.zig");
const Interval = @import("interval.zig");
const Hittable = @import("hittable.zig");
const HitRecord = @import("hittable.zig").HitRecord;
const Color = @import("color.zig").Color;

obj: *anyopaque,
scatterFn: *const fn(*anyopaque, *std.Random, Ray, *HitRecord) Vec3,
albedoFn: *const fn(*anyopaque) Color,

pub fn init(comptime T: type, obj: *T) @This() {
    return .{.obj = obj, .scatterFn = scatterImp(T), .albedoFn = albedoImp(T)};
}

fn scatterImp(comptime T: type) *const fn (*anyopaque, *std.Random, Ray, *HitRecord) Vec3 {
    return struct {
        fn f(ptr: *anyopaque, rand: *std.Random, r_in: Ray, hr: *HitRecord) Vec3 {
            const self = @as(*T, @ptrCast(@alignCast(ptr)));
            return self.scatter(rand, r_in, hr);
        }
    }.f;
}

pub fn scatter(self: *const @This(), rand: * std.Random, r_in: Ray, hr: *HitRecord) Vec3 {
    //hr.material = self;
    return self.scatterFn(self.obj, rand, r_in, hr);
}


pub fn albedoImp(comptime T: type) *const fn (*anyopaque) Color {
    return struct {
        fn f(ptr: *anyopaque) Color {
            const self = @as(*T, @ptrCast(@alignCast(ptr)));
            return self.albedo;
        }
    }.f;
}

pub fn albedo(self: *const @This()) Color {
    return self.albedoFn(self.obj);
}

