//
//  Boutique.swift
//  BomBomDev
//
//  Created by Aurélien VALADE on 14/11/2020.
//

import SpriteKit

enum Direction : CaseIterable{
    case up, left, right
}

protocol ShoppingElement {
    func getNode() -> SKNode
}

class Tapis : ShoppingElement {
    private let direction : Direction
    private let length : UInt
    private let node : SKNode
    
    init(direction: Direction, length: UInt) {
        self.direction = direction
        self.length = length
        
        let image = SKSpriteNode(imageNamed: "tapis-v")
        switch direction {
        case .up:
            image.zRotation = 0
        case .left:
            image.zRotation = CGFloat.pi / 2
        case .right:
            image.zRotation = -CGFloat.pi / 2
        }
        let labelNode = SKLabelNode(text: "\(length)")
        labelNode.fontSize = Constants.fontSize
        labelNode.fontName = Constants.fontName
        labelNode.fontColor = .red
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        self.node = SKNode()
        image.zPosition = 0
        labelNode.zPosition = 1
        self.node.addChild(image)
        self.node.addChild(labelNode)
    }
    
    func getDirection() -> Direction {
        return direction
    }
    
    func getNode() -> SKNode {
        return node
    }
}

enum ShoppingProduct: CaseIterable{
    //TODO
    case tapisL1
    case tapisL2
    case tapisL3
    case tapisU1
    case tapisU2
    case tapisU3
    case tapisR1
    case tapisR2
    case tapisR3
}

extension ShoppingProduct {
    func asElement() -> ShoppingElement {
        switch self {
        case .tapisL1:
            return Tapis(direction: .left, length: 1)
        case .tapisL2:
            return Tapis(direction: .left, length: 2)
        case .tapisL3:
            return Tapis(direction: .left, length: 3)
        case .tapisU1:
            return Tapis(direction: .up, length: 1)
        case .tapisU2:
            return Tapis(direction: .up, length: 2)
        case .tapisU3:
            return Tapis(direction: .up, length: 3)
        case .tapisR1:
            return Tapis(direction: .right, length: 1)
        case .tapisR2:
            return Tapis(direction: .right, length: 2)
        case .tapisR3:
            return Tapis(direction: .right, length: 3)
        }
    }
}


class Shop {
    /// L'élément de la boutique sélectionné (TODO: pour Aurélien)
    var selectedShoppingItem: ShoppingProduct? = nil
    private let baseNode : SKShapeNode
    private var elements : [ShoppingProduct]
    private let height : CGFloat
    
    init(parent: SKNode, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        baseNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: w, height: h))
        baseNode.lineWidth = 0
        elements = []
        height = h
        baseNode.position = CGPoint(x: x, y: y)
        parent.addChild(baseNode)
    }
    
    func updateDiplay() {
        self.baseNode.removeAllChildren()
        
        for (index, child) in self.elements.enumerated() {
            let node = child.asElement().getNode()
            node.position = CGPoint(x: 0, y: (self.height/3) * (CGFloat(index) + 0.5))
            self.baseNode.addChild(node)
        }
    }
    
    func newNode() {
        guard let elt = ShoppingProduct.allCases.randomElement() else { return }
        elements.append(elt)
        updateDiplay()
    }
    
    /// Confirme la volonté d'acheter l'élément sélectionné
    func purchase() {  }
}

extension Notification.Name {
    static let shopElementSelected = Notification.Name.init("ShopElementSelected")
    static let shopElementDeselected = Notification.Name.init("ShopElementDeselected")
}
