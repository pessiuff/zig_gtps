const std = @import("std");

pub fn build(project_build: *std.Build) void {
    const server_executable = project_build.addExecutable(.{ .name = "gtps", .root_module = project_build.createModule(.{ .root_source_file = project_build.path("src/main.zig"), .target = project_build.graph.host }) });

    server_executable.root_module.link_libc = true;
    server_executable.root_module.addLibraryPath(project_build.path("c_lib"));
    server_executable.root_module.linkSystemLibrary("enet", .{ .preferred_link_mode = .static });
    server_executable.root_module.addIncludePath(project_build.path("c_include"));

    project_build.installArtifact(server_executable);

    const run_server_executable = project_build.addRunArtifact(server_executable);
    const run_step = project_build.step("run", "Run the server.");
    run_step.dependOn(&run_server_executable.step);
}
