const std = @import("std");

const Context = @import("context.zig").gtps.Context;

pub fn main() void {
    var context = Context.create() catch |err| {
        std.log.err("Error while creating server context: {any}", .{err});
        @panic("context creation failed");
    };
    context.run();
    context.destroy();
}
