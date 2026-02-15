//
//  DailyObjectives.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import Foundation
import Combine

enum DailyObjectiveType: Codable {
    case finishTwoTasksToday
    case feedPet
    case makePetHappy
}

struct DailyObjective: Codable {
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
        for purchase in manager.purchaseHistory.filter({ Calendar.current.isDateInToday($0.timestamp) }) {
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

@Observable
final class DailyObjectiveManager {
    weak var animalManager: AnimalManager?
    
    var currentObjective: DailyObjective?
    var completedObjectives: [DailyObjective] = []
    
    func assignNewObjective() {
        if let objective = currentObjective, Calendar.current.isDateInYesterday(objective.date) {
            completedObjectives.append(objective)
            currentObjective = createNewObjective()
            animalManager?.save()
        }
    }
    
    func completeObjective() {
        if let objective = currentObjective {
            completedObjectives.append(objective)
            animalManager?.save()
        }
        
        currentObjective = nil
    }
    
    func assignInitialObjective() {
        currentObjective = createNewObjective()
        // Only save if we have a connected animalManager (avoid saving during init)
        if animalManager != nil {
            animalManager?.save()
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
    
    func resetObjectives() {
        currentObjective = nil
        completedObjectives = []
        assignInitialObjective()
        animalManager?.save()
    }
}
