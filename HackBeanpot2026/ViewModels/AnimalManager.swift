//
//  AnimalManager.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
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

final class AnimalManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AnimalManager()

    @Published private(set) var animal: Animal
    private let shop: Shop
    @Published private(set) var coins: Int
    let taskManager: TaskStore
    @Published private(set) var purchaseHistory: [PurchaseRecord] = []
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let animalType = "animalType"
        static let happiness = "happiness"
        static let health = "health"
        static let hunger = "hunger"
        static let coins = "coins"
        static let purchaseHistory = "purchaseHistory"
    }

    private init() {
        self.shop = Shop()
        self.taskManager = TaskStore()
        
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
        
        // Create animal from saved data
        let animalType = AnimalType.fromString(savedAnimalType)
        let happiness = AnimalHappiness(value: savedHappiness)
        let health = AnimalHealth(value: savedHealth)
        let hunger = AnimalHunger(value: savedHunger)
        let status = AnimalStatus(happiness: happiness, health: health, hunger: hunger)
        
        self.animal = Animal(type: animalType, status: status)
        self.coins = savedCoins
        
        // Set up the bidirectional relationship
        self.taskManager.animalManager = self
    }
    
    private init(animal: Animal, shop: Shop, taskManager: TaskStore, coins: Int = 0) {
        self.animal = animal
        self.shop = shop
        self.taskManager = taskManager
        self.coins = coins
        self.purchaseHistory = []
        
        // Set up the bidirectional relationship
        self.taskManager.animalManager = self
    }
    
    convenience init(testing: Bool) {
        let happiness = AnimalHappiness(value: 100)
        let hunger = AnimalHunger(value: 100)
        let health = AnimalHealth(value: 100)
        let status = AnimalStatus(happiness: happiness, health: health, hunger: hunger)
        let shop = Shop()
        let animal = Animal(type: .blob, status: status)
        let taskManager = TaskStore()
        
        self.init(animal: animal, shop: shop, taskManager: taskManager)
    }

    //error enum to handle invalid purchases
    enum PurchaseError: Error {
        case insufficientFunds
        case invalidUpgrade
    }

    //Check if you can upgrade or if you have enough coins for the given item
    func canBuy(_ item: ShopItem) -> Bool {
        switch item {
            //if upgrade check if the animal is next to be unlocked
        case .upgrade(let upgrade):
            return coins >= item.cost && upgrade.isUnlocked(animal.type)
        default:
            return coins >= item.cost
        }
    }

    //buys an item from the shop, if user doesn't have enough coins or can't upgrade throw purchase error
    //if we are upgrading we change the animal accordingly, same with background,
    //then subtract the number of coins if successful
    /// Attempts to buy a `ShopItem` and apply its effect to the animal.
    /// - Throws: `PurchaseError.insufficientFunds` if you don't have enough coins,
    ///           `PurchaseError.invalidUpgrade` if the requested upgrade isn't unlocked for the animal's current type
    func buy(_ item: ShopItem) throws(PurchaseError) {
        guard coins >= item.cost else {
            throw PurchaseError.insufficientFunds
        }

        // Apply the item's effect or perform the upgrade.
        switch item {
        case .upgrade(let upgrade):
            guard upgrade.isUnlocked(animal.type) else {
                throw PurchaseError.invalidUpgrade
            }
            animal.type = upgrade.asAnimalType

        default:
            apply(levelIncrease: item.increase)
        }

        // Deduct coins and clamp status values into 0...100 after applying effects.
        coins -= item.cost
        clampStatus()
        
        // Record the purchase in history
        let purchaseRecord = PurchaseRecord(item: item)
        purchaseHistory.append(purchaseRecord)
        
        // Save the updated state
        saveState()
    }

    
    //Apply an increase in happiness, health, or hunger
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
    
    /// Awards coins and applies stat increases for completing a habit task
    func awardTaskCompletion(coinsEarned: Int, happinessIncrease: Int, healthIncrease: Int, hungerIncrease: Int) {
        // Award coins
        coins += coinsEarned
        
        // Apply stat increases
        animal.status.happiness.value += happinessIncrease
        animal.status.health.value += healthIncrease
        animal.status.hunger.value += hungerIncrease
        
        // Clamp values to valid range
        clampStatus()
        
        // Save the updated state
        saveState()
        
        print("Task completed! Awarded \(coinsEarned) coins")
        print("Happiness: +\(happinessIncrease), Health: +\(healthIncrease), Hunger: +\(hungerIncrease)")
        print("Current stats - Happiness: \(animal.status.happiness.value), Health: \(animal.status.health.value), Hunger: \(animal.status.hunger.value)")
        print("Total coins: \(coins)")
    }
    
    // MARK: - Persistence
    
    /// Saves the current state to UserDefaults
    private func saveState() {
        UserDefaults.standard.set(animal.type.rawValue, forKey: UserDefaultsKeys.animalType)
        UserDefaults.standard.set(animal.status.happiness.value, forKey: UserDefaultsKeys.happiness)
        UserDefaults.standard.set(animal.status.health.value, forKey: UserDefaultsKeys.health)
        UserDefaults.standard.set(animal.status.hunger.value, forKey: UserDefaultsKeys.hunger)
        UserDefaults.standard.set(coins, forKey: UserDefaultsKeys.coins)
        
        // Save purchase history
        if let historyData = try? JSONEncoder().encode(purchaseHistory) {
            UserDefaults.standard.set(historyData, forKey: UserDefaultsKeys.purchaseHistory)
        }
    }
    
    /// Manually save state (can be called externally)
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
        default: return .blob // default to blob if unknown
        }
    }
}
