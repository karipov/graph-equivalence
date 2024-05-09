# Colorful Complexity: Graph Coloring in Diverse Domains

## Project Objective

> Can some problems be reduced to graph coloring problems? Can we solve certain problems simply by finding a coloring of a corresponding graph?

In this project we explore two problems that can be translated to graph coloring problems: scheduling and latin squares. We not only check that a translation is possible, but also show that 


## Model Design and Signatures

We start with modeling graph coloring, scheduling and latin squares individually. Our expected solution space is all the possible graph colorings, all the possible scheduling and all the possible solutions to latin squares. 

#### Graph and Coloring Representation

In the midterm project, we represented the graph as a Vertex and a set of other vertices it is adjacent to. We have chosen to keep this characterization.

```
sig Vertex {
  adjacent: set Vertex
}
```

Now that we have a have a working model for a Graph, we can start thinking about how to model the coloring of the graph. We start by defining a set of colors and a function that maps each vertex to a color. To do this, we create a `Coloring` sig with a `pfunc`, as described.

```
sig Color {}

one sig Coloring {
    color: pfunc Vertex -> Color
}
```

#### Scheduling


## Predicates and Visualization

We can divide our predicates into two groups: those that check the existence of a graph coloring and those that check the validity of a greedy graph coloring algorithm.

#### Existence of Graph Coloring

- Our `wellformed` predicate checks that the graph is connected, undirected and has no self loops. Though there exist graph coloring algorithms that work with directed graphs, we thought that undirected graphs were more interesting. Furthermore, we wanted our graphs to be connected, because colorings for disconnected graphs can be reduced to colorings for each connected component of the graph. These are all choices and abstractions that we have built into our model.

- Our `wellformed_colorings` predicate checks that the coloring is valid. This means that no two adjacent vertices share the same color. We also check that the coloring is complete, i.e. every vertex has a color. This is the essence of graph coloring.

When run together, for N vertices and M colors, we get all the possible colorings of graphs with N vertices and M colors. If a graph with N vertices cannot be colored with M colors, we get UNSAT. Sterling gives us a nice visualization.

### Existence of Scheduling solution