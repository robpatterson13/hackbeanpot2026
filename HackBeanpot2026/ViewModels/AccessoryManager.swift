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
            .blob: AccessoryPosition(xOffset: 0, yOffset: -52),
            .fish: AccessoryPosition(xOffset: 5, yOffset: -45),
            .gecko: AccessoryPosition(xOffset: -13, yOffset: -91),
            .cat: AccessoryPosition(xOffset: 10, yOffset: -80),
            .dog: AccessoryPosition(xOffset: 12, yOffset: -89),
            .unicorn: AccessoryPosition(xOffset: -13, yOffset: -62)
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
            .blob: AccessoryPosition(xOffset: -5, yOffset: 25),
            .fish: AccessoryPosition(xOffset: -35, yOffset: 30),
            .gecko: AccessoryPosition(xOffset: -10, yOffset: -3),
            .cat: AccessoryPosition(xOffset: 10, yOffset: 10),
            .dog: AccessoryPosition(xOffset: 5, yOffset: 15),
            .unicorn: AccessoryPosition(xOffset: -18, yOffset: 25)
        ],
        
        .tie: [
            .blob: AccessoryPosition(xOffset: 0, yOffset: 43),
            .fish: AccessoryPosition(xOffset: -48, yOffset: 40),
            .gecko: AccessoryPosition(xOffset: -10, yOffset: 15),
            .cat: AccessoryPosition(xOffset: 10, yOffset: 32),
            .dog: AccessoryPosition(xOffset: 5, yOffset: 35),
            .unicorn: AccessoryPosition(xOffset: -20, yOffset: 50)
        ]
    ]
    
    func getAccessoryPosition(for accessoryType: AccessoryType, animalType: AnimalType) -> AccessoryPosition? {
        return accessoryPositions[accessoryType]?[animalType]
    }
}
