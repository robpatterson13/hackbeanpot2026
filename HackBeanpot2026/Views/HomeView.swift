//
//  ContentViewModel.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import Foundation
import SwiftUI

@Observable
class HomeViewModel {
    weak private var animalManager: AnimalManager?
    
    init(animalManager: AnimalManager) {
        self.animalManager = animalManager
    }
    
    func getAnimalImages() -> (String, String) {
        switch animalManager?.animal.type {
        case .blob:
            return ("blob_state_1", "blob_state_2")
        case .fish:
            return ("fish_state_1", "fish_state_2")
        case .gecko:
            return ("gecko_state_1", "gecko_state_2")
        case .cat:
            return ("cat_state_1", "cat_state_2")
        case .dog:
            return ("dog_state_1", "dog_state_2")
        case .unicorn:
            return ("unicorn_state_1", "unicorn_state_2")
        case .none:
            return ("", "")
        }
    }

    func getBackgroundImage() -> String {
        switch animalManager?.selectedBackground {
        case .city:
            return "city"
        case .desert:
            return "desert"
        case .forest:
            return "forest"
        case .ocean:
            return "ocean"
        case .livingRoom:
            return "livingRoom"
        case .none:
            return ""
        }
    }
}

struct HomeView: View {
    @State private var homeViewModel: HomeViewModel = .init(animalManager: AnimalManager.shared)
    @State private var yOffset: CGFloat = 0
    @State private var animationManager = AnimationManager.shared
    @State private var animalManager = AnimalManager.shared
    @State private var isBlob: Bool = true
    @State private var showDevMode: Bool = false
    @State private var devModeUnlocked: Bool = false
    @State private var tapCount: Int = 0
    @State private var showResetAlert: Bool = false
    @State private var resetType: ResetType?
    @State private var showCoinSetter: Bool = false
    @State private var coinAmount: String = ""
    @State private var showTaskAssigner: Bool = false
    @State private var showInventory: Bool = false
    
    // Accessory positioning helper
    private let accessoryManager = AnimalAccessoryManager()
    
    enum ResetType: String, CaseIterable {
        case tasks = "Tasks"
        case money = "Money"
        case animalProgression = "Animal Progression"
        case shopPurchases = "Shop Purchases"
        case inventory = "Inventory"
        case all = "Everything"
    }
    
    private var animal: Animal? {
        AnimalManager.shared.animal
    }
    
    // Convenience to get current animal type
    private var currentAnimalType: AnimalType {
        AnimalManager.shared.animal.type
    }
    
    // Equipped accessories from inventory
    private var equippedAccessories: [AccessoryType] {
        AnimalManager.shared.inventoryManager
            .equippedItems
            .compactMap { item in
                if case .accessory(let type) = item.itemType { return type }
                return nil
            }
    }
    
    var body: some View {
        ZStack {
            Image(animalManager.currentBackground.imageName)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    VStack(spacing: 10) {
                        if let animal {
                            StatBar(value: Double(animal.status.health.value),
                                    color: .red,
                                    icon: Image("health"),
                                    iconWidth: 40)
                            
                            StatBar(value: Double(animal.status.hunger.value),
                                    color: .blue,
                                    icon: Image("hunger"),
                                    iconWidth: 40)
                            
                            StatBar(value: Double(animal.status.happiness.value),
                                    color: .orange,
                                    icon: Image("happiness"),
                                    iconWidth: 30)
                        }
                    }
                    .frame(width: 315)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.5))
                    )
                }
                
                Spacer()
                
                // Dev Mode Toggle Button (hidden until unlocked)
                if devModeUnlocked {
                    HStack {
                        Spacer()
                        Button("Dev Mode") {
                            showDevMode.toggle()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.trailing)
                        .popover(isPresented: $showDevMode, arrowEdge: .top) {
                            DevModePopoverContent(
                                showResetAlert: $showResetAlert,
                                resetType: $resetType,
                                showCoinSetter: $showCoinSetter,
                                showTaskAssigner: $showTaskAssigner
                            )
                        }
                    }
                    .padding(.top)
                }
                
                Spacer()
                
                // Animal + Accessories share the same animated vertical offset
                ZStack {
                    Image(animationManager.showState1 ? homeViewModel.getAnimalImages().0 : homeViewModel.getAnimalImages().1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .offset(y: yOffset)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 3)
                                    .repeatForever(autoreverses: true)
                            ) {
                                yOffset = -15
                            }
                        }
                        .onTapGesture {
                            // Secret dev mode unlock: tap animal 7 times quickly
                            tapCount += 1
                            if tapCount >= 7 {
                                devModeUnlocked = true
                                tapCount = 0
                            }
                            
                            // Reset tap count after 2 seconds of no tapping
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                if tapCount < 7 {
                                    tapCount = 0
                                }
                            }
                        }
                    
                    // Overlay all equipped accessories with per-animal positioning and bobbing
                    ForEach(equippedAccessories, id: \.self) { accessory in
                        if let pos = accessoryManager.getAccessoryPosition(for: accessory, animalType: currentAnimalType) {
                            Image(accessory.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: accessoryImageSize(for: accessory), height: accessoryImageSize(for: accessory))
                                // Base placement relative to animal center
                                .offset(x: pos.xOffset, y: pos.yOffset)
                                // Apply the same animated vertical motion
                                .offset(y: yOffset)
                        }
                    }
                }
                
                Spacer()
            }
                    
            // Inventory Button
            VStack {
                Button(action: {
                    showInventory = true
                }) {
                    Image(systemName: "bag.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                Spacer()
            }
            .padding(.trailing, 16)
            
            // Coin Setter Overlay
            if showCoinSetter {
                CoinSetterOverlay(
                    isPresented: $showCoinSetter,
                    coinAmount: $coinAmount
                )
            }
            
            // Task Assigner Overlay
            if showTaskAssigner {
                TaskAssignerOverlay(
                    isPresented: $showTaskAssigner
                )
            }
            
            // Inventory Viewer Overlay
            if showInventory {
                InventoryOverlay(
                    isPresented: $showInventory
                )
            }
        }
        .alert("Reset \(resetType?.rawValue ?? "")", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                performReset()
            }
        } message: {
            Text("Are you sure you want to reset \(resetType?.rawValue.lowercased() ?? "")? This action cannot be undone.")
        }
    }
    
    // Size tweaks per accessory; adjust as needed
    private func accessoryImageSize(for accessory: AccessoryType) -> CGFloat {
        switch accessory {
        case .fedora: return 100
        case .sunglasses: return 90
        case .tie, .bowtie: return 80
        }
    }
    
    private func performReset() {
        guard let resetType = resetType else { return }
        
        switch resetType {
        case .tasks:
            resetTasks()
        case .money:
            resetMoney()
        case .animalProgression:
            resetAnimalProgression()
        case .shopPurchases:
            resetShopPurchases()
        case .inventory:
            resetInventory()
        case .all:
            resetMoney()
            resetAnimalProgression() // This clears inventory, tasks, objectives, purchase history, and resets animal
        }
    }
    
    private func resetTasks() {
        let taskManager = AnimalManager.shared.taskManager
        taskManager.clearAllTasks()
    }
    
    private func resetMoney() {
        AnimalManager.shared.resetCoins()
    }
    
    private func resetAnimalProgression() {
        AnimalManager.shared.resetAnimalProgression()
    }
    
    private func resetShopPurchases() {
        AnimalManager.shared.clearPurchaseHistory()
    }
    
    private func resetInventory() {
        AnimalManager.shared.clearInventory()
    }
    
    private func resetObjectives() {
        AnimalManager.shared.objectivesManager.resetObjectives()
    }
}
    
    
struct DevModePopoverContent: View {
    @Binding var showResetAlert: Bool
    @Binding var resetType: HomeView.ResetType?
    @Binding var showCoinSetter: Bool
    @Binding var showTaskAssigner: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Text("Developer Tools")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Set Coins Button
                        Button("Set Coins") {
                            showCoinSetter = true
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // Assign Task Button
                        Button("Assign Specific Task") {
                            showTaskAssigner = true
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Divider()
                    
                    VStack(spacing: 12) {
                        Text("Reset Options")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ForEach(HomeView.ResetType.allCases, id: \.rawValue) { type in
                            Button("Reset \(type.rawValue)") {
                                resetType = type
                                showResetAlert = true
                                dismiss()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Developer Mode")
            .navigationBarTitleDisplayMode(.inline)
            .frame(minWidth: 300, minHeight: 400)
        }
    }
}

struct CoinSetterOverlay: View {
    @Binding var isPresented: Bool
    @Binding var coinAmount: String
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text("Set Coins")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Current: \(AnimalManager.shared.coins) coins")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Enter coin amount", text: $coinAmount)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .focused($isTextFieldFocused)
                
                HStack(spacing: 15) {
                    Button("Cancel") {
                        isPresented = false
                        coinAmount = ""
                    }
                    .padding()
                    .background(.secondary)
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Set") {
                        if let amount = Int(coinAmount), amount >= 0 {
                            AnimalManager.shared.setCoins(amount)
                            isPresented = false
                            coinAmount = ""
                        }
                    }
                    .padding()
                    .background(coinAmount.isEmpty || Int(coinAmount) == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(coinAmount.isEmpty || Int(coinAmount) == nil)
                }
            }
            .padding(30)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(30)
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

struct TaskAssignerOverlay: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text("Assign Specific Task")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose a task to assign:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(Habit.allCases, id: \.self) { habit in
                        TaskAssignmentButton(habit: habit) {
                            AnimalManager.shared.taskManager.assignTask(for: habit)
                            isPresented = false
                        }
                    }
                }
                
                Button("Close") {
                    isPresented = false
                }
                .padding()
                .background(.secondary)
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(30)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(30)
        }
    }
}

struct TaskAssignmentButton: View {
    let habit: Habit
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: habit.imageName)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(habit.displayName)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct InventoryOverlay: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            NavigationView {
                InventoryView(animalManager: AnimalManager.shared)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                isPresented = false
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(20)
        }
    }
}

private struct StatBar: View {
    let value: Double
    let color: Color
    let icon: Image
    let iconWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.7)).frame(width: 32, height: 32)
                    .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconWidth, height: iconWidth)
            }
            .frame(width: 40, height: 40, alignment: .center)
            
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    Rectangle()
                        .fill(color)
                        .frame(width: max((geo.size.width - 11 ) * CGFloat(value / 100), 0), height: 12)
                        .padding(.horizontal, 5)
                        .frame(height: 12)
                }
                Image("bar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 12)
                    .offset(y: 4)
                
                
            }
            .frame(height: 12)
            
            Text("\(Int(value))/100")
                .font(.caption)
                .foregroundColor(.black)
                .frame(width: 50, alignment: .trailing)
        }
        .frame(height: 24)
    }
}
