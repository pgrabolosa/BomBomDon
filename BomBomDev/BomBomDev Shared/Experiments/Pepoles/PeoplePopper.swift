//
//  PepolesPopper.swift
//  BomBomDev
//
//  Created by Aurélien VALADE on 13/11/2020.
//

import SpriteKit

class PeoplePopper : SKScene {
    
    private var people : [Person] = []
    private var timer : Timer?
    
    class func newScene() -> PeoplePopper {
        guard let scene = SKScene(fileNamed: "PeoplePopper") as? PeoplePopper else {
            fatalError("Failed to find PeoplePopper")
        }
        scene.scaleMode = .aspectFit
    
        scene.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            scene.people.append(Person(parent: scene))
        }
        return scene
    }
    
    override func didMove(to view: SKView) {
        people.append(Person(parent: self))
    }
    
}

struct BloodMarkers {
    let a : Bool
    let b : Bool
    
    init(a: Bool, b: Bool) {
        self.a = a
        self.b = b
    }
}

enum BloodType{
    case O, A, B, AB
    
    static func random<G: RandomNumberGenerator>(using generator: inout G) -> BloodType {
        let value = generator.next(upperBound: UInt16(100))
        if value < 10 {
            return .AB
        } else if value < 30 {
            return .B
        } else if value < 50 {
            return .A
        } else {
            return .O
        }
     }

     static func random() -> BloodType {
         var g = SystemRandomNumberGenerator()
         return BloodType.random(using: &g)
     }
    
    func markers() -> BloodMarkers {
        switch self {
        case .O:
            return BloodMarkers(a: false, b: false)
        case .A:
            return BloodMarkers(a: true, b: false)
        case .B:
            return BloodMarkers(a:false, b:true)
        case .AB:
            return BloodMarkers(a:true, b:true)
        }
    }
}


class Person {
    
    private let bloodType : BloodType
    private let sprite : SKSpriteNode
    
    init(parent: SKScene) {
        let height = parent.frame.maxY
        let x = CGFloat.random(in: -100...100)
        self.sprite = SKSpriteNode(imageNamed: "walking-down-0")
        self.sprite.position = CGPoint(x:x, y:height)
        self.bloodType = BloodType.random()
        let atlas = SKTextureAtlas(named: "walking")
        let frames = atlas.textureNames.map { atlas.textureNamed($0) }
        self.sprite.run(SKAction.repeatForever(SKAction.animate(with:frames, timePerFrame: 0.2)))
        self.sprite.run(SKAction.sequence([
                                            SKAction.move(to: CGPoint(x:x, y:parent.frame.minY), duration: 5),
                                            SKAction.run{
                                                self.sprite.removeFromParent()
                                            }]))
        parent.addChild(self.sprite)
    }
}
