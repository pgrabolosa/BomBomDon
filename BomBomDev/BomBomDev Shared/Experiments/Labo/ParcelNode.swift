//
//  ParcelNode.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class ParcelNode : SKShapeNode {
    var parcel: Parcel?
    
    class func newInstance(with parcel: Parcel?, at position: CGPoint) -> ParcelNode {
        let shape = ParcelNode(rectOf: CGSize(width: 50, height: 50))
        shape.fillColor = .red
        shape.zPosition = 5
        shape.position = position
        shape.parcel = parcel
        shape.run(SKAction.sequence(shape.makeActions()))
    
        return shape
    }
    
    func makeActions() -> [SKAction] {
        guard let parcel = parcel else {
            return []
        }
        
        let conveyor = parcel.runner.conveyor
        var currentOrientation = conveyor.segments.first!.orientation
        
        return conveyor.segments.flatMap { segment -> [SKAction] in
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
    
    func explode() {
        let emitter = SKEmitterNode(fileNamed: "MagicParticle")!
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { emitter.particleBirthRate = 0 },
            SKAction.wait(forDuration: 1),
            SKAction.removeFromParent()
        ]))
        emitter.position = self.position
        parent?.addChild(emitter)
        self.removeFromParent()
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
