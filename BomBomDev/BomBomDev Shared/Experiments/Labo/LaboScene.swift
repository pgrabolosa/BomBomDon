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
    
    var peopleHandler: PeopleHandler?
    
    override func didMove(to view: SKView) {
        
        peopleHandler = PeopleHandler(parent: self, x: 1620, w: 200)
        
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
        
        
        let targets = SKNode()
        targets.name = "targets"
        addChild(targets)
        
        targets.addChild(TargetNode.newInstance(at: CGPoint(x: 1920/2 - 500/2, y: 1080-100)))
        
        
        newParcelObserver = NotificationCenter.default.addObserver(forName: .newParcel, object: nil, queue: .main) { (notification) in
            let shape = ParcelNode.newInstance(with: notification.object as? Parcel, at: conveyorNode.children.first!.position)
            parcels.addChild(shape)
        }
        
        droppedParcelObserver = NotificationCenter.default.addObserver(forName: .droppedParcel, object: nil, queue: .main) { (notification) in
            let parcel = notification.object as? Parcel
            let parcelNode = parcels.children.first { ($0 as! ParcelNode).parcel === parcel } as! ParcelNode
            
            parcelNode.explode()
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

        // (de)select a parcel node
        if let node = nodes(at: event.location(in: self)).filter({ $0.parent?.name == "parcels" }).first as? ParcelNode {
            if selectedParcel === node {
                selectedParcel = nil
            } else {
                selectedParcel = node
            }
        }
        
        // move the selected parcel node to the selected target
        if let node = nodes(at: event.location(in: self)).filter({ $0.parent?.name == "targets" }).first as? TargetNode {
            if let parcelNode = selectedParcel, let parcel = parcelNode.parcel {
                print("TODO: remove selected from convoyer and send it to the target")
                runner.remove(parcel)
                
                parcelNode.removeAllActions()
                parcelNode.run(SKAction.sequence([
                    SKAction.move(to: node.position, duration: 1),
                    SKAction.run { parcelNode.explode() }
                ]))
            }
        }
        
        
    }
    #endif
    
}
