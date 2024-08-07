const std = @import("std");

const root = @import("root.zig");

pub fn Vec(comptime len: u8, comptime T: type) type {
    const type_info = @typeInfo(T);
    comptime switch (type_info) {
        .Int, .Float => {},
        else => @compileError("Vec only supports numerical type. Type '" ++ @typeName(T) ++ "' is not supported"),
    };

    return struct {
        const Self = @This();
        const Float = std.meta.Float;

        data: @Vector(len, T),

        pub const precision = switch (type_info) {
            .Int => |int| int.bits,
            .Float => |float| float.bits,
            else => unreachable,
        };

        pub fn from(in: @Vector(len, T)) Self {
            return Self{
                .data = in,
            };
        }

        pub fn zero() Self {
            return Self{
                .data = @splat(@as(T, 0)),
            };
        }

        pub fn right() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 1, 0, 0 },
            };
        }

        pub fn left() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ -1, 0, 0 },
            };
        }

        pub fn up() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 0, 1, 0 },
            };
        }

        pub fn down() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 0, -1, 0 },
            };
        }

        pub fn forward() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 0, 0, 1 },
            };
        }

        pub fn back() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 0, 0, -1 },
            };
        }

        pub fn x(self: Self) T {
            if (len < 1) {
                @compileError("len must be at least 1 to get x component");
            }

            return self.data[0];
        }

        pub fn y(self: Self) T {
            if (len < 2) {
                @compileError("len must be at least 2 to get y component");
            }

            return self.data[1];
        }

        pub fn z(self: Self) T {
            if (len < 3) {
                @compileError("len must be at least 3 to get z component");
            }

            return self.data[2];
        }

        pub fn w(self: Self) T {
            if (len < 4) {
                @compileError("len must be at least 4 to get w component");
            }

            return self.data[3];
        }

        pub fn add(l: Self, r: Self) Self {
            return Self{
                .data = l.data + r.data,
            };
        }

        pub fn sub(l: Self, r: Self) Self {
            return Self{
                .data = l.data - r.data,
            };
        }

        pub fn neg(self: Self) Self {
            return Self{
                .data = -self.data,
            };
        }

        pub inline fn scale(self: Self, s: T) Self {
            return Self{
                .data = self.data * @as(@Vector(len, T), @splat(s)),
            };
        }

        pub fn squareLength(self: Self) Float(precision) {
            const l = @reduce(.Add, self.data * self.data);
            switch (type_info) {
                .Int => return @floatFromInt(l),
                .Float => return l,
                else => unreachable,
            }
        }

        pub fn length(self: Self) Float(precision) {
            return @sqrt(self.squareLength());
        }

        pub fn normalized(self: Self) Vec(len, Float(precision)) {
            const norm = self.length();
            if (len == 0.0) return Vec(len, Float(precision)).zero();

            return self.scale(1.0 / norm);
        }

        pub fn dot(l: Self, r: Self) T {
            return @reduce(.Add, l.data * r.data);
        }

        pub fn cross(l: Vec(3, T), r: Vec(3, T)) Vec(3, T) {
            if (len != 3) {
                @compileError("Vector parameters must have three elements for cross() to be defined");
            }

            return Vec(3, T){
                .data = .{
                    l.y() * r.z() - l.z() * r.y(),
                    l.z() * r.x() - l.x() * r.z(),
                    l.x() * r.y() - l.y() * r.x(),
                },
            };
        }

        pub fn distance(a: Self, b: Self) Float(precision) {
            return Self.from(b.data - a.data).length();
        }

        pub fn angle(a: Self, b: Self) Float(precision) {
            switch (type_info) {
                .Float => {
                    const dot_product = a.dot(b);
                    return std.math.acos(dot_product / (a.length() * b.length()));
                },
                .Int => {
                    const fa = Vec(len, Float(precision)).from(@floatFromInt(a.data));
                    const fb = Vec(len, Float(precision)).from(@floatFromInt(b.data));

                    const dot_product = fa.dot(fb);
                    return std.math.acos(dot_product / (fa.length() * fb.length()));
                },
                else => unreachable,
            }
        }

        /// No extrapolation. Clamps `t`.
        ///
        /// `T` must be `.Float`.
        pub fn lerp(a: Self, b: Self, t: Float(precision)) Self {
            return Self{
                .data = @mulAdd(@Vector(len, T), b.data - a.data, @splat(t), a.data),
            };
        }

        // TODO: Finish format
        // /// This function allows `Vectors` to be formated by Zig's `std.fmt`.
        // /// Example: `std.debug.print("Vec: {any}", .{ zm.Vec3.up() });`
        // pub fn format(
        //     v: Self,
        //     comptime fmt: []const u8,
        //     options: std.fmt.FormatOptions,
        //     writer: anytype,
        // ) !void {
        //     _ = fmt;
        //     _ = options;
        //
        //     try writer.print("(" ++ ("{d}, " ** len) ++ ")", .{});
        // }
    };
}
