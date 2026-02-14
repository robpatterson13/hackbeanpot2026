//
//  HackBeanpot2026App.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct HackBeanpot2026App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameData.self,
            CompletedTask.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .onAppear {
                    Task {
                        await setupApp()
                    }
                }
        }
    }
    
    private func setupApp() async {
        // Request permissions
        let notificationService = NotificationService()
        let healthService = HealthService()
        
        do {
            try await notificationService.requestPermission()
            try await notificationService.scheduleTaskReminder()
            try await notificationService.scheduleMotivationalReminders()
        } catch {
            print("Failed to setup notifications: \(error)")
        }
        
        do {
            try await healthService.requestHealthKitPermission()
        } catch {
            print("Failed to setup HealthKit: \(error)")
        }
        
        healthService.requestLocationPermission()
    }
}