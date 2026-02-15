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
    @State private var isBlob: Bool = true
    @State private var showDevMode: Bool = false
    @State private var devModeUnlocked: Bool = false
    @State private var tapCount: Int = 0
    @State private var showResetAlert: Bool = false
    @State private var resetType: ResetType?
    @State private var showCoinSetter: Bool = false
    @State private var coinAmount: String = ""
    @State private var showTaskAssigner: Bool = false
    
    enum ResetType: String, CaseIterable {
        case tasks = "Tasks"
        case money = "Money"
        case animalProgression = "Animal Progression"
        case shopPurchases = "Shop Purchases"
        case all = "Everything"
    }
    
    var body: some View {
        ZStack {
            Image(homeViewModel.getBackgroundImage())
                .resizable()
                .ignoresSafeArea()
            
            VStack {
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
                            // Only setup bounce animation, timer is handled by AnimationManager
                            withAnimation(
                                .easeInOut(duration: 3)
                                .repeatForever(autoreverses: true)
                            ) {
                                yOffset = -15 // Bounce up 15 points
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
            
            // Dev Mode Overlay
            if showDevMode {
                DevModeOverlay(
                    isPresented: $showDevMode,
                    showResetAlert: $showResetAlert,
                    resetType: $resetType,
                    showCoinSetter: $showCoinSetter,
                    showTaskAssigner: $showTaskAssigner
                )
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
        case .all:
            resetTasks()
            resetMoney()
            resetAnimalProgression()
            resetShopPurchases()
            resetObjectives()
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
    
    private func resetObjectives() {
        AnimalManager.shared.objectivesManager.resetObjectives()
    }
}

struct DevModeOverlay: View {
    @Binding var isPresented: Bool
    @Binding var showResetAlert: Bool
    @Binding var resetType: HomeView.ResetType?
    @Binding var showCoinSetter: Bool
    @Binding var showTaskAssigner: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text("Developer Mode")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    // Set Coins Button
                    Button("Set Coins") {
                        showCoinSetter = true
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Assign Task Button
                    Button("Assign Specific Task") {
                        showTaskAssigner = true
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Text("Reset Options")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    ForEach(HomeView.ResetType.allCases, id: \.rawValue) { type in
                        Button("Reset \(type.rawValue)") {
                            resetType = type
                            showResetAlert = true
                            isPresented = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
