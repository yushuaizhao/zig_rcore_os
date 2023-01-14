const std = @import("std");
// pub const SBI_SET_TIMER: usize = 0;
pub const SBI_CONSOLE_PUTCHAR: usize = 1;
// pub const SBI_CONSOLE_GETCHAR: usize = 2;
// pub const SBI_CLEAR_IPI: usize = 4;
// pub const SBI_SEND_IPI: usize = 5;
// pub const SBI_REMOTE_FENCE_I: usize = 6;
// pub const SBI_REMOTE_SFENCE_VMA: usize = 7;
// pub const SBI_REMOTE_SFENCE_VMA_ASID: usize = 7;
pub const SBI_SHUTDOWN: usize = 8;

pub inline fn sbi_call(which: usize, arg0: usize, arg1: usize, arg2: usize) usize {
    return asm volatile ("ecall"
        : [ret] "={x10}" (-> usize),
        : [arg0] "{x10}" (arg0),
          [arg1] "{x11}" (arg1),
          [arg2] "{x12}" (arg2),
          [which] "{x17}" (which),
    );
}

// @panic need this and should be imported in root file
pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    _ = error_return_trace;
    print("\n!!!!!!!!!!! panic !!!!!!!!!!!\n", .{});
    print("ret_addr: {X}\n", .{ret_addr orelse @returnAddress()});
    print("error: {s}\n", .{msg});
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n", .{});
    _ = shutdown();
}

export fn shutdown() noreturn {
    print("shutdown now\n", .{});
    _ = sbi_call(SBI_SHUTDOWN, 0, 0, 0);
    @panic("should not happen after shutdown");
}

pub fn putchar(c: u8) void {
    _ = sbi_call(SBI_CONSOLE_PUTCHAR, @intCast(usize, c), 0, 0);
}

const Error = error{};

fn printCallBackFn(context: void, bytes: []const u8) Error!usize {
    _ = context;
    for (bytes) |x| {
        putchar(x);
    }
    return bytes.len;
}

const console = std.io.Writer(void, Error, printCallBackFn){ .context = {} };

pub fn print(comptime fmt: []const u8, args: anytype) void {
    _ = console.print(fmt, args) catch {};
}
