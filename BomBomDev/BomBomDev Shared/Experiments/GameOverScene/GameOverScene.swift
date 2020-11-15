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
    
    var canRestart = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        run(.sequence([
            .wait(forDuration: 5),
            .run { self.canRestart = true }
        ]))
    }
    
    #if os(OSX)
    override func mouseUp(with event: NSEvent) {
        view?.presentScene(SplashScreenScene.newScene())
    }
    #elseif os(iOS)
    override func touchesEnded(with event: NSEvent) {
        view?.presentScene(SplashScreenScene.newScene())
    }
    #endif
    
}
