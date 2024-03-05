//
//  GameOverScene.swift
//  Paper Plane iOS
//
//  Created by Chekwube Nweze on 05/03/2024.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    let stateLabel = SKLabelNode()
    
    override init(size: CGSize){
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        background.position = CGPoint(x: 0, y: 0)
        background.path = path
        background.fillColor =  SKColor.green
        addChild(background)
        
        stateLabel.text = "You Lose :("
        stateLabel.fontColor = SKColor.black
        stateLabel.fontSize = 100
        stateLabel.zPosition = 100
        stateLabel.horizontalAlignmentMode = .left
        stateLabel.verticalAlignmentMode = .bottom
        stateLabel.position = CGPoint(x:self.size.width/2 , y: self.size.height/2)
        addChild(stateLabel)
        
        let wait = SKAction.wait(forDuration: 1.0)
        let block = SKAction.run {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.25)
            self.view?.presentScene(myScene, transition: reveal)
        }
        self.run(SKAction.sequence([wait, block]))
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
