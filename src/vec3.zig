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

    pub fn addEq(self: *this, other: this) void {
        self.e[0] += other.x();
        self.e[1] += other.y();
        self.e[2] += other.z();
        return;
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

    pub fn lerp(self: this, other: this, a: f64) this {
        return .{.e = [_]f64{(1.0 - a) * self.x() + a * other.x(), (1.0 - a) * self.y() + a * other.y(), (1.0 - a) * self.z() + a * other.z()}};
    }

    pub fn addScalar(self: this, b: f64) this {
        return .{.e = [_]f64{self.x() + b, self.y() + b, self.z() + b}};
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
        + self.e[2] * b.e[2];
    }
    
    pub fn rgb(self: this) this {
        return self.addScalar(1.0).mulScalar(0.5);
    }

    pub fn cross(self: this, b: this) this {
        return .init(self.e[1] * b.e[2] - self.e[2] * b.e[1],
                     self.e[2] * b.e[0] - self.e[0] * b.e[2],
                     self.e[0] * b.e[1] - self.e[1] * b.e[0]);
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

    pub fn random_unit_vector(rand: std.Random) this {
        var cnt: usize = 0;
        while (true) {
            const p = random_range(rand,-1,1);
            const lensq = p.length_squared();
            if ((1e-160 < lensq and lensq <= 1) or cnt > 100) 
                return p.divScalar(@sqrt(lensq)); 
            cnt += 1;
        }
    }

    pub fn random_on_hemisphere(rand: std.Random, normal: this) this {
        const on_unit_sphere = random_unit_vector(rand);
        if (on_unit_sphere.dot(normal) > 0.0) { // In the same hemisphere as the normal
            return on_unit_sphere;
        }
        return on_unit_sphere.inv(); 
    }
    
    pub fn random (rand: std.Random) this { 
        return .init(rand.float(f64),rand.float(f64),rand.float(f64));
    }

    pub fn random_range(rand: std.Random, min: f64, max: f64) this {
        return .init(min + rand.float(f64) * (max - min),min + rand.float(f64) * (max - min), min + rand.float(f64) * (max - min));
    }
