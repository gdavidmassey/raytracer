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

pub fn scatter(self: this, rand: *std.Random, r: Ray, hr: *HitRecord) Vec3 {
    _= self;
    _= r;
    return Vec3.random_unit_vector(rand).add(hr.normal);
}

