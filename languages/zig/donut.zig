const std = @import("std");

const Config = struct {
    width: usize = 80,
    height: usize = 22,
    r1: f64 = 1.0,
    r2: f64 = 2.0,
    k1: f64 = 30.0,
    k2: f64 = 5.0,
    a_step: f64 = 0.04,
    b_step: f64 = 0.02,
    theta_step: f64 = 0.07,
    phi_step: f64 = 0.02,
    shading: []const u8 = ".,-~:;=!*#$@",
    benchmark: bool = false,
    frames: usize = 500,
};

const Renderer = struct {
    cfg: Config,
    a: f64 = 0.0,
    b: f64 = 0.0,

    fn stepAngles(self: *Renderer) void {
        self.a += self.cfg.a_step;
        self.b += self.cfg.b_step;
    }

    fn renderFrame(self: *Renderer, allocator: std.mem.Allocator) ![]u8 {
        const size = self.cfg.width * self.cfg.height;
        var buffer = try allocator.alloc(u8, size);
        defer allocator.free(buffer);
        @memset(buffer, ' ');

        var zbuffer = try allocator.alloc(f64, size);
        defer allocator.free(zbuffer);
        @memset(zbuffer, 0.0);

        const sin_a = @sin(self.a);
        const cos_a = @cos(self.a);
        const sin_b = @sin(self.b);
        const cos_b = @cos(self.b);

        var theta: f64 = 0.0;
        while (theta < std.math.tau) : (theta += self.cfg.theta_step) {
            const theta_sin = @sin(theta);
            const theta_cos = @cos(theta);
            const circle_x = self.cfg.r2 + self.cfg.r1 * theta_cos;
            const circle_y = self.cfg.r1 * theta_sin;

            var phi: f64 = 0.0;
            while (phi < std.math.tau) : (phi += self.cfg.phi_step) {
                const phi_sin = @sin(phi);
                const phi_cos = @cos(phi);

                const x = circle_x * phi_cos;
                const y = circle_x * phi_sin;
                const z = circle_y;

                const x1 = x;
                const y1 = y * cos_a - z * sin_a;
                const z1 = y * sin_a + z * cos_a;

                const x2 = x1 * cos_b - y1 * sin_b;
                const y2 = x1 * sin_b + y1 * cos_b;
                const z2 = z1;

                const ooz = 1.0 / (z2 + self.cfg.k2);
                const xp_f = @as(f64, @floatFromInt(self.cfg.width)) / 2.0 + self.cfg.k1 * ooz * x2;
                const yp_f = @as(f64, @floatFromInt(self.cfg.height)) / 2.0 - (self.cfg.k1 * 0.5) * ooz * y2;
                const xp = @as(isize, @intFromFloat(xp_f));
                const yp = @as(isize, @intFromFloat(yp_f));

                const luminance = phi_cos * theta_cos * sin_b
                    - cos_a * theta_cos * phi_sin
                    - sin_a * theta_sin
                    + cos_b * (cos_a * theta_sin - theta_cos * sin_a * phi_sin);

                if (luminance > 0.0 and xp >= 0 and yp >= 0 and xp < self.cfg.width and yp < self.cfg.height) {
                    const idx = @as(usize, @intCast(xp)) + self.cfg.width * @as(usize, @intCast(yp));
                    if (ooz > zbuffer[idx]) {
                        zbuffer[idx] = ooz;
                        var shade = @as(isize, @intFromFloat(luminance * 8.0));
                        if (shade < 0) shade = 0;
                        if (shade >= self.cfg.shading.len) shade = @as(isize, @intCast(self.cfg.shading.len - 1));
                        buffer[idx] = self.cfg.shading[@as(usize, @intCast(shade))];
                    }
                }
            }
        }

        var out = try allocator.alloc(u8, size + self.cfg.height);
        var p: usize = 0;
        for (0..self.cfg.height) |y| {
            for (0..self.cfg.width) |x| {
                out[p] = buffer[x + y * self.cfg.width];
                p += 1;
            }
            out[p] = '\n';
            p += 1;
        }
        return out;
    }
};

pub fn main() !void {
    var cfg = Config{};
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.next();

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--benchmark")) cfg.benchmark = true
        else if (std.mem.eql(u8, arg, "--width")) if (args.next()) |v| cfg.width = try std.fmt.parseUnsigned(usize, v, 10)
        else if (std.mem.eql(u8, arg, "--height")) if (args.next()) |v| cfg.height = try std.fmt.parseUnsigned(usize, v, 10)
        else if (std.mem.eql(u8, arg, "--r1")) if (args.next()) |v| cfg.r1 = try std.fmt.parseFloat(f64, v)
        else if (std.mem.eql(u8, arg, "--r2")) if (args.next()) |v| cfg.r2 = try std.fmt.parseFloat(f64, v)
        else if (std.mem.eql(u8, arg, "--k1")) if (args.next()) |v| cfg.k1 = try std.fmt.parseFloat(f64, v)
        else if (std.mem.eql(u8, arg, "--k2")) if (args.next()) |v| cfg.k2 = try std.fmt.parseFloat(f64, v)
        else if (std.mem.eql(u8, arg, "--a-step")) if (args.next()) |v| cfg.a_step = try std.fmt.parseFloat(f64, v)
        else if (std.mem.eql(u8, arg, "--b-step")) if (args.next()) |v| cfg.b_step = try std.fmt.parseFloat(f64, v)
        else if (std.mem.eql(u8, arg, "--theta-step")) if (args.next()) |v| cfg.theta_step = try std.fmt.parseFloat(f64, v)
        else if (std.mem.eql(u8, arg, "--phi-step")) if (args.next()) |v| cfg.phi_step = try std.fmt.parseFloat(f64, v)
        else if (std.mem.eql(u8, arg, "--frames")) if (args.next()) |v| cfg.frames = try std.fmt.parseUnsigned(usize, v, 10)
        else if (std.mem.eql(u8, arg, "--shading")) if (args.next()) |v| cfg.shading = v;
    }

    var renderer = Renderer{ .cfg = cfg };
    const stdout = std.io.getStdOut().writer();

    if (cfg.benchmark) {
        const start = std.time.nanoTimestamp();
        for (0..cfg.frames) |_| {
            const frame = try renderer.renderFrame(allocator);
            allocator.free(frame);
            renderer.stepAngles();
        }
        const end = std.time.nanoTimestamp();
        const total = @as(f64, @floatFromInt(end - start)) / 1_000_000_000.0;
        const avg = total / @as(f64, @floatFromInt(cfg.frames));
        const fps = @as(f64, @floatFromInt(cfg.frames)) / total;
        try stdout.print("Language: Zig\n", .{});
        try stdout.print("Frames: {}\n", .{cfg.frames});
        try stdout.print("Total Time: {d:.4}s\n", .{total});
        try stdout.print("Avg Frame Time: {d:.2}ms\n", .{avg * 1000.0});
        try stdout.print("FPS: {d:.2}\n", .{fps});
        return;
    }

    try stdout.writeAll("\x1b[2J");
    while (true) {
        const frame = try renderer.renderFrame(allocator);
        defer allocator.free(frame);
        try stdout.writeAll("\x1b[H\x1b[2J");
        try stdout.writeAll(frame);
        renderer.stepAngles();
    }
}
