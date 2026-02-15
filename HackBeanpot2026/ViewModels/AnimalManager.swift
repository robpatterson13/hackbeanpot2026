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
    private(set) var selectedBackground: BackgroundType? = .livingRoom
    
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
        self.taskManager = TaskManager()
        self.objectivesManager = DailyObjectiveManager()
        
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
        
        // Save purchase history
        if let historyData = try? JSONEncoder().encode(purchaseHistory) {
            UserDefaults.standard.set(historyData, forKey: UserDefaultsKeys.purchaseHistory)
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
        
        // Reset background to default
        selectedBackground = .livingRoom
        
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

