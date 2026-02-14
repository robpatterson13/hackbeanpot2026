//
//  DailyObjectives.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import Foundation
import Combine

enum DailyObjectiveType {
    case finishTwoTasksToday
    case feedPet
    case makePetHappy
}

struct DailyObjective {
    private(set) var type: DailyObjectiveType
    var date: Date
    
    func isComplete(using manager: DailyObjectiveManager) -> Bool {
        guard let animalManager = manager.animalManager else {
            // If the animal manager isn't wired yet, treat as not complete
            return false
        }
        switch type {
        case .finishTwoTasksToday:
            return finishTwoTasksTodayIsComplete(animalManager)
        case .feedPet:
            return feedPetIsComplete(animalManager)
        case .makePetHappy:
            return makePetHappyIsComplete(animalManager)
        }
    }
    
    private func finishTwoTasksTodayIsComplete(_ manager: AnimalManager) -> Bool {
        let taskManager = manager.taskManager
        let tasksDoneToday = taskManager.completedTasks.filter { Calendar.current.isDateInToday($0.completedAt) }
        return tasksDoneToday.count >= 2
    }
    
    private func feedPetIsComplete(_ manager: AnimalManager) -> Bool {
        for purchase in manager.purchaseHistory.filter({ Calendar.current.isDateInToday($0.purchaseDate) }) {
            if purchase.item.category == .food {
                return true
            }
        }
        return false
    }
    
    private func makePetHappyIsComplete(_ manager: AnimalManager) -> Bool {
        for purchase in manager.purchaseHistory.filter({ Calendar.current.isDateInToday($0.timestamp) }) {
            if purchase.item.category == .accessories || purchase.item.category == .backgrounds {
                return true
            }
        }
        return false
    }
}

@MainActor
final class DailyObjectiveManager: ObservableObject {
    weak var animalManager: AnimalManager?
    
    @Published var currentObjective: DailyObjective?
    @Published var completedObjectives: [DailyObjective] = []
    
    func assignNewObjective() {
        if let objective = currentObjective, Calendar.current.isDateInYesterday(objective.date) {
            completedObjectives.append(objective)
            currentObjective = createNewObjective()
        }
    }
    
    func completeObjective() {
        if let objective = currentObjective {
            completedObjectives.append(objective)
        }
    }
    
    private func createNewObjective() -> DailyObjective {
        let allTypes: [DailyObjectiveType] = [
            .finishTwoTasksToday,
            .feedPet,
            .makePetHappy
        ]
        
        let randomType = allTypes.randomElement() ?? .finishTwoTasksToday
        
        return DailyObjective(
            type: randomType,
            date: Date()
        )
    }
}
