import SwiftUI

struct ObjectivesAndTasksView: View {
    @StateObject private var store = TaskStore()
    @StateObject private var dailyObjectives = DailyObjectiveManager()
    
    @State private var selectedCompleted: CompletedTask? = nil
    @State private var showCompletedDetail = false
    @State private var showAllTaskTypes = false // optional debug toggle like in ContentView
    
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
                // Daily Objective section
                if let objective = dailyObjectives.currentObjective {
                    Section("Daily Objective") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(objectiveTitle(objective.type))
                                .font(.headline)
                            
                            HStack {
                                let progress = objectiveProgress(objective)
                                ProgressView(value: progress.current, total: progress.total)
                                    .progressViewStyle(.linear)
                                Text("\(Int(progress.current))/\(Int(progress.total))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                Button("Check Progress") {
                                    // Re-render; computation is derived from state
                                    _ = objective.isComplete(using: dailyObjectives)
                                }
                                .buttonStyle(.bordered)
                                
                                if objective.isComplete(using: dailyObjectives) {
                                    Button("Claim") {
                                        dailyObjectives.completeObjective()
                                        // Assign a new objective for the day
                                        dailyObjectives.currentObjective = createNewObjective()
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    // If no current objective, offer to create one
                    Section("Daily Objective") {
                        Button("Get Today’s Objective") {
                            dailyObjectives.currentObjective = createNewObjective()
                        }
                    }
                }
                
                // Active tasks
                if !activeTasksToDisplay.isEmpty {
                    Section("Active Tasks") {
                        ForEach(activeTasksToDisplay) { task in
                            TaskView(task: task) {
                                if !showAllTaskTypes {
                                    store.complete(task)
                                }
                            }
                        }
                    }
                }
                
                // Completed tasks at the bottom
                if !store.completedTasks.isEmpty {
                    Section("Completed Tasks") {
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
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $showAllTaskTypes) {
                        Text("Show All")
                    }
                    .toggleStyle(.switch)
                }
            }
            .overlay {
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
        .onAppear {
            // Wire managers
            store.animalManager = animalManager
            dailyObjectives.animalManager = animalManager
            // Ensure we have a current objective
            if dailyObjectives.currentObjective == nil {
                dailyObjectives.currentObjective = createNewObjective()
            }
        }
    }
}

// MARK: - Helpers

private func objectiveTitle(_ type: DailyObjectiveType) -> String {
    switch type {
    case .finishTwoTasksToday: return "Finish two tasks today"
    case .feedPet:             return "Feed your pet today"
    case .makePetHappy:        return "Make your pet happy today"
    }
}

private func objectiveProgress(_ objective: DailyObjective) -> (current: Double, total: Double) {
    // Mirrors DailyObjective’s checks, but returns a progress pair
    switch objective.type {
    case .finishTwoTasksToday:
        let taskManager = animalManager.taskManager
        let tasksDoneToday = taskManager.completedTasks.filter { Calendar.current.isDateInToday($0.completedAt) }
        return (current: Double(tasksDoneToday.count), total: 2.0)
    case .feedPet:
        let didFeed = animalManager.purchaseHistory
            .filter { Calendar.current.isDateInToday($0.purchaseDate) }
            .contains { $0.item.category == .food }
        return (current: didFeed ? 1.0 : 0.0, total: 1.0)
    case .makePetHappy:
        let didMakeHappy = animalManager.purchaseHistory
            .filter { Calendar.current.isDateInToday($0.purchaseDate) }
            .contains { $0.item.category == .accessories || $0.item.category == .backgrounds }
        return (current: didMakeHappy ? 1.0 : 0.0, total: 1.0)
    }
}

private func createNewObjective() -> DailyObjective {
    let allTypes: [DailyObjectiveType] = [.finishTwoTasksToday, .feedPet, .makePetHappy]
    let randomType = allTypes.randomElement() ?? .finishTwoTasksToday
    return DailyObjective(type: randomType, date: Date())
}
