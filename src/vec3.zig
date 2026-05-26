const std = @import("std");

    const this = @This();

    e: [3]f64,
    
    pub fn zero() this {
        return . { .e = [3]f64{0,0,0}};
    }

    pub fn init(e0: f64, e1: f64, e2: f64) this {
        return . { .e = [3]f64{e0,e1,e2}};
    }

    pub fn x(self: this) f64 {return self.e[0];}
    pub fn y(self: this) f64 {return self.e[1];}
    pub fn z(self: this) f64 {return self.e[2];}
        
    

