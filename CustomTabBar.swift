//
//  CustomTabBar.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import UIKit

protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(at index: Int)
}

class CustomTabBar: UIView {
    
    weak var delegate: CustomTabBarDelegate?
    
    private var tabButtons: [CustomTabButton] = []
    private var selectedIndex: Int = 0
    
    private let tabItems = [
        TabItem(title: "Home", icon: "house", selectedIcon: "house.fill"),
        TabItem(title: "Explore", icon: "magnifyingglass", selectedIcon: "magnifyingglass"),
        TabItem(title: "Profile", icon: "person", selectedIcon: "person.fill")
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = 20
        
        setupTabButtons()
    }
    
    private func setupTabButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        for (index, item) in tabItems.enumerated() {
            let button = CustomTabButton(tabItem: item)
            button.tag = index
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            
            if index == selectedIndex {
                button.setSelected(true)
            }
            
            tabButtons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func tabButtonTapped(_ sender: CustomTabButton) {
        let index = sender.tag
        selectTab(at: index)
        delegate?.didSelectTab(at: index)
    }
    
    func selectTab(at index: Int) {
        guard index != selectedIndex, index < tabButtons.count else { return }
        
        // Deselect previous button
        tabButtons[selectedIndex].setSelected(false)
        
        // Select new button
        selectedIndex = index
        tabButtons[selectedIndex].setSelected(true)
    }
}

struct TabItem {
    let title: String
    let icon: String
    let selectedIcon: String
}

class CustomTabButton: UIButton {
    
    private let tabItem: TabItem
    private var iconImageView: UIImageView!
    private var customTitleLabel: UILabel!
    
    init(tabItem: TabItem) {
        self.tabItem = tabItem
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        // Icon
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemGray
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        customTitleLabel = UILabel()
        customTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        customTitleLabel.textColor = .systemGray
        customTitleLabel.textAlignment = .center
        customTitleLabel.text = tabItem.title
        customTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconImageView)
        addSubview(customTitleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            customTitleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            customTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            customTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            customTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        setSelected(false)
    }
    
    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            if selected {
                self.iconImageView.image = UIImage(systemName: self.tabItem.selectedIcon)
                self.iconImageView.tintColor = .systemBlue
                self.customTitleLabel.textColor = .systemBlue
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } else {
                self.iconImageView.image = UIImage(systemName: self.tabItem.icon)
                self.iconImageView.tintColor = .systemGray
                self.customTitleLabel.textColor = .systemGray
                self.transform = .identity
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            if self.iconImageView.tintColor == .systemBlue {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } else {
                self.transform = .identity
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            if self.iconImageView.tintColor == .systemBlue {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } else {
                self.transform = .identity
            }
        }
    }
}
