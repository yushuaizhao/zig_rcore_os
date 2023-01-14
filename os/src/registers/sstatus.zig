const Reg = @import("./register.zig");

pub inline fn isUserInterruptEnable(v: usize) bool {
    return (v & 1);
}

pub inline fn isSuperVisorInterruptEnable(v:usize) bool {
    return (v >> 1) & 1;
}

pub const SPP = enum {
    Supervisor,
    User,
};

pub inline fn setSPP(spp: SPP) void {
    const nx:usize = 0x1 << 8;
    const v = Reg.read(.sstatus);
    switch (spp) {
        .Supervisor => {
            Reg.write(.sstatus, v | nx);
        },
        .User => {
            Reg.write(.sstatus, v & (~nx));
        },
    }
}
