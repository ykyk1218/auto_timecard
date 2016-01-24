//
//  GameView.swift
//  auto_timecard
//
//  Created by 小林芳樹 on 2016/01/10.
//  Copyright © 2016年 小林芳樹. All rights reserved.
//

import UIKit
import SpriteKit

class GameView: SKView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.showsFPS = true
        let skScene = SKScene(size: CGSize(width: 300,height: 100))
        skScene.backgroundColor = UIColor.whiteColor()
        
        let node = SKLabelNode()
        node.text = "hello world"
        node.fontColor = UIColor.blackColor()
        node.position = CGPointMake(CGRectGetMidX(self.frame)+30, CGRectGetMidY(self.frame) + 40)
        node.fontSize = 20
//        skScene.addChild(node)
        
        
        
        var points = [CGPointMake(0.0, 0.0),CGPointMake(150.0, 30.0)]
        //path.moveToPoint(CGPointMake(5, 5))
        //path.addLineToPoint(CGPointMake(300,20))
        
        
        let circle = SKShapeNode(circleOfRadius: 20.0)
        circle.position = CGPointMake(CGRectGetMidX(self.frame)+30, CGRectGetMidY(self.frame) + 40)
        circle.fillColor = UIColor.redColor()
        
        let line = SKShapeNode(points: &points, count: points.count)
        //line.path = path.CGPath
        line.position = CGPointMake(CGRectGetMidX(self.frame)+30, CGRectGetMidY(self.frame) + 300)
        line.fillColor = SKColor.redColor()
        line.lineWidth = 5.0
        
        skScene.addChild(line)
        skScene.addChild(circle)
        self.presentScene(skScene)
        
        print(line.frame)
        
        /*
        let floor = SKNode()
        floor.runAction(SKAction.repeatActionForever(SKAction.sequence(
            SKAction.moveTo(CGPointMake(0.0, <#T##NSTimeInterval#>)
            ))
        
        
        skScene.addChild(node)
        self.presentScene(skScene)
        */
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
