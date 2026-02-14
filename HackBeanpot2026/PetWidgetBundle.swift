//
//  PetWidgetBundle.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import WidgetKit
import SwiftUI

struct PetWidgetBundle: WidgetBundle {
    var body: some Widget {
        PetStatusWidget()
        TaskReminderWidget()
    }
}

struct PetStatusWidget: Widget {
    let kind: String = "PetStatusWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetStatusProvider()) { entry in
            PetStatusWidgetView(entry: entry)
        }
        .configurationDisplayName("🕹️ Pet Status")
        .description("Keep track of your 8-bit virtual pet's wellbeing")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TaskReminderWidget: Widget {
    let kind: String = "TaskReminderWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskReminderProvider()) { entry in
            TaskReminderWidgetView(entry: entry)
        }
        .configurationDisplayName("🎮 Current Quest")
        .description("View your current habit quest")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Pet Status Widget

struct PetStatusEntry: TimelineEntry {
    let date: Date
    let dogName: String
    let health: Int
    let happiness: Int
    let hunger: Int
    let coins: Int
}

struct PetStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> PetStatusEntry {
        PetStatusEntry(date: Date(), dogName: "BUDDY", health: 80, happiness: 70, hunger: 60, coins: 50)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PetStatusEntry) -> ()) {
        // Load from UserDefaults with 8-bit styling
        let dogName = UserDefaults.group.getWidgetDogName().uppercased()
        let health = UserDefaults.group.getWidgetHealth()
        let happiness = UserDefaults.group.getWidgetHappiness()
        let hunger = UserDefaults.group.getWidgetHunger()
        let coins = UserDefaults.group.getWidgetCoins()
        
        let entry = PetStatusEntry(
            date: Date(),
            dogName: dogName,
            health: health > 0 ? health : 80,
            happiness: happiness > 0 ? happiness : 70,
            hunger: hunger > 0 ? hunger : 60,
            coins: coins
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let dogName = UserDefaults.group.getWidgetDogName().uppercased()
        let health = UserDefaults.group.getWidgetHealth()
        let happiness = UserDefaults.group.getWidgetHappiness()
        let hunger = UserDefaults.group.getWidgetHunger()
        let coins = UserDefaults.group.getWidgetCoins()
        
        let entry = PetStatusEntry(
            date: Date(),
            dogName: dogName,
            health: health > 0 ? health : 80,
            happiness: happiness > 0 ? happiness : 70,
            hunger: hunger > 0 ? hunger : 60,
            coins: coins
        )
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct PetStatusWidgetView: View {
    var entry: PetStatusProvider.Entry
    
    var body: some View {
        ZStack {
            // 8-bit background pattern
            LinearGradient(
                colors: [Color.pixel8BitDarkGray, Color.pixel8BitLightGray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Pixelated border effect
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.pixel8BitBlue, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.black.opacity(0.8))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                // Header with pet name
                HStack {
                    Text(entry.dogName)
                        .font(.pixel12)
                        .foregroundColor(.pixel8BitYellow)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    // Pixel dog sprite
                    PixelDogSprite(wellbeing: Double(entry.health + entry.happiness + entry.hunger) / 300.0)
                }
                
                // 8-bit stat bars
                VStack(spacing: 3) {
                    Pixel8BitStatBar(
                        label: "HP",
                        value: entry.health,
                        color: .pixel8BitRed,
                        maxValue: 100
                    )
                    
                    Pixel8BitStatBar(
                        label: "JOY", 
                        value: entry.happiness,
                        color: .pixel8BitYellow,
                        maxValue: 100
                    )
                    
                    Pixel8BitStatBar(
                        label: "FOOD",
                        value: entry.hunger,
                        color: .pixel8BitGreen,
                        maxValue: 100
                    )
                }
                
                // Coins with pixel styling
                HStack {
                    Text("COINS:")
                        .font(.pixel8)
                        .foregroundColor(.pixel8BitCyan)
                    
                    Text("\(entry.coins)")
                        .font(.pixel10)
                        .foregroundColor(.pixel8BitYellow)
                    
                    Spacer()
                }
            }
            .padding(8)
        }
    }
}

struct Pixel8BitStatBar: View {
    let label: String
    let value: Int
    let color: Color
    let maxValue: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.pixel8)
                .foregroundColor(.pixel8BitCyan)
                .frame(width: 30, alignment: .leading)
            
            // Pixelated progress bar
            HStack(spacing: 1) {
                ForEach(0..<10, id: \.self) { index in
                    let segmentValue = (index + 1) * (maxValue / 10)
                    Rectangle()
                        .fill(value >= segmentValue ? color : Color.pixel8BitDarkGray)
                        .frame(width: 6, height: 6)
                }
            }
            
            Text("\(value)")
                .font(.pixel8)
                .foregroundColor(.white)
                .frame(width: 20, alignment: .trailing)
        }
    }
}

struct PixelDogSprite: View {
    let wellbeing: Double
    
    var body: some View {
        ZStack {
            // Create pixelated dog using rectangles
            VStack(spacing: 0) {
                // Dog ears
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.pixel8BitOrange)
                        .frame(width: 4, height: 4)
                    
                    Spacer()
                        .frame(width: 8)
                    
                    Rectangle()
                        .fill(Color.pixel8BitOrange)
                        .frame(width: 4, height: 4)
                }
                
                // Dog head
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.pixel8BitOrange)
                        .frame(width: 16, height: 8)
                    
                    // Eyes and nose
                    HStack(spacing: 2) {
                        Rectangle()
                            .fill(wellbeing > 0.5 ? Color.black : Color.pixel8BitRed)
                            .frame(width: 2, height: 2)
                        
                        Spacer()
                            .frame(width: 4)
                        
                        Rectangle()
                            .fill(wellbeing > 0.5 ? Color.black : Color.pixel8BitRed)
                            .frame(width: 2, height: 2)
                    }
                    
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 2, height: 2)
                }
            }
        }
        .scaleEffect(wellbeing < 0.3 ? 0.8 : 1.0)
        .animation(.easeInOut(duration: 0.5), value: wellbeing)
    }
}

// MARK: - Task Reminder Widget

struct TaskReminderEntry: TimelineEntry {
    let date: Date
    let currentTask: String?
    let taskDescription: String?
    let reward: Int?
    let timeUntilNext: String?
}

struct TaskReminderProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskReminderEntry {
        TaskReminderEntry(
            date: Date(),
            currentTask: "DRINK H2O",
            taskDescription: "Consume 16 oz of water",
            reward: 10,
            timeUntilNext: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TaskReminderEntry) -> ()) {
        let task = UserDefaults.group.getWidgetCurrentTask()?.uppercased()
        let description = UserDefaults.group.getWidgetCurrentTaskDescription()
        let reward = UserDefaults.group.getWidgetCurrentTaskReward()
        
        let entry = TaskReminderEntry(
            date: Date(),
            currentTask: task,
            taskDescription: description,
            reward: reward > 0 ? reward : nil,
            timeUntilNext: nil
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let task = UserDefaults.group.getWidgetCurrentTask()?.uppercased()
        let description = UserDefaults.group.getWidgetCurrentTaskDescription()
        let reward = UserDefaults.group.getWidgetCurrentTaskReward()
        
        let entry = TaskReminderEntry(
            date: Date(),
            currentTask: task,
            taskDescription: description,
            reward: reward > 0 ? reward : nil,
            timeUntilNext: nil
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct TaskReminderWidgetView: View {
    var entry: TaskReminderProvider.Entry
    
    var body: some View {
        ZStack {
            // 8-bit quest background
            LinearGradient(
                colors: [Color.pixel8BitPurple.opacity(0.8), Color.pixel8BitBlue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Pixelated border
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.pixel8BitCyan, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.black.opacity(0.9))
                )
            
            VStack(alignment: .leading, spacing: 8) {
                if let task = entry.currentTask {
                    // Quest header
                    HStack {
                        Text("QUEST")
                            .font(.pixel10)
                            .foregroundColor(.pixel8BitCyan)
                            .textCase(.uppercase)
                        
                        Spacer()
                        
                        // Quest icon
                        PixelQuestIcon()
                    }
                    
                    // Task name with typing effect styling
                    Text("> \(task)")
                        .font(.pixel12)
                        .foregroundColor(.pixel8BitYellow)
                        .lineLimit(2)
                    
                    if let description = entry.taskDescription {
                        Text(description.uppercased())
                            .font(.pixel8)
                            .foregroundColor(.pixel8BitLightGray)
                            .lineLimit(3)
                    }
                    
                    if let reward = entry.reward {
                        HStack {
                            Text("REWARD:")
                                .font(.pixel8)
                                .foregroundColor(.pixel8BitGreen)
                            
                            Text("\(reward) COINS")
                                .font(.pixel8)
                                .foregroundColor(.pixel8BitYellow)
                        }
                    }
                    
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NO ACTIVE QUEST")
                            .font(.pixel12)
                            .foregroundColor(.pixel8BitRed)
                        
                        Text("AWAITING ORDERS...")
                            .font(.pixel8)
                            .foregroundColor(.pixel8BitLightGray)
                        
                        if let timeUntilNext = entry.timeUntilNext {
                            Text("NEXT: \(timeUntilNext)")
                                .font(.pixel8)
                                .foregroundColor(.pixel8BitCyan)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(8)
        }
    }
}

struct PixelQuestIcon: View {
    var body: some View {
        VStack(spacing: 0) {
            // Pixel sword/quest icon
            Rectangle()
                .fill(Color.pixel8BitYellow)
                .frame(width: 2, height: 8)
            
            Rectangle()
                .fill(Color.pixel8BitOrange)
                .frame(width: 6, height: 2)
            
            Rectangle()
                .fill(Color.pixel8BitOrange)
                .frame(width: 2, height: 4)
        }
    }
}
