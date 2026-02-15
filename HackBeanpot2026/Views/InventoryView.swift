//
//  InventoryView.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import SwiftUI

struct InventoryView: View {
    @State private var viewModel: InventoryViewModel
    @State private var selectedCategory: InventoryCategory = .animals
    
    init(animalManager: AnimalManager) {
        _viewModel = State(initialValue: InventoryViewModel(animalManager: animalManager))
    }
    
    var body: some View {
        VStack {
            // Category picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(InventoryCategory.allCases, id: \.self) { category in
                    Text(category.rawValue)
                        .tag(category)
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
                        .font(.h3)
                        .foregroundColor(.secondary)
                    
                    Text("Visit the shop to purchase items!")
                        .font(.body)
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
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
            
            // Equip/Unequip button (animals and backgrounds can't be unequipped, only switched)
            Button(action: item.isEquipped ? (cannotUnequip ? {} : onUnequip) : onEquip) {
                Text(buttonText)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(buttonColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .disabled(item.isEquipped && cannotUnequip)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private var isAnimal: Bool {
        switch item.itemType {
        case .animal:
            return true
        default:
            return false
        }
    }
    
    private var isBackground: Bool {
        switch item.itemType {
        case .background:
            return true
        default:
            return false
        }
    }
    
    private var cannotUnequip: Bool {
        return isAnimal || isBackground
    }
    
    private var buttonText: String {
        if item.isEquipped {
            if isAnimal {
                return "Active"
            } else if isBackground {
                return "Active"
            } else {
                return "Unequip"
            }
        } else {
            return "Equip"
        }
    }
    
    private var buttonColor: Color {
        if item.isEquipped {
            if cannotUnequip {
                return Color.green
            } else {
                return Color.orange
            }
        } else {
            return Color.accentColor
        }
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
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 8))
        case .accessory(let accessoryType):
            Image(accessoryType.rawValue)
                .resizable()
                .scaledToFit()
        }
    }
}

@Observable
final class InventoryViewModel {
    private let animalManager: AnimalManager
    
    init(animalManager: AnimalManager) {
        self.animalManager = animalManager
    }
    
    func items(for category: InventoryCategory) -> [InventoryItem] {
        animalManager.inventoryManager.items(for: category)
    }
    
    func equipItem(_ item: InventoryItem) {
        // When equipping an animal, automatically unequip the current one
        if case .animal(let codableAnimalType) = item.itemType {
            // First equip the new animal in inventory (this will unequip others automatically)
            animalManager.inventoryManager.equipItem(withId: item.id)
            
            // Then update the animal manager's current animal
            animalManager.animal.type = codableAnimalType.asAnimalType
        } else if case .background(let backgroundType) = item.itemType {
            // First equip the new background in inventory (this will unequip others automatically)
            animalManager.inventoryManager.equipItem(withId: item.id)
            
            // Then update the animal manager's current background
            animalManager.setSelectedBackground(backgroundType)
        } else {
            // For accessories, use normal equip logic
            animalManager.inventoryManager.equipItem(withId: item.id)
        }
        
        animalManager.save()
    }
    
    func unequipItem(_ item: InventoryItem) {
        // Prevent unequipping animals and backgrounds entirely
        guard case .animal = item.itemType else {
            guard case .background = item.itemType else {
                animalManager.inventoryManager.unequipItem(withId: item.id)
                
                // Handle unequipping effects for accessories only
                switch item.itemType {
                case .accessory:
                    // Remove accessory effects
                    break
                case .animal, .background:
                    // Should never reach here due to guards
                    break
                }
                
                animalManager.save()
                return
            }
            // For backgrounds, do nothing - they cannot be unequipped
            return
        }
        
        // For animals, do nothing - they cannot be unequipped
    }
}

#Preview {
    NavigationView {
        InventoryView(animalManager: AnimalManager.shared)
    }
}
