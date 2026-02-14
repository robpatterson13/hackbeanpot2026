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
        
        setupViewControllers()
        setupCustomTabBar()
        configureForFullScreenLayout()
        
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
        
        let shopVC = ShopViewController()
        let shopNav = UINavigationController(rootViewController: shopVC)
        shopNav.tabBarItem = UITabBarItem(title: "Shop", image: UIImage(systemName: "cart"), tag: 2)
        
        viewControllers = [homeNav, exploreNav, shopNav] 
    }
    
    private func setupCustomTabBar() {
        print("MainTabBarController: Setting up custom tab bar")
        
        // Hide the default tab bar
        tabBar.isHidden = true
        
        // Create custom tab bar
        customTabBar = CustomTabBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        customTabBar.delegate = self
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.backgroundColor = .clear
        
        view.addSubview(customTabBar)
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        print("MainTabBarController: Custom tab bar setup complete")
    }
    
    private func configureForFullScreenLayout() {
        print("MainTabBarController: Configuring full screen layout")
        
        // Configure the tab bar controller to extend edge-to-edge
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        guard let navControllers = viewControllers as? [UINavigationController] else { return }
        
        for navController in navControllers {
            // Configure each navigation controller for full screen layout
            navController.edgesForExtendedLayout = .all
            navController.extendedLayoutIncludesOpaqueBars = true
            navController.automaticallyAdjustsScrollViewInsets = false
            
            // Configure the root view controller for edge-to-edge layout
            if let rootViewController = navController.topViewController {
                configureViewControllerForFullScreen(rootViewController)
            }
        }
    }
    
    private func configureViewControllerForFullScreen(_ viewController: UIViewController) {
        // Ensure each view controller extends edge-to-edge
        viewController.edgesForExtendedLayout = .all
        viewController.extendedLayoutIncludesOpaqueBars = true
        viewController.automaticallyAdjustsScrollViewInsets = false
        
        // Make sure the view extends to the full bounds
        viewController.view.frame = view.bounds
        viewController.additionalSafeAreaInsets = .zero
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure all child views extend to full screen bounds
        guard let navControllers = viewControllers as? [UINavigationController] else { return }
        
        for navController in navControllers {
            navController.view.frame = view.bounds
            if let rootViewController = navController.topViewController {
                rootViewController.view.frame = navController.view.bounds
            }
        }
    }
}

extension MainTabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        selectedIndex = index
    }
}
