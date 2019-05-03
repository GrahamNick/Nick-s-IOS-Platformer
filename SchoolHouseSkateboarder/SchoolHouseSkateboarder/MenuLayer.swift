//
//  MenuLayer.swift
//  SchoolHouseSkateboarder
//
//  Created by Student on 4/30/19.
//  Copyright © 2019 Student. All rights reserved.
//

import SpriteKit

class MenuLayer: SKSpriteNode {
    func display(message: String, score: Int?) {
        let messageLabel: SKLabelNode = SKLabelNode(text: message)
        
        let messageX = -frame.width
        let messageY = frame.height/2
        messageLabel.position = CGPoint(x: messageX, y: messageY)
        
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontName = "Courier-Bold"
        messageLabel.fontSize = 48.0
        messageLabel.zPosition = 20
        self.addChild(messageLabel)
        
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3)
        messageLabel.run(messageAction)
        
        if let scoreToDisplay = score {
            let scoreString = String(format: "Score: %04d", scoreToDisplay)
            let scoreLabel: SKLabelNode = SKLabelNode(text: scoreString)
            
            let scoreLabelX = frame.width
            let scoreLabelY = messageLabel.position.y - messageLabel.frame.height
            scoreLabel.position = CGPoint(x:scoreLabelX, y: scoreLabelY)
        }
    }
}
