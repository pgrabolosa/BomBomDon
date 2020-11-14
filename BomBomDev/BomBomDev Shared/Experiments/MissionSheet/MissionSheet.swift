//
//  MissionSheet.swift
//  BomBomDev
//
//  Created by Aurélien VALADE on 14/11/2020.
//

import SpriteKit

class MissionSheet: SKScene {
    class func newScene(number: Int) -> MissionSheet {
        guard let scene = SKScene(fileNamed: "MissionSheet") as? MissionSheet else {
            fatalError("Failed to find MissionSheet")
        }
        scene.scaleMode = .aspectFit
        let titleLabel = scene.childNode(withName: "//MissionTitle") as? SKLabelNode
        let descLabel = scene.childNode(withName: "//MissionDescription") as? SKLabelNode
       
        titleLabel?.text = Bundle.main.localizedString(forKey: "MissionTitle\(number)", value: nil, table: "Texts")
        descLabel?.text = Bundle.main.localizedString(forKey: "MissionDescription\(number)", value: nil, table: "Texts")
        
        return scene
    }
}
