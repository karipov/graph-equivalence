#lang forge

open "graph-coloring.frg"
open "scheduling.frg"
open "equivalence.frg"


// testing equivalence


// basic tests for graph coloring
test suite for wellformed_graph {

  // wellformed graphs are not directed
  example directed is {not wellformed_graph} for {
    Vertex = `Vertex1 + `Vertex2
    `Vertex1.adjacent = `Vertex2
  }

  // wellformed graphs are not disconnected
  example unconnected is {not wellformed_graph} for {
    Vertex = `Vertex1 + `Vertex2
  }

  // wellformed graphs don't contain self loops
  example selfLoop is {not wellformed_graph} for {
    Vertex = `Vertex1
    `Vertex1.adjacent = `Vertex1
  }

  // cyclic graphs are an example of wellformed graphs
  example cyclic is {wellformed_graph} for {
    Vertex = `Vertex1 + `Vertex2 + `Vertex3 + `Vertex4 + `Vertex5
    `Vertex1.adjacent = `Vertex5 + `Vertex2
    `Vertex2.adjacent = `Vertex1 + `Vertex3
    `Vertex3.adjacent = `Vertex2 + `Vertex4
    `Vertex4.adjacent = `Vertex3 + `Vertex5
    `Vertex5.adjacent = `Vertex4 + `Vertex1
  }

  //trees are examples of wellformed graphs
  example SixVertexTree is {wellformed_graph} for {
    Vertex = `Vertex1 + `Vertex2 + `Vertex3 + `Vertex4 + `Vertex5 + `Vertex6
    `Vertex1.adjacent = `Vertex2 + `Vertex3 + `Vertex6
    `Vertex2.adjacent = `Vertex1 + `Vertex4 + `Vertex5
    `Vertex3.adjacent = `Vertex1
    `Vertex4.adjacent = `Vertex2
    `Vertex5.adjacent = `Vertex2
    `Vertex6.adjacent = `Vertex1
  }

  // cliques are examples of wellformed graphs
  example ThreeClique is {wellformed_graph} for {
    Vertex = `Vertex1 + `Vertex2 + `Vertex3 
    `Vertex1.adjacent = `Vertex2 + `Vertex3
    `Vertex2.adjacent = `Vertex1 + `Vertex3
    `Vertex3.adjacent = `Vertex2 + `Vertex1
  }
}

pred wellformed_and_colored { wellformed_graph and wellformed_colorings }

test suite for wellformed_and_colored {
    -- no graph can be colored with one color
    test expect { one_color_impossible: {
        wellformed_and_colored
        #{v: Vertex | some v} > 1
    } for exactly 1 Color is unsat}

    test expect {incomplete_color: {
      wellformed_and_colored
      some vertex: Vertex | {no Coloring.color[vertex]}
      } for exactly 1 Coloring is unsat} 

    -- any tree can be colored with two colors
    example fiveVertexTree is { wellformed_and_colored } for {
      Vertex = `Vertex1 + `Vertex2 + `Vertex3 + `Vertex4 + `Vertex5
      `Vertex1.adjacent = `Vertex2 + `Vertex3
      `Vertex2.adjacent = `Vertex1 + `Vertex4 + `Vertex5
      `Vertex3.adjacent = `Vertex1
      `Vertex4.adjacent = `Vertex2
      `Vertex5.adjacent = `Vertex2

      Color = `Red + `Blue
      Coloring = `Coloring1
      `Coloring1.color =  `Vertex1 -> `Red + 
                          `Vertex2 -> `Blue +
                          `Vertex3 -> `Blue +
                          `Vertex4 -> `Red +
                          `Vertex5 -> `Red
    }

  -- a clique with N vertices cannot be colored with N-1 colors
  example ThreeCliqueTwoColors is {not wellformed_and_colored} for {
    Vertex = `Vertex1 + `Vertex2 + `Vertex3 
    `Vertex1.adjacent = `Vertex2 + `Vertex3
    `Vertex2.adjacent = `Vertex1 + `Vertex3
    `Vertex3.adjacent = `Vertex2 + `Vertex1

    Color = `Red + `Blue
    Coloring = `Coloring1
    `Coloring1.color =  `Vertex1 -> `Red + 
                        `Vertex2 -> `Blue +
                        `Vertex3 -> `Blue
  }
    
  -- a clique with N vertices can be colored with N colors
  example ThreeCliqueThreeColors is {wellformed_and_colored} for {
    Vertex = `Vertex1 + `Vertex2 + `Vertex3 
    `Vertex1.adjacent = `Vertex2 + `Vertex3
    `Vertex2.adjacent = `Vertex1 + `Vertex3
    `Vertex3.adjacent = `Vertex2 + `Vertex1

    Color = `Red + `Blue + `Green
    Coloring = `Coloring1
    `Coloring1.color =  `Vertex1 -> `Red + 
                        `Vertex2 -> `Blue +
                        `Vertex3 -> `Green
  }

  -- cyclic graphs with an even number of vertices can be colored with 2 colors
  example cyclicEvenTwoColors is {wellformed_and_colored} for {
    Vertex = `Vertex1 + `Vertex2 + `Vertex3 + `Vertex4 + `Vertex5 + `Vertex6
    `Vertex1.adjacent = `Vertex6 + `Vertex2
    `Vertex2.adjacent = `Vertex1 + `Vertex3
    `Vertex3.adjacent = `Vertex2 + `Vertex4
    `Vertex4.adjacent = `Vertex3 + `Vertex5
    `Vertex5.adjacent = `Vertex4 + `Vertex6
    `Vertex6.adjacent = `Vertex5 + `Vertex1

    Color = `Red + `Blue
    Coloring = `Coloring1
    `Coloring1.color =  `Vertex1 -> `Red + 
                        `Vertex2 -> `Blue +
                        `Vertex3 -> `Red +
                        `Vertex4 -> `Blue +
                        `Vertex5 -> `Red +
                        `Vertex6 -> `Blue 
  }
  
  -- a coloring with a non minimal number of colors is still wellformed
  example unoptimal is {wellformed_and_colored} for {
    Vertex = `Vertex1 + `Vertex2 + `Vertex3 + `Vertex4 + `Vertex5 + `Vertex6
    `Vertex1.adjacent = `Vertex6 + `Vertex2
    `Vertex2.adjacent = `Vertex1 + `Vertex3
    `Vertex3.adjacent = `Vertex2 + `Vertex4
    `Vertex4.adjacent = `Vertex3 + `Vertex5
    `Vertex5.adjacent = `Vertex4 + `Vertex6
    `Vertex6.adjacent = `Vertex5 + `Vertex1

    Color = `Red + `Blue + `Green
    Coloring = `Coloring1
    `Coloring1.color =  `Vertex1 -> `Red + 
                        `Vertex2 -> `Blue +
                        `Vertex3 -> `Red +
                        `Vertex4 -> `Green +
                        `Vertex5 -> `Red +
                        `Vertex6 -> `Blue
  }
}
