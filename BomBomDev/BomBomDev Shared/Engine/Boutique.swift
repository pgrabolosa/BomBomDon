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

protocol ShoppingElement : SKNode {
    func getPrice() -> CGFloat
}

class Tapis : SKNode, ShoppingElement {
    private let direction : Direction
    var length : UInt
        
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
        image.zPosition = 0
        labelNode.zPosition = 1
        super.init()
        addChild(image)
        addChild(labelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getDirection() -> Direction {
        return direction
    }
    
    func getNode() -> SKNode {
        return self
    }
    
    func getPrice() -> CGFloat {
        #warning("TODO: Price depends on length?")
        return 50.0 * (0.5 + CGFloat(length)*0.5)
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
    var selectedShoppingItem: ShoppingElement? = nil {
        didSet {
            if selectedShoppingItem == nil {
                NotificationCenter.default.post(name: .shopElementDeselected, object: oldValue)
            } else {
                NotificationCenter.default.post(name: .shopElementSelected, object: selectedShoppingItem)
            }
        }
    }
    
    private let baseNode : SKShapeNode
    private var elements : [ShoppingElement]
    private let height : CGFloat
    
    init(parent: SKNode, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        baseNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: w, height: h))
        baseNode.lineWidth = 0
        baseNode.name = "Shop"
        elements = []
        height = h
        baseNode.position = CGPoint(x: x, y: y)
        parent.addChild(baseNode)
    }
    
    func updateDiplay() {
        self.baseNode.removeAllChildren()
        
        for (index, child) in self.elements.enumerated() {
            child.position = CGPoint(x: 0, y: (self.height/3) * (CGFloat(index) + 0.5))
            self.baseNode.addChild(child)
        }
    }
    
    func newNode() {
        if elements.count == 3 {
            // purge
            elements.removeAll()
            baseNode.removeAllChildren()
        }
        
        guard let elt = ShoppingProduct.allCases.randomElement() else { return }
        let node = elt.asElement()
        
        let priceTag = SKLabelNode(text: "\(Int(node.getPrice()))")
        priceTag.fontName = Constants.fontName
        priceTag.fontSize = Constants.fontSize * 0.8
        priceTag.fontColor = Constants.bleuChloe
        priceTag.position = CGPoint(x: baseNode.frame.size.width*0.23, y: -height*0.08)
        node.addChild(priceTag)
        
        elements.append(node)
        updateDiplay()
    }
    
    func select(element: ShoppingElement) -> Bool {
        if selectedShoppingItem === element {
            print("Deselecting")
            selectedShoppingItem?.childNode(withName: "background")?.removeFromParent()
            selectedShoppingItem = nil
            return false
        }
        else {
            for el in elements {
                el.childNode(withName: "background")?.removeFromParent()
            }
            print("Selecting")
            selectedShoppingItem = element
            let background = SKShapeNode(circleOfRadius: 50)
            background.name = "background"
            background.strokeColor = Constants.bleuChloe
            background.lineWidth = 3
            background.glowWidth = 2
            background.zPosition = 5
            element.addChild(background)
            return true
        }
    }
    
    /// Confirme la volonté d'acheter l'élément sélectionné
    func purchase(using resource: ResourcesManagement? = nil) -> String? {
        guard let selectedShoppingItem = selectedShoppingItem else {
            return nil // ignore, as nothing is selected
        }
        
        defer {
            _ = self.select(element: selectedShoppingItem)
        }
        
        guard CGFloat(resource?.available() ?? 0) >= selectedShoppingItem.getPrice() else {
            return "Fonds Insuffisants"
        }
        _ = resource?.withdraw(amount: Int(selectedShoppingItem.getPrice()))
        
        selectedShoppingItem.removeFromParent()
        self.selectedShoppingItem = nil

        // remove it all
        self.elements.removeAll()
        self.baseNode.removeAllChildren()
        
        return nil
    }
}

extension Notification.Name {
    static let shopElementSelected = Notification.Name.init("ShopElementSelected")
    static let shopElementDeselected = Notification.Name.init("ShopElementDeselected")
}
