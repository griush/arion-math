// On my Intel® Core™ i9-9900K
// Test - Vec3 Normalize(100_000_000): 176 ms
// Test - Mat4 multiply Vec4(100_000_000): 175 ms
//

const std = @import("std");
const zm = @import("zm");

var prng = std.Random.Pcg.init(0);
const random = prng.random();

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const g_allocator = gpa.allocator();

const Timer = struct {
    start: i64,

    pub fn init() Timer {
        return Timer{
            .start = std.time.milliTimestamp(),
        };
    }

    pub fn milliElapsed(self: Timer) i64 {
        return std.time.milliTimestamp() - self.start;
    }

    pub fn reset(self: *Timer) void {
        self.start = std.time.milliTimestamp();
    }
};

pub fn main() !void {
    std.debug.print("zm - Benchmarks\n", .{});

    var timer = Timer.init();
    std.debug.print("Generating data...\n", .{});
    const count = 100_000_000;
    var vec3s = try std.ArrayList(zm.Vec3).initCapacity(g_allocator, count);
    for (0..count) |_| {
        try vec3s.append(zm.Vec3.from(random.float(f32), random.float(f32), random.float(f32)));
    }

    std.debug.print("Done, took: {d}ms\n", .{timer.milliElapsed()});
    timer.reset();

    // Normalize
    for (0..count) |i| {
        var v = vec3s.items[i];
        _ = v.normalize();

        std.mem.doNotOptimizeAway(v);
    }

    std.debug.print("Test - Vec3 Normalize({d}): {d} ms\n", .{ count, timer.milliElapsed() });
    timer.reset();

    // Cross + scale
    // for (0..count) |_| {
    //     // const a = zm.Vec3.from(random.float(f32), random.float(f32), random.float(f32));
    //     // const b = zm.Vec3.from(random.float(f32), random.float(f32), random.float(f32));
    //     const a = zm.Vec3.up();
    //     const b = zm.Vec3.up();
    //
    //     var c = a.cross(b);
    //     _ = c.scaleMut(0.1);
    // }
    //
    // std.debug.print("Test - Vec3 Cross + Vec3 scale + random generation({d}): {d} ms\n", .{ count, timer.milliElapsed() });
    // timer.reset();

    // mat mul vec
    for (0..count) |i| {
        const m = zm.Mat4.perspective(std.math.pi / 2.0, 16.0 / 9.0, 0.05, 100.0);
        // const v = zm.Vec4.from(random.float(f32), random.float(f32), random.float(f32), random.float(f32));
        const v = zm.Vec4.fromVec3(vec3s.items[i], 1.0);
        const r = zm.Mat4.multiplyByVec4(m, v);

        std.mem.doNotOptimizeAway(r);
    }

    std.debug.print("Test - Mat4 multiply Vec4({d}): {d} ms\n", .{ count, timer.milliElapsed() });
    timer.reset();
}