//
//  ParcelNode.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class ParcelNode : SKSpriteNode {
    var parcel: Parcel?
    var observation: Any?
    
    /// Les textures pour les globules
    static let globulesAtlas = SKTextureAtlas(named: "globules")
    
    class func newInstance(with parcel: Parcel?, at position: CGPoint) -> ParcelNode {
        let shape = ParcelNode(texture: nil, size: CGSize(width: 50, height: 50))
        shape.run(SKAction.repeatForever(
            SKAction.animate(with: globulesAtlas.textureNames.map{globulesAtlas.textureNamed($0)}, timePerFrame: 0.5)
        ), withKey: "textureAnimation")
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
    
    func explode(success: Bool, texture: SKTexture? = nil) {
        
        if success == false { // splash it down
            let emitter = SKEmitterNode(fileNamed: "MagicParticle")!
            if let texture = texture {
                emitter.particleTexture = texture
                emitter.particleScale = 0.2 // HACK
            }
            emitter.run(SKAction.sequence([
                SKAction.playSoundFileNamed("broken gasss", waitForCompletion: false),
                SKAction.wait(forDuration: 0.5),
                SKAction.run { emitter.particleBirthRate = 0 },
                SKAction.wait(forDuration: 1),
                SKAction.removeFromParent(),
            ]))
            emitter.position = self.position
            parent?.addChild(emitter)
            self.removeFromParent()
        } else {
            run(.playSoundFileNamed("bood fall 2", waitForCompletion: false))
            run(.removeFromParent())
        }
    }
    
    let bleuChloe = SKColor(calibratedRed: CGFloat(UInt8(0x32))/255, green: CGFloat(UInt8(0xaf))/255, blue: CGFloat(UInt8(0xff))/255, alpha: 1.0)
    
    func selectionStyle(_ selected: Bool) {
        if selected {
            //run(SKAction.repeatForever(SKAction.colorize(with: bleuChloe, colorBlendFactor: 1.0, duration: 0.3)), withKey: "selection")
            let ring = SKShapeNode(circleOfRadius: frame.width/2)
            ring.name = "ring"
            ring.fillColor = .clear
            ring.strokeColor = bleuChloe
            ring.lineWidth = 3
            ring.glowWidth = 2
            addChild(ring)
        } else {
            //removeAction(forKey: "selection")
            childNode(withName: "ring")?.removeFromParent()
        }
    }
}
