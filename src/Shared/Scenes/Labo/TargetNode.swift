//
//  ParcelNode.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class TargetNode : SKShapeNode {
    
    var bloodType: BloodType = .O

    class func newInstance(at position: CGPoint, with size: CGSize, for bloodType: BloodType) -> TargetNode {
        let shape = TargetNode(rectOf: size)
        shape.fillColor = .clear
        shape.strokeColor = .clear
        shape.position = position
        shape.bloodType = bloodType
        return shape
    }
    
}
