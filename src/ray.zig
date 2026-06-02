const std = @import("std");
const Vec3 = @import("vec3.zig");
pub const Point3 = Vec3;
const Ray = @This();

    orig: Point3,
    dir: Vec3,

    const this = @This();

    pub fn init(origin: Point3, direction: Vec3) this {
        return .{.orig = origin, .dir = direction};
    }

    pub fn at(self: this, t: f64) Point3 {
        return self.orig.add(self.dir.mulScalar(t));
    }

 
test "ray test" {
    const ray: Ray = .init(.init(0,0,0), .init(1,1,1));
    try std.testing.expectEqual(ray.dir.x(), 1);
    const ray_at: Point3 = ray.at(5);
    try std.testing.expectEqual(ray_at.x(), 5);
}

