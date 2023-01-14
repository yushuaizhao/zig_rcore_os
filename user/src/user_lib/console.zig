const STDOUT: usize = 1;
const lib = @import("base_lib.zig");
const std = @import("std");

const Error = error{};

fn printCallBackFn(fd: usize, message: []const u8) Error!usize {
    _ = lib.write(fd, message);
    return message.len;
}

pub const stdout = std.io.Writer(usize, Error, printCallBackFn){ .context = STDOUT };

pub fn print(comptime fmt: []const u8, args: anytype) void {
    stdout.print(fmt, args) catch {};
}
