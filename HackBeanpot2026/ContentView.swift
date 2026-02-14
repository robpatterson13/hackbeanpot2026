//
//  ContentViewModel.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import Foundation
import SwiftUI
import UIKit

// Helper to choose a hunger icon with fallbacks across OS versions.
private func hungerSymbolName() -> String {
    if UIImage(systemName: "bone.fill") != nil {
        return "bone.fill"
    } else if UIImage(systemName: "drumstick.fill") != nil {
        return "drumstick.fill"
    } else {
        return "fork.knife"
    }
}

struct ContentView: View {

    @StateObject private var store = TaskStore()

    // DEBUG: Toggle this to show one row for every habit type regardless of TaskStore generation.
    // You can comment this out or set to false to return to normal behavior.
    @State private var showAllTaskTypes = false

    @State private var selectedCompleted: CompletedTask? = nil
    @State private var showCompletedDetail = false

    // Active items to show: either the real store.tasks or a debug list of all habits.
    private var activeTasksToDisplay: [HabitTask] {
        if showAllTaskTypes {
            return HabitTask.allTasks
        } else {
            return store.tasks
        }
    }

    var body: some View {
        NavigationView {
            List {
                // Active tasks
                if !activeTasksToDisplay.isEmpty {
                    Section("Active") {
                        ForEach(activeTasksToDisplay) { task in
                            // When showAllTaskTypes is on, these rows won’t be in the store, so completion won’t remove them.
                            // That’s fine for visual testing. Turn off the toggle to return to real behavior.
                            TaskView(task: task) {
                                // completion handler from TaskView (only meaningful when using store.tasks)
                                if !showAllTaskTypes {
                                    store.complete(task)
                                }
                            }
                        }
                    }
                }

                // Completed tasks at the bottom
                if !store.completedTasks.isEmpty {
                    Section("Completed") {
                        ForEach(store.completedTasks) { completed in
                            HStack(spacing: 16) {
                                Image(systemName: completed.habit.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.secondary)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(completed.habit.displayName)
                                        .font(.body)
                                    Text(completed.completedAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedCompleted = completed
                                showCompletedDetail = true
                            }
                        }
                    }
                }
            }
            .toolbar {
                // Simple debug toggle you can comment out.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $showAllTaskTypes) {
                        Text("Show All")
                    }
                    .toggleStyle(.switch)
                }
            }
            .navigationTitle("Tasks")
            .overlay {
                // Overlays:
                // 1) No tasks and no completed -> original empty state
                // 2) No active tasks but there are completed -> “Completed all active tasks.”
                if activeTasksToDisplay.isEmpty && store.completedTasks.isEmpty {
                    ContentUnavailableView("No Tasks Right Now",
                                           systemImage: "sun.max",
                                           description: Text("Check back later — tasks appear throughout the day."))
                } else if activeTasksToDisplay.isEmpty && !store.completedTasks.isEmpty {
                    ContentUnavailableView("Completed all active tasks",
                                           systemImage: "checkmark.seal",
                                           description: Text("Great job! New tasks will appear when their time windows open."))
                }
            }
            .sheet(isPresented: $showCompletedDetail) {
                if let completed = selectedCompleted {
                    CompletedDetailView(completed: completed)
                }
            }
        }
    }
}

struct CompletedDetailView: View {
    let completed: CompletedTask
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: completed.habit.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .foregroundColor(.accentColor)
                
                Text(completed.habit.displayName)
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Completed on")
                        Spacer()
                        Text(completed.completedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                    .font(.body)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Rewards breakdown for completed task
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rewards")
                        .font(.headline)
                    HStack {
                        Image(systemName: "heart.fill").foregroundColor(.red)
                        Text("Health +\(completed.habit.healthIncrease)")
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "face.smiling").foregroundColor(.orange)
                        Text("Happiness +\(completed.habit.happinessIncrease)")
                        Spacer()
                    }
                    HStack {
                        Image(systemName: hungerSymbolName()).foregroundColor(.blue)
                        Text("Hunger +\(completed.habit.hungerIncrease)")
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding()
            .navigationTitle("Completed Task")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

class ContentViewModel {
    var property: String
    
    init() {
        self.property = "Start"
    }
}

// Shared animation manager to persist timer across tab changes
@Observable
class AnimationManager {
    static let shared = AnimationManager()
    
    private var timer: Timer?
    var showState1: Bool = true
    
    private init() {
        startTimer()
    }
    
    private func startTimer() {
        // Only start timer if it's not already running
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            self.showState1.toggle()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
}

@Observable
class TestViewModel {
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
}

struct TestView: View {
    @State private var testViewModel: TestViewModel = .init(animalManager: animalManager)
    @State private var yOffset: CGFloat = 0
    @State private var animationManager = AnimationManager.shared
    @State private var isBlob: Bool = true
    
    var body: some View {
        ZStack {
            Image("forest")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    Image(animationManager.showState1 ? testViewModel.getAnimalImages().0 : testViewModel.getAnimalImages().1)
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
                }
            }
        }
    }
}
