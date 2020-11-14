//
//  GameScene.swift
//  BomBomDev Shared
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import SpriteKit

enum Constants {
    static let fontName = "Montserrat-Black"
    static let fontSize = CGFloat(36)
}

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
        addChild(makeButton(at: CGPoint(x: 0, y: -300), color: .red, title: "Exp-Labo", action: { self.load(LaboScene.newScene()) }))
        addChild(makeButton(at: CGPoint(x: 0, y: -100), color: .red, title: "Exp-Boutique", action: { self.load(ExpBoutiqueScene.newScene()) }))
        addChild(makeButton(at: CGPoint(x: 0, y: 100), color: .blue, title: "Exp-Credits", action: { self.load(CreditsScene.newScene()) }))
        addChild(makeButton(at: CGPoint(x: 0, y: 300), color: .green, title: "Exp-Popper", action: { self.load(MissionSheet.newScene(title: "Votre mission si vous l'acceptez", description: "Terminer ce jeu avant\nDemain 15h\n\nEt le commiter sur Itch.io")) }))
    }

    func makeButton(at pos: CGPoint, color: SKColor, title: String, action: (()->Void)? = nil) -> SKNode {
        let text  = SKLabelNode(text: title)
        text.fontColor = .white
        text.position = CGPoint(x: 0, y: -35)
        text.fontSize = 70
        
        let shape = SKShapeNode(rectOf: CGSize(width: 500, height: 100), cornerRadius: 12)
        shape.addChild(text)
        shape.position = pos
        shape.fillColor = color
        
        if let action = action {
            buttonActions[shape] = action
        }
        
        return shape
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func touched(at loc: CGPoint) {
        for node in nodes(at: loc) {
            if let action = buttonActions[node] {
                action()
                break
            }
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            touched(at: loc)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
        let loc = event.location(in: self)
        touched(at: loc)
    }
}
#endif

