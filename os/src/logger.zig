const std = @import("std");
const sbi = @import("sbi.zig");

pub const LogLevel = enum(u8) {
    ERROR,
    WARN,
    INFO,
    DEBUG,
    TRACE,
};

pub var PRINTLEVEL: LogLevel = .DEBUG;

const Error = error{};

const LoggerWriter = std.io.Writer(LogLevel, Error, loggerPrintFn);

const error_logger = LoggerWriter{ .context = .ERROR };
const warn_logger = LoggerWriter{ .context = .WARN };
const info_logger = LoggerWriter{ .context = .INFO };
const debug_logger = LoggerWriter{ .context = .DEBUG };
const trace_logger = LoggerWriter{ .context = .TRACE };

fn colorPrintFn(color: u8, message: []const u8) void {
    sbi.print("\x1b[{d}m{s}\x1b[0m", .{ color, message });
}

pub fn loggerPrintFn(context: LogLevel, message: []const u8) Error!usize {
    if (@enumToInt(context) > @enumToInt(PRINTLEVEL)) {
        return 0;
    }
    switch (context) {
        .ERROR => colorPrintFn(31, message),
        .WARN => colorPrintFn(93, message),
        .INFO => colorPrintFn(34, message),
        .DEBUG => colorPrintFn(32, message),
        .TRACE => colorPrintFn(90, message),
    }
    return message.len;
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    _ = error_logger.print("[ERROR] ", .{}) catch {};
    _ = error_logger.print(fmt, args) catch {};
    sbi.putchar('\n');
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    _ = warn_logger.print("[WARN] ", .{}) catch {};
    _ = warn_logger.print(fmt, args) catch {};
    sbi.putchar('\n');
}

pub fn info(comptime fmt: []const u8, args: anytype) void {
    _ = info_logger.print("[INFO] ", .{}) catch {};
    _ = info_logger.print(fmt, args) catch {};
    sbi.putchar('\n');
}

pub fn debug(comptime fmt: []const u8, args: anytype) void {
    _ = debug_logger.print("[DEBUG] ", .{}) catch {};
    _ = debug_logger.print(fmt, args) catch {};
    sbi.putchar('\n');
}

pub fn trace(comptime fmt: []const u8, args: anytype) void {
    _ = trace_logger.print("[TRACE] ", .{}) catch {};
    _ = trace_logger.print(fmt, args) catch {};
    sbi.putchar('\n');
}
