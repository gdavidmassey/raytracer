const std = @import("std");
const Vec3 = @import("vec3.zig");

pub const Color = Vec3;

pub fn write_color(w: anytype, pixel_color: *const Color) !void {
    const r: f64 = pixel_color.x();
    const g: f64 = pixel_color.y();
    const b: f64 = pixel_color.z();
    
    const ir: u8 = @intFromFloat(255.999 * r);
    const ig: u8 = @intFromFloat(255.999 * g);
    const ib: u8 = @intFromFloat(255.999 * b);
    
    try w.print("{} {} {}\n",.{ir,ig,ib});
} 
