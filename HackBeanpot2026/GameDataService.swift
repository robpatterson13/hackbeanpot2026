//
//  GameDataService.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import Foundation
import SwiftData

@Model
class GameData {
    var dogName: String
    var health: Int
    var happiness: Int
    var hunger: Int
    var coins: Int
    var lastTaskAssignment: Date
    var completedTasksToday: [CompletedTask]
    var currentTaskType: String?
    var currentTaskTitle: String?
    var currentTaskDescription: String?
    var currentTaskReward: Int
    var totalTasksCompleted: Int
    var totalCoinsEarned: Int
    var createdAt: Date
    
    init(dogName: String = "Buddy") {
        self.dogName = dogName
        self.health = 80
        self.happiness = 70
        self.hunger = 60
        self.coins = 50
        self.lastTaskAssignment = Date()
        self.completedTasksToday = []
        self.currentTaskType = nil
        self.currentTaskTitle = nil
        self.currentTaskDescription = nil
        self.currentTaskReward = 0
        self.totalTasksCompleted = 0
        self.totalCoinsEarned = 0
        self.createdAt = Date()
    }
}

@Model
class CompletedTask {
    var taskType: String
    var title: String
    var reward: Int
    var completedAt: Date
    
    init(taskType: String, title: String, reward: Int) {
        self.taskType = taskType
        self.title = title
        self.reward = reward
        self.completedAt = Date()
    }
}

@Observable
class GameDataService {
    private var modelContext: ModelContext?
    private var gameData: GameData?
    
    func initialize(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadGameData()
    }
    
    private func loadGameData() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<GameData>()
        do {
            let existingData = try context.fetch(descriptor)
            if let data = existingData.first {
                self.gameData = data
            } else {
                // Create new game data
                let newGameData = GameData()
                context.insert(newGameData)
                self.gameData = newGameData
                try context.save()
            }
        } catch {
            print("Failed to load game data: \(error)")
            // Fallback to creating new data
            let newGameData = GameData()
            context.insert(newGameData)
            self.gameData = newGameData
        }
    }
    
    func getCurrentGameData() -> GameData? {
        return gameData
    }
    
    func updateDogStats(health: Int, happiness: Int, hunger: Int) {
        guard let gameData = gameData, let context = modelContext else { return }
        
        gameData.health = health
        gameData.happiness = happiness
        gameData.hunger = hunger
        
        do {
            try context.save()
        } catch {
            print("Failed to save dog stats: \(error)")
        }
    }
    
    func updateCoins(_ coins: Int) {
        guard let gameData = gameData, let context = modelContext else { return }
        
        gameData.coins = coins
        
        do {
            try context.save()
        } catch {
            print("Failed to save coins: \(error)")
        }
    }
    
    func setCurrentTask(_ task: HabitTask) {
        guard let gameData = gameData, let context = modelContext else { return }
        
        gameData.currentTaskType = String(describing: task.type)
        gameData.currentTaskTitle = task.title
        gameData.currentTaskDescription = task.description
        gameData.currentTaskReward = task.reward
        gameData.lastTaskAssignment = Date()
        
        do {
            try context.save()
        } catch {
            print("Failed to save current task: \(error)")
        }
    }
    
    func completeCurrentTask() {
        guard let gameData = gameData, let context = modelContext else { return }
        guard let taskType = gameData.currentTaskType,
              let taskTitle = gameData.currentTaskTitle else { return }
        
        let completedTask = CompletedTask(
            taskType: taskType,
            title: taskTitle,
            reward: gameData.currentTaskReward
        )
        
        gameData.completedTasksToday.append(completedTask)
        gameData.totalTasksCompleted += 1
        gameData.totalCoinsEarned += gameData.currentTaskReward
        gameData.coins += gameData.currentTaskReward
        
        // Clear current task
        gameData.currentTaskType = nil
        gameData.currentTaskTitle = nil
        gameData.currentTaskDescription = nil
        gameData.currentTaskReward = 0
        
        do {
            try context.save()
        } catch {
            print("Failed to complete task: \(error)")
        }
    }
    
    func resetDailyTasks() {
        guard let gameData = gameData, let context = modelContext else { return }
        
        let calendar = Calendar.current
        if !calendar.isDate(gameData.lastTaskAssignment, inSameDayAs: Date()) {
            gameData.completedTasksToday.removeAll()
            
            do {
                try context.save()
            } catch {
                print("Failed to reset daily tasks: \(error)")
            }
        }
    }
    
    func getCurrentTask() -> HabitTask? {
        guard let gameData = gameData,
              let taskTypeString = gameData.currentTaskType,
              let taskTitle = gameData.currentTaskTitle,
              let taskDescription = gameData.currentTaskDescription else {
            return nil
        }
        
        // Convert string back to HabitType
        let habitType: HabitType
        switch taskTypeString {
        case "water": habitType = .water
        case "sleep": habitType = .sleep
        case "steps": habitType = .steps
        case "jobApplication": habitType = .jobApplication
        case "outside": habitType = .outside
        case "leetcode": habitType = .leetcode
        case "shower": habitType = .shower
        default: return nil
        }
        
        let verificationType: VerificationType
        switch habitType {
        case .sleep, .steps: verificationType = .healthKit
        case .jobApplication: verificationType = .photo
        case .outside: verificationType = .location
        default: verificationType = .manual
        }
        
        return HabitTask(
            type: habitType,
            title: taskTitle,
            description: taskDescription,
            reward: gameData.currentTaskReward,
            verificationType: verificationType
        )
    }
    
    func exportGameStats() -> [String: Any] {
        guard let gameData = gameData else { return [:] }
        
        return [
            "dogName": gameData.dogName,
            "health": gameData.health,
            "happiness": gameData.happiness,
            "hunger": gameData.hunger,
            "coins": gameData.coins,
            "totalTasksCompleted": gameData.totalTasksCompleted,
            "totalCoinsEarned": gameData.totalCoinsEarned,
            "createdAt": gameData.createdAt,
            "completedToday": gameData.completedTasksToday.count
        ]
    }
}

// MARK: - UserDefaults Extension for Widget Data

extension UserDefaults {
    private enum Keys {
        static let dogName = "widget_dog_name"
        static let health = "widget_health"
        static let happiness = "widget_happiness"
        static let hunger = "widget_hunger"
        static let coins = "widget_coins"
        static let currentTaskTitle = "widget_current_task"
        static let currentTaskDescription = "widget_current_task_description"
        static let currentTaskReward = "widget_current_task_reward"
    }
    
    static let group = UserDefaults(suiteName: "group.hackbeanpot2026.petapp")!
    
    func setWidgetData(gameData: GameData) {
        Self.group.set(gameData.dogName, forKey: Keys.dogName)
        Self.group.set(gameData.health, forKey: Keys.health)
        Self.group.set(gameData.happiness, forKey: Keys.happiness)
        Self.group.set(gameData.hunger, forKey: Keys.hunger)
        Self.group.set(gameData.coins, forKey: Keys.coins)
        Self.group.set(gameData.currentTaskTitle, forKey: Keys.currentTaskTitle)
        Self.group.set(gameData.currentTaskDescription, forKey: Keys.currentTaskDescription)
        Self.group.set(gameData.currentTaskReward, forKey: Keys.currentTaskReward)
    }
    
    func getWidgetDogName() -> String {
        return Self.group.string(forKey: Keys.dogName) ?? "Buddy"
    }
    
    func getWidgetHealth() -> Int {
        return Self.group.integer(forKey: Keys.health)
    }
    
    func getWidgetHappiness() -> Int {
        return Self.group.integer(forKey: Keys.happiness)
    }
    
    func getWidgetHunger() -> Int {
        return Self.group.integer(forKey: Keys.hunger)
    }
    
    func getWidgetCoins() -> Int {
        return Self.group.integer(forKey: Keys.coins)
    }
    
    func getWidgetCurrentTask() -> String? {
        return Self.group.string(forKey: Keys.currentTaskTitle)
    }
    
    func getWidgetCurrentTaskDescription() -> String? {
        return Self.group.string(forKey: Keys.currentTaskDescription)
    }
    
    func getWidgetCurrentTaskReward() -> Int {
        return Self.group.integer(forKey: Keys.currentTaskReward)
    }
}