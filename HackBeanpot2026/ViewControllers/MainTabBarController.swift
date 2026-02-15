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
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let exploreVC = ExploreViewController()
        exploreVC.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        let shopVC = ShopViewController()
        shopVC.tabBarItem = UITabBarItem(title: "Shop", image: UIImage(systemName: "cart"), tag: 2)
        
        viewControllers = [homeVC, exploreVC, shopVC] 
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
        
        guard let viewControllers = viewControllers else { return }
        
        for viewController in viewControllers {
            // Configure each view controller for full screen layout
            configureViewControllerForFullScreen(viewController)
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
        guard let viewControllers = viewControllers else { return }
        
        for viewController in viewControllers {
            viewController.view.frame = view.bounds
        }
    }
}

extension MainTabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        selectedIndex = index
    }
}
