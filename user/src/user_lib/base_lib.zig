const sys = @import("syscall.zig");

pub fn write(fd: usize, buf: []const u8) isize {
    return sys.sys_write(fd, buf);
}

pub fn exit(exit_code: usize) isize {
    return sys.sys_exit(exit_code);
}
