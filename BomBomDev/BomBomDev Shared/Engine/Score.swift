//
//  Score.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 15/11/2020.
//

import SpriteKit

class Score {
    private var score: Int {
        didSet { self.scoreLabel.text = "\(self.score)" }
    }
    
    private let scoreLabel: SKLabelNode
    private let scoreSprite: SKSpriteNode
    private let baseNode: SKShapeNode
    
    private var configuration = ScoreConfiguration.default
    
    struct ScoreConfiguration /*TODO: Codable*/ {
        static let `default` = ScoreConfiguration()
        
        var bagScoredByHand: [BloodType:Int] = [.A: 100, .B: 100, .AB: 50, .O: 200]
        var bagDropped: Int = -200
        var badBag: Int = -200
    }
    
    init(parent: SKNode, x: CGFloat, y:CGFloat, w:CGFloat, h:CGFloat) {
        score = 0
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = "Noteworthy-Bold"
        scoreLabel.fontSize = 38
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
        
        parent.addChild(baseNode)
        
        NotificationCenter.default.addObserver(forName: .bagScored, object: nil, queue: .main) { (notification) in
            guard let type = notification.userInfo?["BloodType"] as? BloodType else {
                print("Error getting blood type")
                return }
            
            self.score += self.configuration.bagScoredByHand[type] ?? 0
        }
        
        NotificationCenter.default.addObserver(forName: .bagDropped, object: nil, queue: .main) { (notification) in
            self.score += self.configuration.bagDropped
        }
        
        NotificationCenter.default.addObserver(forName: .badBag, object: nil, queue: .main) { (notification) in
            self.score += self.configuration.badBag
        }
    }
}

extension Notification.Name {
    static let bagDropped = Notification.Name(rawValue: "BagDropped")
    static let bagScored = Notification.Name(rawValue: "BagScored")
    static let badBag = Notification.Name(rawValue: "BadBag")
}
