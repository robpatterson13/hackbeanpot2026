import Foundation
import SwiftUI

// Struct to hold accessory positions (x, y offset) and optional width override
struct AccessoryPosition {
    var xOffset: CGFloat
    var yOffset: CGFloat
    var width: CGFloat? = nil
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
            .blob: AccessoryPosition(xOffset: -12, yOffset: -8, width: 125),
            .fish: AccessoryPosition(xOffset: -50, yOffset: 0, width: 88),
            .gecko: AccessoryPosition(xOffset: -20, yOffset: -65, width: 150),
            .cat: AccessoryPosition(xOffset: 7, yOffset: -30, width: 128),
            .dog: AccessoryPosition(xOffset: 5, yOffset: -30, width: 130),
            .unicorn: AccessoryPosition(xOffset: -28, yOffset: -20, width: 115)
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

