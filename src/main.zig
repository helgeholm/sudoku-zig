const std = @import("std");
const Board = @import("data.zig").Board;
const solve_r = @import("solve_rec.zig").solve;

pub fn main() !void {
    var boardIn = Board{};
    try boardIn.read(std.io.getStdIn());
    var board = boardIn;
    std.debug.print("Input\n", .{});
    try board.write(std.io.getStdOut());
    _ = solve_r(&board);
    std.debug.print("\nSolution\n", .{});
    try board.write(std.io.getStdOut());
    const N = 1000;
    benchmark(N, boardIn, "rec", solve_r);
}

fn benchmark(n: u32, board: Board, name: []const u8, solver: anytype) void {
    std.debug.print("\nBenchmarking {s} N={}...\n", .{ name, n });
    var runs: u64 = 0;
    const before = std.time.milliTimestamp();
    for (0..n) |_| {
        var bBoard = board;
        if (solver(&bBoard)) runs += 1;
    }
    const delta = std.time.milliTimestamp() - before;
    std.debug.print("N={}, t={}ms, avg={d:2}ms\n", .{ n, delta, @as(f32, @floatFromInt(delta)) / @as(f32, @floatFromInt(n)) });
}
