//
//  ContentViewModel.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import Foundation
import SwiftUI
import UIKit

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
    @State private var showStatDecaySettings: Bool = false
    @State private var showGameOver: Bool = false
    
    enum ResetType: String, CaseIterable {
        case tasks = "Tasks"
        case money = "Money"
        case animalProgression = "Animal Progression"
        case shopPurchases = "Shop Purchases"
        case inventory = "Inventory"
        case all = "Everything"
    }
    
    private var animal: Animal {
        AnimalManager.shared.animal
    }
    
    private var isGameOver: Bool {
        return animal.status.health.value <= 0 || 
               animal.status.happiness.value <= 0 || 
               animal.status.hunger.value <= 0
    }
    
    var body: some View {
        ZStack {
            Image(animalManager.currentBackground.imageName)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 8) {
                    HStack {
                        VStack(spacing: 10) {
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
                        .frame(width: 315)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.5))
                        )
                    }
                    .padding(.top, 12)
                    
                    // Inventory Button positioned below the health bars
                    HStack {
                        Spacer()
                        Button(action: {
                            showInventory = true
                        }) {
                            Image("inventory")
                                .resizable()
                                .frame(width: 80, height: 80)
                        }
                        .popover(isPresented: $showInventory, arrowEdge: .top) {
                            InventoryPopoverContent(isPresented: $showInventory)
                                // Let the content fully define size; suggest a popover size
                                .frame(minWidth: 360, minHeight: 420)
                        }
                    }
                    .padding(.trailing, 30)
                    .padding(.top, 12)
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
                                showTaskAssigner: $showTaskAssigner,
                                showStatDecaySettings: $showStatDecaySettings
                            )
                        }
                    }
                    .padding(.top)
                }
                
                Spacer()
                
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
                }
                
                Spacer()
            }
                    
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
            
            // Stat Decay Settings Overlay
            if showStatDecaySettings {
                StatDecaySettingsOverlay(
                    isPresented: $showStatDecaySettings
                )
            }
            
            // Game Over Overlay
            if isGameOver || showGameOver {
                // Hide the custom tab bar while Game Over is shown
                TabBarVisibilityController(hide: true)
                    .allowsHitTesting(false) // invisible helper, doesn't intercept touches
                GameOverOverlay(
                    animalManager: $animalManager,
                    isPresented: $showGameOver,
                    onReset: resetAfterGameOver
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
        .zIndex(0)
        .onChange(of: isGameOver) { _, newValue in
            if newValue {
                // Pause stat decay when game over condition is reached
                AnimalManager.shared.pauseStatDecay()
                showGameOver = true
            }
        }
        .onChange(of: showGameOver) { _, visible in
            // Extra safety: pause when the overlay is shown; resume if it is manually dismissed
            if visible {
                AnimalManager.shared.pauseStatDecay()
            } else if !isGameOver {
                // Only resume if the game-over condition is no longer true
                AnimalManager.shared.resumeStatDecay()
            }
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
    
    private func resetAfterGameOver() {
        // Fully reset all game state
        AnimalManager.shared.resetAnimalProgression()
        AnimalManager.shared.resetCoins()
        AnimalManager.shared.clearPurchaseHistory()
        AnimalManager.shared.clearInventory()
        AnimalManager.shared.taskManager.clearAllTasks()
        AnimalManager.shared.objectivesManager.resetObjectives()
        
        // Remove all animal inventory items except blob
        let inventory = AnimalManager.shared.inventoryManager
        let allAnimalTypes: [AnimalType] = [.fish, .gecko, .cat, .dog, .unicorn]
        for type in allAnimalTypes {
            inventory.removeItem(.animal(CodableAnimalType(type)))
        }
        // Ensure blob is present and equipped
        if !inventory.hasItem(.animal(AnimalType.blob)) {
            inventory.addItem(.animal(AnimalType.blob), isEquipped: true)
        } else {
            // Make sure blob is equipped
            if let blobItem = inventory.items.first(where: { $0.itemType == .animal(AnimalType.blob) }) {
                inventory.equipItem(withId: blobItem.id)
            }
        }
        
        AnimalManager.shared.save()
        // Dismiss the overlay
        showGameOver = false
        
        // Resume stat decay for the new game
        AnimalManager.shared.resumeStatDecay()
        
        // Animate the custom tab bar back in after the overlay is dismissed
        TabBarVisibilityController.showTabBarAnimated()
    }
}
    
    
struct DevModePopoverContent: View {
    @Binding var showResetAlert: Bool
    @Binding var resetType: HomeView.ResetType?
    @Binding var showCoinSetter: Bool
    @Binding var showTaskAssigner: Bool
    @Binding var showStatDecaySettings: Bool
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
                        
                        // Stat Decay Settings Button
                        Button("Stat Decay Settings") {
                            showStatDecaySettings = true
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.purple.opacity(0.8))
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
                    // Animate tab bar back when dismissing via background tap
                    TabBarVisibilityController.showTabBarAnimated()
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
                        // Animate tab bar back in case this overlay was used similarly
                        TabBarVisibilityController.showTabBarAnimated()
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
                            TabBarVisibilityController.showTabBarAnimated()
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
                    TabBarVisibilityController.showTabBarAnimated()
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
                            TabBarVisibilityController.showTabBarAnimated()
                        }
                    }
                }
                
                Button("Close") {
                    isPresented = false
                    TabBarVisibilityController.showTabBarAnimated()
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
                .ignoresSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("Inventory")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("Close") {
                        isPresented = false
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
                .background(.regularMaterial)
                
                // Inventory content
                InventoryView(animalManager: AnimalManager.shared)
                    .background(.regularMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(20)
        }
        .zIndex(999)
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

struct StatDecaySettingsOverlay: View {
    @Binding var isPresented: Bool
    @State private var intervalString: String = ""
    @State private var currentInterval: TimeInterval = 600
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                    TabBarVisibilityController.showTabBarAnimated()
                }
            
            VStack(spacing: 20) {
                Text("Stat Decay Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    Text("Current interval: \(Int(currentInterval)) seconds")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Default: 600 seconds (10 minutes)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                TextField("Enter interval in seconds", text: $intervalString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .focused($isTextFieldFocused)
                
                HStack(spacing: 15) {
                    Button("Cancel") {
                        isPresented = false
                        intervalString = ""
                        TabBarVisibilityController.showTabBarAnimated()
                    }
                    .padding()
                    .background(.secondary)
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Reset to Default") {
                        AnimalManager.shared.resetStatDecayInterval()
                        currentInterval = 600
                        intervalString = ""
                        isPresented = false
                        TabBarVisibilityController.showTabBarAnimated()
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Set") {
                        if let interval = TimeInterval(intervalString), interval > 0 {
                            AnimalManager.shared.setStatDecayInterval(interval)
                            currentInterval = interval
                            isPresented = false
                            intervalString = ""
                            TabBarVisibilityController.showTabBarAnimated()
                        }
                    }
                    .padding()
                    .background(intervalString.isEmpty || TimeInterval(intervalString) == nil || TimeInterval(intervalString) ?? 0 <= 0 ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(intervalString.isEmpty || TimeInterval(intervalString) == nil || TimeInterval(intervalString) ?? 0 <= 0)
                }
            }
            .padding(30)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(30)
        }
        .onAppear {
            currentInterval = AnimalManager.shared.currentStatDecayInterval
            isTextFieldFocused = true
        }
    }
}

struct GameOverOverlay: View {
    @Binding var animalManager: AnimalManager
    @Binding var isPresented: Bool
    var onReset: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Game Over!")
                        .font(.petName)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("Your pet's vital stats have dropped to zero.")
                        .font(.habitTitle)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("All your progress will be reset. You'll have to start over with a new pet.")
                        .font(.body)
                        .foregroundColor(.indigo)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 16) {
                    Text("Final Stats:")
                        .font(.habitTitle)
                        .foregroundColor(.black)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(animalManager.animal.status.health.value <= 0 ? .red : .black)
                            Text("Health: \(animalManager.animal.status.health.value)/100")
                                .font(.body)
                                .foregroundColor(animalManager.animal.status.health.value <= 0 ? .red : .black)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "face.smiling.fill")
                                .foregroundColor(animalManager.animal.status.happiness.value <= 0 ? .red : .black)
                            Text("Happiness: \(animalManager.animal.status.happiness.value)/100")
                                .font(.body)
                                .foregroundColor(animalManager.animal.status.happiness.value <= 0 ? .red : .black)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(animalManager.animal.status.hunger.value <= 0 ? .red : .black)
                            Text("Hunger: \(animalManager.animal.status.hunger.value)/100")
                                .font(.body)
                                .foregroundColor(animalManager.animal.status.hunger.value <= 0 ? .red : .black)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button("Start Over") {
                    onReset?()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.red)
                .foregroundColor(.white)
                .font(.body)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(40)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .opacity(0.87)
            .padding(30)
        }
        .zIndex(2000) // Ensure it appears above everything else
    }
}

// MARK: - Inventory popover content
private struct InventoryPopoverContent: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        // Use a container that expands fully and ignores safe areas to eliminate top/bottom gaps
        VStack(spacing: 0) {
            // Header (only this consumes its own height)
            HStack {
                Text("Inventory")
                    .font(.headline)
                Spacer()
                Button("Close") {
                    isPresented = false
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
            
            // Content fills the rest
            InventoryView(animalManager: AnimalManager.shared)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Clear any navigation title spacing inside the view
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .ignoresSafeArea() // ensure no extra safe-area padding in popover
    }
}

// MARK: - UIKit bridge to control MainTabBarController visibility from SwiftUI
private struct TabBarVisibilityController: UIViewRepresentable {
    let hide: Bool
    
    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        DispatchQueue.main.async {
            updateTabBarVisibility(from: v)
        }
        return v
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            updateTabBarVisibility(from: uiView)
        }
    }
    
    private func updateTabBarVisibility(from view: UIView) {
        guard let tab = findTabBarController(from: view) as? MainTabBarController else { return }
        if hide {
            tab.hideCustomTabBar(animated: true)
        } else {
            tab.showCustomTabBar(animated: true)
        }
    }
    
    private func findTabBarController(from view: UIView) -> UITabBarController? {
        var responder: UIResponder? = view
        while let r = responder {
            if let vc = r as? UIViewController, let tbc = vc.tabBarController {
                return tbc
            }
            responder = r.next
        }
        return nil
    }
    
    // Convenience method to show the tab bar with animation from SwiftUI actions
    static func showTabBarAnimated() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.keyWindow,
              let root = window.rootViewController else { return }
        if let tab = findMainTabBarController(from: root) {
            tab.showCustomTabBar(animated: true)
        }
    }
    
    private static func findMainTabBarController(from root: UIViewController) -> MainTabBarController? {
        if let tab = root as? MainTabBarController { return tab }
        if let nav = root as? UINavigationController {
            return nav.viewControllers.compactMap { findMainTabBarController(from: $0) }.first
        }
        for child in root.children {
            if let found = findMainTabBarController(from: child) {
                return found
            }
        }
        if let presented = root.presentedViewController {
            return findMainTabBarController(from: presented)
        }
        return nil
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        return self.windows.first { $0.isKeyWindow }
    }
}

