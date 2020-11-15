//
//  Score.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 15/11/2020.
//

import SpriteKit

class Score {
    private var score: Int {
        didSet {
            // update the display
            self.scoreLabel.text = "\(self.score)"
            
            // if the score falls bellow this limit => Game Over
            if score <= configuration.gameOverLimit {
                // Causes the GameViewController to display the end game title
                NotificationCenter.default.post(name: .gameOver, object: self)
            }
        }
    }
    
    private let scoreLabel: SKLabelNode
    private let baseNode: SKShapeNode
    
    private var configuration = ScoreConfiguration.default
    
    struct ScoreConfiguration /*TODO: Codable*/ {
        static let `default` = ScoreConfiguration()
        
        var bagScoredByHand: [BloodType:Int] = [.A: 100, .B: 100, .AB: 50, .O: 200]
        var bagDropped: Int = -200
        var badBag: Int = -200
        
        /// Whenever the score reaches this lower boung => Game Over
        var gameOverLimit = -1000
    }
    
    var observers: [Any] = []
    
    init(parent: SKNode, x: CGFloat, y:CGFloat, w:CGFloat, h:CGFloat) {
        score = 0
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = Constants.fontName
        scoreLabel.fontSize = Constants.fontSize
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x:w, y:0)
        
        baseNode = SKShapeNode(rect: CGRect(x:0.0, y:0.0, width:w, height:h))
        baseNode.position = CGPoint(x:x-100, y:y)
        baseNode.lineWidth = 0
        baseNode.addChild(scoreLabel)
        
        parent.addChild(baseNode)
        
        observers.append(NotificationCenter.default.addObserver(forName: .bagScored, object: nil, queue: .main) { [weak self] (notification) in
            guard let self = self else { return }
            guard let type = notification.userInfo?["BloodType"] as? BloodType else {
                print("Error getting blood type")
                return }
            
            self.score += self.configuration.bagScoredByHand[type] ?? 0
        })
        
        observers.append(NotificationCenter.default.addObserver(forName: .bagDropped, object: nil, queue: .main) { [weak self] (notification) in
            guard let self = self else { return }
            self.score += self.configuration.bagDropped
        })
        
        observers.append(NotificationCenter.default.addObserver(forName: .badBag, object: nil, queue: .main) { [weak self] (notification) in
            guard let self = self else { return }
            self.score += self.configuration.badBag
        })
    }
}

extension Notification.Name {
    static let bagDropped = Notification.Name(rawValue: "BagDropped")
    static let bagScored = Notification.Name(rawValue: "BagScored")
    static let badBag = Notification.Name(rawValue: "BadBag")
    static let gameOver = Notification.Name(rawValue: "GameOver")
}
