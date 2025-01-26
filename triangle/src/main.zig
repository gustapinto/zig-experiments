const std = @import("std");

fn get_rows_from_command_line_args(allocator: std.mem.Allocator) !u64 {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        return error.CallWithoutRows;
    }

    return try std.fmt.parseInt(u64, args[1], 10);
}

fn print_triangle(allocator: std.mem.Allocator, stdout: anytype, rows: u64) !void {
    for (1..rows + 1) |i| {
        var list = std.ArrayList(u8).init(allocator);
        defer list.deinit();

        const spaces: u64 = @as(u64, rows - i);
        const stars: u64 = @as(u64, ((i * 2) - 1));

        try list.appendNTimes(' ', spaces);
        try list.appendNTimes('*', stars);

        const line = try list.toOwnedSlice();
        defer allocator.free(line);

        try stdout.print("{s}\n", .{line});
    }
}

pub fn main() !void {
    // Inicializa um alocador de memória
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Obtém argumentos de linha de comando
    const rows = get_rows_from_command_line_args(allocator) catch {
        try stdout.print("Triangle rows not provided", .{});
        try bw.flush();
        std.process.exit(1);
    };

    try print_triangle(allocator, stdout, rows);
    try bw.flush();
}
