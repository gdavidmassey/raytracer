const std = @import("std");
const this = @This();

    min: f64 = std.math.inf(f64),
    max: f64 = -std.math.inf(f64),

    pub fn init(min: f64, max: f64) this {
        return .{.min = min, .max = max};
    }

    pub fn size(self: this) f64 {
        return self.max - self.min;
    }

    pub fn contains(self: this, x: f64) f64 {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: this, x: f64) f64 {
        return self.min < x and x < self.max;
    }

    pub fn clamp(self: this, x: f64) f64 {
        if (x < self.min) return self.min;
        if (x > self.max) return self.max;
        return x;
    }

const empty: this = .{};
const universe: this = .{.min = -std.math.inf(f64), .max = std.math.inf(f64)};


    

