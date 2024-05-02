#lang forge

open "graph-coloring.frg"
open "scheduling.frg"

sig Equivalence {
    morphism: set Course -> set Vertex
}

sig SlotColorCorrespondance {
    mapping: set ExamSlot -> set Color
}

// define constraints on the mapping
// one-to-one mapping from course to vertex
// for any two courses, mapping is adjacent to another iff they are intersecting
// Isomorphisms:
// - Course <-> Vertex
// - (Vertex -> Color) <-> (Course -> ExamSlot)
// - ~(Vertex -> Color) <-> (Course -> ExamSlot) gives from a coloring and a schedule a map from color to exam slot?
// Note: use dot notation and relations to get equivalence of the mappings 

pred isomorphism {
    all equiv : Equivalence | {
        -- total
        all course : Course | some equiv.morphism[course]
        -- injective
        all disj course1, course2 : Course | equiv.morphism[course1] != equiv.morphism[course2]
        -- surjective
        all vertex : Vertex | some course : Course | equiv.morphism[course] = vertex
        -- "shape" preserving
        -- note: in both wellformed graphs and schedules we impose that intersecting and adjacent are reflexive
        all disj course1, course2 : Course | (equiv.morphism[course1] in equiv.morphism[course2].adjacent) iff (course 1 in course2.intersecting)
    }
}

pred correspondance {
    all scc : SlotColorCorrespondance | {
        -- total
        all slot : ExamSlot | some scc.mapping[slot]
        -- injective
        all disj slot1, slot2 : ExamSlot | scc.mapping[slot1] != scc.mapping[slot2]
        -- surjective
        all color: Color | some slot: ExamSlot | scc.mapping[slot] = color
    }
}

// to get coloring from scheduling: ~(Course <-> Vertex).(Course -> ExamSlot).(ExamSlot <-> Color) 
// to get scheduling from coloring: (Course <-> Vertex).(Vertex -> Color).~(ExamSlot <-> Color)

// there is the concert that we construct relations and want to show that they exhibit the behaviour of function
// further, given the resulting relation how do we show that it's a wellformed coloring/scheduling? Can preds intake sigs? that would be ideal