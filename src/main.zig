const std = @import("std");
const Vec3 = @import("vec3.zig");
const color = @import("color.zig");
const Ray = @import("ray.zig");
const Io = std.Io;

const raytrace = @import("raytrace");

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    // In order to do I/O operations need an `Io` instance.
    const io = init.io;

    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    try raytrace.printAnotherMessage(stdout_writer);

    try stdout_writer.flush(); // Don't forget to flush!
                               //
    // globals

    const image_width: usize = 512;
    const image_height: usize = 256;

    // Render
    var buffer: [1024]u8 = undefined;
    const file = try std.Io.Dir.cwd().createFile(init.io, "./res/test_out.ppm", .{});
    defer file.close(init.io);
    const len = try file.realPath(init.io, &buffer);
    std.debug.print("The test begins\n", .{});
    std.debug.print("{s}\n",.{buffer[0..len]});
    var writer = file.writer(init.io, &buffer);
    const w = &writer.interface;
    defer w.flush() catch {};

    try w.print("P3\n{} {}\n255\n",.{image_width, image_height});

    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {}",.{image_height-j});
        for (0..image_width) |i| {
                const r: f64 = @as(f64,@floatFromInt(i)) / @as(f64,@floatFromInt(image_width-1));
                const g: f64 = @as(f64,@floatFromInt(j)) / @as(f64,@floatFromInt(image_height-1));
                const b: f64 = 0.15;

                const pixel: color.Color = .init(r,g,b);

                try color.write_color(w, &pixel);
        }

    }
    std.debug.print("\rDone.                          \n",.{});

}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    try std.testing.fuzz({}, testOne, .{});
}

fn testOne(context: void, smith: *std.testing.Smith) !void {
    _ = context;
    // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!

    const gpa = std.testing.allocator;
    var list: std.ArrayList(u8) = .empty;
    defer list.deinit(gpa);
    while (!smith.eos()) switch (smith.value(enum { add_data, dup_data })) {
        .add_data => {
            const slice = try list.addManyAsSlice(gpa, smith.value(u4));
            smith.bytes(slice);
        },
        .dup_data => {
            if (list.items.len == 0) continue;
            if (list.items.len > std.math.maxInt(u32)) return error.SkipZigTest;
            const len = smith.valueRangeAtMost(u32, 1, @min(32, list.items.len));
            const off = smith.valueRangeAtMost(u32, 0, @intCast(list.items.len - len));
            try list.appendSlice(gpa, list.items[off..][0..len]);
            try std.testing.expectEqualSlices(
                u8,
                list.items[off..][0..len],
                list.items[list.items.len - len ..],
            );
        },
    };
}
