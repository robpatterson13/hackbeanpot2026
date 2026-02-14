//
//  Animal.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/14/26.
//

protocol AnimalLevel {

}

struct AnimalNeverLevel: AnimalLevel {
    
}

struct AnimalHappiness: AnimalLevel {
    var value: Int
}

struct AnimalHealth: AnimalLevel {
    var value: Int
}

struct AnimalHunger: AnimalLevel {
    var value: Int
}

class AnimalStatus {
    var happiness: AnimalHappiness
    var health: AnimalHealth
    var hunger: AnimalHunger
    
    init(happiness: AnimalHappiness, health: AnimalHealth, hunger: AnimalHunger) {
        self.happiness = happiness
        self.health = health
        self.hunger = hunger
    }
}

enum AnimalType {
    case blob, fish, gecko, cat, dog, unicorn
}

class Animal {
    var type: AnimalType
    var status: AnimalStatus
    
    init(type: AnimalType, status: AnimalStatus) {
        self.type = type
        self.status = status
    }
}
