const std = @import("std");
const console = @import("user_lib");

pub fn main() usize {
    console.print("Into Test store_fault, we will insert an invalid store operation...", .{});
    console.print("Kernel should kill this application!", .{});
    return 0;
}
