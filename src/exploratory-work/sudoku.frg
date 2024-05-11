#lang forge

sig Position {
    row: Int,
    column: Int,
}

sig Cell {
    rows: set Int,
    columns: set Int,
}

one sig Puzzle {
    values: pfunc Position -> Int
}

pred wellformed {
    // number of unique rows and columns is the same
    #{p: Position | p.row } = #{p: Position | p.column }
}