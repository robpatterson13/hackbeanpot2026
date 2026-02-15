//
//  InventoryManager.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//
//  Manages the user's inventory of purchased items including accessories, backgrounds, and animals.
//  Prevents duplicate purchases of one-time items while allowing consumable items to be purchased multiple times.
//

import Foundation

// MARK: - Inventory Item
struct InventoryItem: Codable, Identifiable {
    let id: UUID
    let shopItem: ShopItem
    let purchaseDate: Date
    let isEquipped: Bool // For accessories and backgrounds
    
    init(shopItem: ShopItem, purchaseDate: Date = Date(), isEquipped: Bool = false) {
        self.id = UUID()
        self.shopItem = shopItem
        self.purchaseDate = purchaseDate
        self.isEquipped = isEquipped
    }
}

@Observable
final class InventoryManager {
    
    // MARK: - Properties
    private(set) var items: [InventoryItem] = []
    weak var animalManager: AnimalManager?
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let inventoryItems = "inventoryItems"
    }
    
    init() {
        loadInventory()
    }
    
    // MARK: - Inventory Management
    
    /// Adds an item to the inventory
    func addItem(_ shopItem: ShopItem, isEquipped: Bool = false) {
        let inventoryItem = InventoryItem(shopItem: shopItem, isEquipped: isEquipped)
        items.append(inventoryItem)
        saveInventory()
    }
    
    /// Checks if the user owns a specific item
    func owns(_ shopItem: ShopItem) -> Bool {
        return items.contains { $0.shopItem.isSameItem(as: shopItem) }
    }
    
    /// Checks if an item can be purchased (prevents duplicates for one-time items)
    func canPurchase(_ shopItem: ShopItem) -> Bool {
        switch shopItem.category {
        case .accessories, .backgrounds, .upgrades:
            // One-time purchase items - can't buy if already owned
            return !owns(shopItem)
        case .food:
            // Consumable items - can always be purchased
            return true
        }
    }
    
    /// Gets all items of a specific category
    func items(in category: ShopCategory) -> [InventoryItem] {
        return items.filter { $0.shopItem.category == category }
    }
    
    /// Gets all accessories
    var accessories: [InventoryItem] {
        return items(in: .accessories)
    }
    
    /// Gets all backgrounds
    var backgrounds: [InventoryItem] {
        return items(in: .backgrounds)
    }
    
    /// Gets all upgrades (animals)
    var upgrades: [InventoryItem] {
        return items(in: .upgrades)
    }
    
    /// Gets all food items
    var food: [InventoryItem] {
        return items(in: .food)
    }
    
    // MARK: - Equipment Management
    
    /// Equips an accessory (unequips others of the same type)
    func equipAccessory(_ item: InventoryItem) {
        guard item.shopItem.category == .accessories else { return }
        
        // Unequip all other accessories of the same type
        for i in items.indices {
            if items[i].shopItem.category == .accessories &&
               items[i].shopItem.accessoryType == item.shopItem.accessoryType {
                items[i] = InventoryItem(
                    shopItem: items[i].shopItem,
                    purchaseDate: items[i].purchaseDate,
                    isEquipped: false
                )
            }
        }
        
        // Equip the selected item
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = InventoryItem(
                shopItem: item.shopItem,
                purchaseDate: item.purchaseDate,
                isEquipped: true
            )
        }
        
        saveInventory()
    }
    
    /// Unequips an accessory
    func unequipAccessory(_ item: InventoryItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        items[index] = InventoryItem(
            shopItem: item.shopItem,
            purchaseDate: item.purchaseDate,
            isEquipped: false
        )
        
        saveInventory()
    }
    
    /// Sets the active background
    func setBackground(_ item: InventoryItem) {
        guard item.shopItem.category == .backgrounds else { return }
        
        // Unequip all other backgrounds
        for i in items.indices {
            if items[i].shopItem.category == .backgrounds {
                items[i] = InventoryItem(
                    shopItem: items[i].shopItem,
                    purchaseDate: items[i].purchaseDate,
                    isEquipped: false
                )
            }
        }
        
        // Equip the selected background
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = InventoryItem(
                shopItem: item.shopItem,
                purchaseDate: item.purchaseDate,
                isEquipped: true
            )
        }
        
        // Update the animal manager's selected background
        if case .background(let backgroundType) = item.shopItem {
            animalManager?.selectedBackground = backgroundType
        }
        
        saveInventory()
    }
    
    /// Gets the currently equipped accessories
    var equippedAccessories: [InventoryItem] {
        return accessories.filter { $0.isEquipped }
    }
    
    /// Gets the currently equipped background
    var equippedBackground: InventoryItem? {
        return backgrounds.first { $0.isEquipped }
    }
    
    // MARK: - Utility Methods
    
    /// Gets the total number of items in inventory
    var totalItems: Int {
        return items.count
    }
    
    /// Gets items purchased within a date range
    func itemsPurchased(from startDate: Date, to endDate: Date) -> [InventoryItem] {
        return items.filter { item in
            item.purchaseDate >= startDate && item.purchaseDate <= endDate
        }
    }
    
    /// Clears all inventory items (for dev mode)
    func clearInventory() {
        items.removeAll()
        saveInventory()
    }
    
    // MARK: - Persistence
    
    private func saveInventory() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.inventoryItems)
        }
    }
    
    private func loadInventory() {
        if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.inventoryItems),
           let decodedItems = try? JSONDecoder().decode([InventoryItem].self, from: data) {
            self.items = decodedItems
        }
    }
}

// MARK: - ShopItem Extensions

extension ShopItem {
    /// Checks if two shop items are the same (for inventory comparison)
    func isSameItem(as other: ShopItem) -> Bool {
        switch (self, other) {
        case (.steak, .steak),
             (.fedora, .fedora),
             (.sunglasses, .sunglasses),
             (.tie, .tie),
             (.bowtie, .bowtie),
             (.potion, .potion),
             (.pills, .pills):
            return true
        case (.background(let a), .background(let b)):
            return a == b
        case (.upgrade(let a), .upgrade(let b)):
            return a == b
        default:
            return false
        }
    }
    
    /// Gets the accessory type for grouping similar accessories
    var accessoryType: AccessoryType? {
        switch self {
        case .fedora:
            return .hat
        case .sunglasses:
            return .eyewear
        case .tie, .bowtie:
            return .neckwear
        default:
            return nil
        }
    }
}

// MARK: - Accessory Type Enum

enum AccessoryType {
    case hat
    case eyewear
    case neckwear
}