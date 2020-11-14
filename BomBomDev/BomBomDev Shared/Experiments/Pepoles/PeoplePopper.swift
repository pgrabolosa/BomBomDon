//
//  PepolesPopper.swift
//  BomBomDev
//
//  Created by Aurélien VALADE on 13/11/2020.
//

import SpriteKit

class PeoplePopper : SKScene {
    
    var people : [Person] = []
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


class Person {
    
    let bloodType : BloodType
    let sprite : SKSpriteNode
    let gender = [Gender.male, Gender.female].randomElement()!
    
    init(parent: SKScene) {
        let height = parent.frame.maxY
        let x = CGFloat.random(in: -100...100)
        
        sprite = SKSpriteNode(texture: gender.sprite)
        sprite.position = CGPoint(x:x, y:height)
                
        bloodType = BloodType.allCases.randomElement()!
        sprite.run(SKAction.repeatForever(SKAction.animate(with:gender.walkingSprites, timePerFrame: 0.2)))
        sprite.run(SKAction.sequence([SKAction.move(to: CGPoint(x:x, y:parent.frame.minY), duration: 5),
                                      SKAction.run{
                                        self.sprite.removeFromParent()
                                        if let scn = self.sprite.scene as? PeoplePopper {
                                            if let index = scn.people.firstIndex(where:{ $0 === self }) {
                                                scn.people.remove(at: index)
                                            }
                                        }
                                      }]))
        parent.addChild(self.sprite)
    }
}
