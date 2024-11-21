const std = @import("std");

const Board = struct {
    cell: [9 * 9]u4 = undefined,
    fn get(self: *Board, row: usize, col: usize) u4 {
        return self.cell[row * 9 + col];
    }
    fn set(self: *Board, row: usize, col: usize, val: u4) void {
        self.cell[row * 9 + col] = val;
    }
};

pub fn main() !void {
    var boardIn = Board{};
    try readInto(&boardIn, std.io.getStdIn());
    var board = boardIn;
    std.debug.print("Input\n", .{});
    try printBoard(&board);
    _ = solve(&board);
    std.debug.print("\nSolution\n", .{});
    try printBoard(&board);
    const N = 1000;
    std.debug.print("\nBenchmarking N={}...\n", .{N});
    var runs: u64 = 0;
    const before = std.time.milliTimestamp();
    for (0..N) |_| {
        var bBoard = boardIn;
        if (solve(&bBoard)) runs += 1;
    }
    const delta = std.time.milliTimestamp() - before;
    std.debug.print("N={}, t={}ms, avg={d:2}ms\n", .{ N, delta, @as(f32, @floatFromInt(delta)) / N });
}

inline fn square(rowOrCol: usize) usize {
    return @divTrunc(rowOrCol, 3);
}

fn solve(board: *Board) bool {
    for (0..9) |row| {
        const sRow = square(row);
        for (0..9) |col| {
            if (board.get(row, col) != 0)
                continue;
            const sCol = square(col);
            var opts = [_]bool{true} ** 10;
            for (0..9) |otherRow| {
                if (row == otherRow) {
                    for (0..9) |otherCol|
                        opts[board.get(otherRow, otherCol)] = false;
                    continue;
                }
                const otherSRow = square(otherRow);
                for (0..9) |otherCol| {
                    if (col == otherCol or sCol == square(otherCol) and sRow == otherSRow)
                        opts[board.get(otherRow, otherCol)] = false;
                }
            }
            for (1..10) |value| {
                if (opts[value]) {
                    board.set(row, col, @intCast(value));
                    if (solve(board))
                        return true;
                }
            }
            board.set(row, col, 0);
            return false;
        }
    }
    return true;
}

fn printBoard(board: *Board) !void {
    const out = std.io.getStdOut();
    for (0..9) |row| {
        if (row % 3 == 0)
            try out.writer().writeAll("+---+---+---+\n");
        for (0..9) |col| {
            if (col % 3 == 0)
                try out.writer().writeByte('|');
            const v = board.get(row, col);
            try out.writer().writeByte(switch (v) {
                0 => ' ',
                else => '0' + @as(u8, v),
            });
        }
        try out.writer().writeAll("|\n");
    }
    try out.writer().writeAll("+---+---+---+\n");
}

fn readInto(board: *Board, reader: anytype) !void {
    var input: [256]u8 = undefined;
    const n = try reader.readAll(input[0..input.len]);
    var pos: usize = 0;
    for (input[0..n]) |c| {
        switch (c) {
            ' ' => {
                board.cell[pos] = 0;
                pos += 1;
            },
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' => {
                board.cell[pos] = @intCast(c - '0');
                pos += 1;
            },
            else => {},
        }
        if (pos == board.cell.len) {
            break;
        }
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
