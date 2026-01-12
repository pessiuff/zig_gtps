const std = @import("std");

const Server = @import("net/server.zig").gtps.Server;

pub const gtps = struct {
    pub const Context = struct {
        is_running: bool,
        server: Server,

        pub fn create() !Context {
            return Context{ .is_running = false, .server = try Server.init() };
        }

        pub fn run(self: *Context) void {
            self.is_running = true;

            while (self.is_running) {
                self.server.pollEvents(0) catch |err| {
                    std.log.err("Error while polling events: {any}", .{err});
                };
            }
        }

        pub fn destroy(self: *Context) void {
            self.server.deinit();
        }
    };
};
