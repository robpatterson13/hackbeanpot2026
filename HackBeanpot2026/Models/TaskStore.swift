//
//  TaskStore.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import Foundation
import Combine

struct CompletedTask: Identifiable, Equatable {
    let id: UUID
    let habit: Habit
    let completedAt: Date

    init(from task: HabitTask, completedAt: Date = Date()) {
        self.id = task.id
        self.habit = task.habit
        self.completedAt = completedAt
    }

    static func == (lhs: CompletedTask, rhs: CompletedTask) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [HabitTask] = []
    @Published private(set) var completedTasks: [CompletedTask] = []

    private var timerCancellable: AnyCancellable?
    private let calendar: Calendar
    private let generationInterval: TimeInterval = 60

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        regenerateTasksIfNeeded(now: Date())
        removeExpiredTasks(now: Date())

        timerCancellable = Timer.publish(every: generationInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self else { return }
                self.removeExpiredTasks(now: now)
                self.regenerateTasksIfNeeded(now: now)
            }
    }

    func complete(_ task: HabitTask) {
        // Record completion
        let completion = CompletedTask(from: task, completedAt: Date())
        completedTasks.append(completion)
        // Keep most recent first
        completedTasks.sort { $0.completedAt > $1.completedAt }

        // Remove from active tasks
        tasks.removeAll { $0.id == task.id }
    }

    func removeExpiredTasks(now: Date = Date()) {
        tasks.removeAll { $0.isExpired }
    }

    private func hasActiveTask(for habit: Habit) -> Bool {
        tasks.contains { $0.habit == habit && !$0.isExpired }
    }

    private func regenerateTasksIfNeeded(now: Date) {
        for habit in Habit.allCases {
            guard isHabitActive(habit, at: now) else { continue }
            if !hasActiveTask(for: habit) {
                let newTask = HabitTask(habit: habit, calendar: calendar)
                tasks.append(newTask)
            }
        }
        tasks.sort { $0.expiration < $1.expiration }
    }

    private func isHabitActive(_ habit: Habit, at date: Date) -> Bool {
        let hour = calendar.component(.hour, from: date)

        switch habit {
        case .sleep:
            // Night: 21:00–23:59 and 00:00–06:00
            return hour >= 21 || hour < 6
        case .leetcode:
            // Afternoon: 12:00–18:00
            return (12...18).contains(hour)
        case .jobs:
            // Morning: 09:00–12:00
            return (9...12).contains(hour)
        case .shower:
            // Morning 06–09 or evening 18–21
            return (6...9).contains(hour) || (18...21).contains(hour)
        case .water:
            // Every 2 hours from 08:00–22:00; to avoid spamming, only generate when minute is 0 and hour is even
            guard (8...22).contains(hour) else { return false }
            let minute = calendar.component(.minute, from: date)
            return minute == 0 && hour % 2 == 0
        case .outside:
            // Midday: 10:00–16:00
            return (10...16).contains(hour)
        }
    }
}
