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
        
        // build the scene grid
        let gridNode = SKNode()
        
        var gridItems: [[SKShapeNode]] = []
        
        for i in 0..<gridConfiguration.itemsWidth {
            var column: [SKShapeNode] = []
            for j in 0..<gridConfiguration.itemsHeight {
                let shapeNode = SKShapeNode(rectOf: gridConfiguration.itemSize)
                shapeNode.fillColor = .white
                shapeNode.strokeColor = .gray
                shapeNode.name = "\(prefix)-\(i)-\(j)"
                
                shapeNode.position.x = (CGFloat(i) + 0.5) * shapeNode.frame.width
                shapeNode.position.y = (CGFloat(j) + 0.5) * shapeNode.frame.height
                
                gridNode.addChild(shapeNode)
                column.append(shapeNode)
            }
            gridItems.append(column)
        }
        
        // color
        var loc = (x: x, y: y)
        gridItems[x][y].fillColor = .black
        
        for segment in segments {
            let orientation = segment.orientation.integerOffset
            
            for _ in 0..<segment.length {
                loc.x += orientation.dx
                loc.y += orientation.dy
                
                if 0 <= loc.x && loc.x < gridConfiguration.itemsWidth && 0 <= loc.y && loc.y < gridConfiguration.itemsHeight {
                    gridItems[loc.x][loc.y].fillColor = .black
                }
            }
        }
        
        return gridNode
    }
    
}
