//
//  ParcelNode.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class ParcelNode : SKShapeNode {
    var parcel: Parcel?
    var observation: Any?
    
    class func newInstance(with parcel: Parcel?, at position: CGPoint) -> ParcelNode {
        let shape = ParcelNode(rectOf: CGSize(width: 50, height: 50))
        shape.fillColor = .red
        shape.zPosition = 5
        shape.position = position
        shape.parcel = parcel
        
        shape.observation = NotificationCenter.default.addObserver(forName: .parcelMovedToNewConveyorCell, object: parcel, queue: .main, using: { (notification) in
            if let ox = notification.userInfo?["orientationX"] as? Int,
               let oy = notification.userInfo?["orientationY"] as? Int,
               let speed = notification.userInfo?["speed"] as? TimeInterval,
               let length = notification.userInfo?["length"] as? Int {
                
                let sz = GridConfiguration.default.itemSize
                let dx = CGFloat(ox * length) * sz.width
                let dy = CGFloat(oy * length) * sz.height
                
                shape.run(SKAction.move(by: CGVector(dx: dx, dy: dy), duration: speed * TimeInterval(length)))
            }
        })
    
        return shape
    }
    
    @available(*, deprecated, message: "Actions are now built live through notifications…")
    func makeActions() -> [SKAction] {
        fatalError("Actions are now built live through notifications…")
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
