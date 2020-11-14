//
//  LaboScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit
#if os(OSX)
import Carbon.HIToolbox
#endif

enum ShoppingProduct: CaseIterable {
    //TODO
}

class Shop {
    /// L'élément de la boutique sélectionné (TODO: pour Aurélien)
    var selectedShoppingItem: ShoppingProduct? = nil
    
    /// Confirme la volonté d'acheter l'élément sélectionné
    func purchase() {  }
}



class LaboScene : SKScene {
    
    // MARK: - Constructeurs
    
    /// Au lieu d'un constructeur, utiliser cette méthode fabrique
    class func newScene() -> LaboScene {
        guard let scene = SKScene(fileNamed: "LaboScene") as? LaboScene else {
            fatalError("Failed to find LaboScene")
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    // MARK: - Variables
    
    /// The runners organized by BloodType
    var conveyorRunners: [BloodType:ConveyorRunner] = {
        var result = [BloodType:ConveyorRunner]()
        BloodType.allCases.forEach { result[$0] = ConveyorRunner() }
        return result
    }()
    
    /// The nodes containing the conveyor cells
    var conveyorNodes: [BloodType:SKNode] = [:]
    
    /// HUD for resources (money)
    var resourceDisplay: ResourcesManagement?
    
    /// Afficheur du Score
    var score: Score?
    
    /// Tokens d'observation du NotificationCenter
    var observers: [Any] = []
    
    /// Le paquet sélectionné
    var selectedParcel: ParcelNode? {
        didSet {
            /// modifier le style d'affichage
            if let current = selectedParcel {
                current.selectionStyle(true)
            }
            if let previous = oldValue {
                previous.selectionStyle(false)
            }
        }
    }
    
    /// La boutique
    var shop: Shop!
    
    /// Le gestionnaire des piétons
    var peopleHandler: PeopleHandler!
    
    
    // MARK: - Évènementiel
    
    override func didMove(to view: SKView) {
        
        // Ces noeuds servent à encapsuler les cibles et les poches de sang.
        // Ainsi lors d'un clic/toucher on peut traverser la hiérarchie et vérifier
        // s'il s'agit d'un target ou d'un parcel. ==> TODO: Utiliser des types de nœuds ≠
        
        let targets = SKNode()
        targets.name = "targets"
        addChild(targets)
        
        let parcels = SKNode()
        parcels.name = "parcels"
        addChild(parcels)
        
        let placeholders = SKNode() // pour indiquer où ajouter des éléments
        placeholders.name = "placeholders"
        addChild(placeholders)
        
        // MARK: Configuration du layout
        // Il faut tout d'abord créer les tapis roulants initiaux
        // ainsi que les poches qui vont recevoir le sang (`target`).
        // En voici la configuration, par type de sang.
        
        // NB: la coordonnée X est dérivée de là où finit le tapis initial.
        
        let config: [(bloodType:BloodType, length:Int, x:Int, y:Int, targetPosition:CGPoint)] = [
            (.AB, 2, 13, 4, CGPoint(x: 0, y: 1080-100)),
            ( .A, 4, 13, 3, CGPoint(x: 0, y: 1080-100)),
            ( .B, 6, 13, 2, CGPoint(x: 0, y: 1080-100)),
            ( .O, 8, 13, 1, CGPoint(x: 0, y: 1080-100)),
        ]
        
        config.forEach { (blood, length, x, y, targetPosition) in
            var conveyor = Conveyor()
            conveyor.segments.append(ConveyorSegment(length: length, orientation: .left, bloodTypeMask: .all))
            let node = conveyor.makeSprites(with: "\(blood)", startingAtX: x, y: y)
            node.name = "conveyor-\(blood)"
            addChild(node)
            
            self.conveyorNodes[blood] = node
            
            conveyorRunners[blood]?.conveyor = conveyor
            conveyorRunners[blood]?.name = "\(blood)"
            
            // one target per blood type
            let target = TargetNode.newInstance(at: CGPoint(x: node.children.last!.position.x - GridConfiguration.default.itemSize.width, y: targetPosition.y), for: blood)
            target.name = "target-\(blood)"
            targets.addChild(target)
        }
        
        // MARK: Configuration des éléments
        // Initialisation des éléments auxiliaires
        
        peopleHandler = PeopleHandler(parent: self, x: 1620, w: 200)
        peopleHandler.masterNode.zPosition = 5
        
        score = Score(parent: self, x: 50, y: 950, w: 200, h: 70)
        resourceDisplay = ResourcesManagement(parent: self, x: 50, y: 1000, w: 200, h: 70)
        
        // MARK: Générateurs de particules (💸 et ❤️)
        // Initialisation des filtres à particules liés au don de sang/argent
        
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
        
        // Écoute des Notifications
        
        // MARK: Notification : Gives Money 💰
        observers.append(NotificationCenter.default.addObserver(forName: .givesMoney, object: nil, queue: .main) { (notification) in
            moneyEmitter.particleBirthRate += 0.5
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(500))) {
                moneyEmitter.particleBirthRate -= 0.5
            }
        })
        
        // MARK: Notification : Gives Blood 🩸
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
        
        // MARK: Notification : Conveyor Shape Changed
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
        
        // MARK: Notification : New Parcel Available
        observers.append(NotificationCenter.default.addObserver(forName: .newParcel, object: nil, queue: .main) { (notification) in
            let parcel = notification.object as! Parcel
            let shape = ParcelNode.newInstance(with: parcel, at: self.childNode(withName: "/conveyor-\(parcel.bloodType)")!.children.first!.position)
            parcels.addChild(shape)
        })
        
        // MARK: Notification : A Parcel was Dropped
        observers.append(NotificationCenter.default.addObserver(forName: .droppedParcel, object: nil, queue: .main) { (notification) in
            let parcel = notification.object as? Parcel
            if let parcelNode = parcels.children.first(where: { ($0 as! ParcelNode).parcel === parcel }) as? ParcelNode {
                if self.selectedParcel === parcelNode {
                    self.selectedParcel = nil
                }
                NotificationCenter.default.post(name: .bagDropped, object: nil)
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
    
    // MARK: - Interaction Utilisateur
    
    func tapped(at location: CGPoint) {
        // (de)select a parcel node
        if let node = nodes(at: location).filter({ $0.parent?.name == "parcels" }).first as? ParcelNode {
            if selectedParcel === node {
                selectedParcel = nil
            } else {
                selectedParcel = node
            }
        }
        
        // move the selected parcel node to the selected target
        if let node = nodes(at: location).filter({ $0.parent?.name == "targets" }).first as? TargetNode {
            if let parcelNode = selectedParcel, let parcel = parcelNode.parcel {
                conveyorRunners.forEach { (_, runner) in runner.remove(parcel) }
                parcelNode.move(toParent: self) // remove from the parcels to avoid future interactions
                selectedParcel = nil
                
                if (parcel.bloodType == node.bloodType) {
                    print("TODO: Success! :-)")
                    NotificationCenter.default.post(name: .bagScored, object: nil, userInfo: ["BloodType" : node.bloodType])
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
    
    #if os(OSX)
    override func mouseUp(with event: NSEvent) {
        tapped(at: event.location(in: self))
    }
    
    override func keyUp(with event: NSEvent) {
       
        // This is mostly for testing / debug
        if (event.keyCode == kVK_ANSI_A) {
            conveyorRunners[.A]?.load(bloodType: .A)
        } else if (event.keyCode == kVK_ANSI_B) {
            conveyorRunners[.B]?.load(bloodType: .B)
        } else if (event.keyCode == kVK_ANSI_C) {
            conveyorRunners[.AB]?.load(bloodType: .AB)
        } else if (event.keyCode == kVK_ANSI_O) {
            conveyorRunners[.O]?.load(bloodType: .O)
        } else if (event.keyCode == kVK_ANSI_Equal) {
            _ = peopleHandler.increaseBloodRate()
        } else if (event.keyCode == kVK_ANSI_Minus) {
            _ = peopleHandler.increaseMoneyRate()
        } else if (event.keyCode == kVK_ANSI_V) {
            // test to append a segment to the O conveyor
            //conveyorRunners[.O]!.append(ConveyorSegment(length: 2, orientation: .up, bloodTypeMask: .all, speed: 1))
            
            BloodType.allCases.forEach { bloodType in
                let loc = locationAfterLastCell(of: bloodType)
                let shape = SKShapeNode(ellipseOf: CGSize(width: 65, height: 65))
                shape.fillColor = .green
                shape.position = loc
                
                addChild(shape)
            }
        }
    }
    #elseif os(iOS)
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            tapped(at: touch.location(in: self))
        }
    }
    #endif
    
    // MARK: - Utility Functions
    
    func lastCell(of type: BloodType) -> SKNode {
        return conveyorNodes[type]!.children.last!
    }
    
    func locationAfterLastCell(of type: BloodType) -> CGPoint {
        let cell = lastCell(of: type)
        let orientation = conveyorRunners[type]!.conveyor.segments.last!.orientation
        let itemSize = GridConfiguration.default.itemSize
        
        var position: CGPoint = cell.position
        position.x += CGFloat(orientation.integerOffset.dx) * itemSize.width
        position.y += CGFloat(orientation.integerOffset.dy) * itemSize.height
        
        return position
    }
    
}
