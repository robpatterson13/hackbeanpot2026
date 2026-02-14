import SwiftUI
import Combine

struct ObjectivesAndTasksView: View {
    @StateObject private var manager = TaskManager()
    @StateObject private var dailyObjectives = DailyObjectiveManager()
    
    @State private var selectedCompleted: CompletedTask? = nil
    @State private var showAllTaskTypes = false // optional debug toggle
    
    private var activeTasksToDisplay: [HabitTask] {
        if showAllTaskTypes {
            return HabitTask.allTasks
        } else {
            return manager.tasks
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // Daily Objective
                Section("Daily Objective") {
                    if let objective = dailyObjectives.currentObjective {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Text(objectiveTitle(objective.type))
                                    .font(.headline)
                                if objectiveIsComplete(objective) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            HStack {
                                let progress = progressForObjective(objective)
                                ProgressView(value: progress.current, total: progress.total)
                                    .progressViewStyle(.linear)
                                Text("\(Int(progress.current))/\(Int(progress.total))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if objectiveIsComplete(objective) {
                                Button("Claim") {
                                    dailyObjectives.completeObjective()
                                    dailyObjectives.currentObjective = createNewObjective()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Button("Get Today’s Objective") {
                            dailyObjectives.currentObjective = createNewObjective()
                        }
                    }
                }
                
                // Completed Objectives
                if !dailyObjectives.completedObjectives.isEmpty {
                    Section("Completed Objectives") {
                        ForEach(Array(dailyObjectives.completedObjectives.enumerated()), id: \.offset) { _, completed in
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(objectiveTitle(completed.type))
                                        .font(.body)
                                    Text(completed.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // Active tasks
                if !activeTasksToDisplay.isEmpty {
                    Section("Active Tasks") {
                        ForEach(activeTasksToDisplay) { task in
                            TaskView(task: task) {
                                if !showAllTaskTypes {
                                    manager.complete(task)
                                }
                            }
                        }
                    }
                }
                
                // Completed tasks
                if !manager.completedTasks.isEmpty {
                    Section("Completed Tasks") {
                        ForEach(manager.completedTasks) { completed in
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
                if activeTasksToDisplay.isEmpty && manager.completedTasks.isEmpty && dailyObjectives.currentObjective == nil {
                    ContentUnavailableView("No Tasks Right Now",
                                           systemImage: "sun.max",
                                           description: Text("Check back later — tasks and objectives appear throughout the day."))
                } else if activeTasksToDisplay.isEmpty && !manager.completedTasks.isEmpty {
                    ContentUnavailableView("Completed all active tasks",
                                           systemImage: "checkmark.seal",
                                           description: Text("Great job! New tasks will appear when their time windows open."))
                }
            }
            .sheet(item: $selectedCompleted) { completed in
                CompletedDetailView(completed: completed)
            }
        }
        .onAppear {
            // Wire managers
            manager.animalManager = animalManager
            dailyObjectives.animalManager = animalManager
            
            // Ensure we have a current objective for today
            if dailyObjectives.currentObjective == nil {
                dailyObjectives.currentObjective = createNewObjective()
            } else {
                dailyObjectives.assignNewObjective()
            }
        }
    }
    
    // MARK: - Inline helpers
    
    private func objectiveIsComplete(_ objective: DailyObjective) -> Bool {
        objective.isComplete(using: dailyObjectives)
    }
    
    private func progressForObjective(_ objective: DailyObjective) -> (current: Double, total: Double) {
        switch objective.type {
        case .finishTwoTasksToday:
            let tasksDoneToday = manager.completedTasks.filter {
                Calendar.current.isDateInToday($0.completedAt)
            }
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
}

// MARK: - Free helpers

private func objectiveTitle(_ type: DailyObjectiveType) -> String {
    switch type {
    case .finishTwoTasksToday: return "Finish two tasks today"
    case .feedPet:             return "Feed your pet today"
    case .makePetHappy:        return "Make your pet happy today"
    }
}

private func createNewObjective() -> DailyObjective {
    let allTypes: [DailyObjectiveType] = [.finishTwoTasksToday, .feedPet, .makePetHappy]
    let randomType = allTypes.randomElement() ?? .finishTwoTasksToday
    return DailyObjective(type: randomType, date: Date())
}
