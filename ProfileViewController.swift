//
//  ProfileViewController.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureForEdgeToEdgeLayout()
    }
    
    private func configureForEdgeToEdgeLayout() {
        // Configure this view controller for edge-to-edge layout
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
    }
    
    private func setupUI() {
        view.backgroundColor = .clear // Make transparent so shared background shows through
        title = "Profile"
        
        let label = UILabel()
        label.text = "Profile View"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white // Change to white since background might be darker
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Add shadow for better readability
        label.shadowColor = UIColor.black.withAlphaComponent(0.5)
        label.shadowOffset = CGSize(width: 1, height: 1)
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}