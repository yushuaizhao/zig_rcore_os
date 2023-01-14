const Reg = @import("./register.zig");

pub const TrapMode = enum {
    Direct,
    Vectored,
    Unknown,

    pub fn code(self: TrapMode) usize {
        return switch (self) {
            .Direct => 0,
            .Vectored => 1,
            else => 2,
        };
    }
};

pub fn getAddress(v: usize) usize {
    return v - (v & 0b11);
}

pub fn getMode(v: usize) TrapMode {
    const m = v & 0b11;
    if (m == 0) {
        return .Direct;
    } else if (m == 1) {
        return .Vectored;
    }
    return .Unknown;
}

pub fn write(addr:usize, mode: TrapMode) void {
    Reg.write(.stvec, addr + mode.code());
}
