//
//  GameViewController.swift
//  BomBomDev iOS
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var gameOverObservation: Any? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SplashScreenScene.newScene()

        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        //skView.ignoresSiblingOrder = true
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        
        gameOverObservation = NotificationCenter.default.addObserver(forName: .gameOver, object: nil, queue: .main) { [unowned skView] _ in
            skView.presentScene(GameOverScene.newScene(score: 0))
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
