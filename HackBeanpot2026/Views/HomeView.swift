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
}

struct HomeView: View {
    @State private var testViewModel: HomeViewModel = .init(animalManager: AnimalManager.shared)
    @State private var yOffset: CGFloat = 0
    @State private var animationManager = AnimationManager.shared
    @State private var isBlob: Bool = true
    
    var body: some View {
        ZStack {
            Image("forest")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    Image(animationManager.showState1 ? testViewModel.getAnimalImages().0 : testViewModel.getAnimalImages().1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .offset(y: yOffset)
                        .onAppear {
                            // Only setup bounce animation, timer is handled by AnimationManager
                            withAnimation(
                                .easeInOut(duration: 3)
                                .repeatForever(autoreverses: true)
                            ) {
                                yOffset = -15 // Bounce up 15 points
                            }
                        }
                }
            }
        }
    }
}
