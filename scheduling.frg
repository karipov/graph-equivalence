#lang forge

sig ExamSlot {}

sig Course {
    intersecting: set Course
}

sig Scheduling {
    schedule: pfunc Course -> ExamSlot
}

pred wellformed_course {
    // no course can intersect with itself
    all disj c1, c2: Course | {
        // all courses are connected by intersecting
        reachable[c1, c2, intersecting]

        // the graph is undirected
        c1 in c2.intersecting implies c2 in c1.intersecting
    }

    // no self-intersection
    all c: Course | c not in c.intersecting
}

pred wellformed_schedule {
    all s: Scheduling | {
        // all courses have some assigned exam time slot
        all c: Course | some s.schedule[c]

        // if there's some intersection of students between two courses
        // then the exam time slots are different
        all disj c1, c2: Course | {
            (c1 in c2.intersecting) implies s.schedule[c1] != s.schedule[c2]
        }
    }
}

run { 
  wellformed_schedule
  wellformed_course
} for exactly 3 Course, exactly 2 ExamSlot, exactly 1 Scheduling