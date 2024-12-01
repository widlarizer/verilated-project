const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const run = std.ChildProcess.exec;

pub fn build(b: *std.Build) !void {
    const module_name = "top";

    // Verilate step
    const verilate_step = b.step("verilate", "run verilator to generate c++ code");
    const verilate_cmd = b.addSystemCommand(&[_][]const u8{
        "verilator",
        "-CFLAGS",
        "-std=c++14",
        "-Wall",
        "--trace",
        "-Wno-DECLFILENAME",
        "-Wno-EOFNEWLINE",
        "-Wno-UNUSEDSIGNAL",
        "--top",
        module_name,
        "-cc",
        b.fmt("{s}.sv", .{module_name}),
    });
    verilate_step.dependOn(&verilate_cmd.step);

    const spade_step = b.step("spade", "run spade to generate verilog design");
    const spade_cmd = b.addSystemCommand(&[_][]const u8{ "spade", "-o", module_name ++ ".sv", "src/main.spade" });
    spade_step.dependOn(&spade_cmd.step);
    verilate_step.dependOn(spade_step);

    // Add a command to touch .stamp.verilate
    const touch_stamp = b.addSystemCommand(&[_][]const u8{
        "touch",
        ".stamp.verilate",
    });
    touch_stamp.step.dependOn(&verilate_cmd.step);
    verilate_step.dependOn(&touch_stamp.step);

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "verilator-test",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add C++ wrapper compilation
    const cpp = b.addObject(.{
        .name = "wrapper",
        .target = target,
        .optimize = optimize,
    });
    cpp.addCSourceFile(.{
        .file = b.path("wrapper.cpp"),
        .flags = &[_][]const u8{"-std=c++14"},
    });

    // Add Verilator static code
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const verilator_root = try std.process.getEnvVarOwned(arena.allocator(), "VERILATOR_ROOT");
    var buf: [4096]u8 = undefined;
    const verilator_include = try std.fmt.bufPrint(&buf, "{s}/include", .{verilator_root});
    // const verilator_root = std.os.getenv("VERILATOR_ROOT") orelse @panic("VERILATOR_ROOT not set");
    const verilator_include_path: std.Build.LazyPath = .{ .cwd_relative = verilator_include };
    cpp.addIncludePath(verilator_include_path);
    // Add Verilator generated code
    cpp.addIncludePath(b.path("obj_dir")); // Verilator output directory
    cpp.addCSourceFile(.{
        .file = b.path("obj_dir/V" ++ module_name ++ ".cpp"),
        .flags = &[_][]const u8{"-std=c++14"},
    });
    // Add other Verilator generated files as needed
    cpp.addCSourceFile(.{
        .file = b.path("obj_dir/V" ++ module_name ++ "__Syms.cpp"),
        .flags = &[_][]const u8{"-std=c++14"},
    });
    cpp.linkLibCpp();
    cpp.step.dependOn(verilate_step);

    // Link with Verilator runtime
    exe.addObjectFile(b.path("obj_dir/verilated.o"));
    exe.addObjectFile(cpp.getEmittedBin());

    // Add include paths
    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("obj_dir"));

    // Link with C++ standard library
    exe.linkLibCpp();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    // b.default_step = verilate_step;
}
