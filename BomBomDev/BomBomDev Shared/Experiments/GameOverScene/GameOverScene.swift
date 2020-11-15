//
//  GameOverScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 15/11/2020.
//

import SpriteKit

class GameOverScene : SKScene {
    
    class func newScene() -> GameOverScene {
        guard let scene = SKScene(fileNamed: "GameOverScene") as? GameOverScene else {
            fatalError("Failed to find GameOverScene")
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
}
