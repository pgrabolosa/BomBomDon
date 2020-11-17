//
//  CreditsScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 15/11/2020.
//

import SpriteKit

class CreditsScene : SKScene {
    
    class func newScene() -> CreditsScene {
        guard let scene = SKScene(fileNamed: "CreditsScene") as? CreditsScene else {
            fatalError("Failed to find CreditsScene")
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    var canContinue = false
    
    func doContinue() {
        if self.canContinue {
            view?.presentScene(SplashScreenScene.newScene())
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
