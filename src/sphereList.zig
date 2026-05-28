 @import("vec3.zig");
const Point3 = Vec3;
const Ray = @import("ray.zig");
const Interval = @import("interval.zig");
const this = @This();
const HitRecord = @import("hittable.zig").HitRecord;

    center: Point3,
    radius: f64,

    pub fn init(center: Point3, radius: f64) this {
        return .{.center = center, .radius = @max(0,radius)};
    }

    pub fn hit(self: this, r: Ray, ray_t: Interval) ?HitRecord {
        const oc = self.center.sub(r.orig);
        const a = r.dir.length_squared();
        const h = r.dir.dot(oc);
        const c = oc.length_squared() - (self.radius * self.radius);
        const discriminant = h * h - a * c;

        if (discriminant < 0) {
            return null;
        }
        
        const sqrtd: f64 = @sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range.
        var root: f64 = (h - sqrtd) / a;
        if (root <= ray_t.min or ray_t.max <= root) {
            root = (h + sqrtd) / a;
            if (root <= ray_t.min or ray_t.max <= root) {
                return null;
            }
        }

        return .{.t = root, .p = r.at(root), .normal = r.at(root).sub(self.center).divScalar(self.radius)};

    }


