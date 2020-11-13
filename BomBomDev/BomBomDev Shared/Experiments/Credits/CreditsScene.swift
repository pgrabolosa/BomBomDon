//
//  CreditsScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import SpriteKit

class CreditsScene : SKScene {
    
    class func newScene() -> CreditsScene {
        guard let scene = SKScene(fileNamed: "CreditsScene") as? CreditsScene else {
            fatalError("Failed to load CreditsScene")
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
}
