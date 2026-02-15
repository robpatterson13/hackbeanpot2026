//
//  AnimalManager.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//
//  Updated to include persistent storage for:
//  - Active tasks and completed tasks from TaskManager
//  - Task cooldowns to prevent duplicate tasks
//  - Current and completed objectives from DailyObjectiveManager
//  
//  All data is automatically saved to UserDefaults when modified.
//

import Foundation
import Combine

// MARK: - Purchase Record
struct PurchaseRecord: Codable, Identifiable {
    let id: UUID
    let item: ShopItem
    let timestamp: Date
    let coinsCost: Int
    
    init(item: ShopItem, timestamp: Date = Date()) {
        self.id = UUID()
        self.item = item
        self.timestamp = timestamp
        self.coinsCost = item.cost
    }
}

@Observable
final class AnimalManager {
    
    // MARK: - Singleton
    static let shared = AnimalManager()

    private(set) var animal: Animal
    private let shop: Shop
    private(set) var coins: Int
    var taskManager: TaskManager
    var objectivesManager: DailyObjectiveManager
    private(set) var purchaseHistory: [PurchaseRecord] = []
    
    // Additional state used by objectives/UI
    private(set) var selectedBackground: BackgroundType? = .livingRoom {
        didSet {
            // Persist immediately and notify observers via @Observable
            saveState()
        }
    }
    
    var currentBackground: BackgroundType {
        selectedBackground ?? .livingRoom
    }
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let animalType = "animalType"
        static let happiness = "happiness"
        static let health = "health"
        static let hunger = "hunger"
        static let coins = "coins"
        static let purchaseHistory = "purchaseHistory"
        static let selectedBackground = "selectedBackground"
        
        // Task Manager keys
        static let activeTasks = "activeTasks"
        static let completedTasks = "completedTasks"
        static let habitCooldowns = "habitCooldowns"
        
        // Objectives Manager keys
        static let currentObjective = "currentObjective"
        static let completedObjectives = "completedObjectives"
    }

    private init() {
        self.shop = Shop()
        
        // Load persisted data or create defaults
        let savedAnimalType = UserDefaults.standard.string(forKey: UserDefaultsKeys.animalType) ?? "blob"
        let savedHappiness = UserDefaults.standard.object(forKey: UserDefaultsKeys.happiness) as? Int ?? 100
        let savedHealth = UserDefaults.standard.object(forKey: UserDefaultsKeys.health) as? Int ?? 100
        let savedHunger = UserDefaults.standard.object(forKey: UserDefaultsKeys.hunger) as? Int ?? 100
        let savedCoins = UserDefaults.standard.object(forKey: UserDefaultsKeys.coins) as? Int ?? 0
        
        // Load purchase history
        if let purchaseHistoryData = UserDefaults.standard.data(forKey: UserDefaultsKeys.purchaseHistory),
           let decodedHistory = try? JSONDecoder().decode([PurchaseRecord].self, from: purchaseHistoryData) {
            self.purchaseHistory = decodedHistory
        } else {
            self.purchaseHistory = []
        }
        
        // Load selected background
        if let bgString = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedBackground),
           let bg = BackgroundType(rawValue: bgString) {
            self.selectedBackground = bg
        } else {
            self.selectedBackground = .livingRoom
        }
        
        // Create animal from saved data
        let animalType = AnimalType.fromString(savedAnimalType)
        let happiness = AnimalHappiness(value: savedHappiness)
        let health = AnimalHealth(value: savedHealth)
        let hunger = AnimalHunger(value: savedHunger)
        let status = AnimalStatus(happiness: happiness, health: health, hunger: hunger)
        
        self.animal = Animal(type: animalType, status: status)
        self.coins = savedCoins
        
        // Initialize managers
        self.taskManager = TaskManager()
        self.objectivesManager = DailyObjectiveManager()
        
        // Load task manager data
        if let activeTasksData = UserDefaults.standard.data(forKey: UserDefaultsKeys.activeTasks),
           let decodedTasks = try? JSONDecoder().decode([HabitTask].self, from: activeTasksData) {
            self.taskManager.tasks = decodedTasks
        }
        
        if let completedTasksData = UserDefaults.standard.data(forKey: UserDefaultsKeys.completedTasks),
           let decodedCompletedTasks = try? JSONDecoder().decode([CompletedTask].self, from: completedTasksData) {
            self.taskManager.completedTasks = decodedCompletedTasks
        }
        
        if let cooldownData = UserDefaults.standard.data(forKey: UserDefaultsKeys.habitCooldowns),
           let decodedCooldowns = try? JSONDecoder().decode([String: Date].self, from: cooldownData) {
            // Convert string keys back to Habit enum
            for (habitString, date) in decodedCooldowns {
                if let habit = Habit.allCases.first(where: { "\($0)" == habitString }) {
                    self.taskManager.setCooldown(for: habit, until: date)
                }
            }
        }
        
        // Load objectives manager data
        if let currentObjectiveData = UserDefaults.standard.data(forKey: UserDefaultsKeys.currentObjective),
           let decodedCurrentObjective = try? JSONDecoder().decode(DailyObjective.self, from: currentObjectiveData) {
            self.objectivesManager.currentObjective = decodedCurrentObjective
        } else {
            // If no saved objective, create an initial one
            self.objectivesManager.assignInitialObjective()
        }
        
        if let completedObjectivesData = UserDefaults.standard.data(forKey: UserDefaultsKeys.completedObjectives),
           let decodedCompletedObjectives = try? JSONDecoder().decode([DailyObjective].self, from: completedObjectivesData) {
            self.objectivesManager.completedObjectives = decodedCompletedObjectives
        }
        
        // Set up the bidirectional relationship
        self.taskManager.animalManager = self
        self.objectivesManager.animalManager = self
    }

    enum PurchaseError: Error {
        case insufficientFunds
        case invalidUpgrade
    }

    func canBuy(_ item: ShopItem) -> Bool {
        switch item {
        case .upgrade(let upgrade):
            return coins >= item.cost && upgrade.isUnlocked(animal.type)
        default:
            return coins >= item.cost
        }
    }

    func buy(_ item: ShopItem) throws(PurchaseError) {
        guard coins >= item.cost else {
            throw PurchaseError.insufficientFunds
        }

        switch item {
        case .upgrade(let upgrade):
            guard upgrade.isUnlocked(animal.type) else {
                throw PurchaseError.invalidUpgrade
            }
            animal.type = upgrade.asAnimalType

        case .background(let bg):
            selectedBackground = bg
            // Buying a background does not change animal stats
            
        default:
            apply(levelIncrease: item.increase)
        }

        coins -= item.cost
        clampStatus()
        
        // Record the purchase in history
        let purchaseRecord = PurchaseRecord(item: item)
        purchaseHistory.append(purchaseRecord)
        
        // Save the updated state
        saveState()
    }

    private func apply(levelIncrease level: AnimalLevel) {
        if let add = level as? AnimalHappiness {
            animal.status.happiness.value += add.value
        } else if let add = level as? AnimalHealth {
            animal.status.health.value += add.value
        } else if let add = level as? AnimalHunger {
            animal.status.hunger.value += add.value
        }
    }

    private func clampStatus() {
        let minVal = 0
        let maxVal = 100
        animal.status.happiness.value = max(minVal, min(maxVal, animal.status.happiness.value))
        animal.status.health.value    = max(minVal, min(maxVal, animal.status.health.value))
        animal.status.hunger.value    = max(minVal, min(maxVal, animal.status.hunger.value))
    }
    
    // MARK: - Task Completion Rewards
    
    func awardTaskCompletion(coinsEarned: Int, happinessIncrease: Int, healthIncrease: Int, hungerIncrease: Int) {
        coins += coinsEarned
        animal.status.happiness.value += happinessIncrease
        animal.status.health.value += healthIncrease
        animal.status.hunger.value += hungerIncrease
        clampStatus()
        saveState()
    }
    
    // MARK: - Persistence
    
    private func saveState() {
        UserDefaults.standard.set(animal.type.rawValue, forKey: UserDefaultsKeys.animalType)
        UserDefaults.standard.set(animal.status.happiness.value, forKey: UserDefaultsKeys.happiness)
        UserDefaults.standard.set(animal.status.health.value, forKey: UserDefaultsKeys.health)
        UserDefaults.standard.set(animal.status.hunger.value, forKey: UserDefaultsKeys.hunger)
        UserDefaults.standard.set(coins, forKey: UserDefaultsKeys.coins)
        
        // Save selected background
        if let bg = selectedBackground {
            UserDefaults.standard.set(bg.rawValue, forKey: UserDefaultsKeys.selectedBackground)
        }
        
        // Save purchase history
        if let historyData = try? JSONEncoder().encode(purchaseHistory) {
            UserDefaults.standard.set(historyData, forKey: UserDefaultsKeys.purchaseHistory)
        }
        
        // Save task manager data
        if let tasksData = try? JSONEncoder().encode(taskManager.tasks) {
            UserDefaults.standard.set(tasksData, forKey: UserDefaultsKeys.activeTasks)
        }
        
        if let completedTasksData = try? JSONEncoder().encode(taskManager.completedTasks) {
            UserDefaults.standard.set(completedTasksData, forKey: UserDefaultsKeys.completedTasks)
        }
        
        // Save cooldowns by converting Habit keys to strings
        let cooldownDict = taskManager.getCooldowns()
        let stringKeyCooldowns = Dictionary(uniqueKeysWithValues: cooldownDict.map { (key, value) in
            ("\(key)", value)
        })
        if let cooldownData = try? JSONEncoder().encode(stringKeyCooldowns) {
            UserDefaults.standard.set(cooldownData, forKey: UserDefaultsKeys.habitCooldowns)
        }
        
        // Save objectives manager data
        if let currentObjective = objectivesManager.currentObjective,
           let currentObjectiveData = try? JSONEncoder().encode(currentObjective) {
            UserDefaults.standard.set(currentObjectiveData, forKey: UserDefaultsKeys.currentObjective)
        }
        
        if let completedObjectivesData = try? JSONEncoder().encode(objectivesManager.completedObjectives) {
            UserDefaults.standard.set(completedObjectivesData, forKey: UserDefaultsKeys.completedObjectives)
        }
    }
    
    func save() {
        saveState()
    }
    
    // MARK: - Purchase History Methods
    
    /// Returns the total number of purchases made
    var totalPurchases: Int {
        purchaseHistory.count
    }
    
    /// Returns the total coins spent on all purchases
    var totalCoinsSpent: Int {
        purchaseHistory.reduce(0) { $0 + $1.coinsCost }
    }
    
    /// Returns purchase history filtered by a specific date range
    func purchaseHistory(from startDate: Date, to endDate: Date) -> [PurchaseRecord] {
        purchaseHistory.filter { purchase in
            purchase.timestamp >= startDate && purchase.timestamp <= endDate
        }
    }
    
    /// Returns the most recent purchases (limited by count)
    func recentPurchases(limit: Int = 10) -> [PurchaseRecord] {
        Array(purchaseHistory.suffix(limit))
    }
    
    /// Clears all purchase history (for testing or reset purposes)
    func clearPurchaseHistory() {
        purchaseHistory.removeAll()
        saveState()
    }
    
    // MARK: - Developer Mode Reset Functions
    
    /// Resets coins to 0
    func resetCoins() {
        coins = 0
        saveState()
    }
    
    /// Sets coins to a specific amount
    func setCoins(_ amount: Int) {
        coins = max(0, amount) // Ensure non-negative
        saveState()
    }
    
    /// Resets animal to initial state (blob with full stats)
    func resetAnimalProgression() {
        // Reset to blob with full stats
        animal.type = .blob
        animal.status.happiness.value = 100
        animal.status.health.value = 100
        animal.status.hunger.value = 100
        
        // Clear purchase history since animal progression is reset
        purchaseHistory.removeAll()
        
        // Clear task and objective data
        taskManager.clearAllTasks()
        objectivesManager.resetObjectives()
        
        // Reset background to default
        selectedBackground = .livingRoom
        
        saveState()
    }
    
    // MARK: - Task and Objective Reset Functions
    
    /// Clears all task data (for dev mode)
    func resetTasks() {
        taskManager.clearAllTasks()
        saveState()
    }
    
    /// Clears all objective data (for dev mode)
    func resetObjectives() {
        objectivesManager.resetObjectives()
        saveState()
    }
}

private extension UpgradeType {
    var asAnimalType: AnimalType {
        switch self {
        case .fish:    return .fish
        case .gecko:   return .gecko
        case .cat:     return .cat
        case .dog:     return .dog
        case .unicorn: return .unicorn
        }
    }
}

extension AnimalType {
    var rawValue: String {
        switch self {
        case .blob: return "blob"
        case .fish: return "fish"
        case .gecko: return "gecko"
        case .cat: return "cat"
        case .dog: return "dog"
        case .unicorn: return "unicorn"
        }
    }
    
    static func fromString(_ string: String) -> AnimalType {
        switch string {
        case "blob": return .blob
        case "fish": return .fish
        case "gecko": return .gecko
        case "cat": return .cat
        case "dog": return .dog
        case "unicorn": return .unicorn
        default: return .blob
        }
    }
}

