#lang forge

open "coloring.frg"
open "scheduling.frg"
open "equivalence.frg"

pred wellformed_total {wellformed_schedule and wellformed_course}

test suite for wellformed_total {
    //trees/cliques/cycles should be valid schedule graphs
    example basicTree is {wellformed_total} for {
        Course = `Course1 + `Course2 + `Course3 + `Course4
        `Course1.intersecting = `Course2 + `Course3
        `Course2.intersecting = `Course1
        `Course3.intersecting = `Course1 + `Course4
        `Course4.intersecting = `Course3

        ExamSlot = `Slot1 + `Slot2
        Scheduling = `Scheduling1
        `Scheduling1.schedule = `Course1 -> `Slot1 +
                                `Course2 -> `Slot2 +
                                `Course3 -> `Slot2 +
                                `Course4 -> `Slot1
    }

    example basicCycle is {wellformed_total} for {
        Course = `Course1 + `Course2 + `Course3 + `Course4
        `Course1.intersecting = `Course2 + `Course4
        `Course2.intersecting = `Course1 + `Course3
        `Course3.intersecting = `Course2 + `Course4
        `Course4.intersecting = `Course3 + `Course1

        ExamSlot = `Slot1 + `Slot2
        Scheduling = `Scheduling1
        `Scheduling1.schedule = `Course1 -> `Slot1 +
                                `Course2 -> `Slot2 +
                                `Course3 -> `Slot1 +
                                `Course4 -> `Slot2
    }

    example basicClique is {wellformed_total} for {
        Course = `Course1 + `Course2 + `Course3 + `Course4
        `Course1.intersecting = `Course2 + `Course3 + `Course4
        `Course2.intersecting = `Course1 + `Course3 + `Course4
        `Course3.intersecting = `Course2 + `Course1 + `Course4
        `Course4.intersecting = `Course2 + `Course3 + `Course1

        ExamSlot = `Slot1 + `Slot2 + `Slot3 + `Slot4
        Scheduling = `Scheduling1
        `Scheduling1.schedule = `Course1 -> `Slot1 +
                                `Course2 -> `Slot2 +
                                `Course3 -> `Slot3 +
                                `Course4 -> `Slot4
    }

    //courses cannot intersect with themselves
    example mismatchIntersection is {not wellformed_total} for {
        Course = `Course1
        `Course1.intersecting = `Course1
    }

    test expect { noSelfIntersections: {
        wellformed_total
        some course: Course | course in course.intersecting
    } for exactly 1 Course, exactly 1 Scheduling is unsat } 

    //all courses intersect with each other somehow
    example noIntersection is {not wellformed_total} for {
        Course = `Course1 + `Course2 + `Course3
        `Course1.intersecting = `Course2
        `Course2.intersecting  = `Course1
    }

    test expect { allIntersect: {
        wellformed_total
        some course1, course2: Course | not reachable[course1, course2, intersecting]
    } for exactly 2 Course, exactly 1 Scheduling is unsat}

    //undirected
    example noDirected is {not wellformed_total} for {
        Course = `Course1 + `Course2
        `Course1.intersecting = `Course2
    }

    //is this extraneous
    test expect { neverDirected: {
        wellformed_total
        some course1, course2: Course | reachable[course2, course1, intersecting] and not reachable[course1, course2, intersecting]
    } for exactly 1 Scheduling is unsat}

    //all courses have an assigned exam time slot
    example assignmentsExist is {not wellformed_total} for {
        Course = `Course1 + `Course2 + `Course3 + `Course4
        `Course1.intersecting = `Course2 + `Course3
        `Course2.intersecting = `Course1
        `Course3.intersecting = `Course1 + `Course4
        `Course4.intersecting = `Course3

        ExamSlot = `Slot1 + `Slot2
        Scheduling = `Scheduling1
        `Scheduling1.schedule = `Course1 -> `Slot1 +
                                `Course2 -> `Slot2 +
                                `Course3 -> `Slot2

    }

    test expect { allCoursesScheduled: {
        wellformed_total
        some course: Course, scheduling: Scheduling | course not in scheduling.schedule.ExamSlot
    } for exactly 1 Scheduling is unsat}

    //intersecting courses must have different exam slots
    example schedulingConflict is {not wellformed_total} for {
        Course = `Course1 + `Course2 + `Course3 + `Course4
        `Course1.intersecting = `Course2 + `Course3 + `Course4
        `Course2.intersecting = `Course1 + `Course3 + `Course4
        `Course3.intersecting = `Course2 + `Course1 + `Course4
        `Course4.intersecting = `Course2 + `Course3 + `Course1

        ExamSlot = `Slot1 + `Slot2 + `Slot3 + `Slot4
        Scheduling = `Scheduling1
        `Scheduling1.schedule = `Course1 -> `Slot1 +
                                `Course2 -> `Slot2 +
                                `Course3 -> `Slot3 +
                                `Course4 -> `Slot1
    }

    test expect { differentSlots: {
        wellformed_total
        some course1, course2: Course, scheduling: Scheduling, slot: ExamSlot {
            course1 in scheduling.schedule.slot
            course2 in scheduling.schedule.slot
            course1 in course2.intersecting or course2 in course1.intersecting
        }
    }for exactly 1 Scheduling is unsat}

}

