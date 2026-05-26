const Vec3 = @import("vec3.zig");
const Point3 = Vec3;

    const this = @This();

    orig: Point3,
    dir: Vec3,

    pub fn init(origin: Point3, direction: Vec3) this {
        return .{.orig = origin, .dir = direction};
    }

    pub fn at(self: this, t: f64) this {
        return self.orig.add(self.dir.mulScalar(t));
    }

    
