#lang forge

open "coloring.frg"
open "scheduling.frg"
open "equivalence.frg"


// Property verifications

test suite for isomorphism {

  // First we show that if we have a wellformed graph 
  // and we know there is an isomorphism with the courses, then the courses are wellformed
  test expect { wellformed_graph_to_wellformed_course: {
    wellformed_course and isomorphism implies wellformed_graph
    } for exactly 1 Equivalence is theorem
  }

  //Similarly, we show that if we have wellformed courses
  // and we know there is an isomorphism with the graph, then the graph is wellformed
  test expect { wellformed_course_to_wellformed_graph: {
    wellformed_graph and isomorphism implies wellformed_course
    } for exactly 1 Equivalence is theorem
  }

  // Now that we know that the "shape" equivalence works,
  // we can move onto coloring and scheduling questions:
  
  // We prove that if we have:
  // -- wellformed graph
  // -- a wellformed coloring
  // -- an isomorphism between the graph and the courses
  // -- a 1 to 1 correspondance between colors and exam slots
  // then, there exists a wellformed scheduling for the courses
  test expect { some_coloring_to_some_scheduling: {
    wellformed_graph and isomorphism and wellformed_colorings and correspondance implies wellformed_schedule
  } for exactly 1 Coloring, exactly 1 Scheduling is sat}

  // Similarly, we prove that if we have:
  // -- wellformed courses
  // -- a wellformed scheduling
  // -- an isomorphism between the graph and the courses
  // -- a 1 to 1 correspondance between colors and exam slots
  // then, there exists a wellformed coloring for the graph
  test expect { some_scheduling_to_some_coloring: {
    wellformed_course and isomorphism and wellformed_schedule and correspondance implies wellformed_colorings
  } for exactly 1 Coloring, exactly 1 Scheduling is sat}

  // The two previous tests prove that a graph is colorable with a certain number of colors
  // if and only if the corresponding isomorphic courses have a schedule with that same number of exam slots
  // In sum, this means that if we can solve one problem, we know the other has the same answer

  // Beyond *knowing* if the problems are solvable, 
  // is it possible to solve one to get the solution for the other?
  // AKA given a wellformed schedule can we fully specify a wellformed coloring ?
  // And given a wellformed coloring, can we fully specify a wellformed schedule ?
  // The following tests prove that it is always possible:

  test expect {coloring_to_scheduling: {
    isomorphism and correspondance and wellformed_colorings and wellformed_graph implies {
      concat_is_wellformed_scheduling[(Equivalence.morphism).(Coloring.color).~(SlotColorCorrespondance.mapping)]
      }
  } for exactly 1 Coloring, exactly 1 Equivalence, exactly 1 SlotColorCorrespondance is theorem}

  test expect {scheduling_to_coloring: {
    isomorphism and correspondance and wellformed_schedule and wellformed_course implies {
      concat_is_wellformed_coloring[(~(Equivalence.morphism)).(Scheduling.schedule).(SlotColorCorrespondance.mapping)]
      }
  } for exactly 1 Scheduling, exactly 1 Equivalence, exactly 1 SlotColorCorrespondance is theorem}

  // Onto a few miscellaneous properties of isomorphisms:

  // If there is an isomorphism, 
  // then the number of vertices and the number of courses are equal
  test expect {cardinality: {
    isomorphism and wellformed_graph implies #Vertex = #Course
  } for exactly 1 Equivalence is theorem }

  // empty sets are vacuously isomorphic
  test expect {empty_isomorphism: {
    isomorphism
  } for exactly 0 Vertex, exactly 0 Course is theorem }
}


// Model Verifications

test suite for isomorphism {
  // valid isomorphism example
  example valid_isomorphism is isomorphism for {
    Vertex = `vertex0 + `vertex1
    Course = `course0 + `course1
    `vertex1.adjacent = `vertex0
    `course0.intersecting = `course1

    Equivalence = `equiv0  + `equiv1 
    `equiv0.morphism = `course0 -> `vertex0 + `course1 -> `vertex1
    `equiv1.morphism = `course0 -> `vertex1 + `course1 -> `vertex0
  }

  // total
  example morphism_not_total is not isomorphism for {
    Vertex = `vertex0 
    Course = `course0 + `course1
    `course0.intersecting = `course1

    Equivalence = `equiv0
    `equiv0.morphism = `course0 -> `vertex0 
  }

  // injective
  example morphism_not_injective is not isomorphism for {
    Vertex = `vertex0 
    Course = `course0 + `course1 
    `course0.intersecting = `course1

    Equivalence = `equiv0  + `equiv1 
    `equiv0.morphism = `course0 -> `vertex0 + `course1 -> `vertex0
  }
  // surjective
  example morphism_not_surjective is not isomorphism for {
    Vertex = `vertex0 + `vertex1 + `vertex2
    Course = `course0 + `course1
    `vertex1.adjacent = `vertex0 + `vertex2
    `course0.intersecting = `course1

    Equivalence = `equiv0
    `equiv0.morphism = `course0 -> `vertex0 + `course1 -> `vertex1
  }

  example morphism_not_surjective_empty is not isomorphism for {
    Vertex = `vertex0 + `vertex1 + `vertex2
    `vertex1.adjacent = `vertex0 + `vertex2

    Equivalence = `equiv0
  }
  // preserve shape

  example morphism_not_shape_preserving is not isomorphism for {
    Vertex = `vertex0 + `vertex1 + `vertex2
    Course = `course0 + `course1 + `course2
    `vertex1.adjacent = `vertex0 + `vertex2
    `course0.intersecting = `course1 + `course2
    `course1.intersecting = `course0 + `course2

    Equivalence = `equiv0
    `equiv0.morphism = `course0 -> `vertex0 + `course1 -> `vertex1 + `course2 -> `vertex2
  }
}

test suite for correspondance {

  // valid correspondance example 
  example valid_correspondance is correspondance for {
    Color = `c0 + `c1
    ExamSlot = `es0 + `es1

    SlotColorCorrespondance = `cor0 
    `cor0.mapping = `es0 -> `c0 + `es1 -> `c1
  }

  //total 
  example mapping_not_total is not correspondance for {
    Color = `c0 
    ExamSlot = `es0 + `es1

    SlotColorCorrespondance = `cor0 
    `cor0.mapping = `es0 -> `c0 
  }

  //injective 
  example mapping_not_injective is not correspondance for {
    Color = `c0
    ExamSlot = `es0 + `es1

    SlotColorCorrespondance = `cor0 
    `cor0.mapping = `es0 -> `c0 + `es1 -> `c0
  }

  //surjective 
  example mapping_not_surjective is not correspondance for {
    Color = `c0 + `c1
    ExamSlot = `es0 

    SlotColorCorrespondance = `cor0 
    `cor0.mapping = `es0 -> `c0 
  }
}