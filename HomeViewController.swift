//
//  HomeViewController.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let viewModel = ContentViewModel()
    
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
        title = "Home"
        
        // Create main content
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle("Hello, World!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        let label = UILabel()
        label.text = viewModel.property
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(label)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // Store label reference to update it
        view.subviews.forEach { subview in
            if let stack = subview as? UIStackView {
                if let label = stack.arrangedSubviews.last as? UILabel {
                    label.tag = 100 // Tag for easy reference
                }
            }
        }
    }
    
    @objc private func buttonTapped() {
        viewModel.property = "Switched"
        if let label = view.viewWithTag(100) as? UILabel {
            label.text = viewModel.property
        }
    }
}