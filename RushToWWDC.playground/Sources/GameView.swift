//
//  GameView.swift
//  background
//
//  Created by Anirudh Natarajan on 3/31/18.
//  Copyright © 2018 Anirudh Natarajan. All rights reserved.
//

import UIKit
import SpriteKit

public class GameView: SKScene {
    let background = SKSpriteNode(imageNamed: "back")
    let clouds = SKSpriteNode(imageNamed: "clouds")
    var cloudForward = true
    
    public override func didMove(to view: SKView) {
        // set the inital positions
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x: -335, y: 0)
        background.scale(to: CGSize(width: 1238, height: 2575))
        background.zPosition = 0
        addChild(background)
        
        clouds.anchorPoint = CGPoint.zero
        clouds.position = CGPoint(x: -670, y: 650)
        clouds.scale(to: CGSize(width: 672, height: 227))
        clouds.zPosition = 1
        addChild(clouds)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // check what to animate in what direction
        if(background.position.y > -890){
            background.position = CGPoint(x: background.position.x, y: background.position.y - 4)
        } else {
            if clouds.position.x < -670 {
                cloudForward = true
            } else if clouds.position.x > 600 {
                cloudForward = false
            }
            
            if(cloudForward) {
                clouds.position = CGPoint(x: clouds.position.x + 4, y: clouds.position.y)
            } else {
                clouds.position = CGPoint(x: clouds.position.x - 4, y: clouds.position.y)
            }
        }
    }
}

