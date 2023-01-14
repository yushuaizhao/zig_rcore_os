const std = @import("std");
const console = @import("user_lib");

pub fn main() usize {
    console.print("Try to access privileged CSR in U Mode", .{});
    console.print("Kernel should kill this application!", .{});
    _ = asm volatile ("sret");
    return 0;
}
