//
//  LaboScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class LaboScene : SKScene {
    
    class func newScene() -> LaboScene {
        guard let scene = SKScene(fileNamed: "LaboScene") as? LaboScene else {
            fatalError("Failed to find LaboScene")
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    override func didMove(to view: SKView) {
        // initial setup
        
        var conveyor = Conveyor()
        conveyor.segments.append(ConveyorSegment(length: 2, orientation: .left, bloodTypeMask: .all))
        conveyor.segments.append(ConveyorSegment(length: 3, orientation: .up, bloodTypeMask: .all))
        
        try! JSONEncoder().encode(conveyor).write(to: URL(fileURLWithPath: "/Users/pierre/Downloads/conv.json"))
        
        let conveyorNode = conveyor.makeSprites(with: "test", startingAtX: 8, y: 1)
        addChild(conveyorNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    #if os(OSX)
    override func mouseMoved(with event: NSEvent) {
    }
    
    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
    }
    #endif
    
}
