//
//  ParcelNode.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class ParcelNode : SKShapeNode {
    var parcel: Parcel?
    
    func makeActions() -> [SKAction] {
        guard let parcel = parcel else {
            return []
        }
        
        let conveyor = parcel.runner.conveyor
        var currentOrientation = parcel.runner.conveyor.segments.first!.orientation
        
        return parcel.runner.conveyor.segments.flatMap { segment -> [SKAction] in
            let (dx, dy) = segment.orientation.integerOffset
            let offset = CGVector(dx: CGFloat(dx * segment.length) * 100,
                                  dy: CGFloat(dy * segment.length) * 100)
            let duration = TimeInterval(segment.length) * segment.speed
            
            var actions = [SKAction.move(by: offset, duration: duration)]
            
            if currentOrientation != segment.orientation {
                let rotationDuration: TimeInterval = 0.2
                
                actions[0].duration -= rotationDuration
                actions.insert(SKAction.rotate(byAngle: (segment.orientation.rotation - currentOrientation.rotation).truncatingRemainder(dividingBy: .pi), duration: rotationDuration), at: 0)
                currentOrientation = segment.orientation
            }
            
            return actions
        }
    }
    
    func selectionStyle(_ selected: Bool) {
        if selected {
            strokeColor = .cyan
            lineWidth = 4
            glowWidth = 8
        } else {
            strokeColor = .clear
            lineWidth = 0
            glowWidth = 0
        }
    }
}
