#lang forge

open "latinsquare.frg"

pred threebythree {
    wellformed_graph
    wellformed_colorings
    row_and_column_specs
    allIntersect
}

pred coloringOnce {
    //no color is in the same row/column as another
    all v: Vertex, c: Coloring | {
        c.color[v] not in ~(c.color).(v.adjacent)
    }
}

assert coloringOnce is necessary for threebythree