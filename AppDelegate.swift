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
}
