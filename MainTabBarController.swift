//
//  CustomTabBarController.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private var customTabBar: CustomTabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainTabBarController: viewDidLoad called")
        
        // Configure edge-to-edge layout for the tab bar controller
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        
        setupViewControllers()
        setupCustomTabBar()
        configureNavigationBars()
        
        // Set background color to make sure view is visible
        view.backgroundColor = .systemBackground
    }
    
    private func setupViewControllers() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let exploreVC = ExploreViewController()
        let exploreNav = UINavigationController(rootViewController: exploreVC)
        exploreNav.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)
        
        viewControllers = [homeNav, exploreNav, profileNav] 
    }
    
    private func setupCustomTabBar() {
        print("MainTabBarController: Setting up custom tab bar")
        
        // Hide the default tab bar
        tabBar.isHidden = true
        
        // Create custom tab bar
        customTabBar = CustomTabBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        customTabBar.delegate = self
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.backgroundColor = .clear // Temporary color to make it visible
        
        view.addSubview(customTabBar)
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        print("MainTabBarController: Custom tab bar setup complete")
    }
    
    private func configureNavigationBars() {
        print("MainTabBarController: Configuring navigation bars to ignore safe area")
        
        guard let navControllers = viewControllers as? [UINavigationController] else { return }
        
        for navController in navControllers {
            // Configure the navigation controller to extend edge-to-edge
            navController.edgesForExtendedLayout = .all
            navController.extendedLayoutIncludesOpaqueBars = true
            navController.automaticallyAdjustsScrollViewInsets = false
        }
    }
}

extension MainTabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        selectedIndex = index
    }
}
