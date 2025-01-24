const std = @import("std");

fn input_str(comptime message: []const u8) ![]const u8 {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var buf: [100]u8 = undefined;

    try stdout.print(message, .{});

    const result = try stdin.readUntilDelimiterOrEof(&buf, '\n');
    if (result) |user_input| { // Handle optional value
        return @as([]const u8, user_input);
    }

    return "";
}

fn input_number(comptime message: []const u8) !f64 {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var buf: [100]u8 = undefined;

    try stdout.print(message, .{});

    const result = try stdin.readUntilDelimiterOrEof(&buf, '\n');
    if (result) |user_input| {
        return std.fmt.parseFloat(f64, user_input) catch {
            return @as(f64, 0);
        };
    }

    return @as(f64, 0);
}

fn calculate_result(n1: f64, n2: f64, operator: []const u8) !f64 {
    return switch (operator[0]) {
        '+' => n1 + n2,
        '-' => n1 - n2,
        '*' => n1 * n2,
        '/' => n1 / n2,
        else => error.InvalidOperator,
    };
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const n1: f64 = try input_number("First Number: ");
    const n2: f64 = try input_number("Second Number: ");
    const operator: []const u8 = try input_str("Operator: ");
    const result: f64 = try calculate_result(n1, n2, operator);

    try stdout.print("{d} {c} {d} = {d}", .{ n1, operator[0], n2, result });
}
