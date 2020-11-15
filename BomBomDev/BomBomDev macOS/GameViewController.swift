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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SplashScreenScene.newScene()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        //skView.ignoresSiblingOrder = true // optimisation
        
        skView.showsFPS = false
        skView.showsNodeCount = false
    }

}

