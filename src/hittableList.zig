const std = @import("std");
const Ray = @import("ray.zig");
const Hittable = @import("hittable.zig");
const HitRecord = Hittable.HitRecord;
const Interval = @import("interval.zig");
const this = @This();

objects: std.ArrayList(Hittable) = .{},

pub fn clear(self: *this, allocator: std.mem.Allocator) void {
    self.objects.deinit(allocator);
}

pub fn add(self: *this, allocator: std.mem.Allocator, obj: Hittable) !void {
    self.objects.append(allocator, obj);
}

pub fn hit(self: this, r: Ray, ray_t: Interval) ?HitRecord {
    //var hit_anything: bool = false;
    var closest_so_far = ray_t;
    var temp_rec = null;

    for (self.objects) |obj| {
        temp_rec = obj.hit(r, closest_so_far) orelse continue;
        //hit_anything = true;
        closest_so_far.max = temp_rec.t;
    }

    return temp_rec;
}

