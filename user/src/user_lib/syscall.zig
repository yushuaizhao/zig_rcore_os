fn syscall(id: usize, arg0: usize, arg1: usize, arg2: usize) isize {
    return asm volatile ("ecall"
        : [ret] "={x10}" (-> isize),
        : [arg0] "{x10}" (arg0),
          [arg1] "{x11}" (arg1),
          [arg2] "{x12}" (arg2),
          [id] "{x17}" (id),
    );
}

const SYSCALL_WRITE: usize = 64;
const SYSCALL_EXIT: usize = 93;

pub fn sys_write(fd: usize, buffer: []const u8) isize {
    return syscall(SYSCALL_WRITE, fd, @ptrToInt(buffer.ptr), buffer.len);
}

pub fn sys_exit(xstate: usize) isize {
    return syscall(SYSCALL_EXIT, xstate, 0, 0);
}

extern fn start_bss() noreturn;
extern fn end_bss() noreturn;

pub fn clear_bss() void {
    var sbss = @ptrToInt(&start_bss);
    var ebss = @ptrToInt(&end_bss);
    @memset(@intToPtr([*]u8, sbss), 0, ebss - sbss);
}
