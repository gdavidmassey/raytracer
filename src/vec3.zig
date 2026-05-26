const std = @import("std");

    const this = @This();

    e: [3]f64 = [_]f64{0,0,0},
    
    pub fn zero() this {
        return . { .e = [3]f64{0,0,0}};
    }

    pub fn init(e0: f64, e1: f64, e2: f64) this {
        return . { .e = [3]f64{e0,e1,e2}};
    }

    pub fn x(self: this) f64 {return self.e[0];}
    pub fn y(self: this) f64 {return self.e[1];}
    pub fn z(self: this) f64 {return self.e[2];}

    pub fn inv(self: this) this {
        return .{.e = [_]f64{-self.x(), -self.y(), -self.z()}};
    }

    pub fn add(self: this, other: this) this {
        return .{.e = [_]f64{self.x() + other.x(), self.y() + other.y(), self.z() + other.z()}};
    }

    pub fn sub(self: this, other: this) this {
        return .{.e = [_]f64{self.x() - other.x(), self.y() - other.y(), self.z() - other.z()}};
    }
    
    pub fn subScalar(self: this, b: f64) this {
        return .{.e = [_]f64{self.x() - b, self.y() - b, self.z() - b}};
    }

    pub fn mulElement(self: this, other: this) this {
        return .{.e = [_]f64{self.x() * other.x(), self.y() * other.y(), self.z() * other.z()}};
    }

    pub fn mulScalar(self: this, b: f64) this {
        return .{.e = [_]f64{self.x() * b, self.y() * b, self.z() * b}};
    }

    pub fn divScalar(self: this, b: f64) this {
        return self.mulScalar(1 / b);
    }

    pub fn dot(self: this, b: this) f64 {
        return self.e[0] * b.e[0] 
        + self.e[1] * b.e[1] 
        + self.e[2] * b.e[2] 
    }
    
    pub fn cross(self: this, b: this) this {
        return .init(self.e[1] * b.e[2] - self.e[2] * b.e[1],
                     self.e[2] * b.e[0] - self.e[0] * b.e[2],
                     self.e[0] * b.e[1] - self.e[1] * b.e[0])
    }

    pub fn length_squared(self: this) f64 {
        return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
    }

    pub fn length(self: this) f64 {
        return @sqrt(self.length_squared());
    }
        
    pub fn unit_vector(self: this) this {
        return self.divScalar(self.length());
    }
    

