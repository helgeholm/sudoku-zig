const Board = @import("data.zig").Board;

pub fn solve(board: *Board) bool {
    for (0..9) |row| {
        for (0..9) |col| {
            if (board.get(row, col) != 0)
                continue;
            const opts = board.options(row, col);
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
