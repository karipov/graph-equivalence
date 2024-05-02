#lang forge

open "graph-coloring.frg"
open "scheduling.frg"

sig Equivalence {
    mapping: set Course -> set Vertex
}

// define constraints on the mapping
// one-to-one mapping from course to vertex
// for any two courses, mapping is adjacent to another iff they are intersecting
// Isomorphisms:
// - Course <-> Vertex
// - (Vertex -> Color) <-> (Course -> ExamSlot)
// Note: use dot notation and relations to get equivalence of the mappings 