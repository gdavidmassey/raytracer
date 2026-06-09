const std = @import("std");
const Vec3 = @import("vec3.zig");
const Point3 = Vec3;
const Ray = @import("ray.zig");
const Material = @import("material.zig");
const Interval = @import("interval.zig");
const this = @This();
const HitRecord = @import("hittable.zig").HitRecord;

center: Point3,
side: f64,
material: *const Material,

pub fn init(center: Point3, side: f64, material: *const Material) this {
    return .{.center = center, .side = @max(0,side), .material = material};
}

pub fn hit(self: this, r: Ray, ray_t: Interval) ?HitRecord {
    const half = (self.side / 2) * 0.8;
    const min = self.center.sub(Vec3.init(half, half, half));
    const max = self.center.add(Vec3.init(half, half, half));

    var tmin = ray_t.min;
    var tmax = ray_t.max;

    inline for (.{ 0, 1, 2 }) |axis| {
        const invD = 1.0 / r.dir.e[axis];
        var t0 = (min.e[axis] - r.orig.e[axis]) * invD;
        var t1 = (max.e[axis] - r.orig.e[axis]) * invD;

        if (invD < 0) std.mem.swap(f64, &t0, &t1);

        tmin = if (t0 > tmin) t0 else tmin;
        tmax = if (t1 < tmax) t1 else tmax;

        if (tmax <= tmin) return null;
    }

    const t = tmin;
    const p = r.at(t);

    // Compute normal: which face did we hit?
    var normal = Vec3.init(0,0,0);
    const eps = 1e-6;

    if (@abs(p.x() - min.x()) < eps) normal = Vec3.init(-1,0,0)
    else if (@abs(p.x() - max.x()) < eps) normal = Vec3.init(1,0,0)
    else if (@abs(p.y() - min.y()) < eps) normal = Vec3.init(0,-1,0)
    else if (@abs(p.y() - max.y()) < eps) normal = Vec3.init(0,1,0)
    else if (@abs(p.z() - min.z()) < eps) normal = Vec3.init(0,0,-1)
    else if (@abs(p.z() - max.z()) < eps) normal = Vec3.init(0,0,1);

    var rec = HitRecord{
        .t = t,
        .p = p,
        .normal = normal,
        .front_face = undefined,
    };

    rec.set_face_normal(r, normal);
    rec.material = self.material;
    return rec;
}

