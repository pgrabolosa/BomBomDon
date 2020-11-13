//
//  ExpBoutiqueScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import SpriteKit

class ExpBoutiqueScene : SKScene {
    
    class func newScene() -> ExpBoutiqueScene {
        guard let scene = SKScene(fileNamed: "ExpBoutiqueScene") as? ExpBoutiqueScene else {
            fatalError("Failed to find ExpBoutiqueScene")
        }
        scene.scaleMode = .aspectFill
        return scene
    }
    
}
