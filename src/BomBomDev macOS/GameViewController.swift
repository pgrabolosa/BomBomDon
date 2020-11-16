//
//  GameViewController.swift
//  BomBomDev macOS
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    var gameOverObservation: Any? = nil
    
    var skView: SKView { self.view as! SKView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SplashScreenScene.newScene()
        
        // Present the scene
        skView.presentScene(scene)
        
        //skView.ignoresSiblingOrder = true // optimisation
        
        gameOverObservation = NotificationCenter.default.addObserver(forName: .gameOver, object: nil, queue: .main) { [weak self] (notification) in
            guard let self = self else { return }
            //self.view = SKView(frame: self.view.frame)
            let score = notification.userInfo?["score"] as? Int ?? 0
            self.skView.presentScene(GameOverScene.newScene(score: score))
        }
    }
}

