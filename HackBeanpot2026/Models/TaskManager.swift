//
//  TaskManager.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import Foundation
import Combine

struct CompletedTask: Identifiable, Equatable, Codable {
    let id: UUID
    let sourceTaskID: UUID
    let habit: Habit
    let completedAt: Date

    init(from task: HabitTask, completedAt: Date = Date()) {
        self.id = UUID()
        self.sourceTaskID = task.id
        self.habit = task.habit
        self.completedAt = completedAt
    }

    static func == (lhs: CompletedTask, rhs: CompletedTask) -> Bool {
        lhs.id == rhs.id
    }
}

@Observable
final class TaskManager: ObservableObject {
    var tasks: [HabitTask] = []
    var completedTasks: [CompletedTask] = []

    weak var animalManager: AnimalManager?
    private var timerCancellable: AnyCancellable?
    private let calendar: Calendar
    private let generationInterval: TimeInterval = 60

    private var cooldownUntil: [Habit: Date] = [:]

    init(calendar: Calendar = .current, animalManager: AnimalManager? = nil) {
        self.calendar = calendar
        self.animalManager = animalManager
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
        let now = Date()

        // Record completion
        let completion = CompletedTask(from: task, completedAt: now)
        completedTasks.append(completion)
        // Keep most recent first
        completedTasks.sort { $0.completedAt > $1.completedAt }

        // Remove from active tasks
        tasks.removeAll { $0.id == task.id }

        // Start cooldown until end of current active window
        if let end = windowEnd(for: task.habit, at: now) {
            cooldownUntil[task.habit] = end
        }

        // Apply rewards to the pet
        applyRewards(for: task.habit)
        
        // Trigger save in the animal manager
        animalManager?.save()
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

            // Skip if habit is still in cooldown for current active window
            if let until = cooldownUntil[habit], now < until {
                continue
            }

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
//            return (10...16).contains(hour)
            return (1...24).contains(hour)
        }
    }

    // MARK: - Active window end calculation

    private func windowEnd(for habit: Habit, at date: Date) -> Date? {
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        guard let today = calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: comps.day)) else {
            return nil
        }

        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0

        switch habit {
        case .sleep:
            if hour >= 21 {
                return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date))
            } else if hour < 6 {
                return calendar.date(bySettingHour: 6, minute: 0, second: 0, of: today)
            } else {
                return nil
            }

        case .leetcode:
            if (12...18).contains(hour) {
                return calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)
            }
            return nil

        case .jobs:
            if (9...12).contains(hour) {
                return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)
            }
            return nil

        case .shower:
            if (6...9).contains(hour) {
                return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)
            } else if (18...21).contains(hour) {
                return calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today)
            }
            return nil

        case .water:
            if (8...22).contains(hour), minute == 0, hour % 2 == 0 {
                return date.addingTimeInterval(60)
            }
            return nil

        case .outside:
            if (10...16).contains(hour) {
                return calendar.date(bySettingHour: 16, minute: 0, second: 0, of: today)
            }
            return nil
        }
    }

    // MARK: - Rewards to pet

    private func applyRewards(for habit: Habit) {
        guard let animalManager else { return }

        animalManager.animal.status.happiness.value += habit.happinessIncrease
        animalManager.animal.status.health.value    += habit.healthIncrease
        animalManager.animal.status.hunger.value    += habit.hungerIncrease

        // Clamp to 0...100
        let minVal = 0
        let maxVal = 100
        animalManager.animal.status.happiness.value = max(minVal, min(maxVal, animalManager.animal.status.happiness.value))
        animalManager.animal.status.health.value    = max(minVal, min(maxVal, animalManager.animal.status.health.value))
        animalManager.animal.status.hunger.value    = max(minVal, min(maxVal, animalManager.animal.status.hunger.value))
    }
    
    // MARK: - Developer Mode Reset Functions
    
    /// Clears all active and completed tasks (for testing or reset purposes)
    func clearAllTasks() {
        tasks.removeAll()
        completedTasks.removeAll()
        cooldownUntil.removeAll()
        regenerateTasksIfNeeded(now: .now)
    }
    
    /// Manually assigns a specific task (for dev mode)
    func assignTask(for habit: Habit) {
        // Remove any existing task for this habit
        tasks.removeAll { $0.habit == habit }
        
        // Remove cooldown for this habit
        cooldownUntil.removeValue(forKey: habit)
        
        // Add the new task
        let newTask = HabitTask(habit: habit, calendar: calendar)
        tasks.append(newTask)
        
        // Sort by expiration
        tasks.sort { $0.expiration < $1.expiration }
    }
    
    // MARK: - Persistence Support Methods
    
    /// Returns the current cooldowns dictionary for persistence
    func getCooldowns() -> [Habit: Date] {
        return cooldownUntil
    }
    
    /// Sets a cooldown for a specific habit (used during initialization from persistent data)
    func setCooldown(for habit: Habit, until date: Date) {
        cooldownUntil[habit] = date
    }
}
