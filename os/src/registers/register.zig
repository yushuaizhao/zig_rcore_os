pub const Register = enum {
    scause,
    stval,
    sstatus,
    sepc,
    stvec,
};

pub inline fn write(comptime register: Register, value: usize) void {
    asm volatile ("csrw " ++ @tagName(register) ++ ", %[value]"
        :
        : [value] "r" (value),
        : "memory"
    );
}

pub inline fn read(comptime register: Register) usize {
    return asm volatile ("csrr %[ret], " ++ @tagName(register)
        : [ret] "=r" (-> usize),
    );
}
