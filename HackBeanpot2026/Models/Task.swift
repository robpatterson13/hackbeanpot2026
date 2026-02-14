//
//  Task.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import Foundation

struct HabitTask: Identifiable, Equatable {
    let id = UUID()
    let habit: Habit
    let expiration: Date

    init(habit: Habit, calendar: Calendar = .current) {
        self.habit = habit

        let now = Date()
        let startOfTmr = calendar.startOfDay(for: now).addingTimeInterval(60*60*24)
        self.expiration = startOfTmr.addingTimeInterval(-1)
    }

    var isExpired: Bool {
        Date() > expiration
    }

    static func == (lhs: HabitTask, rhs: HabitTask) -> Bool {
        lhs.id == rhs.id
    }

    // Returns a list of tasks, one for each possible habit.
    static var allTasks: [HabitTask] {
        Habit.allCases.map { HabitTask(habit: $0) }
    }
}
