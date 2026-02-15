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

enum BackgroundType: String, CaseIterable, Codable {
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

enum UpgradeType: CaseIterable, Buyable, Codable {
    case fish, gecko, cat, dog, unicorn
    
    func isUnlocked(_ existing: AnimalType) -> Bool {
        switch (self, existing) {
        case (.fish, .blob),
             (.gecko, .fish),
             (.cat, .gecko),
             (.dog, .cat),
             (.unicorn, .dog):
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
    
    var title: String {
        switch self {
        case .fish:    return "Fish"
        case .gecko:   return "Gecko"
        case .cat:     return "Cat"
        case .dog:     return "Dog"
        case .unicorn: return "Unicorn"
        }
    }
}

enum ShopItem: Buyable, Codable {
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
    
    var displayName: String {
        switch self {
        case .steak:                 return "Steak"
        case .fedora:                return "Fedora"
        case .sunglasses:            return "Sunglasses"
        case .tie:                   return "Tie"
        case .bowtie:                return "Bow Tie"
        case .potion:                return "Potion"
        case .pills:                 return "Pills"
        case .background(let b):     return b.displayName
        case .upgrade(let upgrade):  return "Upgrade: \(upgrade.title)"
        }
    }
    
    /// SF Symbol name to use for non-background items. Backgrounds return nil because they use their image asset.
    var iconSystemName: String? {
        switch self {
        case .steak:       return "fork.knife.circle"
        case .fedora:      return "tshirt"
        case .sunglasses:  return "sunglasses"
        case .tie:         return "tshirt"
        case .bowtie:      return "tshirt"
        case .potion:      return "cross.case.fill"
        case .pills:       return "pills"
        case .background:  return nil
        case .upgrade:     return "arrow.up.circle"
        }
    }
}

class Shop {
    let items: [ShopItem]
    
    init() {
        var base: [ShopItem] = [
            .steak,
            .potion,
            .pills,
            .fedora,
            .sunglasses,
            .tie,
            .bowtie
        ]
        
        // Add all backgrounds and upgrades to the catalog
        base += BackgroundType.allCases.map { .background($0) }
        base += UpgradeType.allCases.map { .upgrade($0) }
        
        self.items = base
    }
}
