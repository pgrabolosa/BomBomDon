//
//  PepolesPopper.swift
//  BomBomDev
//
//  Created by Aurélien VALADE on 13/11/2020.
//

import SpriteKit


class PeoplePopper : SKScene {
    private var peopleHandler : PeopleHandler?
    
    class func newScene() -> PeoplePopper {
        guard let scene = SKScene(fileNamed: "PeoplePopper") as? PeoplePopper else {
            fatalError("Failed to find PeoplePopper")
        }
        scene.scaleMode = .aspectFit
        scene.peopleHandler = PeopleHandler(parent: scene, x: 700, w: 200)
        
        
        return scene
    }
    
    override func didMove(to view: SKView) {
       
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

class PeopleHandler {
    private let masterNode: SKShapeNode
    private var people : [Person] = []
    private var popper : SKAction?
    private var personRemover : Any?
    
    init(parent: SKScene, x: CGFloat, w: CGFloat) {
        masterNode = SKShapeNode(rect: CGRect(x: 0, y: parent.frame.minY, width: w, height: parent.size.height))
        masterNode.lineWidth = 0
        masterNode.fillColor = .gray
        masterNode.position.x = x - (w/2)
     
        personRemover = NotificationCenter.default.addObserver(forName: .personAsksToBeRemoved, object: nil, queue: .main) { (notification) in
            if let person = self.people.firstIndex(where: { (person) -> Bool in
                return person === notification.object as? Person
            })
            {
                self.people.remove(at: person)
            }
        }
       
        popper = SKAction.repeatForever(SKAction.sequence([
            SKAction.run {
                self.people.append(Person(parent: self.masterNode, sideWalkWidth: w))
            },
            SKAction.wait(forDuration: 1, withRange: 3)
        ]))
        
        masterNode.run(popper!)
        
        parent.addChild(masterNode)
    }
    
    
}


class Person {
    
    let bloodType : BloodType
    let sprite : SKSpriteNode
    let gender = [Gender.male, Gender.female].randomElement()!
    let activity : Activity
    
    init(parent: SKNode, sideWalkWidth : CGFloat) {
        let height = parent.frame.maxY
        let x = CGFloat.random(in: -0...sideWalkWidth)
        let speed = Double.random(in: 3...8)
        
        activity = Activity.random()
        
        sprite = SKSpriteNode(texture: gender.sprite)
        sprite.position = CGPoint(x:x, y:height)
        
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.frame.size)
        sprite.physicsBody?.allowsRotation = false
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -Double.random(in: 150...300))
        
        bloodType = BloodType.allCases.randomElement()!
        sprite.run(SKAction.repeatForever(SKAction.animate(with:gender.walkingSprites, timePerFrame: 0.2)))
//        sprite.run(SKAction.sequence([SKAction.move(to: CGPoint(x:x, y:parent.frame.minY), duration: speed),
//                                      SKAction.run{
//                                        self.sprite.removeFromParent()
//                                        NotificationCenter.default.post(name: .personAsksToBeRemoved, object: self)
//                                      }]))
        parent.addChild(self.sprite)
    }
    
    func givesBlood()
    {
        
    }
}


extension Notification.Name {
    static let personAsksToBeRemoved = Notification.Name("PersonAsksToBeRemoved")
}
