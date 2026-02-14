//
//  PixelStyle.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import SwiftUI

// MARK: - Pixel Fonts

extension Font {
    // Pixel-style fonts mapped to system with monospaced design for a retro feel.
    // If you add a real pixel font asset later, update these to use .custom("YourPixelFontName", size: ...)
    static let pixel8: Font = .system(size: 8, weight: .bold, design: .monospaced)
    static let pixel10: Font = .system(size: 10, weight: .bold, design: .monospaced)
    static let pixel12: Font = .system(size: 12, weight: .bold, design: .monospaced)
    static let pixel16: Font = .system(size: 16, weight: .heavy, design: .monospaced)
}

// MARK: - Pixel Color Palette

extension Color {
    // Core 8-bit inspired colors
    static let pixel8BitYellow = Color(red: 1.0, green: 0.92, blue: 0.23)     // bright yellow
    static let pixel8BitOrange = Color(red: 1.0, green: 0.58, blue: 0.16)     // orange
    static let pixel8BitPurple = Color(red: 0.55, green: 0.35, blue: 0.95)    // purple
    static let pixel8BitBlue   = Color(red: 0.20, green: 0.55, blue: 0.95)    // blue
    static let pixel8BitCyan   = Color(red: 0.20, green: 0.90, blue: 0.95)    // cyan
    static let pixel8BitGreen  = Color(red: 0.20, green: 0.85, blue: 0.35)    // green
    static let pixel8BitRed    = Color(red: 0.95, green: 0.25, blue: 0.30)    // red

    // Grays and background
    static let pixel8BitLightGray = Color(red: 0.80, green: 0.85, blue: 0.90)
    static let pixel8BitDarkGray  = Color(red: 0.15, green: 0.18, blue: 0.22)
    static let pixel8BitBlack     = Color(red: 0.05, green: 0.05, blue: 0.06)
}

// MARK: - ShapeStyle convenience for Color lookups (optional)

extension ShapeStyle where Self == Color {
    static var pixel8BitYellow: Color { .pixel8BitYellow }
    static var pixel8BitOrange: Color { .pixel8BitOrange }
    static var pixel8BitPurple: Color { .pixel8BitPurple }
    static var pixel8BitBlue: Color { .pixel8BitBlue }
    static var pixel8BitCyan: Color { .pixel8BitCyan }
    static var pixel8BitGreen: Color { .pixel8BitGreen }
    static var pixel8BitRed: Color { .pixel8BitRed }
    static var pixel8BitLightGray: Color { .pixel8BitLightGray }
    static var pixel8BitDarkGray: Color { .pixel8BitDarkGray }
    static var pixel8BitBlack: Color { .pixel8BitBlack }
}
