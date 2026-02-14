//
//  NotificationService.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import UserNotifications
import SwiftUI

@Observable
class NotificationService {
    private let center = UNUserNotificationCenter.current()
    
    func requestPermission() async throws {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
        try await center.requestAuthorization(options: options)
    }
    
    func scheduleTaskReminder() async throws {
        let content = UNMutableNotificationContent()
        content.title = "🐕 Your Pet Needs You!"
        content.body = "Buddy is waiting for you to complete your habit task. Don't let him down!"
        content.sound = .default
        content.badge = 1
        
        // Add custom actions
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Complete Task",
            options: .foreground
        )
        
        let viewPetAction = UNNotificationAction(
            identifier: "VIEW_PET",
            title: "Check on Pet",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, viewPetAction],
            intentIdentifiers: []
        )
        
        center.setNotificationCategories([category])
        content.categoryIdentifier = "TASK_REMINDER"
        
        // Schedule for every 3 hours
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10800, repeats: true)
        let request = UNNotificationRequest(identifier: "task-reminder", content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    func schedulePetCareReminder(dogName: String, health: Int, happiness: Int, hunger: Int) async throws {
        var needsAttention: [String] = []
        
        if health < 30 {
            needsAttention.append("health is low")
        }
        if happiness < 30 {
            needsAttention.append("happiness is low")
        }
        if hunger < 30 {
            needsAttention.append("hunger is low")
        }
        
        guard !needsAttention.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🚨 \(dogName) Needs Immediate Care!"
        content.body = "\(dogName)'s \(needsAttention.joined(separator: " and ")). Visit the shop to help!"
        content.sound = .defaultCritical
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "pet-emergency-\(UUID().uuidString)", content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    func scheduleMotivationalReminders() async throws {
        let motivationalMessages = [
            "Your coding skills and \(["Buddy", "Rex", "Luna"].randomElement()!) both need daily practice! 💪",
            "Real developers drink water and take care of virtual pets 💧🐕",
            "LeetCode problems won't solve themselves, and neither will your pet's needs! 🧠",
            "Job applications today = treats for your pet tomorrow! 📝✨",
            "Fresh air is good for debugging code and pet happiness! 🌳",
            "Clean code, clean coder - time for that shower! 🚿",
            "8 hours of sleep = better algorithms + happier pet 😴"
        ]
        
        for (index, message) in motivationalMessages.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "💡 Developer + Pet Parent Tip"
            content.body = message
            content.sound = .default
            
            // Schedule throughout the day
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: Double(3600 * (index + 1)), // Every hour starting from 1 hour
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "motivation-\(index)",
                content: content,
                trigger: trigger
            )
            
            try await center.add(request)
        }
    }
    
    func clearAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        switch response.actionIdentifier {
        case "COMPLETE_TASK":
            // This would be handled by the main app to complete the current task
            NotificationCenter.default.post(name: .completeCurrentTask, object: nil)
            
        case "VIEW_PET":
            // This would be handled by the main app to navigate to pet view
            NotificationCenter.default.post(name: .viewPet, object: nil)
            
        default:
            break
        }
    }
}

// MARK: - Notification Names for App Integration

extension Notification.Name {
    static let completeCurrentTask = Notification.Name("completeCurrentTask")
    static let viewPet = Notification.Name("viewPet")
}

// MARK: - App Delegate for Notification Handling

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationService = NotificationService()
        notificationService.handleNotificationResponse(response)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}