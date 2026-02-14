////
////  GameModelTests.swift
////  HackBeanpot2026Tests
////
////  Created by Rob Patterson on 2/13/26.
////
//
//import Testing
//@testable import HackBeanpot2026
//
//@Suite("Game Model Tests")
//struct GameModelTests {
//    
//    @Test("Dog stats should be within valid ranges")
//    func dogStatsValidation() async throws {
//        let dog = VirtualDog()
//        
//        #expect(dog.health >= 0 && dog.health <= 100, "Health should be between 0 and 100")
//        #expect(dog.happiness >= 0 && dog.happiness <= 100, "Happiness should be between 0 and 100")
//        #expect(dog.hunger >= 0 && dog.hunger <= 100, "Hunger should be between 0 and 100")
//        #expect(!dog.name.isEmpty, "Dog should have a name")
//    }
//    
//    @Test("Task completion should reward coins")
//    func taskCompletionRewardsCoins() async throws {
//        let model = GameModel()
//        let initialCoins = model.coins
//        let task = HabitTask.random()
//        let expectedReward = task.reward
//        
//        model.currentTask = task
//        model.completeTask()
//        
//        #expect(model.coins == initialCoins + expectedReward, "Coins should increase by task reward amount")
//        #expect(model.currentTask == nil, "Current task should be cleared after completion")
//        #expect(model.completedTasks.count == 1, "Completed tasks should include the finished task")
//    }
//    
//    @Test("Shop item purchase should affect pet stats")
//    func shopItemPurchaseAffectsStats() async throws {
//        let model = GameModel()
//        model.coins = 100 // Ensure enough coins
//        
//        let initialHealth = model.dog.health
//        let healthPotion = ShopItem(name: "Test Health Potion", type: .healthPotion, price: 20, value: 40, emoji: "🧪")
//        
//        let purchaseSuccessful = model.purchaseItem(healthPotion)
//        
//        #expect(purchaseSuccessful, "Purchase should be successful with sufficient coins")
//        #expect(model.dog.health > initialHealth, "Health should increase after using health potion")
//        #expect(model.coins == 80, "Coins should be reduced by item price")
//    }
//    
//    @Test("Insufficient coins should prevent purchase")
//    func insufficientCoinsPreventsPurchase() async throws {
//        let model = GameModel()
//        model.coins = 10 // Not enough for expensive item
//        
//        let expensiveItem = ShopItem(name: "Expensive Item", type: .toy, price: 50, value: 25, emoji: "💎")
//        let initialHappiness = model.dog.happiness
//        
//        let purchaseSuccessful = model.purchaseItem(expensiveItem)
//        
//        #expect(!purchaseSuccessful, "Purchase should fail with insufficient coins")
//        #expect(model.dog.happiness == initialHappiness, "Happiness should not change if purchase fails")
//        #expect(model.coins == 10, "Coins should remain unchanged if purchase fails")
//    }
//    
//    @Test("Dog wellbeing calculation")
//    func dogWellbeingCalculation() async throws {
//        var dog = VirtualDog()
//        dog.health = 90
//        dog.happiness = 80
//        dog.hunger = 70
//        
//        let expectedWellbeing = (90.0 + 80.0 + 70.0) / 300.0
//        
//        #expect(dog.overallWellbeing == expectedWellbeing, "Overall wellbeing should be calculated correctly")
//        #expect(dog.overallWellbeing >= 0.0 && dog.overallWellbeing <= 1.0, "Wellbeing should be normalized between 0 and 1")
//    }
//    
//    @Test("Random task generation should be valid")
//    func randomTaskGenerationIsValid() async throws {
//        let task = HabitTask.random()
//        
//        #expect(!task.title.isEmpty, "Task should have a title")
//        #expect(!task.description.isEmpty, "Task should have a description")
//        #expect(task.reward > 0, "Task should have a positive reward")
//        #expect(HabitType.allCases.contains(task.type), "Task type should be valid")
//    }
//}
//
//@Suite("Health Service Tests")
//struct HealthServiceTests {
//    
//    @Test("HealthKit availability check")
//    func healthKitAvailabilityCheck() async throws {
//        let healthService = HealthService()
//        
//        // This will return true on device, false on simulator typically
//        let isAvailable = healthService.isHealthKitAvailable
//        #expect(isAvailable == HKHealthStore.isHealthDataAvailable(), "HealthKit availability should match system availability")
//    }
//}
