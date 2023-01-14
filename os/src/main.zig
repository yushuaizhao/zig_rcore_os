const std = @import("std");
const sbi = @import("sbi.zig");
const logger = @import("logger.zig");
const batch = @import("batch.zig");
const trap = @import("trap.zig");

extern fn sbss() noreturn;
extern fn ebss() noreturn;
extern fn stext() noreturn;
extern fn etext() noreturn;
extern fn srodata() noreturn;
extern fn erodata() noreturn;
extern fn sdata() noreturn;
extern fn edata() noreturn;
extern fn sbt() noreturn;
extern fn ebt() noreturn;
extern fn skernel() noreturn;
extern fn _start() noreturn;

pub const panic = sbi.panic;

fn clear_bss() void {
    var sbss_address = @ptrToInt(&sbss);
    var ebss_address = @ptrToInt(&ebss);
    std.mem.set(u8, @intToPtr([*]u8, sbss_address)[0..(ebss_address - sbss_address)], 0);
    logger.debug("sbss adress value {any}: {d}", .{ &@intToPtr([*]u8, sbss_address)[0], @intToPtr([*]u8, sbss_address)[0] });
}

export fn rust_main() void {
    clear_bss();
    logger.debug("{s}", .{"hello world"});
    logger.info(".start [{X}, {X})", .{ @ptrToInt(&skernel), @ptrToInt(&_start) });
    logger.info(".text [{X}, {X})", .{ @ptrToInt(&stext), @ptrToInt(&etext) });
    logger.debug(".rodata [{X}, {X})", .{ @ptrToInt(&srodata), @ptrToInt(&erodata) });
    logger.err(".data [{X}, {X})", .{ @ptrToInt(&sdata), @ptrToInt(&edata) });
    logger.info(".boot_stack [{X}, {X})", .{ @ptrToInt(&sbt), @ptrToInt(&ebt) });
    logger.info(".bss [{X}, {X})", .{ @ptrToInt(&sbss), @ptrToInt(&ebss) });
    trap.init();
    batch.init();
    batch.run_next_app();
    @panic("oom");
}
