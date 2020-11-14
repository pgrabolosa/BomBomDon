//
//  Conveyor+SpriteKit.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

struct GridConfiguration {
    let itemsWidth = 15
    let itemsHeight = 6
    
    let itemSize = CGSize(width: 100, height: 100)
    var size: CGSize {
        CGSize(width: CGFloat(itemsWidth) * itemSize.width,
               height: CGFloat(itemsHeight) * itemSize.height)
    }
    
    func pointFor(x: Int, y: Int) -> CGPoint {
        return CGPoint(x: CGFloat(x)*itemSize.width, y: CGFloat(y)*itemSize.height)
    }
    
    static let `default` = GridConfiguration()
}

extension Conveyor {
    static let defaultTexture = SKTexture(imageNamed: "conveyor_left")
    
    static let horizontalTexture = SKTexture(imageNamed: "tapis-h")
    static let verticalTexture = SKTexture(imageNamed: "tapis-v")
    static let bentTexture = SKTexture(imageNamed: "tapis-c")
    
    func makeCell(prefix: String, i:Int, x:Int, y:Int, orientation:Orientation, bendIt: Bool) -> SKNode {
        var texture: SKTexture
        switch orientation {
            case .up, .down:
                texture = Conveyor.verticalTexture
            case .left, .right:
                texture = Conveyor.horizontalTexture
        }
        if bendIt { texture = Conveyor.bentTexture }
        
        let gridConfiguration = GridConfiguration.default // TODO: move into args
        let spriteNode = SKSpriteNode(texture: texture, size: gridConfiguration.itemSize)
        spriteNode.name = "\(prefix)-\(i)"
        
        spriteNode.position.x = (CGFloat(x) + 0.5) * spriteNode.frame.width
        spriteNode.position.y = (CGFloat(y) + 0.5) * spriteNode.frame.height
        
        return spriteNode
    }
    
    func makeSprites(with prefix: String, startingAtX x: Int, y: Int) -> SKNode {
        // build the scene grid
        let gridNode = SKNode()
        
        // color
        var loc = (x: x, y: y)
        var cellIndex = 0
        
        var previousOrientation: Orientation? = nil
        
        for segment in segments {
            let orientation = segment.orientation.integerOffset
            
            let changeInDir = previousOrientation != nil && previousOrientation != segment.orientation
            
            for i in 0..<segment.length {
                gridNode.addChild(makeCell(prefix: prefix, i: cellIndex, x: loc.x, y: loc.y, orientation: segment.orientation, bendIt: i == 0 && changeInDir))
                
                cellIndex += 1
                loc.x += orientation.dx
                loc.y += orientation.dy
            }
            
            previousOrientation = segment.orientation
        }
        
        return gridNode
    }
    
    func makeSpritesForSegment(with prefix: String, havingStartedAtX x: Int, y: Int, segment: ConveyorSegment) -> [SKNode] {
        var loc: (x:Int, y:Int) = (x,y)
        for segment in segments.dropLast() {
            loc.x += segment.length * segment.orientation.integerOffset.dx
            loc.y += segment.length * segment.orientation.integerOffset.dy
        }
        
        let bendIt = segments.dropLast().last?.orientation != segment.orientation
        
        var cellIndex = segments.reduce(0) { $0 + $1.length }
        
        // build the nodes
        var nodes = [SKNode]()
        (0..<segment.length).forEach { i in
            nodes.append(makeCell(prefix: prefix, i: cellIndex, x: loc.x, y: loc.y, orientation: segment.orientation, bendIt: i == 0 && bendIt))
            
            cellIndex += 1
            loc.x += segment.orientation.integerOffset.dx
            loc.y += segment.orientation.integerOffset.dy
        }
        
        return nodes
    }
}
