//
//  InventoryView.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//
//  A view for displaying and managing the user's inventory of purchased items.
//

import SwiftUI

struct InventoryView: View {
    @ObservedObject private var animalManager: AnimalManager
    @State private var selectedCategory: InventoryCategory = .accessories
    
    init(animalManager: AnimalManager = AnimalManager.shared) {
        self.animalManager = animalManager
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Category picker
                categoryPicker
                
                // Items grid
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(filteredItems) { item in
                            InventoryItemCard(
                                item: item,
                                animalManager: animalManager
                            )
                        }
                    }
                    .padding()
                }
                
                if filteredItems.isEmpty {
                    Spacer()
                    Text("No items in this category yet")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    Text("Visit the shop to purchase items!")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Spacer()
                }
            }
            .navigationTitle("Inventory")
        }
    }
    
    private var categoryPicker: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(InventoryCategory.allCases, id: \.self) { category in
                Text(category.displayName)
                    .tag(category)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 160), spacing: 16)
        ]
    }
    
    private var filteredItems: [InventoryItem] {
        switch selectedCategory {
        case .accessories:
            return animalManager.inventoryManager.accessories
        case .backgrounds:
            return animalManager.inventoryManager.backgrounds
        case .animals:
            return animalManager.inventoryManager.upgrades
        }
    }
}

enum InventoryCategory: CaseIterable {
    case accessories
    case backgrounds
    case animals
    
    var displayName: String {
        switch self {
        case .accessories: return "Accessories"
        case .backgrounds: return "Backgrounds"
        case .animals: return "Animals"
        }
    }
}

struct InventoryItemCard: View {
    let item: InventoryItem
    let animalManager: AnimalManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Item image/icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 80)
                
                if case .background = item.shopItem, let imageName = shopAssetName(for: item.shopItem) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if let imageName = shopAssetName(for: item.shopItem) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                } else {
                    Image(systemName: item.shopItem.iconSystemName ?? "bag")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.accentColor)
                }
                
                // Equipped indicator
                if item.isEquipped {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .background(Color.white, in: Circle())
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
            
            // Item name
            Text(item.shopItem.displayName)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
            
            // Purchase date
            Text("Purchased: \(item.purchaseDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Action button
            actionButton
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch item.shopItem.category {
        case .accessories:
            if item.isEquipped {
                Button("Unequip") {
                    animalManager.inventoryManager.unequipAccessory(item)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                Button("Equip") {
                    animalManager.inventoryManager.equipAccessory(item)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
        case .backgrounds:
            if item.isEquipped {
                Text("Active Background")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            } else {
                Button("Use Background") {
                    animalManager.inventoryManager.setBackground(item)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
        case .upgrades:
            if item.isEquipped {
                Text("Current Animal")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            } else {
                Text("Owned")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        default:
            EmptyView()
        }
    }
}

// Helper function to get asset name (reused from ShopView)
fileprivate func shopAssetName(for item: ShopItem) -> String? {
    switch item {
    case .steak: return "steak"
    case .fedora: return "fedora"
    case .sunglasses: return "sunglasses"
    case .tie: return "tie"
    case .bowtie: return "bowtie"
    case .potion: return "potion"
    case .pills: return "pills"
    case .background(let type): return type.imageName
    case .upgrade(let upgrade):
        switch upgrade {
        case .fish: return "fish_state_1"
        case .gecko: return "gecko_state_1"
        case .cat: return "cat_state_1"
        case .dog: return "dog_state_1"
        case .unicorn: return "unicorn_state_1"
        }
    }
}

#Preview {
    InventoryView()
}