//
//  Habit.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

enum Habit {
    case sleep
    case leetcode
    case jobs
    case shower
    case water
    case outside
    
    var happinessIncrease: Int {
        switch self {
        case .sleep:
            return 5
        case .leetcode:
            return 2
        case .jobs:
            return 2
        case .shower:
            return 1
        case .water:
            return 2
        case .outside:
            return 5
        }
    }
    
    var healthIncrease: Int {
        switch self {
        case .sleep:
            return 5
        case .leetcode:
            return 2
        case .jobs:
            return 2
        case .shower:
            return 4
        case .water:
            return 5
        case .outside:
            return 4
        }
    }
    
    var hungerIncrease: Int {
        switch self {
        case .sleep:
            return 0
        case .leetcode:
            return 10
        case .jobs:
            return 8
        case .shower:
            return 0
        case .water:
            return 5
        case .outside:
            return 2
        }
    }
}
