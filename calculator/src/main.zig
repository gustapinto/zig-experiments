const std = @import("std");

fn input_str(comptime message: []const u8, args: anytype) ![]const u8 {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var buf: [100]u8 = undefined;

    try stdout.print(message, args);

    const result = try stdin.readUntilDelimiterOrEof(&buf, '\n');
    if (result) |user_input| { // Handle optional value
        return user_input;
    }

    return "";
}

fn input_number(comptime message: []const u8, args: anytype) !i64 {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var buf: [100]u8 = undefined;

    try stdout.print(message, args);

    const result = try stdin.readUntilDelimiterOrEof(&buf, '\n');
    if (result) |user_input| {
        return std.fmt.parseInt(i64, user_input, 10) catch {
            return @as(i64, 0);
        };
    }

    return @as(i64, 0);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // const n1 = try input_number("First Number: ", .{});
    // const n2 = try input_number("Second Number: ", .{});
    const operator = try input_str("Operator: ", .{});

    // std.debug.print("\n{s}\n", .{operator});

    // try stdout.print("Sum: {d}\n", .{n1});
    try stdout.print("Operator: {s}\n", .{operator});
}
