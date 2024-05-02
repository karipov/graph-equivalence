#lang forge

sig Student {}
sig ExamSlot {}

sig Course {
    students: set Student
}

sig Scheduling {
    schedule: pfunc Course -> ExamSlot
}

pred wellformed_course {
    all c: Course | some c.students
}

pred wellformed_schedule {
    all s: Scheduling | {
        // all courses have some assigned exam time slot
        all c: Course | some s.schedule[c]

        // if there's some intersection of students between two courses
        // then the exam time slots are different
        all disj c1, c2: Course | {
            some (c1.students & c2.students) implies s.schedule[c1] != s.schedule[c2]
        }
    }
}

run { 
  wellformed_schedule
  wellformed_course
} for exactly 3 Course, exactly 4 Student, exactly 2 ExamSlot, exactly 1 Scheduling