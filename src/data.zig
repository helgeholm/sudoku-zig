const std = @import("std");

pub const Board = struct {
    cell: [9 * 9]u4 = undefined,
    pub fn get(self: *Board, row: usize, col: usize) u4 {
        return self.cell[row * 9 + col];
    }

    pub fn set(self: *Board, row: usize, col: usize, val: u4) void {
        self.cell[row * 9 + col] = val;
    }

    pub fn options(self: *Board, row: usize, col: usize) [10]bool {
        var opts = [_]bool{true} ** 10;
        const p = row * 9 + col;
        for ((comptime effectors())[p]) |e| {
            opts[self.cell[e]] = false;
        }
        return opts;
    }

    pub fn write(self: *Board, out: anytype) !void {
        for (0..9) |row| {
            if (row % 3 == 0)
                try out.writer().writeAll("+---+---+---+\n");
            for (0..9) |col| {
                if (col % 3 == 0)
                    try out.writer().writeByte('|');
                const v = self.get(row, col);
                try out.writer().writeByte(switch (v) {
                    0 => ' ',
                    else => '0' + @as(u8, v),
                });
            }
            try out.writer().writeAll("|\n");
        }
        try out.writer().writeAll("+---+---+---+\n");
    }

    pub fn read(self: *Board, reader: anytype) !void {
        var input: [256]u8 = undefined;
        const n = try reader.readAll(input[0..input.len]);
        var pos: usize = 0;
        for (input[0..n]) |c| {
            switch (c) {
                ' ' => {
                    self.cell[pos] = 0;
                    pos += 1;
                },
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' => {
                    self.cell[pos] = @intCast(c - '0');
                    pos += 1;
                },
                else => {},
            }
            if (pos == self.cell.len) {
                break;
            }
        }
    }
};

fn square(rowOrCol: usize) usize {
    return @divTrunc(rowOrCol, 3);
}

fn effectors() [81][20]usize {
    @setEvalBranchQuota(25000);
    var result: [81][20]usize = undefined;
    for (0..81) |i| {
        const row = @divTrunc(i, 9);
        const col = i % 9;
        var effector = 0;
        for (0..81) |j| {
            if (i == j) continue;
            const otherRow = @divTrunc(j, 9);
            const otherCol = j % 9;
            const sameRow = row == otherRow;
            const sameCol = col == otherCol;
            const sameSquare = square(row) == square(otherRow) and square(col) == square(otherCol);
            if (sameRow or sameCol or sameSquare) {
                result[i][effector] = otherRow * 9 + otherCol;
                effector += 1;
            }
        }
    }
    return result;
}
