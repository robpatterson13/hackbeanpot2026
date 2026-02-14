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
        title = "Explore"
        
        // Create and configure the SwiftUI hosting controller to fill the entire screen
        let swiftUIHostingController = UIHostingController(rootView: TaskListView())
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

// SwiftUI View for Task List - similar to ContentView but focused on tasks
struct TaskListView: View {
    @StateObject private var store = TaskStore()
    @State private var selectedCompleted: CompletedTask? = nil
    @State private var showCompletedDetail = false

    var body: some View {
        NavigationView {
            List {
                // Active tasks
                if !store.tasks.isEmpty {
                    Section("Active Tasks") {
                        ForEach(store.tasks) { task in
                            TaskView(task: task) {
                                // completion handler from TaskView
                                store.complete(task)
                                
                                // Award coins and apply benefits to animal
                                awardTaskCompletion(for: task.habit)
                            }
                        }
                    }
                }

                // Completed tasks at the bottom
                if !store.completedTasks.isEmpty {
                    Section("Completed Tasks") {
                        ForEach(store.completedTasks) { completed in
                            CompletedTaskRow(completed: completed) {
                                selectedCompleted = completed
                                showCompletedDetail = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .overlay {
                if store.tasks.isEmpty && store.completedTasks.isEmpty {
                    ContentUnavailableView("No Tasks Right Now",
                                           systemImage: "sun.max",
                                           description: Text("Check back later — tasks appear throughout the day."))
                }
            }
            .sheet(isPresented: $showCompletedDetail) {
                if let completed = selectedCompleted {
                    CompletedTaskDetailView(completed: completed)
                }
            }
        }
        .onAppear {
            // Link the store to the global animal manager
            store.animalManager = AnimalManager.shared
        }
    }
    
    private func awardTaskCompletion(for habit: Habit) {
        // Use AnimalManager to award coins and apply stat increases
        let coinsEarned = 25 // Base coins for any completed task
        
        AnimalManager.shared.awardTaskCompletion(
            coinsEarned: coinsEarned,
            happinessIncrease: habit.happinessIncrease,
            healthIncrease: habit.healthIncrease,
            hungerIncrease: habit.hungerIncrease
        )
    }
}

struct CompletedTaskRow: View {
    let completed: CompletedTask
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: completed.habit.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(completed.habit.displayName)
                    .font(.body)
                Text(completed.completedAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct CompletedTaskDetailView: View {
    let completed: CompletedTask
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: completed.habit.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .foregroundColor(.accentColor)
                
                Text(completed.habit.displayName)
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Completed on")
                        Spacer()
                        Text(completed.completedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                    .font(.body)
                    
                    // Show the benefits that were gained
                    HStack(spacing: 16) {
                        Label {
                            Text("+\(completed.habit.happinessIncrease)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        } icon: {
                            Image(systemName: "face.smiling")
                                .foregroundColor(.orange)
                        }
                        Label {
                            Text("+\(completed.habit.healthIncrease)")
                                .font(.caption)
                                .foregroundColor(.red)
                        } icon: {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                        Label {
                            Text("+\(completed.habit.hungerIncrease)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        } icon: {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Completed Task")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}