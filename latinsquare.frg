#lang forge

sig Color {}

sig Vertex {
    adjacent: set Vertex
}

sig Coloring {
    color: pfunc Vertex -> Color
}

//every vertex has exactly 4 neighbors-- its row and column mates
pred row_and_column_specs {
    all v: Vertex | {
        #{v.adjacent} = 4
    }
}

//all vertexes need to share at least one common vertex
//vertexes in separate rows/columns share 2
pred allIntersect {
    all disj v1, v2: Vertex | {
        #{v1.adjacent & v2.adjacent} >= 1
        v2 in v1.adjacent => #{v1.adjacent & v2.adjacent} = 1
    }
}

//every vertex has exactly 6 neighbors-- its row and column mates
pred row_and_column_specs16 {
    all v: Vertex | {
        #{v.adjacent} = 6
    }
}

//every two vertexes should have two members in their intersection (column and row intersection)
//and if two vertexes are in the same row or column, their mates should be in their intersection--
//which means that they should also share the same column mates as their mates
pred allIntersect16 {
    all disj v1, v2: Vertex | {
        #{v1.adjacent & v2.adjacent} = 2
        v2 in v1.adjacent => {
            all v3: Vertex | v3 in (v1.adjacent & v2.adjacent) => #{v1.adjacent & v2.adjacent & v3.adjacent} = 1
        }
    }
}

// all graphs are well-formed
pred wellformed_graph {
    all disj v1, v2: Vertex | {
        // connected
        reachable[v1, v2, adjacent] 

        // undirected
        v1 in v2.adjacent implies v2 in v1.adjacent
    }

    // no self loops
    all v: Vertex | {not v in v.adjacent}
}

pred wellformed_colorings {
    // all vertices are colored
    all coloring: Coloring | {

        // all colors are used
        all c: Color | some vertex: Vertex | coloring.color[vertex] = c

        // all vertices are colored
        all vertex: Vertex | one coloring.color[vertex]
    
        // no two adjacent vertices have the same color
    all disj v1, v2: Vertex | {
        v2 in v1.adjacent implies (coloring.color[v2] != coloring.color[v1])
    }
    }
}

pred is_wellformed_coloring[coloring:Coloring] {
    all vertex: Vertex | one coloring.color[vertex]
    // no two adjacent vertices have the same color
    all disj v1, v2: Vertex | {
        v2 in v1.adjacent implies (coloring.color[v2] != coloring.color[v1])
    }
}

run { 
  wellformed_graph
  wellformed_colorings
  row_and_column_specs
  allIntersect
} for exactly 9 Vertex, exactly 3 Color, exactly 1 Coloring

// run {
//   wellformed_graph
//   wellformed_colorings
//   row_and_column_specs16
//   allIntersect16  
// } for exactly 16 Vertex, exactly 4 Color, exactly 1 Coloring
