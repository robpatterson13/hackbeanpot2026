//
//  CompletedDetailView.swift
//  HackBeanpot2026
//

import SwiftUI
import UIKit

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
                        Image("health").resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Text("Health +\(completed.habit.healthIncrease)")
                        Spacer()
                    }
                    HStack {
                        Image("happiness").resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Text("Happiness +\(completed.habit.happinessIncrease)")
                        Spacer()
                    }
                    HStack {
                        Image("hunger").resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
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
