const std = @import("std");

const c_enet = @cImport({
    @cInclude("enet/enet.h");
});

const SERVER_PORT: u16 = 1337;
const SERVER_CHANNEL_COUNT: usize = 1;
const SERVER_MAX_PEER_COUNT: usize = 512;
const SERVER_MAX_INCOMING_BANDWIDTH: i32 = 0; // 0 means no limit.
const SERVER_MAX_OUTGOING_BANDWIDTH: i32 = 0; // 0 means no limit.
const SERVER_EVENT_TIMEOUT: u32 = 1000; // In milliseconds.

pub fn main() void {
    if (c_enet.enet_initialize() != 0) {
        @panic("Couldn't initialize ENet!");
    }
    defer c_enet.enet_deinitialize();

    const server_address = c_enet.ENetAddress{ .host = c_enet.ENET_HOST_ANY, .port = SERVER_PORT };
    const server_host = c_enet.enet_host_create(&server_address, SERVER_CHANNEL_COUNT, SERVER_MAX_PEER_COUNT, SERVER_MAX_INCOMING_BANDWIDTH, SERVER_MAX_OUTGOING_BANDWIDTH) orelse {
        @panic("Couldn't create the server host!");
    };
    defer c_enet.enet_host_destroy(server_host);

    server_host.*.checksum = c_enet.enet_crc32;
    if (c_enet.enet_host_compress_with_range_coder(server_host) != 0) {
        @panic("Couldn't setup compression for the server host!");
    }

    while (true) {
        var event = c_enet.ENetEvent{};
        while (c_enet.enet_host_service(server_host, &event, SERVER_EVENT_TIMEOUT) > 0) {
            switch (event.type) {
                c_enet.ENET_EVENT_TYPE_CONNECT => {
                    std.log.debug("A client has connected.", .{});
                },
                c_enet.ENET_EVENT_TYPE_DISCONNECT => {
                    std.log.debug("A client has disconnected.", .{});
                },
                c_enet.ENET_EVENT_TYPE_RECEIVE => {
                    std.log.debug("A client has sent a packet.", .{});
                },
                else => {},
            }
        }
    }
}
