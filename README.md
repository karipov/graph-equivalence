# Colorful Complexity: Graph Coloring in Diverse Domains

<<<<<<< HEAD
![banner](images/banner.png)

## Project Description
> Yeah, #$@! is cool, but have you ever solved a scheduling problem using graph coloring?

Although graph coloring may initially appear to be a purely theoretical problem, it has profound implications in applied fields like operations research and combinatorial optimization. In this project, we explore how the principles of graph coloring are equivalent to, and can be extended to, various practical problems. Specifically, we investigate its application in scheduling, where graph coloring helps in scheduling exams without conflicts, and in constructing Latin squares, which require placing distinct symbols in a grid such that each symbol appears only once per row and column. By examining these equivalences, we aim to enhance the utility of graph coloring properties and demonstrate their broad applicability in solving complex real-world problems.

## Problem Representation
> What tradeoffs did you make in choosing your representation? What else did you try that didn’t work as well?

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

## Visualization
> How should we understand an instance of your model and what your visualization shows (whether custom or default)?

To run the visualization:
1. Adjust the parameters (number of nodes, colors) at the bottom of the `coloring.frg` file and click the green run button.
2. When Sterling opens, copy-paste the contents of `vis.js` into the Script tab, under the \<svg> option and click the blue "Run" button in the top right corner.

You now have two buttons you can click on. Click on `COLOR` to see the coloring of the graph and click on `CONVERT` to see the equivalent scheduling problem. These buttons are toggle-able (you can switch between the views by clicking on them again).

![coloring](images/color.png)

Here we have a plain graph-coloring. The nodes are colored in such a way that no two adjacent nodes (nodes that have an edge between them) have the same color. The graph is placed in a circular pattern and colors are generated evenly on the color-wheel for an arbitrary number of nodes.

![convert](images/convert.png)

We then consider an equivalent scheduling problem where:
- A course is represented by a vertex (e.g. a vertex with label "1" represents Course #1, etc.)
- Each edge represents whether there exists a student that is taking both courses that the edge connects
- A unique color represents a unique time-slot.

Coloring the graph in such a way that no two adjacent nodes have the same color is then equivalent to scheduling exams in such a way that no student has two exams at the same time. The visualization generates some arbitrary but realistic time-slots per color and shows a timetable that is valid for the courses.



## Collaborators and Sharing
© Komron Aripov, Mathilde Kermorgant, and Sahdiah Cox

