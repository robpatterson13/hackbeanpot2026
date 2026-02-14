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

@Observable
class TestViewModel {
    weak private var animalManager: AnimalManager?
    
    init(animalManager: AnimalManager) {
        self.animalManager = animalManager
    }
    
    func getAnimalImages() -> (String, String) {
        switch animalManager?.animal.type {
        case .blob:
            return ("blob_state_1", "blob_state_2")
        case .fish:
            return ("fish_state_1", "fish_state_2")
        case .gecko:
            return ("gecko_state_1", "gecko_state_2")
        case .cat:
            return ("cat_state_1", "cat_state_2")
        case .dog:
            return ("dog_state_1", "dog_state_2")
        case .unicorn:
            return ("unicorn_state_1", "unicorn_state_2")
        case .none:
            return ("", "")
        }
    }
}

struct TestView: View {
    @State private var testViewModel: TestViewModel = .init(animalManager: animalManager)
    @State private var yOffset: CGFloat = 0
    @State private var showState1: Bool = true
    @State private var isBlob: Bool = true
    
    var body: some View {
        ZStack {
            Image("forest")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    Image(showState1 ? testViewModel.getAnimalImages().0 : testViewModel.getAnimalImages().1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .offset(y: yOffset)
                        .onAppear {
                            // Image toggle
                            Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
                                showState1.toggle()
                            }
                            
                            // Bounce animation
                            withAnimation(
                                .easeInOut(duration: 3)
                                .repeatForever(autoreverses: true)
                            ) {
                                yOffset = -15 // Bounce up 20 points
                            }
                        }
                }
            }
        }
    }
}
