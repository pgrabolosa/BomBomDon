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
    
    func makeSprites(with prefix: String, startingAtX x: Int, y: Int) -> SKNode {
        let gridConfiguration = GridConfiguration.default // TODO: move into args
        
        let makeCell = {(i:Int, x:Int, y:Int, orientation:Orientation) -> SKNode in            
            let spriteNode = SKSpriteNode(texture: Conveyor.defaultTexture, size: gridConfiguration.itemSize)
            spriteNode.name = "\(prefix)-\(i)"
            spriteNode.zRotation = orientation.rotation
            
            spriteNode.position.x = (CGFloat(x) + 0.5) * spriteNode.frame.width
            spriteNode.position.y = (CGFloat(y) + 0.5) * spriteNode.frame.height
            
            return spriteNode
        }
        
        // build the scene grid
        let gridNode = SKNode()
        
        // color
        var loc = (x: x, y: y)
        var cellIndex = 0
        
        for segment in segments {
            let orientation = segment.orientation.integerOffset
            
            for _ in 0..<segment.length {
                gridNode.addChild(makeCell(cellIndex, loc.x, loc.y, segment.orientation))
                
                cellIndex += 1
                loc.x += orientation.dx
                loc.y += orientation.dy
            }
        }
        
        return gridNode
    }
    
    func makeSpritesForSegment(with prefix: String, havingStartedAtX x: Int, y: Int, segment: ConveyorSegment) -> [SKNode] {
        let gridConfiguration = GridConfiguration.default // TODO: move into args
        
        var loc: (x:Int, y:Int) = (x,y)
        for segment in segments.dropLast() {
            loc.x += segment.length * segment.orientation.integerOffset.dx
            loc.y += segment.length * segment.orientation.integerOffset.dy
        }
        //loc.x += segments.dropLast().last?.orientation.integerOffset.dx ?? 0
        //loc.y += segments.dropLast().last?.orientation.integerOffset.dy ?? 0
        
        var cellIndex = segments.reduce(0) { $0 + $1.length }
        
        let makeCell = {(i:Int, x:Int, y:Int, orientation:Orientation) -> SKNode in
            let spriteNode = SKSpriteNode(texture: Conveyor.defaultTexture, size: gridConfiguration.itemSize)
            spriteNode.name = "\(prefix)-\(i)"
            spriteNode.zRotation = orientation.rotation
            
            spriteNode.position.x = (CGFloat(x) + 0.5) * spriteNode.frame.width
            spriteNode.position.y = (CGFloat(y) + 0.5) * spriteNode.frame.height
            
            return spriteNode
        }
        
        // build the nodes
        var nodes = [SKNode]()
        (0..<segment.length).forEach { _ in
            nodes.append(makeCell(cellIndex, loc.x, loc.y, segment.orientation))
            
            cellIndex += 1
            loc.x += segment.orientation.integerOffset.dx
            loc.y += segment.orientation.integerOffset.dy
        }
        
        return nodes
    }
}
