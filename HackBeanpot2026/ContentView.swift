//
//  ContentView.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import SwiftUI
import HealthKit
import UserNotifications

// MARK: - 16-bit Modern Style Extensions

extension Font {
    static let retro12 = Font.system(size: 12, weight: .medium, design: .rounded)
    static let retro14 = Font.system(size: 14, weight: .medium, design: .rounded)
    static let retro16 = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let retro18 = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let retro20 = Font.system(size: 20, weight: .bold, design: .rounded)
    static let retro24 = Font.system(size: 24, weight: .bold, design: .rounded)
    static let retro28 = Font.system(size: 28, weight: .heavy, design: .rounded)
}

extension Color {
    // Modern 16-bit inspired color palette with gradients and depth
    static let modernGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let modernGreenDark = Color(red: 0.1, green: 0.6, blue: 0.3)
    static let modernRed = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let modernRedDark = Color(red: 0.8, green: 0.2, blue: 0.2)
    static let modernBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    static let modernBlueDark = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let modernYellow = Color(red: 1.0, green: 0.9, blue: 0.2)
    static let modernYellowDark = Color(red: 0.9, green: 0.7, blue: 0.1)
    static let modernPurple = Color(red: 0.7, green: 0.4, blue: 1.0)
    static let modernPurpleDark = Color(red: 0.5, green: 0.2, blue: 0.8)
    static let modernCyan = Color(red: 0.2, green: 0.9, blue: 0.9)
    static let modernCyanDark = Color(red: 0.1, green: 0.7, blue: 0.7)
    static let modernOrange = Color(red: 1.0, green: 0.7, blue: 0.2)
    static let modernOrangeDark = Color(red: 0.9, green: 0.5, blue: 0.1)
    
    // UI Background colors
    static let gameBackground = Color(red: 0.05, green: 0.08, blue: 0.12)
    static let gamePrimary = Color(red: 0.1, green: 0.15, blue: 0.25)
    static let gameSecondary = Color(red: 0.15, green: 0.2, blue: 0.3)
    static let gameAccent = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let gameText = Color(red: 0.9, green: 0.95, blue: 1.0)
    static let gameTextSecondary = Color(red: 0.7, green: 0.8, blue: 0.9)
}

// Add ShapeStyle extension
extension ShapeStyle where Self == Color {
    static var modernGreen: Color { .modernGreen }
    static var modernGreenDark: Color { .modernGreenDark }
    static var modernRed: Color { .modernRed }
    static var modernRedDark: Color { .modernRedDark }
    static var modernBlue: Color { .modernBlue }
    static var modernBlueDark: Color { .modernBlueDark }
    static var modernYellow: Color { .modernYellow }
    static var modernYellowDark: Color { .modernYellowDark }
    static var modernPurple: Color { .modernPurple }
    static var modernPurpleDark: Color { .modernPurpleDark }
    static var modernCyan: Color { .modernCyan }
    static var modernCyanDark: Color { .modernCyanDark }
    static var modernOrange: Color { .modernOrange }
    static var modernOrangeDark: Color { .modernOrangeDark }
    static var gameBackground: Color { .gameBackground }
    static var gamePrimary: Color { .gamePrimary }
    static var gameSecondary: Color { .gameSecondary }
    static var gameAccent: Color { .gameAccent }
    static var gameText: Color { .gameText }
    static var gameTextSecondary: Color { .gameTextSecondary }
}

// MARK: - Models

@Observable
class GameModel {
    var dog = VirtualDog()
    var currentTask: HabitTask?
    var completedTasks: [HabitTask] = []
    var coins: Int = 50
    var shop = Shop()
    var lastTaskAssignment = Date()
    
    init() {
        assignRandomTask()
    }
    
    func assignRandomTask() {
        currentTask = HabitTask.random()
        lastTaskAssignment = Date()
    }
    
    func completeTask() {
        guard let task = currentTask else { return }
        
        completedTasks.append(task)
        coins += task.reward
        currentTask = nil
        
        // Schedule next task in 30 seconds (for demo, use shorter time)
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { // 30 seconds for testing, change to 10800 for production
            self.assignRandomTask()
        }
    }
    
    func purchaseItem(_ item: ShopItem) -> Bool {
        guard coins >= item.price else { return false }
        
        coins -= item.price
        
        switch item.type {
        case .food:
            dog.hunger = min(100, dog.hunger + item.value)
        case .healthPotion:
            dog.health = min(100, dog.health + item.value)
        case .toy:
            dog.happiness = min(100, dog.happiness + item.value)
        }
        
        return true
    }
}

struct VirtualDog {
    var health: Int = 80
    var happiness: Int = 70
    var hunger: Int = 60
    var name: String = "Buddy"
    
    var overallWellbeing: Double {
        Double(health + happiness + hunger) / 300.0
    }
}

struct HabitTask: Identifiable {
    let id = UUID()
    let type: HabitType
    let title: String
    let description: String
    let reward: Int
    let verificationType: VerificationType
    
    static func random() -> HabitTask {
        let types: [HabitType] = [.water, .sleep, .steps, .jobApplication, .outside, .leetcode, .shower]
        let randomType = types.randomElement()!
        
        switch randomType {
        case .water:
            return HabitTask(type: .water, title: "HYDRATION QUEST", description: "CONSUME 16 OZ H2O", reward: 10, verificationType: .manual)
        case .sleep:
            return HabitTask(type: .sleep, title: "POWER DOWN MODE", description: "SLEEP FOR 7+ HOURS", reward: 20, verificationType: .healthKit)
        case .steps:
            return HabitTask(type: .steps, title: "MOVEMENT PROTOCOL", description: "WALK 5,000 STEPS", reward: 15, verificationType: .healthKit)
        case .jobApplication:
            return HabitTask(type: .jobApplication, title: "CAREER MISSION", description: "SUBMIT JOB APPLICATION", reward: 30, verificationType: .photo)
        case .outside:
            return HabitTask(type: .outside, title: "OUTDOOR EXPEDITION", description: "SPEND 30 MIN OUTSIDE", reward: 15, verificationType: .location)
        case .leetcode:
            return HabitTask(type: .leetcode, title: "CODE CHALLENGE", description: "SOLVE LEETCODE PROBLEM", reward: 25, verificationType: .manual)
        case .shower:
            return HabitTask(type: .shower, title: "HYGIENE PROTOCOL", description: "MAINTAIN CLEANLINESS", reward: 10, verificationType: .manual)
        }
    }
}

enum HabitType: CaseIterable {
    case water, sleep, steps, jobApplication, outside, leetcode, shower
}

enum VerificationType {
    case manual, healthKit, photo, location
}

struct Shop {
    let items: [ShopItem] = [
        ShopItem(name: "MEAT RATION", type: .food, price: 15, value: 30, emoji: "🥩"),
        ShopItem(name: "HEALTH POTION", type: .healthPotion, price: 20, value: 40, emoji: "🧪"),
        ShopItem(name: "PIXEL BALL", type: .toy, price: 12, value: 25, emoji: "⚫"),
        ShopItem(name: "TOY SPRITE", type: .toy, price: 18, value: 35, emoji: "🎮"),
        ShopItem(name: "POWER FOOD", type: .food, price: 25, value: 50, emoji: "⭐")
    ]
}

struct ShopItem: Identifiable {
    let id = UUID()
    let name: String
    let type: ItemType
    let price: Int
    let value: Int
    let emoji: String
}

enum ItemType {
    case food, healthPotion, toy
}

// MARK: - Main Content View

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var model = GameModel()
    @State private var gameDataService = GameDataService()
    @State private var healthService = HealthService()
    @State private var taskVerificationService = TaskVerificationService()
    @State private var notificationService = NotificationService()
    @State private var selectedTab = 0
    @State private var showingPhotoVerification = false
    @State private var capturedImage: UIImage?
    @State private var showingDevMode = false
    @State private var devTapCount = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DogView(model: model, gameDataService: gameDataService)
                .tabItem {
                    Image(systemName: "pawprint.fill")
                    Text("Pet")
                }
                .tag(0)
            
            TaskView(
                model: model,
                gameDataService: gameDataService,
                verificationService: taskVerificationService,
                showingPhotoVerification: $showingPhotoVerification
            )
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Tasks")
            }
            .tag(1)
            
            ShopView(model: model, gameDataService: gameDataService)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Shop")
                }
                .tag(2)
            
            StatsView(model: model, gameDataService: gameDataService, showingDevMode: $showingDevMode)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(3)
        }
        .onAppear {
            setupApp()
        }
        .onReceive(NotificationCenter.default.publisher(for: .completeCurrentTask)) { _ in
            handleCompleteTaskNotification()
        }
        .onReceive(NotificationCenter.default.publisher(for: .viewPet)) { _ in
            selectedTab = 0
        }
        .sheet(isPresented: $showingPhotoVerification) {
            PhotoCaptureView { image in
                capturedImage = image
                verifyPhotoTask()
            }
        }
        .sheet(isPresented: $showingDevMode) {
            DevModeView(model: model, gameDataService: gameDataService)
        }
    }
    
    private func setupApp() {
        gameDataService.initialize(modelContext: modelContext)
        loadGameState()
        
        Task {
            do {
                try await notificationService.requestPermission()
                try await notificationService.scheduleTaskReminder()
                
                // Only try HealthKit setup if available and in production
                #if DEBUG
                print("DEBUG: Skipping HealthKit setup for development")
                #else
                if healthService.isHealthKitAvailable {
                    try await healthService.requestHealthKitPermission()
                }
                #endif
            } catch {
                print("Failed to setup services: \(error)")
                // Don't crash the app if services fail to setup
            }
        }
    }
    
    private func loadGameState() {
        guard let gameData = gameDataService.getCurrentGameData() else { return }
        
        // Load dog stats
        model.dog.name = gameData.dogName
        model.dog.health = gameData.health
        model.dog.happiness = gameData.happiness
        model.dog.hunger = gameData.hunger
        model.coins = gameData.coins
        
        // Load current task if exists
        if let currentTask = gameDataService.getCurrentTask() {
            model.currentTask = currentTask
        }
        
        // Convert completed tasks
        model.completedTasks = gameData.completedTasksToday.map { completed in
            let habitType: HabitType
            switch completed.taskType {
            case "water": habitType = .water
            case "sleep": habitType = .sleep
            case "steps": habitType = .steps
            case "jobApplication": habitType = .jobApplication
            case "outside": habitType = .outside
            case "leetcode": habitType = .leetcode
            case "shower": habitType = .shower
            default: habitType = .water
            }
            
            return HabitTask(
                type: habitType,
                title: completed.title,
                description: "Completed",
                reward: completed.reward,
                verificationType: .manual
            )
        }
        
        // Update widget data
        UserDefaults().setWidgetData(gameData: gameData)
    }
    
    private func handleCompleteTaskNotification() {
        if model.currentTask != nil {
            model.completeTask()
            saveGameState()
        }
    }
    
    private func verifyPhotoTask() {
        guard let image = capturedImage,
              let currentTask = model.currentTask else { return }
        
        Task {
            do {
                let isVerified = try await taskVerificationService.verifyTask(currentTask, photo: image)
                
                await MainActor.run {
                    if isVerified {
                        model.completeTask()
                        saveGameState()
                    } else {
                        // Show verification failed alert
                        print("Photo verification failed")
                    }
                }
            } catch {
                print("Verification error: \(error)")
            }
        }
    }
    
    private func saveGameState() {
        gameDataService.updateDogStats(
            health: model.dog.health,
            happiness: model.dog.happiness,
            hunger: model.dog.hunger
        )
        gameDataService.updateCoins(model.coins)
        
        if let currentTask = model.currentTask {
            gameDataService.setCurrentTask(currentTask)
        }
        
        // Update widget data
        if let gameData = gameDataService.getCurrentGameData() {
            UserDefaults().setWidgetData(gameData: gameData)
        }
        
        // Check if pet needs urgent care
        if model.dog.health < 30 || model.dog.happiness < 30 || model.dog.hunger < 30 {
            Task {
                try? await notificationService.schedulePetCareReminder(
                    dogName: model.dog.name,
                    health: model.dog.health,
                    happiness: model.dog.happiness,
                    hunger: model.dog.hunger
                )
            }
        }
    }
}

// MARK: - Dog View

struct DogView: View {
    @Bindable var model: GameModel
    @Bindable var gameDataService: GameDataService
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [Color.gameBackground, Color.gamePrimary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Pet name with modern styling
                    Text(model.dog.name)
                        .font(.retro28)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.modernYellow, Color.modernOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.modernYellowDark, radius: 2, x: 2, y: 2)
                    
                    // Modern pet display area with glass morphism
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gameSecondary.opacity(0.8))
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.modernBlue.opacity(0.1), Color.modernPurple.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.modernCyan.opacity(0.6), Color.modernBlue.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .frame(height: 320)
                        
                        VStack(spacing: 20) {
                            // Modern sprite-based dog
                            Modern16BitDog(wellbeing: model.dog.overallWellbeing)
                                .scaleEffect(1.8)
                            
                            // Status with modern styling
                            VStack(spacing: 8) {
                                Text(getStatusTitle())
                                    .font(.retro16)
                                    .foregroundColor(getStatusColor())
                                    .shadow(color: getStatusColor().opacity(0.5), radius: 1, x: 1, y: 1)
                                
                                Text(getStatusMessage())
                                    .font(.retro12)
                                    .foregroundColor(.gameTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gamePrimary.opacity(0.7))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(getStatusColor().opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Modern style stats
                    VStack(spacing: 15) {
                        ModernStatBar(
                            label: "Health",
                            value: model.dog.health,
                            maxValue: 100,
                            color: Color.modernRed,
                            icon: "❤️"
                        )
                        
                        ModernStatBar(
                            label: "Joy",
                            value: model.dog.happiness,
                            maxValue: 100,
                            color: Color.modernYellow,
                            icon: "😊"
                        )
                        
                        ModernStatBar(
                            label: "Food",
                            value: model.dog.hunger,
                            maxValue: 100,
                            color: Color.modernGreen,
                            icon: "🍖"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Modern coins display
                    HStack(spacing: 15) {
                        ModernCoinIcon()
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Credits")
                                .font(.retro14)
                                .foregroundColor(.gameTextSecondary)
                            
                            Text("\(model.coins)")
                                .font(.retro24)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.modernYellow, Color.modernOrange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.modernYellowDark, radius: 1, x: 1, y: 1)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gameSecondary.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.modernYellow.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("My Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.gamePrimary.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private func getStatusTitle() -> String {
        let wellbeing = model.dog.overallWellbeing
        if wellbeing > 0.8 { return "Excellent" }
        else if wellbeing > 0.6 { return "Good" }
        else if wellbeing > 0.4 { return "Average" }
        else if wellbeing > 0.2 { return "Poor" }
        else { return "Critical" }
    }
    
    private func getStatusColor() -> Color {
        let wellbeing = model.dog.overallWellbeing
        if wellbeing > 0.8 { return .modernGreen }
        else if wellbeing > 0.6 { return .modernYellow }
        else if wellbeing > 0.4 { return .modernOrange }
        else if wellbeing > 0.2 { return .modernRed }
        else { return .modernRed }
    }
    
    private func getStatusMessage() -> String {
        let wellbeing = model.dog.overallWellbeing
        if wellbeing > 0.8 {
            return "Your pet is thriving and happy!"
        } else if wellbeing > 0.6 {
            return "Your pet is doing well."
        } else if wellbeing > 0.4 {
            return "Your pet needs some attention."
        } else if wellbeing > 0.2 {
            return "Your pet requires urgent care!"
        } else {
            return "Your pet is in critical condition!"
        }
    }
}

struct Modern16BitDog: View {
    let wellbeing: Double
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Dog ears with gradient and shadow
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.modernOrange, Color.modernOrangeDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 12, height: 16)
                    .shadow(color: Color.modernOrangeDark.opacity(0.5), radius: 2, x: 1, y: 1)
                    .rotationEffect(.degrees(-15))
                
                Spacer().frame(width: 20)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.modernOrange, Color.modernOrangeDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 12, height: 16)
                    .shadow(color: Color.modernOrangeDark.opacity(0.5), radius: 2, x: 1, y: 1)
                    .rotationEffect(.degrees(15))
            }
            
            // Dog head with more detail and gradients
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        RadialGradient(
                            colors: [Color.modernOrange, Color.modernOrangeDark],
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: 45, height: 35)
                    .overlay(
                        // Face details with more modern styling
                        VStack(spacing: 4) {
                            // Eyes with animation based on wellbeing
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(wellbeing > 0.3 ? Color.black : Color.modernRed)
                                    .frame(width: 6, height: 6)
                                    .overlay(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 2, height: 2)
                                            .offset(x: -1, y: -1)
                                    )
                                    .scaleEffect(wellbeing > 0.5 ? 1.0 : 0.8)
                                
                                Circle()
                                    .fill(wellbeing > 0.3 ? Color.black : Color.modernRed)
                                    .frame(width: 6, height: 6)
                                    .overlay(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 2, height: 2)
                                            .offset(x: -1, y: -1)
                                    )
                                    .scaleEffect(wellbeing > 0.5 ? 1.0 : 0.8)
                            }
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                            
                            // Nose with gradient
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.black, Color.gray],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 6, height: 4)
                            
                            // Dynamic mouth based on wellbeing
                            Group {
                                if wellbeing > 0.5 {
                                    // Happy mouth - curved smile
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: 0))
                                        path.addQuadCurve(
                                            to: CGPoint(x: 12, y: 0),
                                            control: CGPoint(x: 6, y: 4)
                                        )
                                    }
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 12, height: 4)
                                } else if wellbeing > 0.2 {
                                    // Neutral mouth
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: 8, height: 2)
                                } else {
                                    // Sad mouth - curved frown
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: 4))
                                        path.addQuadCurve(
                                            to: CGPoint(x: 12, y: 4),
                                            control: CGPoint(x: 6, y: 0)
                                        )
                                    }
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 12, height: 4)
                                }
                            }
                            .padding(.top, 2)
                        }
                    )
            }
            
            // Body with more sophisticated shading
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.modernOrange, Color.modernOrangeDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 35, height: 30)
                .shadow(color: Color.modernOrangeDark.opacity(0.3), radius: 3, x: 2, y: 2)
            
            // Legs with rounded caps and gradients
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.modernOrange, Color.modernOrangeDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: 18)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.modernOrange, Color.modernOrangeDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: 18)
                
                Spacer().frame(width: 10)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.modernOrange, Color.modernOrangeDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: 18)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.modernOrange, Color.modernOrangeDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: 18)
            }
            
            // Tail with dynamic animation
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color.modernOrange, Color.modernOrangeDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 4, height: 12)
                    .rotationEffect(.degrees(wellbeing > 0.5 ? (isAnimating ? 25 : 15) : -10))
                    .animation(
                        wellbeing > 0.5 
                        ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                        : .none,
                        value: isAnimating
                    )
            }
            .frame(width: 45)
        }
        .scaleEffect(wellbeing < 0.2 ? 0.9 : 1.0)
        .opacity(wellbeing < 0.1 ? 0.7 : 1.0)
        .animation(.bouncy(duration: 0.8), value: wellbeing)
        .onAppear {
            isAnimating = true
        }
        // Add floating animation for healthy pets
        .offset(y: wellbeing > 0.7 ? (isAnimating ? -2 : 0) : 0)
        .animation(
            wellbeing > 0.7 
            ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
            : .none,
            value: isAnimating
        )
    }
}

struct ModernStatBar: View {
    let label: String
    let value: Int
    let maxValue: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(icon)
                    .font(.retro16)
                
                Text(label)
                    .font(.retro14)
                    .foregroundColor(.gameText)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(value)/\(maxValue)")
                    .font(.retro12)
                    .foregroundColor(.gameTextSecondary)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gameSecondary.opacity(0.6))
                        .frame(height: 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gameAccent.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Progress fill with gradient
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(value) / CGFloat(maxValue), height: 12)
                        .animation(.easeInOut(duration: 0.8), value: value)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(color.opacity(0.8), lineWidth: 1)
                                .frame(width: geometry.size.width * CGFloat(value) / CGFloat(maxValue), height: 12)
                        )
                    
                    // Shine effect
                    if value > 0 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(value) / CGFloat(maxValue), height: 6)
                            .offset(y: -3)
                    }
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gameSecondary.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ModernCoinIcon: View {
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            // Outer ring with gradient
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.modernYellow, Color.modernOrange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 32, height: 32)
            
            // Inner circle with radial gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.modernYellow, Color.modernYellowDark],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: 12
                    )
                )
                .frame(width: 24, height: 24)
                .overlay(
                    // Dollar sign or coin symbol
                    Text("C")
                        .font(.retro12)
                        .fontWeight(.bold)
                        .foregroundColor(.gameBackground)
                )
                .shadow(color: Color.modernYellowDark.opacity(0.5), radius: 2, x: 1, y: 1)
            
            // Shine effect
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20, height: 20)
                .offset(x: -2, y: -2)
        }
        .rotationEffect(.degrees(isRotating ? 360 : 0))
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: false), value: isRotating)
        .onAppear {
            isRotating = true
        }
    }
}

struct StatBar: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .bold()
                Spacer()
                Text("\(value)/100")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value) / 100, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut, value: value)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Task View

struct TaskView: View {
    @Bindable var model: GameModel
    @Bindable var gameDataService: GameDataService
    @Bindable var verificationService: TaskVerificationService
    @Binding var showingPhotoVerification: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [Color.gameBackground, Color.gamePrimary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    if let task = model.currentTask {
                        VStack(spacing: 20) {
                            Text("Active Quest")
                                .font(.retro24)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.modernCyan, Color.modernBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.modernCyanDark, radius: 2, x: 1, y: 1)
                            
                            ModernTaskCard(task: task) {
                                handleTaskCompletion(task)
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            Text("No Active Quest")
                                .font(.retro24)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.modernRed, Color.modernOrange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.modernRedDark, radius: 2, x: 1, y: 1)
                            
                            VStack(spacing: 12) {
                                Text("Next assignment in:")
                                    .font(.retro16)
                                    .foregroundColor(.gameTextSecondary)
                                
                                Text(timeUntilNextTask())
                                    .font(.retro28)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.modernYellow, Color.modernOrange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.modernYellowDark, radius: 2, x: 1, y: 1)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 25)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gameSecondary.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.modernYellow.opacity(0.6), Color.modernOrange.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                            )
                        }
                    }
                    
                    if !model.completedTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Completed Today")
                                .font(.retro18)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.modernGreen, Color.modernCyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.modernGreenDark, radius: 1, x: 1, y: 1)
                            
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(model.completedTasks) { task in
                                        ModernCompletedTaskRow(task: task)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .navigationTitle("Quests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.gamePrimary.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private func handleTaskCompletion(_ task: HabitTask) {
        if task.verificationType == .photo {
            showingPhotoVerification = true
        } else if task.verificationType == .healthKit {
            Task {
                do {
                    // Dev mode: Skip HealthKit verification for testing
                    #if DEBUG
                    let isVerified = true // Always pass in debug mode
                    #else
                    let isVerified = try await verificationService.verifyTask(task)
                    #endif
                    
                    if isVerified {
                        model.completeTask()
                    } else {
                        // Show verification failed message
                        print("HealthKit verification failed")
                    }
                } catch {
                    print("Verification error: \(error)")
                    // In debug mode, still allow completion even with errors
                    #if DEBUG
                    model.completeTask()
                    #endif
                }
            }
        } else {
            model.completeTask()
        }
    }
    
    private func timeUntilNextTask() -> String {
        let nextTaskTime = model.lastTaskAssignment.addingTimeInterval(30) // 30 seconds for testing
        let timeRemaining = nextTaskTime.timeIntervalSinceNow
        
        if timeRemaining <= 0 {
            return "Ready!"
        }
        
        let seconds = Int(timeRemaining)
        if seconds < 60 {
            return "\(seconds)s"
        }
        
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes)m \(remainingSeconds)s"
    }
}

struct ModernTaskCard: View {
    let task: HabitTask
    let onComplete: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.retro18)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.modernYellow, Color.modernOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(task.description)
                        .font(.retro14)
                        .foregroundColor(.gameTextSecondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    ModernCoinIcon()
                        .scaleEffect(0.7)
                    
                    Text("+\(task.reward)")
                        .font(.retro12)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.modernGreen, Color.modernCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            
            // Task type indicator
            HStack {
                Text(getTaskTypeIcon())
                    .font(.title2)
                
                Text(getTaskTypeDescription())
                    .font(.retro12)
                    .foregroundColor(.gameTextSecondary)
                
                Spacer()
            }
            
            Button {
                onComplete()
            } label: {
                HStack {
                    Text("Complete Quest")
                        .font(.retro16)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.retro16)
                }
                .foregroundColor(isPressed ? Color.gameBackground : Color.gameText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: isPressed 
                                ? [Color.modernBlueDark, Color.modernBlue]
                                : [Color.modernBlue, Color.modernBlueDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.modernCyan.opacity(0.6), lineWidth: 2)
                        )
                        .shadow(color: Color.modernBlueDark.opacity(0.4), radius: isPressed ? 2 : 6, x: 0, y: isPressed ? 2 : 4)
                )
            }
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
                
                onComplete()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gameSecondary.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.modernBlue.opacity(0.6), Color.modernPurple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.gameBackground.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
    
    private func getTaskTypeIcon() -> String {
        switch task.type {
        case .water: return "💧"
        case .sleep: return "😴"
        case .steps: return "👟"
        case .jobApplication: return "💼"
        case .outside: return "🌳"
        case .leetcode: return "💻"
        case .shower: return "🚿"
        }
    }
    
    private func getTaskTypeDescription() -> String {
        switch task.verificationType {
        case .manual: return "Tap to complete"
        case .healthKit: return "Auto-verified with HealthKit"
        case .photo: return "Photo verification required"
        case .location: return "Location verification required"
        }
    }
}

struct ModernCompletedTaskRow: View {
    let task: HabitTask
    
    var body: some View {
        HStack(spacing: 15) {
            // Checkmark with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.modernGreen, Color.modernGreenDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                
                Image(systemName: "checkmark")
                    .font(.retro12)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.retro14)
                    .fontWeight(.medium)
                    .foregroundColor(.gameText)
                
                Text("Completed • +\(task.reward) credits")
                    .font(.retro12)
                    .foregroundColor(.gameTextSecondary)
            }
            
            Spacer()
            
            Text(getTaskTypeIcon())
                .font(.title3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gameSecondary.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.modernGreen.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func getTaskTypeIcon() -> String {
        switch task.type {
        case .water: return "💧"
        case .sleep: return "😴"
        case .steps: return "👟"
        case .jobApplication: return "💼"
        case .outside: return "🌳"
        case .leetcode: return "💻"
        case .shower: return "🚿"
        }
    }
}

// MARK: - Shop View

struct ShopView: View {
    @Bindable var model: GameModel
    @Bindable var gameDataService: GameDataService
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [Color.gameBackground, Color.gamePrimary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Modern credits display
                    HStack(spacing: 15) {
                        ModernCoinIcon()
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Credits")
                                .font(.retro16)
                                .foregroundColor(.gameTextSecondary)
                            
                            Text("\(model.coins)")
                                .font(.retro28)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.modernYellow, Color.modernOrange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.modernYellowDark, radius: 2, x: 1, y: 1)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gameSecondary.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.modernYellow.opacity(0.6), Color.modernOrange.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .padding(.horizontal)
                    
                    Text("Shop Items")
                        .font(.retro20)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.modernPurple, Color.modernBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.modernPurpleDark, radius: 1, x: 1, y: 1)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(model.shop.items) { item in
                                ModernShopItemCard(item: item, canAfford: model.coins >= item.price) {
                                    let success = model.purchaseItem(item)
                                    if success {
                                        // Add purchase feedback
                                        print("PURCHASED: \(item.name)")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.gamePrimary.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct ModernShopItemCard: View {
    let item: ShopItem
    let canAfford: Bool
    let onPurchase: () -> Void
    @State private var isPressed = false
    @State private var isPurchased = false
    
    var body: some View {
        let strokeGradient = canAfford
            ? LinearGradient(
                colors: [Color.modernBlue.opacity(0.6), Color.modernPurple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            : LinearGradient(
                colors: [Color.gameSecondary, Color.gameSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        
        VStack(spacing: 15) {
            iconArea
            infoArea
            buyButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gameSecondary.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(strokeGradient, lineWidth: 2)
                )
                .shadow(color: canAfford ? Color.modernBlue.opacity(0.2) : Color.clear, radius: 4, x: 0, y: 2)
        )
        .opacity(canAfford ? 1.0 : 0.7)
        .scaleEffect(canAfford ? 1.0 : 0.96)
        .animation(.easeInOut(duration: 0.3), value: canAfford)
    }
    
    private var iconArea: some View {
        let fillGradient = canAfford
            ? LinearGradient(
                colors: [Color.modernBlue.opacity(0.3), Color.modernPurple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            : LinearGradient(
                colors: [Color.gameSecondary.opacity(0.3), Color.gameSecondary.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        let ringStroke = canAfford ? Color.modernBlue.opacity(0.6) : Color.gameSecondary
        
        return ZStack {
            Circle()
                .fill(fillGradient)
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(ringStroke, lineWidth: 2)
                )
            
            Text(item.emoji)
                .font(.system(size: 32))
                .scaleEffect(canAfford ? 1.0 : 0.8)
        }
    }
    
    private var infoArea: some View {
        VStack(spacing: 8) {
            Text(item.name)
                .font(.retro14)
                .fontWeight(.semibold)
                .foregroundColor(canAfford ? .gameText : .gameTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(getItemEffect())
                .font(.retro12)
                .foregroundColor(.gameTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            HStack(spacing: 6) {
                ModernCoinIcon()
                    .scaleEffect(0.5)
                
                Text("\(item.price)")
                    .font(.retro14)
                    .fontWeight(.bold)
                    .foregroundColor(canAfford ? .modernYellow : .modernRed)
            }
        }
    }
    
    private var buyButton: some View {
        // Precompute a unified ShapeStyle using AnyShapeStyle to avoid ambiguity
        let disabledFill = AnyShapeStyle(Color.gameSecondary.opacity(0.5))
        let purchasedFill = AnyShapeStyle(Color.modernGreen)
        let normalFill = AnyShapeStyle(
            LinearGradient(
                colors: [Color.modernBlue, Color.modernBlueDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        let backgroundFill: AnyShapeStyle = !canAfford ? disabledFill : (isPurchased ? purchasedFill : normalFill)
        
        let borderColor = !canAfford ? Color.gameSecondary
            : isPurchased ? Color.modernGreenDark
            : Color.modernCyan.opacity(0.6)
        
        return Button {
            if canAfford && !isPurchased {
                withAnimation(.spring(response: 0.3)) {
                    isPurchased = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPurchased = false
                    onPurchase()
                }
            }
        } label: {
            HStack(spacing: 6) {
                if isPurchased {
                    Image(systemName: "checkmark")
                        .font(.retro12)
                    Text("Purchased!")
                        .font(.retro12)
                } else {
                    Text("Buy")
                        .font(.retro14)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(
                !canAfford ? .gameTextSecondary
                : isPurchased ? .white
                : .gameText
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
        }
        .disabled(!canAfford)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private func getItemEffect() -> String {
        switch item.type {
        case .food:
            return "+\(item.value) Food"
        case .healthPotion:
            return "+\(item.value) Health"
        case .toy:
            return "+\(item.value) Joy"
        }
    }
}

// MARK: - Stats View

struct StatsView: View {
    @Bindable var model: GameModel
    @Bindable var gameDataService: GameDataService
    @Binding var showingDevMode: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [Color.gameBackground, Color.gamePrimary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Daily Progress Card
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("📊")
                                .font(.title2)
                            
                            Text("Daily Progress")
                                .font(.retro20)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.modernCyan, Color.modernBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Quests Completed:")
                                    .font(.retro14)
                                    .foregroundColor(.gameTextSecondary)
                                Spacer()
                                Text("\(model.completedTasks.count)")
                                    .font(.retro16)
                                    .fontWeight(.bold)
                                    .foregroundColor(.modernGreen)
                            }
                            
                            HStack {
                                Text("Credits Earned Today:")
                                    .font(.retro14)
                                    .foregroundColor(.gameTextSecondary)
                                Spacer()
                                Text("\(model.completedTasks.reduce(0) { $0 + $1.reward })")
                                    .font(.retro16)
                                    .fontWeight(.bold)
                                    .foregroundColor(.modernYellow)
                            }
                            
                            HStack {
                                Text("Total Credits:")
                                    .font(.retro14)
                                    .foregroundColor(.gameTextSecondary)
                                Spacer()
                                Text("\(model.coins)")
                                    .font(.retro16)
                                    .fontWeight(.bold)
                                    .foregroundColor(.modernOrange)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gameSecondary.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.modernCyan.opacity(0.6), Color.modernBlue.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .padding(.horizontal)
                    
                    // Pet Status Card
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("🐕")
                                .font(.title2)
                            
                            Text("Pet Status")
                                .font(.retro20)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.modernOrange, Color.modernYellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 15) {
                            // Wellbeing indicator
                            HStack {
                                Text("Overall Wellbeing:")
                                    .font(.retro14)
                                    .foregroundColor(.gameTextSecondary)
                                Spacer()
                                Text("\(Int(model.dog.overallWellbeing * 100))%")
                                    .font(.retro18)
                                    .fontWeight(.bold)
                                    .foregroundColor(getWellbeingColor())
                            }
                            
                            // Individual stats
                            VStack(spacing: 10) {
                                StatProgressBar(
                                    icon: "❤️",
                                    label: "Health",
                                    value: model.dog.health,
                                    color: .modernRed
                                )
                                
                                StatProgressBar(
                                    icon: "😊",
                                    label: "Joy",
                                    value: model.dog.happiness,
                                    color: .modernYellow
                                )
                                
                                StatProgressBar(
                                    icon: "🍖",
                                    label: "Food",
                                    value: model.dog.hunger,
                                    color: .modernGreen
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gameSecondary.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.modernOrange.opacity(0.6), Color.modernYellow.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Hidden dev mode trigger
                    HStack {
                        Spacer()
                        Button("v2.0") {
                            showingDevMode = true
                        }
                        .font(.retro12)
                        .foregroundColor(.gameTextSecondary.opacity(0.5))
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.gamePrimary.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private func getWellbeingColor() -> Color {
        let wellbeing = model.dog.overallWellbeing
        if wellbeing > 0.8 { return .modernGreen }
        else if wellbeing > 0.6 { return .modernYellow }
        else if wellbeing > 0.4 { return .modernOrange }
        else { return .modernRed }
    }
}

struct StatProgressBar: View {
    let icon: String
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.retro16)
            
            Text(label)
                .font(.retro14)
                .foregroundColor(.gameText)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gameBackground.opacity(0.6))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(value) / 100, height: 8)
                        .animation(.easeInOut(duration: 0.8), value: value)
                }
            }
            .frame(height: 8)
            
            Text("\(value)")
                .font(.retro14)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Photo Capture View

import PhotosUI

struct PhotoCaptureView: View {
    let onPhotoCaptured: (UIImage) -> Void
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var analysisResult: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // 8-bit background
                LinearGradient(
                    colors: [Color.pixel8BitBlack, Color.pixel8BitDarkGray],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("📸 JOB VERIFICATION")
                        .font(.pixel16)
                        .foregroundColor(.pixel8BitCyan)
                        .tracking(2)
                    
                    Text("UPLOAD PROOF OF JOB APPLICATION SUBMISSION")
                        .font(.pixel10)
                        .foregroundStyle(Color.pixel8BitLightGray)
                        .multilineTextAlignment(.center)
                        .tracking(0.5)
                        .padding(.horizontal)
                    
                    if let image = capturedImage {
                        VStack(spacing: 15) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 250)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.pixel8BitCyan, lineWidth: 2)
                                )
                            
                            if isAnalyzing {
                                VStack(spacing: 8) {
                                    Text("ANALYZING...")
                                        .font(.pixel12)
                                        .foregroundColor(.pixel8BitYellow)
                                        .tracking(1)
                                    
                                    // Simple loading animation
                                    HStack(spacing: 4) {
                                        ForEach(0..<8) { index in
                                            Rectangle()
                                                .fill(Color.pixel8BitCyan)
                                                .frame(width: 8, height: 8)
                                                .opacity(Double((index + 1)) / 8.0)
                                        }
                                    }
                                }
                            } else if !analysisResult.isEmpty {
                                ScrollView {
                                    Text(analysisResult)
                                        .font(.pixel8)
                                        .foregroundColor(.pixel8BitLightGray)
                                        .tracking(0.5)
                                        .padding()
                                }
                                .frame(maxHeight: 100)
                                .background(
                                    Rectangle()
                                        .fill(Color.pixel8BitBlue.opacity(0.3))
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.pixel8BitCyan, lineWidth: 1)
                                        )
                                )
                            }
                            
                            Button("SUBMIT VERIFICATION") {
                                analyzeAndSubmit(image)
                            }
                            .font(.pixel12)
                            .foregroundColor(.pixel8BitBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.pixel8BitGreen)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.pixel8BitYellow, lineWidth: 2)
                            )
                            .disabled(isAnalyzing)
                        }
                    } else {
                        VStack(spacing: 15) {
                            PhotosPicker(
                                selection: $selectedPhoto,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                VStack(spacing: 8) {
                                    Text("📁")
                                        .font(.system(size: 40))
                                    
                                    Text("SELECT IMAGE")
                                        .font(.pixel12)
                                        .tracking(1)
                                }
                                .foregroundColor(.pixel8BitYellow)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.pixel8BitBlue.opacity(0.8))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.pixel8BitCyan, lineWidth: 3)
                                )
                            }
                            
                            Button("CANCEL") {
                                dismiss()
                            }
                            .font(.pixel12)
                            .foregroundColor(.pixel8BitRed)
                            .tracking(1)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("VERIFY.EXE")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.pixel8BitBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("EXIT") {
                        dismiss()
                    }
                    .font(.pixel10)
                    .foregroundColor(.pixel8BitRed)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                if let data = try? await newPhoto?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    capturedImage = image
                    analysisResult = ""
                }
            }
        }
    }
    
    private func analyzeAndSubmit(_ image: UIImage) {
        isAnalyzing = true
        
        Task {
            let photoService = PhotoVerificationService()
            let result = await photoService.getVerificationDetails(photo: image)
            
            await MainActor.run {
                isAnalyzing = false
                analysisResult = result.analysisDetails
                
                // Auto-submit if verification passes
                if result.isValid {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        onPhotoCaptured(image)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Developer Mode View

struct DevModeView: View {
    @Bindable var model: GameModel
    @Bindable var gameDataService: GameDataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempCoins: String = ""
    @State private var tempHealth: String = ""
    @State private var tempHappiness: String = ""
    @State private var tempHunger: String = ""
    @State private var dogName: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Warning Banner
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("⚠️")
                                .font(.title2)
                            Text("Developer Mode")
                                .font(.title2)
                                .bold()
                        }
                        
                        Text("This panel allows you to modify game values for testing purposes only.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Current Values
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Current Values")
                            .font(.headline)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🪙 Coins: \(model.coins)")
                            Text("❤️ Health: \(model.dog.health)/100")
                            Text("😊 Happiness: \(model.dog.happiness)/100")
                            Text("🍖 Hunger: \(model.dog.hunger)/100")
                            Text("🐕 Name: \(model.dog.name)")
                        }
                        .font(.subheadline)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Modification Controls
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Modify Values")
                            .font(.headline)
                            .bold()
                        
                        // Coins
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Coins")
                                .font(.subheadline)
                                .bold()
                            
                            HStack {
                                TextField("Enter coins amount", text: $tempCoins)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                
                                Button("Set") {
                                    setCoins()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            
                            HStack {
                                Button("+100") { adjustCoins(100) }
                                Button("+500") { adjustCoins(500) }
                                Button("+1000") { adjustCoins(1000) }
                                Button("Reset") { resetCoins() }
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        // Pet Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pet Name")
                                .font(.subheadline)
                                .bold()
                            
                            HStack {
                                TextField("Enter pet name", text: $dogName)
                                    .textFieldStyle(.roundedBorder)
                                
                                Button("Set") {
                                    setPetName()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        
                        // Pet Stats
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Pet Stats")
                                .font(.subheadline)
                                .bold()
                            
                            // Health
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Health: \(model.dog.health)")
                                    .font(.caption)
                                
                                HStack {
                                    Button("-10") { adjustHealth(-10) }
                                    Button("-5") { adjustHealth(-5) }
                                    Spacer()
                                    Button("+5") { adjustHealth(5) }
                                    Button("+10") { adjustHealth(10) }
                                    Button("Max") { setHealth(100) }
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            // Happiness
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Happiness: \(model.dog.happiness)")
                                    .font(.caption)
                                
                                HStack {
                                    Button("-10") { adjustHappiness(-10) }
                                    Button("-5") { adjustHappiness(-5) }
                                    Spacer()
                                    Button("+5") { adjustHappiness(5) }
                                    Button("+10") { adjustHappiness(10) }
                                    Button("Max") { setHappiness(100) }
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            // Hunger
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hunger: \(model.dog.hunger)")
                                    .font(.caption)
                                
                                HStack {
                                    Button("-10") { adjustHunger(-10) }
                                    Button("-5") { adjustHunger(-5) }
                                    Spacer()
                                    Button("+5") { adjustHunger(5) }
                                    Button("+10") { adjustHunger(10) }
                                    Button("Max") { setHunger(100) }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        
                        // Quick Actions
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Quick Actions")
                                .font(.headline)
                                .bold()
                            
                            VStack(spacing: 12) {
                                Button("🌟 Max All Stats") {
                                    maxAllStats()
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.borderedProminent)
                                
                                Button("💀 Critical State (Test Emergency)") {
                                    setCriticalState()
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.bordered)
                                .foregroundStyle(.red)
                                
                                Button("🔄 Reset to Default") {
                                    resetToDefault()
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.bordered)
                                
                                Button("🎯 Complete Current Task") {
                                    if model.currentTask != nil {
                                        model.completeTask()
                                        saveChanges()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.bordered)
                                .disabled(model.currentTask == nil)
                                
                                Button("📋 Assign New Random Task") {
                                    model.assignRandomTask()
                                    saveChanges()
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.bordered)
                                
                                Button("🏥 Test HealthKit Task") {
                                    // Create a HealthKit task for testing
                                    model.currentTask = HabitTask(
                                        type: .steps,
                                        title: "Test Steps",
                                        description: "Walk 5,000 steps (DEV MODE)",
                                        reward: 15,
                                        verificationType: .healthKit
                                    )
                                    saveChanges()
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.bordered)
                                .foregroundStyle(.blue)
                            }
                        }
                        
                        // Task History
                        if !model.completedTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Today's Completed Tasks")
                                    .font(.headline)
                                    .bold()
                                
                                Button("Clear All Completed Tasks") {
                                    model.completedTasks.removeAll()
                                    saveChanges()
                                }
                                .buttonStyle(.bordered)
                                .foregroundStyle(.red)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dev Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save All") {
                        saveChanges()
                    }
                    .bold()
                }
            }
        }
        .onAppear {
            loadCurrentValues()
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadCurrentValues() {
        tempCoins = String(model.coins)
        tempHealth = String(model.dog.health)
        tempHappiness = String(model.dog.happiness)
        tempHunger = String(model.dog.hunger)
        dogName = model.dog.name
    }
    
    private func setCoins() {
        if let coins = Int(tempCoins), coins >= 0 {
            model.coins = min(coins, 999999) // Cap at reasonable max
            saveChanges()
        }
    }
    
    private func adjustCoins(_ amount: Int) {
        model.coins = max(0, min(999999, model.coins + amount))
        tempCoins = String(model.coins)
        saveChanges()
    }
    
    private func resetCoins() {
        model.coins = 50
        tempCoins = "50"
        saveChanges()
    }
    
    private func setPetName() {
        if !dogName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            model.dog.name = dogName.trimmingCharacters(in: .whitespacesAndNewlines)
            saveChanges()
        }
    }
    
    private func adjustHealth(_ amount: Int) {
        model.dog.health = max(0, min(100, model.dog.health + amount))
        saveChanges()
    }
    
    private func setHealth(_ value: Int) {
        model.dog.health = max(0, min(100, value))
        saveChanges()
    }
    
    private func adjustHappiness(_ amount: Int) {
        model.dog.happiness = max(0, min(100, model.dog.happiness + amount))
        saveChanges()
    }
    
    private func setHappiness(_ value: Int) {
        model.dog.happiness = max(0, min(100, value))
        saveChanges()
    }
    
    private func adjustHunger(_ amount: Int) {
        model.dog.hunger = max(0, min(100, model.dog.hunger + amount))
        saveChanges()
    }
    
    private func setHunger(_ value: Int) {
        model.dog.hunger = max(0, min(100, value))
        saveChanges()
    }
    
    private func maxAllStats() {
        model.dog.health = 100
        model.dog.happiness = 100
        model.dog.hunger = 100
        model.coins = min(model.coins + 1000, 999999)
        saveChanges()
    }
    
    private func setCriticalState() {
        model.dog.health = 15
        model.dog.happiness = 10
        model.dog.hunger = 5
        saveChanges()
    }
    
    private func resetToDefault() {
        model.dog.health = 80
        model.dog.happiness = 70
        model.dog.hunger = 60
        model.dog.name = "Buddy"
        model.coins = 50
        dogName = "Buddy"
        saveChanges()
    }
    
    private func saveChanges() {
        gameDataService.updateDogStats(
            health: model.dog.health,
            happiness: model.dog.happiness,
            hunger: model.dog.hunger
        )
        gameDataService.updateCoins(model.coins)
        
        // Update widget data immediately
        if let gameData = gameDataService.getCurrentGameData() {
            UserDefaults().setWidgetData(gameData: gameData)
        }
    }
}

#Preview {
    ContentView()
}
