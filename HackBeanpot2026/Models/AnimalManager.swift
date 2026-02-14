//
//  AnimalManager.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

var animalManager = AnimalManager(animal: Animal(type: .fish, status: .init(happiness: .init(value: 100), health: .init(value: 100), hunger: .init(value: 100))), shop: Shop())

final class AnimalManager {

    private(set) var animal: Animal
    private let shop: Shop
    private(set) var coins: Int
    private(set) var selectedBackground: BackgroundType?
    
    var taskManager: TaskStore

    init(animal: Animal, shop: Shop, coins: Int = 0) {
        self.animal = animal
        self.shop = shop
        self.coins = coins
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

        case .background(let bg):
            selectedBackground = bg
            apply(levelIncrease: item.increase)

        default:
            apply(levelIncrease: item.increase)
        }

        // Deduct coins and clamp status values into 0...100 after applying effects.
        coins -= item.cost
        clampStatus()
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
