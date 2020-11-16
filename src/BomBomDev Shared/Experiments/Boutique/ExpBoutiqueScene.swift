//
//  ExpBoutiqueScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import SpriteKit
import GameplayKit

class Boutique {
    
    var items: [String] = []
    
    func append(_ item: String) {
        items.append(item)
        NotificationCenter.default.post(name: .BoutiqueNewItem, object: self, userInfo: ["item": item])
    }
    
}

extension Notification.Name {
    static let BoutiqueNewItem = Notification.Name("BoutiqueNewItem")
}


class ExpBoutiqueScene : SKScene {
    
    let boutique = Boutique()
    
    var drawerSprite: SKShapeNode!
    
    class func newScene() -> ExpBoutiqueScene {
        guard let scene = SKScene(fileNamed: "ExpBoutiqueScene") as? ExpBoutiqueScene else {
            fatalError("Failed to find ExpBoutiqueScene")
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    override func didMove(to view: SKView) {
        // initial setup
        
        var o_conveyors = [SKSpriteNode]()
        self.enumerateChildNodes(withName: "//conveyor_O/O_*") { (node, stop) in
            o_conveyors.append(node as! SKSpriteNode)
        }
        o_conveyors.sort { $0.name ?? "" < $1.name ?? "" }
        
        let atlas = SKTextureAtlas(named: "conv")
        atlas.preload {
            o_conveyors.forEach {
                $0.run(SKAction.repeatForever(SKAction.animate(with: atlas.textureNames.map { atlas.textureNamed($0) }, timePerFrame: 0.2)))
            }
        }
        
        var ab_conveyors = [SKSpriteNode]()
        self.enumerateChildNodes(withName: "//conveyor_AB/AB_*") { (node, stop) in
            ab_conveyors.append(node as! SKSpriteNode)
        }
        ab_conveyors.sort { $0.name ?? "" < $1.name ?? "" }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    #if os(OSX)
    override func mouseMoved(with event: NSEvent) {
    }
    
    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
        let loc = event.location(in: self)
        for node in self.nodes(at: loc) where node is SKSpriteNode && node.name?.isEmpty == false {
            let sprite = (node as! SKSpriteNode)
            sprite.run(SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: 1.0))
//            sprite.run(SKAction.fadeAlpha(to: 1.0, duration: 0.5))
        }

    }
    #endif
    
}
