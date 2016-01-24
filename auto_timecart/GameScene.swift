//
//  GameScene.swift
//  auto_timecard
//
//  Created by 小林芳樹 on 2016/01/10.
//  Copyright © 2016年 小林芳樹. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {
    
    var initiated: Bool = false
    
    override func didMoveToView(view: SKView) {
        if(!initiated) {
            self.backgroundColor = SKColor.whiteColor()
            let label = self.viewTxt()
            
            self.addChild(label)
            self.initiated = true
            
        }
    }
    
    func viewTxt() -> SKLabelNode {
        let helloNode = SKLabelNode()
        helloNode.text = "Hello World"
        helloNode.fontColor = SKColor.blackColor()
        helloNode.fontSize = 40
        helloNode.position = CGPoint(x: 150, y: 600)
        
print(helloNode.frame)
        return helloNode
    }

}
