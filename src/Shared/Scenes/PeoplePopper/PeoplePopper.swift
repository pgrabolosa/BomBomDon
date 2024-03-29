//
//  PepolesPopper.swift
//  BomBomDev
//
//  Created by Aurélien VALADE on 13/11/2020.
//

import SpriteKit


class PeoplePopper : SKScene {
    private var peopleHandler : PeopleHandler?
    private var score: ResourcesManagement?
    private var scoreDisplay : Score?
    private var boutique : Shop?
    
    class func newScene() -> PeoplePopper {
        guard let scene = SKScene(fileNamed: "PeoplePopper") as? PeoplePopper else {
            fatalError("Failed to find PeoplePopper")
        }
        scene.scaleMode = .aspectFit
        scene.peopleHandler = PeopleHandler(parent: scene, x: 700, w: 200)
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        score = ResourcesManagement(parent: self, x: self.frame.minX, y: frame.maxY - 100, w: 200, h: 100)
        scoreDisplay = Score(parent: self, x: self.frame.minX, y: frame.maxY-200, w: 200, h: 100)
        boutique = Shop(parent: self, x: -800, y: -500, w: 200, h: 800)
        boutique?.newNode()
        boutique?.newNode()
    }
}

struct BloodMarkers: OptionSet {
    let rawValue: UInt8
    
    static let A = BloodMarkers(rawValue: 1 << 0)
    static let B = BloodMarkers(rawValue: 1 << 1)
}

enum BloodType : CaseIterable {
    case O, A, B, AB
    
    func markers() -> BloodMarkers {
        switch self {
            case .O:
                return []
            case .A:
                return [.A]
            case .B:
                return [.B]
            case .AB:
                return [.A, .B]
        }
    }
}

extension String {
    init(_ bloodType: BloodType) {
        switch bloodType {
        case .O:
            self = "O"
        case .A:
            self = "A"
        case .B:
            self = "B"
        case .AB:
            self = "AB"
        }
    }
}

extension BloodType {
    /// Generate random activity with weighted probabilities
    /// Args:
    /// probabilities: Probabilities for blood types
    static func random(probabilities: [CGFloat]) -> BloodType {
        let probSum = probabilities.reduce(0.0) { (prev, next) -> CGFloat in
            prev+next
        }
        
        var previousLevel = CGFloat(0.0);
        
        let levels = probabilities.map { (value) -> CGFloat in
            previousLevel = value + previousLevel
            return previousLevel
        }
        
        let roll = CGFloat.random(in: 0...probSum)
        
        let index = levels.firstIndex { (level) -> Bool in
            roll <= level
        }
        
        return BloodType.allCases[index!]
    }
    
    static func random() -> BloodType {
        return BloodType.random(probabilities: [10,3,3,1])
    }
}


enum Gender {
    case male
    case female
}

extension Gender {
    private static let atlas = SKTextureAtlas(named: "people")
    
    var spritePrefix: String {
        switch self {
            case .female:
                return "fem-"
            case .male:
                return "man-"
        }
    }
    
    var sprite: SKTexture {
        return Gender.atlas.textureNamed("\(spritePrefix)00")
    }
    
    var walkingSprites: [SKTexture] {
        return Gender.atlas
            .textureNames
            .sorted()
            .filter { $0.hasPrefix(self.spritePrefix) }
            .map { Gender.atlas.textureNamed($0) }
    }
}


struct Activity: OptionSet {
    let rawValue: UInt8
    
    static let givesBlood = Activity(rawValue: 1 << 0)
    static let givesMoney = Activity(rawValue: 1 << 1)
}

extension Activity {
    /// Generate random activity with weighted probabilities
    /// Args:
    /// probBlood: Blood giving probability, between 0 and 1
    /// probMoney: Money giving probability, between 0 and 1
    static func random(probBlood: CGFloat, probMoney: CGFloat) -> Activity {
        let bloodDraw = CGFloat.random(in: 0..<1)
        let moneyDraw = CGFloat.random(in: 0..<1)
        var activity : Activity = Activity(rawValue: 0)
        
        if bloodDraw < probBlood {
            activity.insert(.givesBlood)
        }
        
        if moneyDraw < probMoney {
            activity.insert(.givesMoney)
        }
        
        return activity
    }
    
    static func random() -> Activity {
        return Activity.random(probBlood: 0.1, probMoney: 0.6)
    }
}

class PeopleHandler: ObservableObject {
    let masterNode: SKShapeNode
    private var people : [Person] = []
    private var popper : SKAction?
    private var personRemover : Any?
    
    let bloodPosition : CGPoint
    let moneyPosition : CGPoint
    @Published var bloodRate: CGFloat
    @Published var moneyRate: CGFloat
    
    init(parent: SKScene, x: CGFloat, w: CGFloat) {
        masterNode = SKShapeNode(rect: CGRect(x: 0, y: parent.frame.minY, width: w, height: parent.size.height))
        masterNode.lineWidth = 0
        masterNode.fillColor = .clear
        masterNode.position.x = x - (w/2)
        let height = parent.size.height
        
        bloodRate = 0.1
        moneyRate = 0.3
        
        bloodPosition = CGPoint(x:-300, y:0.45 * height + parent.frame.minY)
        moneyPosition = CGPoint(x:0, y: 0.113 * height + parent.frame.minY)
        
        personRemover = NotificationCenter.default.addObserver(forName: .personAsksToBeRemoved, object: nil, queue: .main) { [weak self] (notification) in
            guard let self = self else { return }
            if let person = self.people.firstIndex(where: { (person) -> Bool in
                return person === notification.object as? Person
            })
            {
                self.people.remove(at: person)
            }
        }
       
        popper = SKAction.repeatForever(SKAction.sequence([
            SKAction.run {
                self.people.append(Person(parent: self.masterNode, sideWalkWidth: w, bloodRate: self.bloodRate, moneyRate: self.moneyRate))
            },
            SKAction.wait(forDuration: 1, withRange: 3)
        ]))
        
        masterNode.run(popper!)
        
        parent.addChild(masterNode)
    }
    
    func setBloodRate(newRate: CGFloat) {
        self.bloodRate = newRate
    }
    
    func setMoneyRate(newRate: CGFloat) {
        self.moneyRate = newRate
    }
    
    func increaseBloodRate() -> CGFloat {
        self.bloodRate += 0.1
        return self.bloodRate
    }
    
    func increaseMoneyRate() -> CGFloat {
        self.moneyRate += 0.1
        return self.moneyRate
    }

}


class Person {
    
    let bloodType : BloodType
    let sprite : SKSpriteNode
    let gender = [Gender.male, Gender.female].randomElement()!
    let activity : Activity
    
    let bloodPosition : CGPoint;
    let moneyPosition : CGPoint;
    
    init(parent: SKNode, sideWalkWidth : CGFloat, bloodRate: CGFloat, moneyRate: CGFloat) {
        let height = parent.frame.maxY
        let x = CGFloat.random(in: -0...sideWalkWidth)
        var speed = Double.random(in: 3...8)
        
        bloodPosition = CGPoint(x:-300, y:0.45 * height + parent.frame.minY)
        moneyPosition = CGPoint(x:0, y: 0.13 * height + parent.frame.minY)
        
        activity = Activity.random(probBlood: bloodRate, probMoney: moneyRate)
        
        sprite = SKSpriteNode(texture: gender.sprite)
        sprite.position = CGPoint(x:x, y:height)
        sprite.setScale(1.5)
                
        bloodType = BloodType.random()
        sprite.run(SKAction.repeatForever(SKAction.animate(with:gender.walkingSprites, timePerFrame: 0.2)), withKey: "walking")
        
        var trajectoir : [SKAction] = []
        
        if activity.contains(.givesBlood) {
            trajectoir.append(SKAction.move(to: CGPoint(x:x, y:bloodPosition.y), duration: speed*0.8))
            trajectoir.append(SKAction.rotate(byAngle: -CGFloat.pi / 2, duration: 0.3))
            trajectoir.append(SKAction.move(to: bloodPosition, duration: 2))
            trajectoir.append(SKAction.run{
                self.sprite.removeAction(forKey: "walking")
                self.sprite.texture = self.gender.walkingSprites[0]
            })
            trajectoir.append(SKAction.wait(forDuration: 2))
            trajectoir.append(SKAction.run{
                self.sprite.run(SKAction.repeatForever(SKAction.animate(with:self.gender.walkingSprites, timePerFrame: 0.2)), withKey: "walking")
            })
            trajectoir.append(SKAction.run {
                NotificationCenter.default.post(name: .givesBlood, object: self, userInfo: ["Type" : self.bloodType])
            })
            trajectoir.append(SKAction.rotate(byAngle: -CGFloat.pi, duration: 0.3))
            trajectoir.append(SKAction.move(to: CGPoint(x:x, y:bloodPosition.y), duration: 2))
            trajectoir.append(SKAction.rotate(byAngle: -CGFloat.pi / 2, duration: 0.3))
            speed *= 0.2
        }
        
        if activity.contains(.givesMoney) {
            trajectoir.append(SKAction.move(to: CGPoint(x:x, y:moneyPosition.y), duration: speed*0.9))
            trajectoir.append(SKAction.rotate(byAngle: -CGFloat.pi / 2, duration: 0.3))
            trajectoir.append(SKAction.move(to: moneyPosition, duration: 0.5))
            trajectoir.append(SKAction.run{
                self.sprite.removeAction(forKey: "walking")
                self.sprite.texture = self.gender.walkingSprites[0]

            })
            trajectoir.append(SKAction.wait(forDuration: 0.2))
            trajectoir.append(SKAction.run{
                self.sprite.run(SKAction.repeatForever(SKAction.animate(with:self.gender.walkingSprites, timePerFrame: 0.2)), withKey: "walking")
            })
            trajectoir.append(SKAction.run {
                NotificationCenter.default.post(name: .givesMoney, object: self, userInfo: ["Amount" : Int.random(in: Constants.moneyRange)])
            })
            trajectoir.append(SKAction.rotate(byAngle: -CGFloat.pi, duration: 0.3))
            trajectoir.append(SKAction.move(to: CGPoint(x:x, y:moneyPosition.y), duration: 0.5))
            trajectoir.append(SKAction.rotate(byAngle: -CGFloat.pi / 2, duration: 0.3))
            speed *= 0.1
        }
        
        trajectoir.append(SKAction.move(to: CGPoint(x:x, y:parent.frame.minY), duration: speed))
        trajectoir.append(SKAction.run{
            self.sprite.removeFromParent()
            NotificationCenter.default.post(name: .personAsksToBeRemoved, object: self)
          })
        
        sprite.run(SKAction.sequence(trajectoir))
        parent.addChild(self.sprite)
    }
    
    func givesBlood()
    {
        
    }
}


extension Notification.Name {
    static let personAsksToBeRemoved = Notification.Name("PersonAsksToBeRemoved")
    static let givesBlood = Notification.Name("GivesBlood")
    static let givesMoney = Notification.Name("GivesMoney")
}
