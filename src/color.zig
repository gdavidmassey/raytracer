const std = @import("std");
const vec3 = @import("vec3.zig");


const color = vec3;

pub fn write_color(w: anytype, pixel_color: *const color) void {
    const r: f32 = pixel_color.x();
    const g: f32 = pixel_color.y();
    const b: f32 = pixel_color.z();
    
    const ir: u8 = @intFromFloat(255.999 * r);
    const ig: u8 = @intFromFloat(255.999 * g);
    const ib: u8 = @intFromFloat(255.999 * b);
    
    try w.print("{} {} {}\n",.{ir,ig,ib});
} 
