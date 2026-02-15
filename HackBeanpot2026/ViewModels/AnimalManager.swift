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
import UIKit

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
    var inventoryManager: InventoryManager
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
    
    func setSelectedBackground(_ background: BackgroundType) {
        selectedBackground = background
    }
    
    // MARK: - Stat Decay System
    private var statDecayTimer: Timer?
    private var statDecayInterval: TimeInterval {
        UserDefaults.standard.object(forKey: UserDefaultsKeys.statDecayInterval) as? TimeInterval ?? 600 // Default 10 minutes
    }
    private let healthDecayRate: Int = 1 // Health decreases by 1 point per interval
    private let happinessDecayRate: Int = 1 // Happiness decreases by 1 point per interval  
    private let hungerDecayRate: Int = 2 // Hunger decreases by 2 points per interval (pets get hungry faster)
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let animalType = "animalType"
        static let happiness = "happiness"
        static let health = "health"
        static let hunger = "hunger"
        static let coins = "coins"
        static let purchaseHistory = "purchaseHistory"
        static let selectedBackground = "selectedBackground"
        static let lastUpdateTime = "lastUpdateTime"
        static let statDecayInterval = "statDecayInterval"
        
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
        self.inventoryManager = InventoryManager()
        
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
        
        // Ensure the current animal is in inventory and equipped
        let currentAnimalItem = InventoryItemType.animal(animal.type)
        if !inventoryManager.hasItem(currentAnimalItem) {
            inventoryManager.addItem(currentAnimalItem, isEquipped: true)
        } else {
            // Make sure the current animal is equipped
            if let itemId = inventoryManager.items.first(where: { $0.itemType == currentAnimalItem })?.id {
                inventoryManager.equipItem(withId: itemId)
            }
        }
        
        // Ensure the current background is in inventory and equipped
        if let currentBg = selectedBackground {
            let currentBackgroundItem = InventoryItemType.background(currentBg)
            if !inventoryManager.hasItem(currentBackgroundItem) {
                inventoryManager.addItem(currentBackgroundItem, isEquipped: true)
            } else {
                // Make sure the current background is equipped
                if let itemId = inventoryManager.items.first(where: { $0.itemType == currentBackgroundItem })?.id {
                    inventoryManager.equipItem(withId: itemId)
                }
            }
        }
        
        // Initialize stat decay system
        setupStatDecay()
    }

    enum PurchaseError: Error {
        case insufficientFunds
        case invalidUpgrade
        case alreadyOwned
    }

    func canBuy(_ item: ShopItem) -> Bool {
        // Check if we have enough coins
        guard coins >= item.cost else { return false }
        
        // Check if item can be purchased (not already owned for unique items)
        guard inventoryManager.canPurchaseShopItem(item) else { return false }
        
        // Check upgrade-specific logic
        switch item {
        case .upgrade(let upgrade):
            return upgrade.isUnlocked(animal.type)
        default:
            return true
        }
        
        if hasPurchased(item) {
            return false
        }
        
        if case .upgrade(let upgrade) = item {
            return upgrade.isUnlocked(animal.type)
        }
        
        return true
    }

    func buy(_ item: ShopItem) throws(PurchaseError) {
        guard coins >= item.cost else {
            throw PurchaseError.insufficientFunds
        }
        
        // Check if item can be purchased (not already owned for unique items)
        guard inventoryManager.canPurchaseShopItem(item) else {
            throw PurchaseError.alreadyOwned
        }

        switch item {
        case .upgrade(let upgrade):
            guard upgrade.isUnlocked(animal.type) else {
                throw PurchaseError.invalidUpgrade
            }
            animal.type = upgrade.asAnimalType
            // Add the new animal to inventory as equipped
            inventoryManager.purchaseShopItem(item, isEquipped: true)

        case .background(let bg):
            setSelectedBackground(bg)
            // Add background to inventory and equip it
            inventoryManager.purchaseShopItem(item, isEquipped: true)
            
        case .fedora, .sunglasses, .tie, .bowtie:
            // Accessories don't immediately affect stats but go to inventory
            inventoryManager.purchaseShopItem(item, isEquipped: false)
            apply(levelIncrease: item.increase)
            
        default:
            // Consumables (food, potions) - apply effect immediately
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
    
    // MARK: - Stat Decay System Implementation
    
    private func setupStatDecay() {
        // Check for time elapsed while app was closed
        handleBackgroundTimeElapsed()
        
        // Start the decay timer
        startStatDecayTimer()
        
        // Listen for app lifecycle events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    private func startStatDecayTimer() {
        stopStatDecayTimer()
        statDecayTimer = Timer.scheduledTimer(withTimeInterval: statDecayInterval, repeats: true) { [weak self] _ in
            self?.decayStats()
        }
    }
    
    private func stopStatDecayTimer() {
        statDecayTimer?.invalidate()
        statDecayTimer = nil
    }
    
    @objc private func appWillEnterBackground() {
        // Save current time when app goes to background
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastUpdateTime)
        stopStatDecayTimer()
    }
    
    @objc private func appDidBecomeActive() {
        // Handle time that elapsed while app was in background
        handleBackgroundTimeElapsed()
        
        // Restart the decay timer
        startStatDecayTimer()
    }
    
    private func handleBackgroundTimeElapsed() {
        guard let lastUpdateTime = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastUpdateTime) as? Date else {
            // First launch or no previous time recorded
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastUpdateTime)
            return
        }
        
        let timeElapsed = Date().timeIntervalSince(lastUpdateTime)
        let intervalsElapsed = Int(timeElapsed / statDecayInterval)
        
        // Apply decay for each interval that passed
        for _ in 0..<intervalsElapsed {
            decayStats()
        }
        
        // Update the last update time
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastUpdateTime)
    }
    
    private func decayStats() {
        let oldHealth = animal.status.health.value
        let oldHappiness = animal.status.happiness.value
        let oldHunger = animal.status.hunger.value
        
        // Decrease each stat by its decay rate
        animal.status.health.value -= healthDecayRate
        animal.status.happiness.value -= happinessDecayRate
        animal.status.hunger.value -= hungerDecayRate
        
        // Ensure stats don't go below 0
        clampStatus()
        
        // Only save if something actually changed
        if oldHealth != animal.status.health.value || 
           oldHappiness != animal.status.happiness.value || 
           oldHunger != animal.status.hunger.value {
            saveState()
            
            // Debug logging
            print("Stats decayed: Health \(oldHealth)→\(animal.status.health.value), Happiness \(oldHappiness)→\(animal.status.happiness.value), Hunger \(oldHunger)→\(animal.status.hunger.value)")
        }
    }
    
    // Public method to manually trigger stat decay (for testing)
    func triggerStatDecay() {
        decayStats()
    }
    
    deinit {
        stopStatDecayTimer()
        NotificationCenter.default.removeObserver(self)
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
    
    /// Clears inventory items (for testing or reset purposes)
    func clearInventory() {
        inventoryManager.clearInventory()
        saveState()
    }
    
    func hasPurchased(_ item: ShopItem) -> Bool {
        return purchaseHistory.contains { $0.item == item }
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
        setSelectedBackground(.livingRoom)
        
        // Clear inventory and add initial defaults (clearInventory already ensures essentials remain)
        inventoryManager.clearInventory()
        // The clearInventory method will ensure blob and living room are equipped, now sync AnimalManager
        animal.type = .blob
        setSelectedBackground(.livingRoom)
        
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
    
    // MARK: - Dev Mode Stat Decay Settings
    
    /// Gets the current stat decay interval in seconds
    var currentStatDecayInterval: TimeInterval {
        return statDecayInterval
    }
    
    /// Sets the stat decay interval in seconds (for dev mode)
    func setStatDecayInterval(_ interval: TimeInterval) {
        let clampedInterval = max(1, interval) // Minimum 1 second
        UserDefaults.standard.set(clampedInterval, forKey: UserDefaultsKeys.statDecayInterval)
        
        // Restart the timer with the new interval if it's currently running
        if statDecayTimer != nil {
            startStatDecayTimer()
        }
    }
    
    /// Resets stat decay interval to default (600 seconds)
    func resetStatDecayInterval() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.statDecayInterval)
        
        // Restart the timer with the default interval if it's currently running
        if statDecayTimer != nil {
            startStatDecayTimer()
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

