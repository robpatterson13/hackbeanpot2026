//
//  InventoryView.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import SwiftUI

struct InventoryView: View {
    @StateObject private var viewModel: InventoryViewModel
    @State private var selectedCategory: InventoryCategory = .animals
    
    init(animalManager: AnimalManager) {
        _viewModel = StateObject(wrappedValue: InventoryViewModel(animalManager: animalManager))
    }
    
    var body: some View {
        VStack {
            // Category picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(InventoryCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Items grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(viewModel.items(for: selectedCategory)) { item in
                        InventoryItemCard(
                            item: item,
                            onEquip: { viewModel.equipItem(item) },
                            onUnequip: { viewModel.unequipItem(item) }
                        )
                    }
                }
                .padding()
            }
            
            if viewModel.items(for: selectedCategory).isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bag")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No \(selectedCategory.rawValue.lowercased()) yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Visit the shop to purchase items!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
        .navigationTitle("Inventory")
        .background(Color(.systemGroupedBackground))
    }
}

struct InventoryItemCard: View {
    let item: InventoryItem
    let onEquip: () -> Void
    let onUnequip: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Item image/icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.isEquipped ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(item.isEquipped ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                
                contentImage
                    .padding(12)
                
                // Equipped badge
                if item.isEquipped {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .background(Color.white, in: Circle())
                        }
                        Spacer()
                    }
                    .padding(6)
                }
            }
            .frame(height: 100)
            
            // Item name
            Text(item.itemType.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
            
            // Equip/Unequip button
            Button(action: item.isEquipped ? onUnequip : onEquip) {
                Text(item.isEquipped ? "Unequip" : "Equip")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(item.isEquipped ? Color.orange : Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var contentImage: some View {
        switch item.itemType {
        case .animal(let animalType):
            Image("\(animalType.rawValue)_state_1")
                .resizable()
                .scaledToFit()
        case .background(let backgroundType):
            Image(backgroundType.imageName)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 8))
        case .accessory(let accessoryType):
            Image(accessoryType.rawValue)
                .resizable()
                .scaledToFit()
        }
    }
}

final class InventoryViewModel: ObservableObject {
    private let animalManager: AnimalManager
    
    init(animalManager: AnimalManager) {
        self.animalManager = animalManager
    }
    
    func items(for category: InventoryCategory) -> [InventoryItem] {
        animalManager.inventoryManager.items(for: category)
    }
    
    func equipItem(_ item: InventoryItem) {
        animalManager.inventoryManager.equipItem(withId: item.id)
        
        // Apply the item effect based on category
        switch item.itemType {
        case .background(let backgroundType):
            animalManager.selectedBackground = backgroundType
        case .animal(let animalType):
            animalManager.animal.type = animalType
        case .accessory:
            // Accessories might provide ongoing effects in the future
            break
        }
        
        animalManager.save()
    }
    
    func unequipItem(_ item: InventoryItem) {
        animalManager.inventoryManager.unequipItem(withId: item.id)
        
        // Handle unequipping effects
        switch item.itemType {
        case .background:
            animalManager.selectedBackground = .livingRoom // Default background
        case .animal:
            // Don't allow unequipping animals - they should switch to another animal instead
            break
        case .accessory:
            // Remove accessory effects
            break
        }
        
        animalManager.save()
    }
}

#Preview {
    NavigationView {
        InventoryView(animalManager: AnimalManager.shared)
    }
}