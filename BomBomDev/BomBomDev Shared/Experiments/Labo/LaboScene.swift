//
//  LaboScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

class LaboScene : SKScene {
    
    let runner = ConveyorRunner()
    var newParcelObserver: Any?
    var droppedParcelObserver: Any?
    
    var selectedParcel: ParcelNode? {
        didSet {
            if let current = selectedParcel {
                current.selectionStyle(true)
            }
            if let previous = oldValue {
                previous.selectionStyle(false)
            }
        }
    }
    
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
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.run { self.runner.load() }
        ])))
        
        let parcels = SKNode()
        parcels.name = "parcels"
        addChild(parcels)
        
        newParcelObserver = NotificationCenter.default.addObserver(forName: .newParcel, object: nil, queue: .main) { (notification) in
            print("Yay!")
            
            let shape = ParcelNode(rectOf: CGSize(width: 50, height: 50))
            shape.fillColor = .red
            shape.zPosition = 5
            shape.position = conveyorNode.children.first!.position
            shape.parcel = notification.object as? Parcel
            
            parcels.addChild(shape)
            shape.run(SKAction.sequence(shape.makeActions()))
        }
        
        droppedParcelObserver = NotificationCenter.default.addObserver(forName: .droppedParcel, object: nil, queue: .main) { (notification) in
            let parcel = notification.object as? Parcel
            let parcelNode = parcels.children.first { ($0 as! ParcelNode).parcel === parcel }!
            
            let emitter = SKEmitterNode(fileNamed: "MagicParticle")!
            emitter.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { emitter.particleBirthRate = 0 },
                SKAction.wait(forDuration: 1),
                SKAction.removeFromParent()
            ]))
            emitter.position = parcelNode.position
            self.addChild(emitter)
            
            parcelNode.removeFromParent()
        }
    }
    
    var lastUpdate: TimeInterval? = nil
    override func update(_ currentTime: TimeInterval) {
        let interval = currentTime - (lastUpdate ?? currentTime)
        lastUpdate = currentTime
        
        runner.update(interval)
    }
    
    #if os(OSX)
    override func mouseMoved(with event: NSEvent) {
    }
    
    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let node = nodes(at: event.location(in: self)).filter({ $0.parent?.name == "parcels" }).first else {
            return
        }
        
        if let parcelNode = node as? ParcelNode {
            if selectedParcel === parcelNode {
                selectedParcel = nil
            } else {
                selectedParcel = parcelNode
            }
        }
    }
    #endif
    
}
