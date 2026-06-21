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
    _ = rand;
    attenuation.* = self.albedo;
    r_scatter.* = r.dir.sub(hr.normal.mulScalar(r.dir.dot(hr.normal) * 2));
    return true;
}

pub fn emit(self: this, color: *Color) bool {
    _ = color;
    _ = self;
    return false;
}

