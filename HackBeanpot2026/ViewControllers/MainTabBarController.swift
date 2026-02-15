//
//  CustomTabBarController.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private var customTabBar: CustomTabBar!
    private var customTabBarBottomConstraint: NSLayoutConstraint?

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
        
        customTabBarBottomConstraint = customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: 80),
            customTabBarBottomConstraint!
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
    
    /// Call this to animate the custom tab bar out of view (down)
    func hideCustomTabBar(animated: Bool = true) {
        guard let constraint = customTabBarBottomConstraint else { return }
        let offset = customTabBar.frame.height + 32 // Hide past bottom edge, 32pt extra for safety
        constraint.constant = offset
        let animations = { self.view.layoutIfNeeded() }
        
        if animated {
            // Slightly slower, still snappy spring out
            UIView.animate(withDuration: 0.36,
                           delay: 0,
                           usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.9,
                           options: [.allowUserInteraction, .beginFromCurrentState]) {
                animations()
            }
        } else {
            animations()
        }
    }
    
    /// Call this to animate the custom tab bar back into view
    func showCustomTabBar(animated: Bool = true) {
        guard let constraint = customTabBarBottomConstraint else { return }
        constraint.constant = 0
        let animations = { self.view.layoutIfNeeded() }
        
        if animated {
            // Slightly slower, crisp spring in
            UIView.animate(withDuration: 0.40,
                           delay: 0,
                           usingSpringWithDamping: 0.78,
                           initialSpringVelocity: 1.1,
                           options: [.allowUserInteraction, .beginFromCurrentState]) {
                animations()
            }
        } else {
            animations()
        }
    }
}

extension MainTabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        selectedIndex = index
    }
}
