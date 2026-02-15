import SwiftUI
import Combine

struct ObjectivesAndTasksView: View {
    @State var animalManager: AnimalManager
    @State private var selectedCompleted: CompletedTask? = nil
    
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    Image("task_list")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
                .scrollDisabled(false)
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Color.clear.frame(height: 160)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            if let objective = animalManager.objectivesManager.currentObjective {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Text(objectiveTitle(objective.type))
                                            .padding(.bottom, 8)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .font(.h2)
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
                                        Button("claim") {
                                            animalManager.objectivesManager.completeObjective()
                                            animalManager.objectivesManager.currentObjective = createNewObjective()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .font(.h3)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                Button("get today’s objective") {
                                    animalManager.objectivesManager.assignInitialObjective()
                                }
                                .font(.h3)
                                .padding()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 48)

                        // Completed Objectives
                        if !animalManager.objectivesManager.completedObjectives.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("completed objectives")
                                    .font(.h2)
                                
                                ForEach(Array(animalManager.objectivesManager.completedObjectives.enumerated()), id: \.offset) { _, completed in
                                    HStack {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.green)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(objectiveTitle(completed.type))
                                                .font(.h3)
                                            Text(completed.date, style: .date)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal, 48)
                        }
                        
                        Color.clear.frame(height: 12)
                        
                        // Active tasks
                        if !animalManager.taskManager.tasks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(animalManager.taskManager.tasks) { task in
                                    TaskView(task: task) {
                                        animalManager.taskManager.complete(task)
                                    }
                                }
                            }
                            .padding(.horizontal, 48)
                            .padding(.vertical, 24)
                        }
                        
                        // Completed tasks
                        if !animalManager.taskManager.completedTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(animalManager.taskManager.completedTasks) { completed in
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
                                    .padding(.horizontal, 20)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .onTapGesture {
                                        selectedCompleted = completed
                                    }
                                }
                            }
                        }
                    }
                    .overlay {
                        if animalManager.taskManager.tasks.isEmpty && animalManager.taskManager.completedTasks.isEmpty && animalManager.objectivesManager.currentObjective == nil {
                            ContentUnavailableView("no tasks right now",
                                                   systemImage: "sun.max",
                                                   description: Text("check back later — tasks and objectives appear throughout the day"))
                        }
                    }
                    .sheet(item: $selectedCompleted) { completed in
                        CompletedDetailView(completed: completed)
                    }
                }
            }
        }
    }
    
    // MARK: - Inline helpers
    
    private func objectiveIsComplete(_ objective: DailyObjective) -> Bool {
        objective.isComplete(using: animalManager.objectivesManager)
    }
    
    private func progressForObjective(_ objective: DailyObjective) -> (current: Double, total: Double) {
        switch objective.type {
        case .finishTwoTasksToday:
            let tasksDoneToday = animalManager.taskManager.completedTasks.filter {
                Calendar.current.isDateInToday($0.completedAt)
            }
            return (current: Double(tasksDoneToday.count), total: 2.0)
        case .feedPet:
            let didFeed = animalManager.purchaseHistory
                .filter { Calendar.current.isDateInToday($0.timestamp) }
                .contains { $0.item.category == .food }
            return (current: didFeed ? 1.0 : 0.0, total: 1.0)
        case .makePetHappy:
            let didMakeHappy = animalManager.purchaseHistory
                .filter { Calendar.current.isDateInToday($0.timestamp) }
                .contains { $0.item.category == .accessories || $0.item.category == .backgrounds }
            return (current: didMakeHappy ? 1.0 : 0.0, total: 1.0)
        }
    }
}

// MARK: - Free helpers

private func objectiveTitle(_ type: DailyObjectiveType) -> String {
    switch type {
    case .finishTwoTasksToday: return "finish two tasks today"
    case .feedPet:             return "feed your pet today"
    case .makePetHappy:        return "make your pet happy today"
    }
}

private func createNewObjective() -> DailyObjective {
    let allTypes: [DailyObjectiveType] = [.finishTwoTasksToday, .feedPet, .makePetHappy]
    let randomType = allTypes.randomElement() ?? .finishTwoTasksToday
    return DailyObjective(type: randomType, date: Date())
}
