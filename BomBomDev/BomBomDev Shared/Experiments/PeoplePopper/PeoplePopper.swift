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
    let masterNode: SKShapeNode
    private var people : [Person] = []
    private var popper : SKAction?
    private var personRemover : Any?
    
    let bloodPosition : CGPoint
    let moneyPosition : CGPoint
    
    init(parent: SKScene, x: CGFloat, w: CGFloat) {
        masterNode = SKShapeNode(rect: CGRect(x: 0, y: parent.frame.minY, width: w, height: parent.size.height))
        masterNode.lineWidth = 0
        masterNode.fillColor = .gray
        masterNode.position.x = x - (w/2)
        let height = parent.size.height
        
        bloodPosition = CGPoint(x:-100, y:0.4 * height + parent.frame.minY)
        moneyPosition = CGPoint(x:0, y: 0.1 * height + parent.frame.minY)
        
        personRemover = NotificationCenter.default.addObserver(forName: .personAsksToBeRemoved, object: nil, queue: .main) { (notification) in
            if let person = self.people.firstIndex(where: { (person) -> Bool in
                return person === notification.object as? Person
            })
            {
                self.people.remove(at: person)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .givesBlood, object: nil, queue: .main) { (notification) in
            guard let type = notification.userInfo?["Type"] else { return }
            let label = SKLabelNode(text: "\(type)")
            label.fontSize = 36
            label.fontColor = .red
            label.fontName = "Noteworthy-Bold"
            self.masterNode.addChild(label)
            
            label.position = self.bloodPosition
            
            let duration = Double.random(in: 1...2)
            
            label.run(SKAction.sequence([SKAction.move(by: CGVector(dx:0, dy: 300), duration: duration),
                                         SKAction.run({
                                            label.removeFromParent()
                                         })]))
            label.run(SKAction.sequence([SKAction.wait(forDuration: duration * 0.7),
            SKAction.fadeOut(withDuration: duration * 0.3),]))
        }
        
        NotificationCenter.default.addObserver(forName: .givesMoney, object: nil, queue: .main) { (notification) in
            guard let amount = notification.userInfo?["Amount"] else { return }
            let label = SKLabelNode(text: "\(amount)")
            label.fontSize = 36
            label.fontColor = .green
            label.fontName = "Noteworthy-Bold"
            self.masterNode.addChild(label)
            
            label.position = self.moneyPosition
            
            let duration = Double.random(in: 1...2)
            
            label.run(SKAction.sequence([SKAction.move(by: CGVector(dx:0, dy: 300), duration: duration),
                                         SKAction.run({
                                            label.removeFromParent()
                                         })]))
            label.run(SKAction.sequence([SKAction.wait(forDuration: duration * 0.7),
            SKAction.fadeOut(withDuration: duration * 0.3),]))
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
    
    let bloodPosition : CGPoint;
    let moneyPosition : CGPoint;
    
    init(parent: SKNode, sideWalkWidth : CGFloat) {
        let height = parent.frame.maxY
        let x = CGFloat.random(in: -0...sideWalkWidth)
        var speed = Double.random(in: 3...8)
        
        bloodPosition = CGPoint(x:-100, y:0.4 * height + parent.frame.minY)
        moneyPosition = CGPoint(x:0, y: 0.1 * height + parent.frame.minY)
        
        activity = Activity.random()
        
        sprite = SKSpriteNode(texture: gender.sprite)
        sprite.position = CGPoint(x:x, y:height)
                
        bloodType = BloodType.allCases.randomElement()!
        sprite.run(SKAction.repeatForever(SKAction.animate(with:gender.walkingSprites, timePerFrame: 0.2)), withKey: "walking")
        
        var trajectoir : [SKAction] = []
        
        if activity.contains(.givesBlood) {
            trajectoir.append(SKAction.move(to: CGPoint(x:x, y:bloodPosition.y), duration: speed*0.8))
            trajectoir.append(SKAction.rotate(byAngle: -CGFloat.pi / 2, duration: 0.3))
            trajectoir.append(SKAction.move(to: bloodPosition, duration: 1))
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
            trajectoir.append(SKAction.move(to: CGPoint(x:x, y:bloodPosition.y), duration: 1))
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
                NotificationCenter.default.post(name: .givesMoney, object: self, userInfo: ["Amount" : Int.random(in: 1...10)])
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
