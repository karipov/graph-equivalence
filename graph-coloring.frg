sig Vertex {
  adjacent: set Vertex
}

sig Color {}

sig Coloring {
    color: pfunc Vertex -> Color
}

// all graphs are well-formed
pred wellformed {
  all disj v1, v2: Vertex | {
    -- connected
    reachable[v1, v2, adjacent] 

    -- undirected
    v1 in v2.adjacent implies v2 in v1.adjacent
  }

  -- no self loops
  all v: Vertex | {not v in v.adjacent}
}

pred wellformed_colorings {
  -- all vertices are colored
  all coloring : Coloring | {
    all vertex: Vertex | one coloring.color[vertex]

  -- no two adjacent vertices have the same color
    all disj v1, v2: Vertex | {
      v2 in v1.adjacent implies (coloring.color[v2] != coloring.color[v1])
    }
  }
}

// run { 
//   wellformed
//   wellformed_colorings
// } for exactly 3 Vertex, exactly 2 Color, exactly 1 Coloring
