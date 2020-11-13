//
//  ExpBoutiqueScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import SpriteKit
import GameplayKit

class ExpBoutiqueScene : SKScene {
    
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
        
        drawerSprite = SKShapeNode(rectOf: CGSize(width: 200, height: self.frame.height - 50))
        drawerSprite.fillColor = .clear
        drawerSprite.strokeColor = .black
        
        
        
        addChild(drawerSprite)
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            
            let item = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
            item.fillColor = .red
            
            self.drawerSprite.addChild(item)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
}
