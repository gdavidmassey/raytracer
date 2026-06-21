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
vtable: *const MaterialVTable,

pub const MaterialVTable = struct {
    scatter: *const fn(*anyopaque, *std.Random, Ray, *HitRecord, *Vec3, *Color) bool,
    albedo: *const fn(*anyopaque) Color,
    emit: *const fn(*anyopaque, *Color) bool,
};

pub fn init(comptime T: type, obj: *T) @This() {
    return .{.obj = obj, .vtable = comptime &makeVTable(T)};
}

pub fn makeVTable(comptime T: type) MaterialVTable {
    return .{
        .scatter = struct {
            fn f(ptr: *anyopaque, rand: *std.Random, r: Ray, hr: *HitRecord, r_scatter: *Vec3, attenuation: *Color) bool {
                const self = @as(*T, @ptrCast(@alignCast(ptr)));
                return self.scatter(rand, r, hr, r_scatter,attenuation);
            }
        }.f,
        .albedo = struct {
            fn f(ptr: *anyopaque) Color {
                const self = @as(*T, @ptrCast(@alignCast(ptr)));
                return self.albedo;
            }
        }.f,
        .emit = struct {
            fn f(ptr: *anyopaque, color: *Color)  bool {
                const self = @as(*T, @ptrCast(@alignCast(ptr)));
                return self.emit(color);
            }
        }.f
    };
}

pub fn scatter(self: *const @This(), rand: *std.Random, r_in: Ray, hr: *HitRecord, r_scatter: *Vec3, attenuation: *Color) bool {
    //hr.material = self;
    return self.vtable.scatter(self.obj, rand, r_in, hr, r_scatter, attenuation);
}

pub fn albedo(self: *const @This()) Color {
    return self.vtable.albedo(self.obj);
}

pub fn emit(self: *const @This(), color: *Color) bool {
    return self.vtable.emit(self.obj, color);
}


