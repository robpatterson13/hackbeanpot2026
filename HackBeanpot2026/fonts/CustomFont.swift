//
//  CustomFont.swift
//  HackBeanpot2026
//
//  Created by Amy Wang on 2/14/26.
//

import SwiftUI

extension Font {
    static func customFont(size: CGFloat) -> Font {
        return .custom("AlmondMilky", size: size)
    }
    
    static let habitTitle = Font.custom("AlmondMilky", size: 24)
    static let habitBody = Font.custom("AlmondMilky", size: 16)
    static let petName = Font.custom("AlmondMilky", size: 32)
}
