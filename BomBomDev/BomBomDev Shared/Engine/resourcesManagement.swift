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
    private var moneyCount: Int
    
    init(parent: SKNode, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        moneyCount = 0
        moneyLabel = SKLabelNode(text: "0")
        moneyLabel.fontName = Constants.fontName
        moneyLabel.fontSize = Constants.fontSize
        moneyLabel.fontColor = .black
        moneyLabel.horizontalAlignmentMode = .left
        moneyLabel.position = CGPoint(x:w, y:0)
        baseNode = SKShapeNode(rect: CGRect(x:0.0, y:0.0, width:w, height:h))
        baseNode.position = CGPoint(x:x-100, y:y)
        baseNode.lineWidth = 0
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
