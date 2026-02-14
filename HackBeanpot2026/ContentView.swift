//
//  ContentView.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Image("test")
            .resizable()
            .scaledToFit()
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
