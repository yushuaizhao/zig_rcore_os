const std = @import("std");

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}

pub const user_lib_pkg = std.build.Pkg{ .name = "user_lib", .source = .{ .path = thisDir() ++ "/src/user_lib/lib.zig" } };

pub const AppBuilder = struct {
    b: *std.build.Builder,
    target: std.zig.CrossTarget,
    mode: std.builtin.Mode,

    pub fn init(b: *std.build.Builder) AppBuilder {
        return AppBuilder{
            .b = b,
            .target = b.standardTargetOptions(.{}),
            .mode = b.standardReleaseOptions(),
        };
    }

    pub fn buildApp(self: AppBuilder, comptime name: []const u8) void {
        const app = std.build.Pkg{ .name = "app", .source = .{ .path = thisDir() ++ "/src/bin/" ++ name ++ ".zig" }, .dependencies = &[1]std.build.Pkg{user_lib_pkg} };
        const exe = self.b.addExecutable(name, "src/main.zig");
        // https://github.com/ziglang/zig/issues/5558
        exe.code_model = .medium;
        exe.addPackage(user_lib_pkg);
        exe.addPackage(app);
        exe.setLinkerScriptPath(std.build.FileSource{ .path = "linker/linker.ld" });
        exe.setTarget(self.target);
        exe.setBuildMode(self.mode);
        exe.install();
    }
};

pub fn build(b: *std.build.Builder) void {
    var app_builder = AppBuilder.init(b);
    // const exe1 = buildApp(b, "01store_fault");
    app_builder.buildApp("00hello_world");
    app_builder.buildApp("01store_fault");
    app_builder.buildApp("02power");
    app_builder.buildApp("03priv_inst");
    app_builder.buildApp("04priv_csr");
    // exe.setTarget(target);
    // exe.setBuildMode(mode);
    // exe.install();
}
