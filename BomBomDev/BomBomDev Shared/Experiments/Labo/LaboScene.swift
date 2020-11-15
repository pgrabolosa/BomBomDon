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

class HandleNode: SKSpriteNode {
    var action: (()->Void)? = nil
    var bloodType: BloodType = .O
    
    class func newNode(for bloodType: BloodType, _ action: @escaping ()->Void) -> HandleNode {
        let sz = GridConfiguration.default.itemSize
        let node = HandleNode(texture: SKTexture(imageNamed: "croix_rose"), size: CGSize(width: 0.8 * sz.width, height: 0.8 * sz.height))
        node.bloodType = bloodType
        node.action = action
        return node
    }
}


class LaboScene : SKScene {
    
    // MARK: - Constructeurs
    
    /// Au lieu d'un constructeur, utiliser cette méthode fabrique
    class func newScene(initialMoney: Int = 0, prevScore: Int = 0, difficulty: Int = 0) -> LaboScene {
        guard let scene = SKScene(fileNamed: "LaboScene") as? LaboScene else {
            fatalError("Failed to find LaboScene")
        }
        scene.scaleMode = .aspectFit
        scene.initialMoney = initialMoney
        scene.previousScore = prevScore
        scene.difficultyClass = difficulty
        return scene
    }
    
    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self)
        self.observers = []
        self.score = nil
        self.peopleHandler = nil
        self.removeAllActions()
        self.removeAllChildren()
        self.childNode(withName: "//music")?.removeFromParent()
    }

    
    // MARK: - Variables
    
    var initialMoney : Int!
    var previousScore : Int!
    var difficultyClass : Int!
    
    /// The runners organized by BloodType
    var conveyorRunners: [BloodType:ConveyorRunner] = {
        var result = [BloodType:ConveyorRunner]()
        BloodType.allCases.forEach { result[$0] = ConveyorRunner() }
        return result
    }()
    
    /// The nodes containing the conveyor cells
    var conveyorNodes: [BloodType:SKNode] = [:]
    
    /// Les poches de sang
    var bloodBags: [BloodType:SKSpriteNode] = [:]
    
    /// HUD for resources (money)
    var resourceDisplay: ResourcesManagement?
    
    /// Afficheur du Score
    var score: Score?
    
    var bloodLevels: [BloodType:Int] = {
        var result = [BloodType:Int]()
        BloodType.allCases.forEach { result[$0] = 0 }
        return result
    }()
    
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
    var gameTimer: GameTimer!
    
    /// Le gestionnaire des piétons
    var peopleHandler: PeopleHandler!
    
    var config: [(bloodType:BloodType, length:Int, x:Int, y:Int, targetPosition:CGPoint)] = [
        (.AB, 1, 13, 4, CGPoint(x: 0, y: 1080)),
        ( .B, 3, 13, 3, CGPoint(x: 0, y: 1080)),
        ( .A, 5, 13, 2, CGPoint(x: 0, y: 1080)),
        ( .O, 7, 13, 1, CGPoint(x: 0, y: 1080)),
    ]
    
    func resetConveyors() {
        let conveyorBelt = childNode(withName: "conveyorBelt")!
        let targets = childNode(withName: "targets")!
        
        conveyorBelt.removeAllActions()
        conveyorBelt.removeAllChildren()
        
        targets.removeAllActions()
        targets.removeAllChildren()
        
        config.forEach { (blood, length, x, y, targetPosition) in
            var conveyor = Conveyor()
            conveyor.segments.append(ConveyorSegment(length: length, orientation: .left, bloodTypeMask: .all))
            let node = conveyor.makeSprites(with: "\(blood)", startingAtX: x, y: y)
            node.name = "conveyor-\(blood)"
            conveyorBelt.addChild(node)
            
            self.conveyorNodes[blood] = node
            
            conveyorRunners[blood]?.conveyor = conveyor
            conveyorRunners[blood]?.name = "\(blood)"
            
            // one target per blood type
            let fr = self.bloodBags[blood]!.frame
            let p = CGPoint(x: node.children.last!.position.x - GridConfiguration.default.itemSize.width, y: targetPosition.y - fr.height)
            
            let target = TargetNode.newInstance(at: p, with: fr.size, for: blood)
            target.name = "target-\(blood)"
            
            targets.addChild(target)
        }

    }
    
    
    // MARK: - Évènementiel
    
    override func didMove(to view: SKView) {
                
        observers.append(NotificationCenter.default.addObserver(forName: .gameOver, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            NotificationCenter.default.removeObserver(self)
            self.observers = []
            self.score = nil
        })
        
        // Ces noeuds servent à encapsuler les cibles et les poches de sang.
        // Ainsi lors d'un clic/toucher on peut traverser la hiérarchie et vérifier
        // s'il s'agit d'un target ou d'un parcel. ==> TODO: Utiliser des types de nœuds ≠
        
        let conveyorBelt = SKNode()
        conveyorBelt.name = "conveyorBelt"
        conveyorBelt.position.y =  -50  // adjusted bc background arrow
        conveyorBelt.position.x = -100 // adjusted bc background arrow
        addChild(conveyorBelt)
        
        let targets = SKNode()
        targets.name = "targets"
        targets.position.y =    0 // adjusted bc background arrow
        targets.position.x = -100 // adjusted bc background arrow
        addChild(targets)
        
        let parcels = SKNode()
        parcels.name = "parcels"
        parcels.position.y =  -50 // adjusted bc background arrow
        parcels.position.x = -100 // adjusted bc background arrow
        addChild(parcels)
        
        let placeholders = SKNode() // pour indiquer où ajouter des éléments
        placeholders.name = "handles"
        placeholders.position.y =  -50 // adjusted bc background arrow
        placeholders.position.x = -100 // adjusted bc background arrow
        addChild(placeholders)
        
        // init blog bags
        bloodBags[ .O] = (childNode(withName: "//blood_o") as? SKSpriteNode)!
        bloodBags[ .A] = (childNode(withName: "//blood_a") as? SKSpriteNode)!
        bloodBags[ .B] = (childNode(withName: "//blood_b") as? SKSpriteNode)!
        bloodBags[.AB] = (childNode(withName: "//blood_ab") as? SKSpriteNode)!
        
        BloodType.allCases.forEach {
            self.setPercentage(of: $0, to: 0)
        }
        
        
        // initialize the shop
        run(.repeatForever(.sequence([
            .wait(forDuration: 20 + 10 * TimeInterval.random(in: 0...1)),
            .run { self.shop.newNode() }
        ])))
        
        
        // MARK: Configuration du layout
        // Il faut tout d'abord créer les tapis roulants initiaux
        // ainsi que les poches qui vont recevoir le sang (`target`).
        // En voici la configuration, par type de sang.
        
        // NB: la coordonnée X est dérivée de là où finit le tapis initial.
        
        resetConveyors()
        
        
        // MARK: Configuration des éléments
        // Initialisation des éléments auxiliaires
        
        peopleHandler = PeopleHandler(parent: self, x: 1750, w: 380)
        peopleHandler.masterNode.zPosition = 5
        
        score = Score(parent: self, x: 1320, y: 950, w: 100, h: 70)
        resourceDisplay = ResourcesManagement(parent: self, x: 1320, y: 860, w: 100, h: 70, initialValue: initialMoney)
        
        shop = Shop(parent: self, x: 150, y: 0, w: 200, h: 600)
        gameTimer = GameTimer.create(rect: CGRect(x: 390, y: 610, width: 60, height: 30))
        addChild(gameTimer)
        
        
        // MARK: Level difficulty handler
        if difficultyClass < Constants.bloodRateLevel.count {
            peopleHandler.setBloodRate(newRate: CGFloat(Constants.bloodRateLevel[self.difficultyClass]))
            peopleHandler.setMoneyRate(newRate: CGFloat(Constants.moneyRateLevel[self.difficultyClass]))
        }
        else
        {
            peopleHandler.setBloodRate(newRate: 1.0)
            peopleHandler.setMoneyRate(newRate: 1.0)
        }
        
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
        
        // MARK: Notification : Boutique 🛍
        observers.append(NotificationCenter.default.addObserver(forName: .shopElementSelected, object: nil, queue: .main, using: { [weak self] (notification) in
            guard let self = self else { return }
            if notification.object != nil {
                self.showHandles()
            } else {
                self.hideHandles()
            }
        }))
        observers.append(NotificationCenter.default.addObserver(forName: .shopElementDeselected, object: nil, queue: .main, using: { [weak self] (notification) in
            guard let self = self else { return }
            self.hideHandles()
        }))
        
        
        // MARK: Notification : Timer end ⏰
        observers.append(NotificationCenter.default.addObserver(forName: .timerFinished, object: nil, queue: .main, using: { [weak self] _ in
            #warning("TODO: Level transition screen")
            self?.resetConveyors()
            self!.previousScore += self!.score!.getScore()
            self?.score?.reset()
            
            self!.difficultyClass += 1
            if self!.difficultyClass >= 5 {
                NotificationCenter.default.post(name: .gameOver, object: nil, userInfo: ["score" : self?.previousScore, "level" : self?.difficultyClass])
            }
//            self?.view?.presentScene(LaboScene.newScene(initialMoney: self!.resourceDisplay!.available(), prevScore: self!.previousScore + self!.score!.getScore(), difficulty: self!.difficultyClass+1))
        }))
        
        // MARK: Notification : Bag received blood 🩸
        observers.append(NotificationCenter.default.addObserver(forName: .bagScored, object: nil, queue: .main, using: { [weak self] (notification) in
            guard let self = self else { return }
            // adjust texture of bag -- TODO: move this in the node itself?
            if let bloodType = notification.userInfo?["BloodType"] as? BloodType {
                self.bloodLevels[bloodType, default: 0] += 1
                self.bloodLevels[bloodType, default: 0] %= 8
                self.setPercentage(of: bloodType, to: CGFloat(self.bloodLevels[bloodType]!) * 13)
                
                if self.bloodLevels[bloodType, default: 0] == 0 {
                    #warning("TODO: Dindon ou pas dindon ?")
                    self.run(SKAction.playSoundFileNamed("dindon", waitForCompletion: false))
                }
            }
        }))
        
        // MARK: Notification : Gives Money 💰
        observers.append(NotificationCenter.default.addObserver(forName: .givesMoney, object: nil, queue: .main) { [weak moneyEmitter] (notification) in
            moneyEmitter?.particleBirthRate += 0.5
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(500))) { [weak moneyEmitter] in
                moneyEmitter?.particleBirthRate -= 0.5
            }
        })
        
        // MARK: Notification : Gives Blood 🩸
        observers.append(NotificationCenter.default.addObserver(forName: .givesBlood, object: nil, queue: .main) { [weak self, weak bloodEmitter] (notification) in
            guard let self = self else { return }
            bloodEmitter?.particleBirthRate += 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(500))) { [weak bloodEmitter] in
                bloodEmitter?.particleBirthRate -= 1
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(750))) { [weak self] in
                guard let bloodType = notification.userInfo?["Type"] as? BloodType else { return }
                self?.conveyorRunners[bloodType]?.load(bloodType: bloodType)
            }
        })
        
        // MARK: Notification : Conveyor Shape Changed
        observers.append(NotificationCenter.default.addObserver(forName: .conveyorShapeDidChange, object: nil, queue: .main) { [weak self] (notification) in
            guard let self = self else { return }
            let runner = notification.object as! ConveyorRunner
            let latestSegment = runner.conveyor.segments.last!
            
            // must generate the nodes
            let configInit = self.config.first(where: { "\($0.bloodType)" == runner.name })!
            let nodes = runner.conveyor.makeSpritesForSegment(with: "\(runner.name)", havingStartedAtX: configInit.x, y: configInit.y, segment: latestSegment)
            
            self.run(SKAction.playSoundFileNamed("pause-convoyeur", waitForCompletion: false))
            
            if let rootNode = self.childNode(withName: "//conveyor-\(runner.name)") {
                nodes.forEach { rootNode.addChild($0) }
            }
        })
        
        // MARK: Notification : New Parcel Available
        observers.append(NotificationCenter.default.addObserver(forName: .newParcel, object: nil, queue: .main) { [weak self, unowned parcels] (notification) in
            guard let self = self else { return }
            let parcel = notification.object as! Parcel
            let shape = ParcelNode.newInstance(with: parcel, at: self.conveyorNodes[parcel.bloodType]!.children.first!.position)
            parcels.addChild(shape)
        })
        
        // MARK: Notification : A Parcel was Dropped
        observers.append(NotificationCenter.default.addObserver(forName: .droppedParcel, object: nil, queue: .main) { [weak self, unowned parcels] (notification) in
            guard let self = self else { return }
            let parcel = notification.object as? Parcel
            if let parcelNode = parcels.children.first(where: { ($0 as? ParcelNode)?.parcel === parcel }) as? ParcelNode {
                if self.selectedParcel === parcelNode {
                    self.selectedParcel = nil
                }
                
                // was it dropped on the letter?
                let height = self.computeDiscreteHeight(for: parcel!.bloodType)
                if height > 7 {
                    // it was!!! dropped on the letter
                    #warning("TODO – déplacer ce 7 dans la configuration de grille `maxHeight`")
                    NotificationCenter.default.post(name: .bagScored, object: nil, userInfo: ["BloodType" : parcel!.bloodType, "isAutomatic":true])
                    parcelNode.explode(success: true)
                } else {
                    // if not… fail!
                    NotificationCenter.default.post(name: .bagDropped, object: nil)
                    parcelNode.explode(success: false)
                }
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
        // deal with handles for the shop
        if let node = nodes(at: location).filter({ $0.parent?.name == "handles" }).first {
            (node as! HandleNode).action?()
            hideHandles()
        }
        
        // deal with sound-on/off
        if let node = nodes(at: location).filter({ $0.name == "soundBtn" }).first {
            let sprite = (node as! SKSpriteNode)
            let music = childNode(withName: "//music")
            
            if music != nil {
                music?.removeFromParent()
                sprite.texture = SKTexture(imageNamed: "son-off")
            } else {
                let audio = SKAudioNode(fileNamed: "piano-2.mp3")
                audio.name = "music"
                audio.autoplayLooped = true
                audio.isPositional = false
                addChild(audio)
                sprite.texture = SKTexture(imageNamed: "son-on")
            }
        }
        
        // deal with play/pause
        if let node = nodes(at: location).filter({ $0.name == "pauseBtn" }).first {
            let sprite = (node as! SKSpriteNode)
            
            if isPaused {
                isPaused = false
                sprite.texture = SKTexture(imageNamed: "pause")
            } else {
                isPaused = true
                sprite.texture = SKTexture(imageNamed: "play")
            }
        }
        
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
                
                let success = (parcel.bloodType == node.bloodType)
                if success {
                    NotificationCenter.default.post(name: .bagScored, object: nil, userInfo: ["BloodType" : node.bloodType])
                } else {
                    NotificationCenter.default.post(name: .badBag, object: nil, userInfo: ["BloodType" : node.bloodType])
                }
                
                var p = node.position
                p.x -= 100 // TODO: fix ugly hack
                
                parcelNode.removeAllActions()
                parcelNode.run(SKAction.sequence([
                    SKAction.move(to: p, duration: 1),
                    SKAction.run { [weak self] in
                        if !success {
                            self?.bloodLevels[node.bloodType, default: 0] = 0
                            self?.setPercentage(of: node.bloodType, to: 0)
                        }
                        parcelNode.explode(success: success,
                                           texture: success ? nil : SKTexture(imageNamed: "tache_b"),
                                           sound: "broken gasss")}
                ]))
            }
        }
        
        if let node = nodes(at: location).filter({ $0.parent?.name == "Shop" }).first as? ShoppingElement {
            _ = shop.select(element: node)
        }
        
        if let _ = nodes(at: location).filter({ $0.name == "easterEgg" }).first {
            self.run(SKAction.playSoundFileNamed("dindon", waitForCompletion: false))
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
        } else if (event.keyCode == kVK_ANSI_T) {
            conveyorRunners[BloodType.allCases.randomElement()!]?.append(ConveyorSegment(length: 4, orientation: .up, bloodTypeMask: .all, speed: 1))
        } else if (event.keyCode == kVK_ANSI_V) {
            toggleHandles()
        } else if (event.keyCode == kVK_ANSI_S) {
            shop.newNode()
        } else if (event.keyCode == kVK_ANSI_1) {
            setPercentage(of: .O, to: 10)
        } else if (event.keyCode == kVK_ANSI_2) {
            setPercentage(of: .O, to: 30)
        } else if (event.keyCode == kVK_ANSI_3) {
            setPercentage(of: .O, to: 60)
        } else if (event.keyCode == kVK_ANSI_4) {
            setPercentage(of: .O, to: 90)
        } else if (event.keyCode == kVK_ANSI_X) {
            resetConveyors()
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
    
    func computeDiscreteHeight(for type: BloodType) -> Int {
        return Int(locationAfterLastCell(of: type).y / CGFloat(GridConfiguration.default.itemSize.height))
    }
    
    /// Ajoute des éléments en fin des tapis/convoyeurs afin de faciliter l'ajout d'éléments
    func showHandles() {
        let placeholders = childNode(withName: "handles")!
        guard let shoppingItem = shop.selectedShoppingItem as? Tapis else {
            return
        }
        
        BloodType.allCases.forEach { bloodType in
            let currentY = computeDiscreteHeight(for: bloodType)
            let nextY = currentY + Int(shoppingItem.length)
            
            if nextY > 8 {
                return // continue
            }
            
            let loc = locationAfterLastCell(of: bloodType)
            let shape = HandleNode.newNode(for: bloodType) {
                if let errorMessage = self.shop.purchase(using: self.resourceDisplay) {
                    self.alert(errorMessage)
                } else {
                    // success
                    self.conveyorRunners[bloodType]?.append(ConveyorSegment(length: Int(shoppingItem.length), orientation: .up, bloodTypeMask: .all, speed: 1))
                }
            }
            shape.position = loc
            placeholders.addChild(shape)
        }
    }
    
    func hideHandles() {
        let placeholders = childNode(withName: "handles")!
        placeholders.removeAllChildren()
    }
    
    func toggleHandles() {
        let placeholders = childNode(withName: "handles")!
        if placeholders.children.isEmpty {
            showHandles()
        } else {
            hideHandles()
        }
    }
    
    func setPercentage(of bloodType: BloodType, to percentage: CGFloat) {
        let imageName: String
        let node = bloodBags[bloodType]!
        
        switch bloodType {
            case .O, .A:
                if percentage <= 25 {
                    imageName = "blood_gauche_25"
                } else if percentage <= 50 {
                    imageName = "blood_gauche_50"
                } else if percentage <= 75 {
                    imageName = "blood_gauche_75"
                } else {
                    imageName = "blood_gauche_100"
                }
            case .B, .AB:
                if percentage <= 25 {
                    imageName = "blood_droite_25"
                } else if percentage <= 50 {
                    imageName = "blood_droite_50"
                } else if percentage <= 75 {
                    imageName = "blood_droite_75"
                } else {
                    imageName = "blood_droite_100"
                }
        }
        
        node.texture = SKTexture(imageNamed: imageName)
    }
    
    func alert(_ message: String, for duration: TimeInterval = 2) {
        guard let alertBox = childNode(withName: "//alertbox") else {
            print("ERROR: alertbox not found")
            return
        }
        
        let label = alertBox.childNode(withName: "//label") as! SKLabelNode
        label.text = message
                
        alertBox.run(SKAction.sequence([
            .move(by: CGVector(dx: 0, dy: alertBox.frame.height), duration: 1),
            .wait(forDuration: duration),
            .move(by: CGVector(dx: 0, dy: -alertBox.frame.height), duration: 1),
        ]))
    }
}
