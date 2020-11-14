//
//  LaboScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class LaboScene : SKScene {
    
    let runner = ConveyorRunner()
    
    class func newScene() -> LaboScene {
        guard let scene = SKScene(fileNamed: "LaboScene") as? LaboScene else {
            fatalError("Failed to find LaboScene")
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    override func didMove(to view: SKView) {
        var conveyor = Conveyor()
        conveyor.segments.append(ConveyorSegment(length: 2, orientation: .left, bloodTypeMask: .all))
        conveyor.segments.append(ConveyorSegment(length: 3, orientation: .up, bloodTypeMask: .all))
        conveyor.segments.append(ConveyorSegment(length: 3, orientation: .left, bloodTypeMask: .all))
        conveyor.segments.append(ConveyorSegment(length: 2, orientation: .up, bloodTypeMask: .all))
        conveyor.segments.append(ConveyorSegment(length: 2, orientation: .right, bloodTypeMask: .all))
        
        let conveyorNode = conveyor.makeSprites(with: "test", startingAtX: 8, y: 1)
        addChild(conveyorNode)
        
        runner.conveyor = conveyor
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.run { self.runner.load() }
        ]))
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
