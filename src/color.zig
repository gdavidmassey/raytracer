const std = @import("std");
const Vec3 = @import("vec3.zig");
const Interval = @import("interval.zig");

pub const Color = Vec3;

const intensity: Interval = .init(0.000, 0.999);

fn linear_to_gamma(linear_component: f64) f64 {
    if (linear_component > 0) 
        return @sqrt(linear_component);
    return 0;
}

pub fn write_color(w: anytype, pixel_color: Color) !void {
    const r: f64 = linear_to_gamma(pixel_color.x());
    const g: f64 = linear_to_gamma(pixel_color.y());
    const b: f64 = linear_to_gamma(pixel_color.z());
   
    const ir: u8 = @intFromFloat(256 * intensity.clamp(r));
    const ig: u8 = @intFromFloat(256 * intensity.clamp(g));
    const ib: u8 = @intFromFloat(256 * intensity.clamp(b));
    
    try w.print("{} {} {}\n",.{ir,ig,ib});
} 
