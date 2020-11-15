//
//  GameTimer.swift
//  BomBomDev
//
//  Created by Aurélien VALADE on 15/11/2020.
//

import SpriteKit

class GameTimer : SKShapeNode {
    
    private var duration : Int = 0
    private var label: SKLabelNode!
    
    class func create(rect: CGRect) -> GameTimer {
        let timer = GameTimer(rectOf: rect.size)
        timer.fillColor = .white
        timer.strokeColor = .clear
        
        timer.duration = Constants.timerStartValue
        
        timer.label = SKLabelNode(text: "\(timer.duration)")
        timer.label?.fontName = Constants.timerFont
        timer.label?.fontSize = Constants.timerSize
        timer.label?.fontColor = Constants.bleuChloe
        timer.label.verticalAlignmentMode = .center
        
        timer.label?.position = CGPoint(x:0, y:0)
        timer.addChild(timer.label!)
        
        timer.position=rect.origin
        
        timer.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 1),
                                                            SKAction.run{ timer.updateTimer() } ])))
        
        return timer
    }
    
    func updateTimer () {
        self.duration -= 1
        self.label?.text = "\(duration)"
        if duration == 0 {
            NotificationCenter.default.post(name: .timerFinished, object: nil)
            removeAllActions()
        }
    }
    
}

extension Notification.Name {
    static let timerFinished = Notification.Name("GameTimerFinished")
}
