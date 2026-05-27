const Vec3 = @import("vec3.zig");
pub const Point3 = Vec3;

    orig: Point3,
    dir: Vec3,

    const this = @This();

    pub fn init(origin: Point3, direction: Vec3) this {
        return .{.orig = origin, .dir = direction};
    }

    pub fn at(self: this, t: f64) Point3 {
        return self.orig.add(self.dir.mulScalar(t));
    }

    
