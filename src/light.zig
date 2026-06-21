const std = @import("std");
const Color = @import("color.zig").Color;
const Ray = @import("ray.zig");
const Vec3 = @import("vec3.zig");
const HitRecord = @import("hittable.zig").HitRecord;
const this = @This();

albedo: Color,

pub fn init(albedo: Color) this {
    return .{.albedo = albedo};
}

pub fn scatter(self: this, rand: *std.Random, r: Ray, hr: *HitRecord, r_scatter: *Vec3, attenuation: *Color) bool {
    _= self;
    _= rand;
    _= r;
    _= hr;
    _= r_scatter;
    _= attenuation;
    return false;
}

pub fn emit(self: this, color: *Color) bool {
    color.* = self.albedo;
    return true;
}


