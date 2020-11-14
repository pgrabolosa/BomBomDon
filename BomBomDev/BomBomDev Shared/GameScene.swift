//
//  GameScene.swift
//  BomBomDev Shared
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import SpriteKit

class GameScene: SKScene {
    
    var buttonActions: [SKNode:()->Void] = [:]
    
    class func newScene() -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            fatalError("Failed to load GameScene.sks")
        }
        scene.scaleMode = .aspectFill
        return scene
    }
    
    // called when first showing in a view
    override func didMove(to view: SKView) {
        run(SKAction.sequence([
            SKAction.wait(forDuration: 5),
            SKAction.run {
                self.enterGame()
            }
        ]))
    }
        
    func touched(at loc: CGPoint) {
        self.removeAllActions()
        self.enterGame()
    }
    
    func enterGame() {
        view?.presentScene(LaboScene.newScene(), transition: .doorsOpenHorizontal(withDuration: 2))
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            touched(at: loc)
        }
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    override func mouseUp(with event: NSEvent) {
        let loc = event.location(in: self)
        touched(at: loc)
    }
}
#endif

