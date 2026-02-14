//
//  DailyObjectives.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

<<<<<<< Updated upstream
import Foundation

=======
>>>>>>> Stashed changes
enum DailyObjective {
    case finishTwoTasksToday
    case feedPet
    case makePetHappy
    
    func isComplete(using manager: DailyObjectiveManager) -> Bool {
        let animalManager = manager.animalManager!
        switch self {
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
<<<<<<< Updated upstream
        let tasksDoneToday = taskManager.completedTasks.filter { Calendar.current.isDateInToday($0.completedAt) }
        return tasksDoneToday.count >= 2
=======
        
>>>>>>> Stashed changes
    }
    
    private func feedPetIsComplete(_ manager: AnimalManager) -> Bool {
        
    }
    
    private func makePetHappyIsComplete(_ manager: AnimalManager) -> Bool {
        
    }
}

final class DailyObjectiveManager {
    weak var animalManager: AnimalManager?
    var currentObjective: DailyObjective?
    var completedObjectives: [DailyObjective] = []
    
    func assignNewObjective() {
        
    }
    
    func completeObjective() {
        
    }
}
