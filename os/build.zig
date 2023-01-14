const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zig_os", "src/main.zig");
    // https://github.com/ziglang/zig/issues/5558
    exe.code_model = .medium;
    exe.addAssemblyFile("linker/start.S");
    exe.addAssemblyFile("linker/link_app.S");
    exe.addAssemblyFile("linker/trap.S");
    exe.setLinkerScriptPath(std.build.FileSource{ .path = "linker/linker.ld" });
    exe.setTarget(target);
    exe.setBuildMode(mode);
    // for debug comment this
    // exe.strip = true;
    exe.install();
}
