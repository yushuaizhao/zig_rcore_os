const Reg = @import("registers/lib.zig");
const sbi = @import("sbi.zig");
const std = @import("std");

pub const TrapContext = struct {
    x: [32]usize,
    sstatus: usize,
    sepc: usize,

    pub fn setSp(self: *TrapContext, sp: usize) void {
        self.x[2] = sp;
    }

    pub fn init(entry: usize, sp: usize) TrapContext {
        var sstatus = Reg.read(.sstatus);
        Reg.Sstatus.setSPP(.User);
        var cx = TrapContext{
            .x = std.mem.zeroes([32]usize),
            .sstatus = sstatus,
            .sepc = entry,
        };
        cx.setSp(sp);
        return cx;
    }
};

extern fn __alltraps() noreturn;

pub fn init() void {
    const addr = @ptrToInt(&__alltraps);
    // mode = 0 direct 1 vectored
    Reg.Stvec.write(addr, .Direct);
}


fn print_register(comptime r: Reg.Register) void {
    const v = Reg.read(r);
    sbi.print("{s} {X}\n", .{@tagName(r), v});
}

export fn print_stack() void {
    const sstatus = Reg.read(.sstatus);
    sbi.print("sstatus {b}\n", .{sstatus});
    const sepc = Reg.read(.sepc);
    sbi.print("sepc is {X}\n", .{sepc});
    const stvec = Reg.read(.stvec);
    sbi.print("stvec {X}\n", .{Reg.Stvec.getAddress(stvec)});
}
