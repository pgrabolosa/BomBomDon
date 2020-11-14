//
//  ParcelNode.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class TargetNode : SKShapeNode {

    class func newInstance(at position: CGPoint) -> TargetNode {
        let shape = TargetNode(rectOf: CGSize(width: 100, height: 100))
        shape.fillColor = .white
        shape.strokeColor = .red
        shape.position = position
        return shape
    }
    
}
