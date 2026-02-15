//
//  ContentViewModel.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import Foundation
import SwiftUI

@Observable
class HomeViewModel {
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
    
    func getBackgroundImage() -> String {
        switch animalManager?.selectedBackground {
        case .city:
            return "city"
        case .desert:
            return "desert"
        case .forest:
            return "forest"
        case .ocean:
            return "ocean"
        case .livingRoom:
            return "livingRoom"
        case .none:
            return ""
        }
    }
}

struct HomeView: View {
    @State private var homeViewModel: HomeViewModel = .init(animalManager: AnimalManager.shared)
    @State private var yOffset: CGFloat = 0
    @State private var animationManager = AnimationManager.shared
    @State private var isBlob: Bool = true
    
    private var animal: Animal? {
        AnimalManager.shared.animal
    }
    
    var body: some View {
        ZStack {
            Image(homeViewModel.getBackgroundImage())
                .resizable()
                .ignoresSafeArea()
  
            VStack {
                HStack {
                    VStack(spacing: 10) {
                        if let animal {
                            StatBar(value: 20 /*Double(animal.status.health.value)*/,
                                    color: .red,
                                    icon: Image("health"),
                                    iconWidth: 40)
                            
                            StatBar(value: Double(animal.status.hunger.value),
                                    color: .blue,
                                    icon: Image("hunger"),
                                    iconWidth: 40)
                            
                            StatBar(value: Double(animal.status.happiness.value),
                                    color: .orange,
                                    icon: Image("happiness"),
                                    iconWidth: 30)
                        }
                    }
                    .frame(width: 315)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.5))
                    )
                }
                
                Spacer()
            }

                    Image(animationManager.showState1 ? homeViewModel.getAnimalImages().0 : homeViewModel.getAnimalImages().1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .offset(y: yOffset)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 3)
                                .repeatForever(autoreverses: true)
                            ) {
                                yOffset = -15
                            }
                        }
            Spacer()
            
        }
    }
}

private struct StatBar: View {
    let value: Double
    let color: Color
    let icon: Image
    let iconWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.7)).frame(width: 32, height: 32)
                    .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconWidth, height: iconWidth)
            }
            .frame(width: 40, height: 40, alignment: .center)
            
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    Rectangle()
                        .fill(color)
                        .frame(width: max((geo.size.width - 11 ) * CGFloat(value / 100), 0), height: 12)
                        .padding(.horizontal, 5)
                        .frame(height: 12)
                }
                Image("bar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 12)
                    .offset(y: 4)
                
                
            }
            .frame(height: 12)
            
            Text("\(Int(value))/100")
                .font(.caption)
                .foregroundColor(.black)
                .frame(width: 50, alignment: .trailing)
        }
        .frame(height: 24)
    }
}
