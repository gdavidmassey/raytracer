const std = @import("std");
const Vec3 = @import("vec3.zig");
const Point3 = Vec3;
const Ray = @import("ray.zig");
const Interval = @import("interval.zig");
const Hittable = @import("hittable.zig");
const HitRecord = @import("hittable.zig").HitRecord;
const Color = @import("color.zig").Color;
const this = @This();

obj: *anyopaque,
vtable: *const this.MaterialVTable,

pub const MaterialVTable = struct {
    scatterFn: *const fn(*anyopaque, *std.Random, Ray, *HitRecord, *Vec3, *Color) bool,
    albedoFn: *const fn(*anyopaque) Color,
};

pub fn init(comptime T: type, obj: *T) @This() {
    return .{.obj = obj, .scatterFn = scatterImp(T), .albedoFn = albedoImp(T)};
}



fn scatterImp(comptime T: type) *const fn (*anyopaque, *std.Random, Ray, *HitRecord, *Vec3, *Color) bool {
    return struct {
        fn f(ptr: *anyopaque, rand: *std.Random, r_in: Ray, hr: *HitRecord, r_scatter: *Vec3, attenuation: *Color) bool {
            const self = @as(*T, @ptrCast(@alignCast(ptr)));
            return self.scatter(rand, r_in, hr, r_scatter, attenuation);
        }
    }.f;
}

pub fn scatter(self: *const @This(), rand: * std.Random, r_in: Ray, hr: *HitRecord, r_scatter: *Vec3, attenuation: *Color) bool {
    //hr.material = self;
    return self.scatterFn(self.obj, rand, r_in, hr, r_scatter, attenuation);
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

