//
//  ContentViewModel.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import Foundation
import SwiftUI
import UIKit

// Helper to choose a hunger icon with fallbacks across OS versions.
private func hungerSymbolName() -> String {
    if UIImage(systemName: "fork.knife") != nil {
        return "fork.knife"
    } else if UIImage(systemName: "bone.fill") != nil {
        return "bone.fill"
    } else if UIImage(systemName: "drumstick.fill") != nil {
        return "drumstick.fill"
    } else {
        return "fork.knife" // default to forks & knives even if not ideal
    }
}

struct ContentView: View {

    @StateObject private var manager = TaskManager()

    @State private var showAllTaskTypes = false
    @State private var selectedCompleted: CompletedTask? = nil
    @State private var showCompletedDetail = false

    private var activeTasksToDisplay: [HabitTask] {
        if showAllTaskTypes {
            return HabitTask.allTasks
        } else {
            return manager.tasks
        }
    }

    var body: some View {
        NavigationView {
            List {
                if !activeTasksToDisplay.isEmpty {
                    Section("Active") {
                        ForEach(activeTasksToDisplay) { task in
                            TaskView(task: task) {
                                if !showAllTaskTypes {
                                    manager.complete(task)
                                }
                            }
                        }
                    }
                }

                if !manager.completedTasks.isEmpty {
                    Section("Completed") {
                        ForEach(manager.completedTasks) { completed in
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
                                selectedCompleted = completed
                                showCompletedDetail = true
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $showAllTaskTypes) {
                        Text("Show All")
                    }
                    .toggleStyle(.switch)
                }
            }
            .navigationTitle("Tasks")
            .overlay {
                if activeTasksToDisplay.isEmpty && manager.completedTasks.isEmpty {
                    ContentUnavailableView("No Tasks Right Now",
                                           systemImage: "sun.max",
                                           description: Text("Check back later — tasks appear throughout the day."))
                }
            }
            .sheet(isPresented: $showCompletedDetail) {
                if let completed = selectedCompleted {
                    CompletedDetailView(completed: completed)
                }
            }
        }
        .onAppear {
            manager.animalManager = animalManager
        }
    }
}
