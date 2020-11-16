//
//  Constants.swift
//  BomBomDev
//
//  Created by Aurélien VALADE on 15/11/2020.
//

import SpriteKit

enum Constants {
    static let fontName = "Montserrat-Black"
    static let fontSize = CGFloat(32)
    static let bleuChloe = SKColor(displayP3Red: CGFloat(UInt8(0x32))/255, green: CGFloat(UInt8(0xaf))/255, blue: CGFloat(UInt8(0xff))/255, alpha: 1.0)
    static let timerFont = "DISPLAY FREE TFB"
    static let timerSize = CGFloat(24)
    static let timerStartValue = 150
    static let autoFactor : Double = 2.0
    #warning("TODO: Set the automatic factor")
    static let bloodRateLevel = [0.1, 0.2, 0.4, 0.7, 0.9]
    static let moneyRateLevel = [0.2, 0.5, 0.8, 1, 1]
    static let moneyRange = 10...20
}
