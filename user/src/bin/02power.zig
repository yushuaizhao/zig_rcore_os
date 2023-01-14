const std = @import("std");
const console = @import("user_lib");

const SIZE: usize = 10;
const P: u32 = 3;
const STEP: usize = 100000;
const MOD: u32 = 10007;

pub fn main() usize {
    var pow = std.mem.zeroes([SIZE]u32);
    var index:usize = 0;
    pow[index] = 1;
    var i:usize = 1;
    while(i <= STEP) : (i += 1) {
        const last = pow[index];
        index = (index + 1) % SIZE;
        pow[index] = last * P % MOD;
        if(i % 10000 == 0) {
            console.print("{}^{}={}(MOD {})", .{P, i, pow[index],MOD});
        }
    }
    console.print("Test power OK!", .{});
    return 0;
}
