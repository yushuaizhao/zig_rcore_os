pub fn code(v: usize) usize {
    const b: usize = 1 << (@sizeOf(usize) * 8 - 1);
    return v & (~b);
}

pub const Exception = enum {
    InstructionMisaligned,
    InstructionFault,
    IllegalInstruction,
    Breakpoint,
    LoadFault,
    StoreMisaligned,
    StoreFault,
    UserEnvCall,
    VirtualSupervisorEnvCall,
    InstructionPageFault,
    LoadPageFault,
    StorePageFault,
    InstructionGuestPageFault,
    LoadGuestPageFault,
    VirtualInstruction,
    StoreGuestPageFault,
    Unknown,

    pub fn from(v: usize) Exception {
        return switch (v) {
            0 => .InstructionMisaligned,
            1 => .InstructionFault,
            2 => .IllegalInstruction,
            3 => .Breakpoint,
            5 => .LoadFault,
            6 => .StoreMisaligned,
            7 => .StoreFault,
            8 => .UserEnvCall,
            10 => .VirtualSupervisorEnvCall,
            12 => .InstructionPageFault,
            13 => .LoadPageFault,
            15 => .StorePageFault,
            20 => .InstructionGuestPageFault,
            21 => .LoadGuestPageFault,
            22 => .VirtualInstruction,
            23 => .StoreGuestPageFault,
            else => .Unknown,
        };
    }
};

pub const Interrupt = enum {
    UserSoft,
    VirtualSupervisorSoft,
    SupervisorSoft,
    UserTimer,
    VirtualSupervisorTimer,
    SupervisorTimer,
    UserExternal,
    VirtualSupervisorExternal,
    SupervisorExternal,
    Unknown,

    pub fn from(v: usize) Interrupt {
        return switch (v) {
            0 => .UserSoft,
            1 => .SupervisorSoft,
            2 => .VirtualSupervisorSoft,
            4 => .UserTimer,
            5 => .SupervisorTimer,
            6 => .VirtualSupervisorTimer,
            8 => .UserExternal,
            9 => .SupervisorExternal,
            10 => .VirtualSupervisorExternal,
            else => .Unknown,
        };
    }
};

pub fn isInterrupt(v: usize) bool {
    return ((v >> (@sizeOf(usize) * 8 - 1)) & 1) == 1;
}

pub fn trapInterrupt(v: usize) Interrupt {
    if (isInterrupt(v)) {
        return Interrupt.from(code(v));
    }
    return .Unknown;
}

pub fn trapException(v: usize) Exception {
    if (isInterrupt(v)) {
        return .Unknown;
    }
    return Exception.from(code(v));
}
