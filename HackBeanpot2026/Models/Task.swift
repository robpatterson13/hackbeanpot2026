//
//  Task.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import Foundation

struct HabitTask: Identifiable, Equatable, Codable {
    let id: UUID
    let habit: Habit
    let expiration: Date

    init(habit: Habit, calendar: Calendar = .current) {
        self.id = UUID()
        self.habit = habit

        let now = Date()
        let startOfTmr = calendar.startOfDay(for: now).addingTimeInterval(60*60*24)
        self.expiration = startOfTmr.addingTimeInterval(-1)
    }
    
    // Custom initializer for creating tasks with specific id and expiration (for decoding)
    init(id: UUID, habit: Habit, expiration: Date) {
        self.id = id
        self.habit = habit
        self.expiration = expiration
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
    
    // MARK: - Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case id, habit, expiration
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let habit = try container.decode(Habit.self, forKey: .habit)
        let expiration = try container.decode(Date.self, forKey: .expiration)
        
        self.init(id: id, habit: habit, expiration: expiration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(habit, forKey: .habit)
        try container.encode(expiration, forKey: .expiration)
    }
}
