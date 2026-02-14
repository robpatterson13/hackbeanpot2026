//
//  Shop.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

protocol Buyable {
    var cost: Int { get }
}

enum ShopCategory {
    case accessories, backgrounds, upgrades, food
}

enum BackgroundType: String, CaseIterable {
    case forest, desert, ocean, city, livingRoom
    
    var imageName: String {
        return self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .forest:
            return "Forest"
        case .desert:
            return "Desert"
        case .ocean:
            return "Ocean"
        case .city:
            return "City"
        case .livingRoom:
            return "Living Room"
        }
    }
}

enum UpgradeType: CaseIterable, Buyable {
    case fish, gecko, cat, dog, unicorn
    
    func isUnlocked(_ existing: AnimalType) -> Bool {
        switch (self, existing) {
        case (.fish, .blob),
            (.gecko, .fish),
            (.fish, .cat),
            (.cat, .dog),
            (.dog, .unicorn):
            return true
        default:
            return false
        }
    }
    
    var cost: Int {
        switch self {
        case .fish:
            return 200
        case .gecko:
            return 450
        case .cat:
            return 700
        case .dog:
            return 800
        case .unicorn:
            return 1000
        }
    }
}

enum ShopItem: Buyable {
    case steak
    case fedora
    case sunglasses
    case tie, bowtie
    case potion, pills
    case background(BackgroundType)
    case upgrade(UpgradeType)
    
    var category: ShopCategory {
        switch self {
        case .steak, .potion, .pills:
            return .food
        case .fedora, .sunglasses, .tie, .bowtie:
            return .accessories
        case .background:
            return .backgrounds
        case .upgrade:
            return .upgrades
        }
    }
    
    var cost: Int {
        switch self {
        case .steak:
            return 200
        case .fedora:
            return 150
        case .sunglasses:
            return 100
        case .tie:
            return 90
        case .bowtie:
            return 75
        case .potion:
            return 150
        case .pills:
            return 30
        case .background:
            return 300
        case .upgrade(let u):
            return u.cost
        }
    }
    
    var increase: AnimalLevel {
        switch self {
        case .steak:
            return AnimalHunger(value: 30)
        case .fedora:
            return AnimalHappiness(value: 8)
        case .sunglasses:
            return AnimalHappiness(value: 15)
        case .tie:
            return AnimalHappiness(value: 10)
        case .bowtie:
            return AnimalHappiness(value: 12)
        case .potion:
            return AnimalHealth(value: 100)
        case .pills:
            return AnimalHealth(value: 15)
        case .background:
            return AnimalHappiness(value: 8)
        case .upgrade:
            return AnimalNeverLevel()
        }
    }

}

class Shop {
    let items: [ShopItem] = []
}
