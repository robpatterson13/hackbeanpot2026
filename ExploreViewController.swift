//
//  ExploreViewController.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import UIKit

class ExploreViewController: UIViewController {
    
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
        view.backgroundColor = .systemBackground
        title = "Explore"
        
        let label = UILabel()
        label.text = "Explore View"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}