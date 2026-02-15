//
//  CustomFont.swift
//  HackBeanpot2026
//
//  Created by Amy Wang on 2/14/26.
//

import SwiftUI

extension Font {
    static func customFont(size: CGFloat) -> Font {
        return .custom("Baby-Doll", size: size)
    }
    
    static let body = Font.custom("Baby-Doll", size: 16)
    static let h3 = Font.custom("Baby-Doll", size: 20)
    static let h2 = Font.custom("Baby-Doll", size: 24)
    static let petName = Font.custom("Baby-Doll", size: 32)
    static let tabTitle = Font.custom("Baby-Doll", size: 10)
}
