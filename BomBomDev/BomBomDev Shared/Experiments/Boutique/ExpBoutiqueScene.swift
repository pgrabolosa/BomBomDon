//
//  ExpBoutiqueScene.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 13/11/2020.
//

import SpriteKit
import GameplayKit

class Boutique {
    
    var items: [String] = []
    
    func append(_ item: String) {
        items.append(item)
        NotificationCenter.default.post(name: .BoutiqueNewItem, object: self, userInfo: ["item": item])
    }
    
}

extension Notification.Name {
    static let BoutiqueNewItem = Notification.Name("BoutiqueNewItem")
}


class ExpBoutiqueScene : SKScene {
    
    let boutique = Boutique()
    
    var drawerSprite: SKShapeNode!
    
    class func newScene() -> ExpBoutiqueScene {
        guard let scene = SKScene(fileNamed: "ExpBoutiqueScene") as? ExpBoutiqueScene else {
            fatalError("Failed to find ExpBoutiqueScene")
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    override func didMove(to view: SKView) {
        // initial setup
        
        drawerSprite = SKShapeNode(rectOf: CGSize(width: 200, height: self.frame.height - 50))
        drawerSprite.fillColor = .clear
        drawerSprite.strokeColor = .black
        
        addChild(drawerSprite)
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.boutique.append("Test \(1 + self.boutique.items.count)")
        }
        
        NotificationCenter.default.addObserver(forName: .BoutiqueNewItem, object: nil, queue: .main) { (notification) in
            let item = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
            item.fillColor = .red
            self.drawerSprite.addChild(item)
            
            // reorder items
            var position = CGPoint.zero
            position.y = -CGFloat(self.boutique.items.count * 50 + (self.boutique.items.count-1) * 20)/2
            for child in self.drawerSprite.children {
                child.position = position
                position.y += 50 + 20
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
}
