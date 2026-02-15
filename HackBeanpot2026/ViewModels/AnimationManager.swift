//
//  AnimationManager.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

import Foundation

// Shared animation manager to persist timer across tab changes
@Observable
class AnimationManager {
    static let shared = AnimationManager()
    
    private var timer: Timer?
    var showState1: Bool = true
    
    private init() {
        startTimer()
    }
    
    private func startTimer() {
        // Only start timer if it's not already running
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            self.showState1.toggle()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
}
