const sbi = @import("sbi.zig");
const mem = @import("std").mem;
const logger = @import("logger.zig");
const trap = @import("trap.zig");
const Reg = @import("registers/lib.zig");
const sys = @import("syscall.zig");

const USER_STACK_SIZE: usize = 4096 * 2;
const KERNEL_STACK_SIZE: usize = 4096 * 4;

fn StackWithSize(comptime size: usize) type {
    return struct {
        data: [size]u8,
        const Self = @This();

        pub fn init() Self {
            return Self{ .data = mem.zeroes([size]u8) };
        }

        pub fn print_stack_info(self: *const Self) void {
            const sp = self.get_sp();
            logger.info("stack {X} {X}", .{ sp - size, sp });
        }

        pub fn get_sp(self: *const Self) usize {
            const sp_address = @ptrToInt(&self.data);
            return sp_address + size;
        }

        pub fn push_context(self: *const Self, cx: trap.TrapContext) *trap.TrapContext {
            const cx_addr = (self.get_sp() - @sizeOf(trap.TrapContext));
            var cx_ptr = @intToPtr(*trap.TrapContext, cx_addr);
            cx_ptr.* = cx;
            sbi.print("push context to ({X}, {X})\n", .{ cx_addr, cx_addr + @sizeOf(trap.TrapContext) });
            return cx_ptr;
        }
    };
}

const APP_BASE_ADDRESS: usize = 0x80400000;
const APP_SIZE_LIMIT: usize = 0x20000;
const MAX_APP_NUM: usize = 16;

extern fn _num_app() noreturn;

const AppManager = struct {
    num_app: usize = 0,
    current_app: usize = 0,
    app_start: [MAX_APP_NUM + 1]usize,

    pub fn print_app_info(self: AppManager) void {
        sbi.print("[kernel] num_app = {}\n", .{self.num_app});
    }

    pub fn init(self: *AppManager) void {
        const num_app_address = @ptrToInt(&_num_app);
        const num_app_ptr = @intToPtr([*]usize, num_app_address);
        self.num_app = num_app_ptr[0];
        self.current_app = 0;
        var i: usize = 1;
        while (i < (self.num_app + 2)) : (i += 1) {
            self.app_start[i - 1] = num_app_ptr[i];
        }
        logger.info("app start {X} {X}", .{ self.app_start[0], self.app_start[self.num_app] });
    }

    pub fn load_app(self: *AppManager, app_id: usize) void {
        if (app_id >= self.num_app) {
            @panic("all app completed");
        }
        sbi.print("[kernel] loading app {d}\n", .{app_id});
        asm volatile ("fence.i");
        mem.set(u8, @intToPtr([*]u8, APP_BASE_ADDRESS)[0..APP_SIZE_LIMIT], 0);
        const app_start_ptr = self.app_start[app_id];
        const app_end_ptr = self.app_start[app_id + 1] + 1;
        @memcpy(@intToPtr([*]u8, APP_BASE_ADDRESS), @intToPtr([*]u8, app_start_ptr), app_end_ptr - app_start_ptr);
        // const app_src = @intToPtr([*]u8, app_start_ptr)[0..(app_end_ptr - app_start_ptr)];
        // var app_dst = @intToPtr([*]u8, APP_BASE_ADDRESS)[0..app_src.len];
        sbi.print("[kernel] load app from ({X}, {X}) to {X}\n", .{ app_start_ptr, app_end_ptr, APP_BASE_ADDRESS });
        // sbi.print("[kernel] load app from ({X}, {X}) to {X}\n", .{ @ptrToInt(&app_src[0]), @ptrToInt(&app_dst[0]) });
        // mem.copy(u8, app_dst, app_src);
    }

    pub fn get_current_app(self: AppManager) usize {
        return self.current_app;
    }

    pub fn move_to_next_app(self: *AppManager) void {
        self.current_app += 1;
    }
};

const KernelStack = StackWithSize(KERNEL_STACK_SIZE);
const UserStack = StackWithSize(USER_STACK_SIZE);

// var KERNEL_STACK align(4096) = KernelStack.init();
// var USER_STACK align(4096) = UserStack.init();

// var KERNEL_STACK align(4096) = KernelStack{ .data = mem.zeroes([KERNEL_STACK_SIZE]u8) };
// var USER_STACK align(4096) = UserStack{ .data = mem.zeroes([USER_STACK_SIZE]u8) };
// var KERNEL_STACK = mem.zeroes([KERNEL_STACK_SIZE]u8);
// var USER_STACK = mem.zeroes([USER_STACK_SIZE]u8);
var app_manager = AppManager{
    .app_start = mem.zeroes([MAX_APP_NUM + 1]usize),
};

var USER_STACK: UserStack = UserStack.init();
var KERNEL_STACK: KernelStack = KernelStack.init();

pub fn init() void {
    app_manager.init();
    USER_STACK.print_stack_info();
    KERNEL_STACK.print_stack_info();
    // logger.debug("stack {X} {X}", .{ &KERNEL_STACK[0], &KERNEL_STACK[KERNEL_STACK_SIZE - 1] });
    // logger.debug("stack {X} {X}", .{ &USER_STACK[0], &USER_STACK[USER_STACK_SIZE - 1] });
    print_app_info();
}

pub fn print_app_info() void {
    app_manager.print_app_info();
}

extern fn __restore(usize) noreturn;

pub export fn run_next_app() void {
    const current_app = app_manager.get_current_app();
    app_manager.load_app(current_app);
    app_manager.move_to_next_app();
    var cx = trap.TrapContext.init(APP_BASE_ADDRESS, USER_STACK.get_sp());
    var cx_ptr = KERNEL_STACK.push_context(cx);
    sbi.print("trap context size is {X}\n", .{@sizeOf(trap.TrapContext)});
    sbi.print("cx_ptr is {X}\n", .{@ptrToInt(cx_ptr)});
    __restore(@ptrToInt(cx_ptr));
    @panic("Unreachable in batch::run_current_app!");
}

export fn trap_handler(cx: *trap.TrapContext) *trap.TrapContext {
    const scause = Reg.read(.scause);
    const stval = Reg.read(.stval);
    _ = stval;
    const exception_type = Reg.Scause.trapException(scause);
    switch (exception_type) {
        .UserEnvCall => {
            // sbi.print("[kernel] call user env call {d} {X} {X} {X}\n", .{cx.x[17], cx.x[10], cx.x[11], cx.x[12]});
            cx.sepc += 4;
            cx.x[10] = sys.syscall(cx.x[17], [3]usize{ cx.x[10], cx.x[11], cx.x[12] });
        },
        .StoreFault, .StorePageFault => {
            sbi.print("[kernel] PageFault in application, kernel killed it.\n", .{});
            run_next_app();
        },
        .IllegalInstruction => {
            sbi.print("[kernel] IllegalInstruction in application, kernel killed it.\n", .{});
            run_next_app();
        },
        else => {
            // sbi.print("[kernel] Unsupported trap {}, stval = {X}\n", .{ exception_type, stval });
            @panic("Unsupported trap");
        },
    }
    // sbi.print("cxxxxx {any}\n", .{cx.*});
    return cx;
}
