//
//  resourcesManagement.swift
//  BomBomDev
//
//  Created by Aurélien VALADE on 14/11/2020.
//

import SpriteKit


class ResourcesManagement {
    private let baseNode : SKShapeNode
    private let moneyLabel: SKLabelNode
    private let moneySprite: SKSpriteNode
    private var moneyCount: Int
    
    init(parent: SKNode, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        moneyCount = 0
        moneyLabel = SKLabelNode(text: "0")
        moneyLabel.fontName = Constants.fontName
        moneyLabel.fontSize = Constants.fontSize
        moneyLabel.fontColor = .black
        moneyLabel.horizontalAlignmentMode = .right
        moneyLabel.position = CGPoint(x:w, y:0)
        moneySprite = SKSpriteNode(imageNamed: "money")
        moneySprite.position = CGPoint(x: h/2, y: 38 / 2)
        moneySprite.scale(to: CGSize(width: h/2, height: h/2))
        baseNode = SKShapeNode(rect: CGRect(x:0.0, y:0.0, width:w, height:h))
        baseNode.position = CGPoint(x:x, y:y)
        baseNode.lineWidth = 0
        baseNode.addChild(moneySprite)
        baseNode.addChild(moneyLabel)
        
        NotificationCenter.default.addObserver(forName: .givesMoney, object: nil, queue: .main) { (notification) in
            guard let amount = notification.userInfo?["Amount"] as? Int else { return }
            
            self.moneyCount += amount
            self.moneyLabel.text = "\(self.moneyCount)"
        }
        parent.addChild(baseNode)
    }
    
    
    func withdraw(amount: Int) -> Bool {
        if amount>moneyCount {
            return false
        } else {
            moneyCount -= amount
            return true
        }
    }
    
    func available() -> Int {
        return moneyCount
    }
}

class Score {
    private var score: Int
    private let scoreLabel: SKLabelNode
    private let scoreSprite: SKSpriteNode
    private let baseNode: SKShapeNode
    
    init(parent: SKNode, x: CGFloat, y:CGFloat, w:CGFloat, h:CGFloat) {
        score = 0
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = Constants.fontName
        scoreLabel.fontSize = Constants.fontSize
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x:w, y:0)
        
        scoreSprite = SKSpriteNode(imageNamed: "heart")
        scoreSprite.position = CGPoint(x: h/2, y: 38 / 2)
        scoreSprite.scale(to: CGSize(width: h/2, height: h/2))
        baseNode = SKShapeNode(rect: CGRect(x:0.0, y:0.0, width:w, height:h))
        baseNode.position = CGPoint(x:x, y:y)
        baseNode.lineWidth = 0
        baseNode.addChild(scoreSprite)
        baseNode.addChild(scoreLabel)
        
        NotificationCenter.default.addObserver(forName: .bagScored, object: nil, queue: .main) { (notification) in
            guard let type = notification.userInfo?["BloodType"] as? BloodType else {
                print("Error getting blood type")
                return }
            
            switch type {
            case .A:
                self.score += 100
            case .B:
                self.score += 100
            case .AB:
                self.score += 50
            case .O:
                self.score += 200
            }
            
            self.scoreLabel.text = "\(self.score)"
        }
        
        NotificationCenter.default.addObserver(forName: .bagDropped, object: nil, queue: .main) { (notification) in
            self.score -= 200
            self.scoreLabel.text = "\(self.score)"
        }
        parent.addChild(baseNode)
    }
}

extension Notification.Name {
    static let bagDropped = Notification.Name(rawValue: "BagDropped")
    static let bagScored = Notification.Name(rawValue: "BagScored")
}
