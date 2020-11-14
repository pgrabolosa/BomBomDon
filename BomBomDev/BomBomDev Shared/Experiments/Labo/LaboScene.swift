//
//  LaboScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit
import Carbon.HIToolbox

class LaboScene : SKScene {
    
    var conveyorRunners: [BloodType:ConveyorRunner] = {
        var result = [BloodType:ConveyorRunner]()
        BloodType.allCases.forEach { result[$0] = ConveyorRunner() }
        return result
    }()
    
    var observers: [Any] = []
    
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
    
    var peopleHandler: PeopleHandler!
    
    override func didMove(to view: SKView) {
        
        let config: [(bloodType:BloodType, length:Int, x:Int, y:Int, targetPosition:CGPoint)] = [
            (.AB, 2, 13, 4, CGPoint(x: 0, y: 1080-100)),
            ( .A, 4, 13, 3, CGPoint(x: 0, y: 1080-100)),
            ( .B, 6, 13, 2, CGPoint(x: 0, y: 1080-100)),
            ( .O, 8, 13, 1, CGPoint(x: 0, y: 1080-100)),
        ]
        
        peopleHandler = PeopleHandler(parent: self, x: 1620, w: 200)
        peopleHandler.masterNode.zPosition = 5
        
        let moneyEmitter = SKEmitterNode(fileNamed: "MoneyParticle")!
        moneyEmitter.particleBirthRate = 0
        moneyEmitter.position = peopleHandler.masterNode.convert(peopleHandler.moneyPosition, to: self)
        moneyEmitter.zPosition = 10
        addChild(moneyEmitter)
        
        let bloodEmitter = SKEmitterNode(fileNamed: "BloodParticle")!
        bloodEmitter.particleBirthRate = 0
        bloodEmitter.position = peopleHandler.masterNode.convert(peopleHandler.bloodPosition, to: self)
        bloodEmitter.zPosition = 10
        addChild(bloodEmitter)
        
        observers.append(NotificationCenter.default.addObserver(forName: .givesMoney, object: nil, queue: .main) { (notification) in
            moneyEmitter.particleBirthRate += 0.5
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(500))) {
                moneyEmitter.particleBirthRate -= 0.5
            }
        })
        observers.append(NotificationCenter.default.addObserver(forName: .givesBlood, object: nil, queue: .main) { (notification) in
            bloodEmitter.particleBirthRate += 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(500))) {
                bloodEmitter.particleBirthRate -= 1
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(750))) {
                guard let bloodType = notification.userInfo?["Type"] as? BloodType else { return }
                self.conveyorRunners[bloodType]?.load(bloodType: bloodType)
            }
        })
        observers.append(NotificationCenter.default.addObserver(forName: .conveyorShapeDidChange, object: nil, queue: .main) { (notification) in
            let runner = notification.object as! ConveyorRunner
            let latestSegment = runner.conveyor.segments.last!
            
            // must generate the nodes
            let configInit = config.first(where: { "\($0.bloodType)" == runner.name })!
            let nodes = runner.conveyor.makeSpritesForSegment(with: "\(runner.name)", havingStartedAtX: configInit.x, y: configInit.y, segment: latestSegment)
            
            if let rootNode = self.childNode(withName: "//conveyor-\(runner.name)") {
                nodes.forEach { rootNode.addChild($0) }
            }
        })
        
        
        let targets = SKNode()
        targets.name = "targets"
        addChild(targets)
        
        config.forEach { (blood, length, x, y, targetPosition) in
            var conveyor = Conveyor()
            conveyor.segments.append(ConveyorSegment(length: length, orientation: .left, bloodTypeMask: .all))
            let node = conveyor.makeSprites(with: "\(blood)", startingAtX: x, y: y)
            node.name = "conveyor-\(blood)"
            addChild(node)
            
            conveyorRunners[blood]?.conveyor = conveyor
            conveyorRunners[blood]?.name = "\(blood)"
            
            // one target per blood type
            let target = TargetNode.newInstance(at: CGPoint(x: node.children.last!.position.x - GridConfiguration.default.itemSize.width, y: targetPosition.y), for: blood)
            target.name = "target-\(blood)"
            targets.addChild(target)
        }
        
        let parcels = SKNode()
        parcels.name = "parcels"
        addChild(parcels)
        
        observers.append(NotificationCenter.default.addObserver(forName: .newParcel, object: nil, queue: .main) { (notification) in
            let parcel = notification.object as! Parcel
            let shape = ParcelNode.newInstance(with: parcel, at: self.childNode(withName: "/conveyor-\(parcel.bloodType)")!.children.first!.position)
            parcels.addChild(shape)
        })
        
        observers.append(NotificationCenter.default.addObserver(forName: .droppedParcel, object: nil, queue: .main) { (notification) in
            let parcel = notification.object as? Parcel
            if let parcelNode = parcels.children.first(where: { ($0 as! ParcelNode).parcel === parcel }) as? ParcelNode {
                if self.selectedParcel === parcelNode {
                    self.selectedParcel = nil
                }
                parcelNode.explode()
            }
        })
    }
    
    var lastUpdate: TimeInterval? = nil
    override func update(_ currentTime: TimeInterval) {
        let interval = currentTime - (lastUpdate ?? currentTime)
        lastUpdate = currentTime
        
        conveyorRunners.forEach { (_, runner) in
            runner.update(interval)
        }
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
                conveyorRunners.forEach { (_, runner) in runner.remove(parcel) }
                parcelNode.move(toParent: self) // remove from the parcels to avoid future interactions
                selectedParcel = nil
                
                if (parcel.bloodType == node.bloodType) {
                    print("TODO: Success! :-)")
                } else {
                    print("TODO: Failed! :-)")
                }
                
                parcelNode.removeAllActions()
                parcelNode.run(SKAction.sequence([
                    SKAction.move(to: node.position, duration: 1),
                    SKAction.run { parcelNode.explode() }
                ]))
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if (event.keyCode == kVK_ANSI_A) {
            conveyorRunners[.A]?.load(bloodType: .A)
        } else if (event.keyCode == kVK_ANSI_B) {
            conveyorRunners[.B]?.load(bloodType: .B)
        } else if (event.keyCode == kVK_ANSI_C) {
            conveyorRunners[.AB]?.load(bloodType: .AB)
        } else if (event.keyCode == kVK_ANSI_O) {
            conveyorRunners[.O]?.load(bloodType: .O)
        } else if (event.keyCode == kVK_ANSI_V) {
            // test to append a segment to the O conveyor
            conveyorRunners[.O]!.append(ConveyorSegment(length: 2, orientation: .up, bloodTypeMask: .all, speed: 1))
        }
    }
    #endif
    
}
