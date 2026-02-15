import Foundation
import SwiftUI

// Struct to hold accessory positions (x, y offset)
struct AccessoryPosition {
    var xOffset: CGFloat
    var yOffset: CGFloat
}
struct Accessory {
    var type: AccessoryType
    var image: String
}

class AnimalAccessoryManager {
    
    private var accessoryPositions: [AccessoryType: [AnimalType: AccessoryPosition]] = [
        .fedora: [
            .blob: AccessoryPosition(xOffset: 0, yOffset: -50),
            .fish: AccessoryPosition(xOffset: 10, yOffset: -60),
            .gecko: AccessoryPosition(xOffset: -13, yOffset: -91),
            .cat: AccessoryPosition(xOffset: 0, yOffset: -50),
            .dog: AccessoryPosition(xOffset: 0, yOffset: -50),
            .unicorn: AccessoryPosition(xOffset: 0, yOffset: -60)
        ],
        
        .sunglasses: [
            .blob: AccessoryPosition(xOffset: 0, yOffset: -40),
            .fish: AccessoryPosition(xOffset: 15, yOffset: -55),
            .gecko: AccessoryPosition(xOffset: 10, yOffset: -40),
            .cat: AccessoryPosition(xOffset: 0, yOffset: -40),
            .dog: AccessoryPosition(xOffset: 0, yOffset: -40),
            .unicorn: AccessoryPosition(xOffset: 0, yOffset: -50)
        ],
        
        .bowtie: [
            .blob: AccessoryPosition(xOffset: -10, yOffset: 30),
            .fish: AccessoryPosition(xOffset: -20, yOffset: 10),
            .gecko: AccessoryPosition(xOffset: -15, yOffset: 25),
            .cat: AccessoryPosition(xOffset: -10, yOffset: 25),
            .dog: AccessoryPosition(xOffset: -10, yOffset: 30),
            .unicorn: AccessoryPosition(xOffset: -15, yOffset: 25)
        ],
        
        .tie: [
            .blob: AccessoryPosition(xOffset: -5, yOffset: 35),
            .fish: AccessoryPosition(xOffset: -15, yOffset: 15),
            .gecko: AccessoryPosition(xOffset: -10, yOffset: 30),
            .cat: AccessoryPosition(xOffset: -5, yOffset: 30),
            .dog: AccessoryPosition(xOffset: -5, yOffset: 35),
            .unicorn: AccessoryPosition(xOffset: -10, yOffset: 30)
        ]
    ]
    
    func getAccessoryPosition(for accessoryType: AccessoryType, animalType: AnimalType) -> AccessoryPosition? {
        return accessoryPositions[accessoryType]?[animalType]
    }
}
