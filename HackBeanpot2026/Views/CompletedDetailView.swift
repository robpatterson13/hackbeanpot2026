//
//  CompletedDetailView.swift
//  HackBeanpot2026
//

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
        return "fork.knife"
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

                // Rewards breakdown for completed task
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rewards")
                        .font(.headline)
                    HStack {
                        Image(systemName: "heart.fill").foregroundColor(.red)
                        Text("Health +\(completed.habit.healthIncrease)")
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "face.smiling").foregroundColor(.orange)
                        Text("Happiness +\(completed.habit.happinessIncrease)")
                        Spacer()
                    }
                    HStack {
                        Image(systemName: hungerSymbolName()).foregroundColor(.blue)
                        Text("Hunger +\(completed.habit.hungerIncrease)")
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
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
