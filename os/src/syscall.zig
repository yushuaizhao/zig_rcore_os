const SYSCALL_WRITE: usize = 64;
const SYSCALL_EXIT: usize = 93;
const FD_STDOUT: usize = 1;
const sbi = @import("sbi.zig");

pub fn syscall(syscall_id: usize, args: [3]usize) usize {
    return switch (syscall_id) {
        SYSCALL_WRITE => sys_write(args[0], @intToPtr([*]u8, args[1]), args[2]),
        SYSCALL_EXIT => sys_exit(args[0]),
        else => {
            sbi.print("Unsupported syscall_id {}", .{syscall_id});
            @panic("");
        },
    };
}

pub fn sys_write(fd: usize, buf: [*]u8, len: usize) usize {
    switch (fd) {
        FD_STDOUT => {
            sbi.print("{s}\n", .{buf[0..len]});
        },
        else => {
            @panic("Unsupported fd in sys_write!");
        },
    }
    return 0;
}

extern fn run_next_app() void;

pub fn sys_exit(exit_code: usize) usize {
    sbi.print("[kernel] Application exited with code {}\n", .{exit_code});
    run_next_app();
    @panic("should not happened");
}
