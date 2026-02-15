//
//  InventoryManager.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import Foundation

// MARK: - Codable AnimalType
enum CodableAnimalType: String, Codable, Hashable, CaseIterable {
    case blob, fish, gecko, cat, dog, unicorn
    
    var displayName: String {
        switch self {
        case .blob: return "Blob"
        case .fish: return "Fish"
        case .gecko: return "Gecko"
        case .cat: return "Cat"
        case .dog: return "Dog"
        case .unicorn: return "Unicorn"
        }
    }
    
    // Convert to/from the original AnimalType
    init(_ animalType: AnimalType) {
        switch animalType {
        case .blob: self = .blob
        case .fish: self = .fish
        case .gecko: self = .gecko
        case .cat: self = .cat
        case .dog: self = .dog
        case .unicorn: self = .unicorn
        }
    }
    
    var asAnimalType: AnimalType {
        switch self {
        case .blob: return .blob
        case .fish: return .fish
        case .gecko: return .gecko
        case .cat: return .cat
        case .dog: return .dog
        case .unicorn: return .unicorn
        }
    }
}

// MARK: - Inventory Item Types
enum InventoryItemType: Codable, Hashable {
    case accessory(AccessoryType)
    case background(BackgroundType)
    case animal(CodableAnimalType)
    
    var displayName: String {
        switch self {
        case .accessory(let accessory):
            return accessory.displayName
        case .background(let background):
            return background.displayName
        case .animal(let animal):
            return animal.displayName
        }
    }
    
    var category: InventoryCategory {
        switch self {
        case .accessory:
            return .accessories
        case .background:
            return .backgrounds
        case .animal:
            return .animals
        }
    }
    
    // Convenience initializer for AnimalType
    static func animal(_ animalType: AnimalType) -> InventoryItemType {
        return .animal(CodableAnimalType(animalType))
    }
}

enum AccessoryType: String, CaseIterable, Codable, Hashable {
    case fedora, sunglasses, tie, bowtie
    
    var displayName: String {
        switch self {
        case .fedora:
            return "Fedora"
        case .sunglasses:
            return "Sunglasses"
        case .tie:
            return "Tie"
        case .bowtie:
            return "Bow Tie"
        }
    }
}

enum InventoryCategory: String, CaseIterable {
    case accessories = "Accessories"
    case backgrounds = "Backgrounds"
    case animals = "Animals"
}

// MARK: - Inventory Item Record
struct InventoryItem: Codable, Identifiable, Hashable {
    let id: UUID
    let itemType: InventoryItemType
    let acquiredDate: Date
    let isEquipped: Bool
    
    init(itemType: InventoryItemType, acquiredDate: Date = Date(), isEquipped: Bool = false) {
        self.id = UUID()
        self.itemType = itemType
        self.acquiredDate = acquiredDate
        self.isEquipped = isEquipped
    }
}

// MARK: - Inventory Manager
@Observable
final class InventoryManager {
    private(set) var items: [InventoryItem] = []
    
    // MARK: - UserDefaults Key
    private enum UserDefaultsKeys {
        static let inventoryItems = "inventoryItems"
    }
    
    init() {
        loadInventory()
        ensureAnimalEquipped()
    }
    
    // MARK: - Core Inventory Methods
    
    /// Ensures at least one animal is equipped at all times
    private func ensureAnimalEquipped() {
        let hasEquippedAnimal = items.contains { item in
            if case .animal = item.itemType, item.isEquipped {
                return true
            }
            return false
        }
        
        if !hasEquippedAnimal {
            // Find any animal in inventory and equip it
            if let animalIndex = items.firstIndex(where: { 
                if case .animal = $0.itemType { return true }
                return false
            }) {
                items[animalIndex] = InventoryItem(
                    itemType: items[animalIndex].itemType,
                    acquiredDate: items[animalIndex].acquiredDate,
                    isEquipped: true
                )
            } else {
                // No animals in inventory, add and equip blob as default
                let defaultAnimal = InventoryItem(itemType: .animal(AnimalType.blob), isEquipped: true)
                items.append(defaultAnimal)
            }
            saveInventory()
        }
    }
    
    /// Adds an item to the inventory
    func addItem(_ itemType: InventoryItemType, isEquipped: Bool = false) {
        // Check if item already exists (prevent duplicates)
        if hasItem(itemType) {
            return
        }
        
        let newItem = InventoryItem(itemType: itemType, isEquipped: isEquipped)
        
        // If this item should be equipped, unequip others in the same category first
        if isEquipped {
            let category = itemType.category
            for i in items.indices {
                if items[i].itemType.category == category {
                    items[i] = InventoryItem(
                        itemType: items[i].itemType,
                        acquiredDate: items[i].acquiredDate,
                        isEquipped: false
                    )
                }
            }
        }
        
        items.append(newItem)
        saveInventory()
    }
    
    /// Checks if the inventory contains a specific item
    func hasItem(_ itemType: InventoryItemType) -> Bool {
        items.contains { $0.itemType == itemType }
    }
    
    /// Returns all items of a specific category
    func items(for category: InventoryCategory) -> [InventoryItem] {
        items.filter { $0.itemType.category == category }
    }
    
    /// Returns all equipped items
    var equippedItems: [InventoryItem] {
        items.filter { $0.isEquipped }
    }
    
    /// Returns equipped item of a specific category (assuming only one can be equipped per category)
    func equippedItem(for category: InventoryCategory) -> InventoryItem? {
        items.first { $0.itemType.category == category && $0.isEquipped }
    }
    
    /// Equips an item (unequips others in the same category)
    func equipItem(withId id: UUID) {
        guard let itemIndex = items.firstIndex(where: { $0.id == id }) else { return }
        
        let category = items[itemIndex].itemType.category
        
        // Unequip all items in the same category
        for i in items.indices {
            if items[i].itemType.category == category {
                items[i] = InventoryItem(
                    itemType: items[i].itemType,
                    acquiredDate: items[i].acquiredDate,
                    isEquipped: false
                )
            }
        }
        
        // Equip the selected item
        items[itemIndex] = InventoryItem(
            itemType: items[itemIndex].itemType,
            acquiredDate: items[itemIndex].acquiredDate,
            isEquipped: true
        )
        
        saveInventory()
    }
    
    /// Unequips an item (animals cannot be unequipped, only switched)
    func unequipItem(withId id: UUID) {
        guard let itemIndex = items.firstIndex(where: { $0.id == id }) else { return }
        
        // Prevent unequipping animals - they should be switched instead
        if case .animal = items[itemIndex].itemType {
            return
        }
        
        items[itemIndex] = InventoryItem(
            itemType: items[itemIndex].itemType,
            acquiredDate: items[itemIndex].acquiredDate,
            isEquipped: false
        )
        
        saveInventory()
    }
    
    /// Removes an item from inventory (for dev/reset purposes)
    /// Prevents removing the last equipped animal to maintain the constraint
    func removeItem(_ itemType: InventoryItemType) {
        // Check if we're trying to remove an equipped animal and it's the only one
        if case .animal = itemType {
            let animalItems = items.filter { 
                if case .animal = $0.itemType { return true }
                return false
            }
            let equippedAnimals = animalItems.filter { $0.isEquipped }
            
            // If this is the only equipped animal and we only have one animal total, don't remove it
            if animalItems.count == 1 && equippedAnimals.count == 1 {
                return // Prevent removal of the last animal
            }
        }
        
        items.removeAll { $0.itemType == itemType }
        
        // After removal, ensure we still have an equipped animal
        ensureAnimalEquipped()
        saveInventory()
    }
    
    /// Clears all inventory items except ensures one animal remains equipped
    func clearInventory() {
        // Find currently equipped animal
        let equippedAnimal = items.first { item in
            if case .animal = item.itemType, item.isEquipped {
                return true
            }
            return false
        }
        
        // Clear all items
        items.removeAll()
        
        // Re-add the equipped animal or default to blob if none was equipped
        if let animal = equippedAnimal {
            items.append(animal)
        } else {
            let defaultAnimal = InventoryItem(itemType: .animal(AnimalType.blob), isEquipped: true)
            items.append(defaultAnimal)
        }
        
        saveInventory()
    }
    
    // MARK: - Convenience Methods for Shop Integration
    
    /// Checks if a shop item can be purchased (not already owned for unique items)
    func canPurchaseShopItem(_ shopItem: ShopItem) -> Bool {
        let inventoryItemType = shopItem.toInventoryItemType()
        
        // Some items can always be purchased (consumables)
        switch shopItem {
        case .steak, .potion, .pills:
            return true // Consumables can always be purchased
        case .fedora, .sunglasses, .tie, .bowtie, .background, .upgrade:
            return !hasItem(inventoryItemType) // Unique items can only be purchased once
        }
    }
    
    /// Adds a shop item to inventory after purchase
    func purchaseShopItem(_ shopItem: ShopItem, isEquipped: Bool = false) {
        let inventoryItemType = shopItem.toInventoryItemType()
        
        // Only add unique items to inventory
        switch shopItem {
        case .fedora, .sunglasses, .tie, .bowtie, .background, .upgrade:
            addItem(inventoryItemType, isEquipped: isEquipped)
        case .steak, .potion, .pills:
            break // Consumables don't go to inventory
        }
    }
    
    // MARK: - Persistence
    
    private func saveInventory() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.inventoryItems)
        }
    }
    
    private func loadInventory() {
        if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.inventoryItems),
           let decoded = try? JSONDecoder().decode([InventoryItem].self, from: data) {
            items = decoded
        }
        // Ensure an animal is equipped after loading
        ensureAnimalEquipped()
    }
}

// MARK: - Extensions

extension ShopItem {
    func toInventoryItemType() -> InventoryItemType {
        switch self {
        case .fedora:
            return .accessory(.fedora)
        case .sunglasses:
            return .accessory(.sunglasses)
        case .tie:
            return .accessory(.tie)
        case .bowtie:
            return .accessory(.bowtie)
        case .background(let backgroundType):
            return .background(backgroundType)
        case .upgrade(let upgradeType):
            return .animal(CodableAnimalType(upgradeType.asAnimalType))
        case .steak, .potion, .pills:
            // Consumables don't have inventory equivalents
            return .accessory(.fedora) // This shouldn't be called for consumables
        }
    }
}

extension UpgradeType {
    var asAnimalType: AnimalType {
        switch self {
        case .fish: return .fish
        case .gecko: return .gecko
        case .cat: return .cat
        case .dog: return .dog
        case .unicorn: return .unicorn
        }
    }
}

extension AnimalType {
    var displayName: String {
        switch self {
        case .blob: return "Blob"
        case .fish: return "Fish"
        case .gecko: return "Gecko"
        case .cat: return "Cat"
        case .dog: return "Dog"
        case .unicorn: return "Unicorn"
        }
    }
}
