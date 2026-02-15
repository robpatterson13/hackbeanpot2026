//
//  AppDelegate.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize the global AnimalManager singleton early
        _ = AnimalManager.shared
        
        // Configure global navigation bar appearance to ignore safe area
        configureNavigationBarAppearance()
        
        // Create the main window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set the root view controller
        let mainTabController = MainTabBarController()
        window?.rootViewController = mainTabController
        
        // Make the window visible
        window?.makeKeyAndVisible()
        
        // Debug print to ensure this is being called
        print("AppDelegate: Window setup complete")
        print("AnimalManager initialized with \(AnimalManager.shared.coins) coins")
        
        return true
    }
    
    private func configureNavigationBarAppearance() {
        // Configure the global navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Apply to all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // This is the key setting for ignoring safe area
        UINavigationBar.appearance().isTranslucent = true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save AnimalManager state when app goes to background
        AnimalManager.shared.save()
        print("AnimalManager state saved to UserDefaults")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save AnimalManager state when app is terminated
        AnimalManager.shared.save()
        print("AnimalManager state saved before termination")
    }
}
