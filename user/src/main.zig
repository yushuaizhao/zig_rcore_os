const user_lib = @import("user_lib");
const app = @import("app");

export fn _start() void {
    user_lib.sys.clear_bss();
    _ = user_lib.exit(app.main());
    unreachable;
}
