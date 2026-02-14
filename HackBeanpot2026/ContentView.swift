//
//  ContentViewModel.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import Foundation

<<<<<<< Updated upstream
<<<<<<< Updated upstream
struct ContentView: View {

    @StateObject private var store = TaskStore()
    @State private var selectedCompleted: CompletedTask? = nil
    @State private var showCompletedDetail = false

    var body: some View {
        NavigationView {
            List {
                // Active tasks
                if !store.tasks.isEmpty {
                    Section("Active") {
                        ForEach(store.tasks) { task in
                            TaskView(task: task) {
                                // completion handler from TaskView
                                store.complete(task)
                            }
                        }
                    }
                }

                // Completed tasks at the bottom
                if !store.completedTasks.isEmpty {
                    Section("Completed") {
                        ForEach(store.completedTasks) { completed in
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
                    CompletedDetailView(completed: completed)
                }
            }
        }
    }
}

struct CompletedDetailView: View {
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
=======
=======
>>>>>>> Stashed changes
class ContentViewModel {
    var property: String
    
    init() {
        self.property = "Start"
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    }
}
