//
//  GameOverScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 15/11/2020.
//

import SpriteKit

class GameOverScene : SKScene {
    
    class func newScene(score: Int) -> GameOverScene {
        guard let scene = SKScene(fileNamed: "GameOverScene") as? GameOverScene else {
            fatalError("Failed to find GameOverScene")
        }
        scene.scaleMode = .aspectFit
        if let sLabel = scene.childNode(withName: "//score") as? SKLabelNode {
            sLabel.text = "\(score)"
        }
        return scene
    }
    
    var canContinue = false
    
    func doContinue() {
        if self.canContinue {
            view?.presentScene(CreditsScene.newScene())
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        run(.sequence([
            .wait(forDuration: 5),
            .run { self.canContinue = true }
        ]))
    }
    
    #if os(OSX)
    override func mouseUp(with event: NSEvent) {
        doContinue()
    }
    #elseif os(iOS)
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        doContinue()
    }
    #endif
    
}
