//
//  Conveyor+SpriteKit.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import SpriteKit

extension Conveyor {
    
    func makeSprites(with prefix: String, startingAtX x: Int, y: Int) -> SKNode {
        struct GridConfiguration {
            let itemsWidth = 15
            let itemsHeight = 6
            
            let itemSize = CGSize(width: 100, height: 100)
            var size: CGSize {
                CGSize(width: CGFloat(itemsWidth) * itemSize.width,
                       height: CGFloat(itemsHeight) * itemSize.height)
            }
        }
        let gridConfiguration = GridConfiguration()
        
        let makeCell = {(x:Int, y:Int) -> SKNode in
            let shapeNode = SKShapeNode(rectOf: gridConfiguration.itemSize)
            shapeNode.fillColor = .white
            shapeNode.strokeColor = .gray
            shapeNode.name = "\(prefix)-\(x)-\(y)"
            
            shapeNode.position.x = (CGFloat(x) + 0.5) * shapeNode.frame.width
            shapeNode.position.y = (CGFloat(y) + 0.5) * shapeNode.frame.height
            
            return shapeNode
        }
        
        // build the scene grid
        let gridNode = SKNode()
        
        // color
        var loc = (x: x, y: y)
        gridNode.addChild(makeCell(x, y)) // starting point
        
        for segment in segments {
            let orientation = segment.orientation.integerOffset
            
            for _ in 0..<segment.length {
                loc.x += orientation.dx
                loc.y += orientation.dy
                
                if 0 <= loc.x && loc.x < gridConfiguration.itemsWidth && 0 <= loc.y && loc.y < gridConfiguration.itemsHeight {
                    gridNode.addChild(makeCell(loc.x, loc.y))
                }
            }
        }
        
        return gridNode
    }
    
}
