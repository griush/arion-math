const std = @import("std");
const zm = @import("zm");

var prng = std.Random.Pcg.init(0);
const random = prng.random();

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const g_allocator = gpa.allocator();

pub fn main() !void {
    std.debug.print("zm - Benchmarks\n", .{});

    var timer = try std.time.Timer.start();
    std.debug.print("Generating random data...\n", .{});
    const count = 50_000_000;
    var vec3s = try std.ArrayList(zm.Vec3).initCapacity(g_allocator, count);
    for (0..count) |_| {
        try vec3s.append(zm.Vec3.from(.{ random.float(f32), random.float(f32), random.float(f32) }));
    }

    std.debug.print("Done, took: {d}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1_000_000.0});

    // dot product
    for (0..count - 1) |i| {
        const a = vec3s.items[i];
        const b = vec3s.items[i + 1];

        const c = a.dot(b);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec3 dot({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });

    // Normalize
    for (0..count) |i| {
        const v = vec3s.items[i].normalized();
        std.mem.doNotOptimizeAway(v);
    }

    std.debug.print("Test - Vec3 Normalize({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });

    // Lerp
    for (0..count - 1) |i| {
        const a = vec3s.items[i];
        const b = vec3s.items[i + 1];

        const c = zm.Vec3.lerp(a, b, 0.5);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec3 Lerp({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });

    // Cross + scale
    for (0..count - 1) |i| {
        const a = vec3s.items[i];
        const b = vec3s.items[i + 1];

        const c = a.cross(b).scale(2.0);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec3 Cross + Vec3 scale({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });

    // mat mul vec
    for (0..count) |i| {
        const m = zm.Mat4.perspective(std.math.pi / 2.0, 16.0 / 9.0, 0.05, 100.0);
        const v3 = vec3s.items[i];
        const v = zm.Vec4.from(.{ v3.x(), v3.y(), v3.z(), 1.0 });
        const r = zm.Mat4.multiplyVec4(m, v);

        std.mem.doNotOptimizeAway(r);
    }

    std.debug.print("Test - Mat4 multiply Vec4({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
}
