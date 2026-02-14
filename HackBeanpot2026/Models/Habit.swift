//
//  Habit.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26
//

enum Habit: CaseIterable {
    case sleep
    case leetcode
    case jobs
    case shower
    case water
    case outside

    enum Verification {
        case confirmation(prompt: String)
        case screenshot(prompt: String)
    }

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
        case .sleep: return 0
        case .leetcode: return 10
        case .jobs: return 8
        case .shower: return 0
        case .water: return 5
        case .outside: return 2
        }
    }

    var displayName: String {
        switch self {
        case .sleep: return "Sleep 7+ hrs"
        case .leetcode: return "Solve LeetCode"
        case .jobs: return "Apply to a Job"
        case .shower: return "Shower"
        case .water: return "Drink Water"
        case .outside: return "Go Outside"
        }
    }

    // Using SF Symbols names to work with Image(systemName:)
    var imageName: String {
        switch self {
        case .sleep: return "bed.double.fill"
        case .leetcode: return "brain.head.profile"
        case .jobs: return "briefcase.fill"
        case .shower: return "shower.fill"
        case .water: return "bone.fill"       // changed from "drop.fill" to represent hunger
        case .outside: return "leaf.fill"
        }
    }

    var verification: Verification {
        switch self {
        case .leetcode:
            return .screenshot(prompt: "Upload a screenshot showing a solved LeetCode problem.")
        case .jobs:
            return .screenshot(prompt: "Upload a screenshot confirming you applied to a job.")
        case .sleep:
            return .confirmation(prompt: "Did you get at least 7 hours of sleep?")
        case .shower:
            return .confirmation(prompt: "Did you shower today?")
        case .water:
            return .confirmation(prompt: "Did you drink water today?")
        case .outside:
            return .confirmation(prompt: "Did you go outside today?")
        }
    }
}

