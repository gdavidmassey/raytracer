const std = @import("std");
const Vec3 = @import("vec3.zig");
const Point3 = Vec3;
const Ray = @import("ray.zig");
const Interval = @import("interval.zig");
const HitRecord = @import("hittable.zig").HitRecord;
const this = @This();

v0: Point3,
v1: Point3,
v2: Point3,

pub fn init(v0: Point3, v1: Point3, v2: Point3) this {
    return .{.v0 = v0, .v1 = v1, .v2 = v2};
}

pub fn hit(self: this, r: Ray, ray_t: Interval) ?HitRecord {
    const eps = 1e-8;

    const v0v1 = self.v1.sub(self.v0);
    const v0v2 = self.v2.sub(self.v0);

    const pvec = r.dir.cross(v0v2);
    const det = v0v1.dot(pvec);

    // If det is near zero, ray is parallel to triangle
    if (@abs(det) < eps) return null;

    const invDet = 1.0 / det;

    const tvec = r.orig.sub(self.v0);
    const u = tvec.dot(pvec) * invDet;
    if (u < 0 or u > 1) return null;

    const qvec = tvec.cross(v0v1);
    const v = r.dir.dot(qvec) * invDet;
    if (v < 0 or u + v > 1) return null;

    const t = v0v2.dot(qvec) * invDet;
    if (t <= ray_t.min or t >= ray_t.max) return null;

    const p = r.at(t);
    const normal = v0v1.cross(v0v2).unit_vector();

    var rec = HitRecord{
        .t = t,
        .p = p,
        .normal = normal,
        .front_face = undefined,
    };

    rec.set_face_normal(r, normal);
    return rec;
}

