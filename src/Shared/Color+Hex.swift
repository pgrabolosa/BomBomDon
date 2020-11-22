//
//  Color+Hex.swift
//  BOAB
//
//  Created by Pierre Grabolosa on 22/11/2020.
//

import SpriteKit

extension SKColor {
    convenience init(rgb24: UInt32) {
        let r: UInt8 = UInt8(0xFF & (rgb24 >> 16))
        let g: UInt8 = UInt8(0xFF & (rgb24 >>  8))
        let b: UInt8 = UInt8(0xFF & (rgb24 >>  0))
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1.0)
    }
    
    convenience init?(rgb24: String) {
        guard let value = UInt32(rgb24, radix: 16) else {
            return nil
        }
        self.init(rgb24: value)
    }
}

