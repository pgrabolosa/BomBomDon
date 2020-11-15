//
//  SplashScreenScene.swift
//  BomBomDev Shared
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import SpriteKit

class SplashScreenScene: SKScene {
    
    var buttonActions: [SKNode:()->Void] = [:]
    
    class func newScene() -> SplashScreenScene {
        guard let scene = SKScene(fileNamed: "SplashScreenScene") as? SplashScreenScene else {
            fatalError("Failed to load SplashScreenScene.sks")
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
        //view?.presentScene(LaboScene.newScene(), transition: .doorsOpenVertical(withDuration: 2))
        //let bleuChloe = SKColor(calibratedRed: CGFloat(UInt8(0x32))/255, green: CGFloat(UInt8(0xaf))/255, blue: CGFloat(UInt8(0xff))/255, alpha: 1.0)
        view?.presentScene(LaboScene.newScene(), transition: .fade(with: .white, duration: 1))
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension SplashScreenScene {
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
extension SplashScreenScene {
    override func mouseUp(with event: NSEvent) {
        let loc = event.location(in: self)
        touched(at: loc)
    }
}
#endif

