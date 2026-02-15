//
//  ExploreViewController.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import UIKit
import SwiftUI

class ExploreViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureForEdgeToEdgeLayout()
    }
    
    private func configureForEdgeToEdgeLayout() {
        // Configure this view controller for full edge-to-edge layout
        edgesForExtendedLayout = UIRectEdge.all
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        // Remove any additional safe area insets
        additionalSafeAreaInsets = UIEdgeInsets.zero
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Objectives"
        
        // Create and configure the SwiftUI hosting controller to fill the entire screen
        let swiftUIHostingController = UIHostingController(rootView: ObjectivesAndTasksView(animalManager: AnimalManager.shared))
        addChild(swiftUIHostingController)
        swiftUIHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        swiftUIHostingController.view.backgroundColor = UIColor.clear
        
        // Configure the SwiftUI hosting controller for edge-to-edge layout
        swiftUIHostingController.edgesForExtendedLayout = UIRectEdge.all
        swiftUIHostingController.extendedLayoutIncludesOpaqueBars = true
        
        view.addSubview(swiftUIHostingController.view)
        
        // Make the SwiftUI view fill the entire screen bounds (not just safe area)
        NSLayoutConstraint.activate([
            swiftUIHostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            swiftUIHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swiftUIHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            swiftUIHostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Complete the child view controller setup
        swiftUIHostingController.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure the view extends to full screen bounds
        view.frame = view.superview?.bounds ?? view.frame
        
        // Make sure all child views also extend to full bounds
        view.subviews.forEach { subview in
            if subview.translatesAutoresizingMaskIntoConstraints == false {
                // Let Auto Layout handle constraint-based views
                return
            }
            subview.frame = view.bounds
        }
    }
}
