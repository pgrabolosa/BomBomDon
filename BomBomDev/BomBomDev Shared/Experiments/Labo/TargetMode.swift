//
//  ParcelNode.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class TargetNode : SKShapeNode {
    
    var bloodType: BloodType = .O

    class func newInstance(at position: CGPoint, for bloodType: BloodType) -> TargetNode {
        let shape = TargetNode(rectOf: CGSize(width: 100, height: 100))
        shape.fillColor = .clear
        shape.strokeColor = .clear
        shape.position = position
        shape.bloodType = bloodType
        return shape
    }
    
}
