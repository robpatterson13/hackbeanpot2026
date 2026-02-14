//
//  AnimalManager.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import Foundation

var animalManager = AnimalManager(animal: Animal(type: .fish, status: .init(happiness: .init(value: 100), health: .init(value: 100), hunger: .init(value: 100))), shop: Shop())

typealias PurchaseHistoryEntry = (item: ShopItem, purchaseDate: Date)

final class AnimalManager {

    private(set) var animal: Animal
    private let shop: Shop
    private(set) var coins: Int
    private(set) var selectedBackground: BackgroundType?
    private(set) var purchaseHistory: [PurchaseHistoryEntry] = []
    
    var taskManager: TaskManager = .init()

    init(animal: Animal, shop: Shop, coins: Int = 0) {
        self.animal = animal
        self.shop = shop
        self.coins = coins
        self.selectedBackground = BackgroundType.livingRoom
        self.taskManager = TaskManager()
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
        
        purchaseHistory.append((item, Date.now))
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
