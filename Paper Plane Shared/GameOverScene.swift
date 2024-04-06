//
//  GameOverScene.swift
//  Paper Plane iOS
//
//  Created by Chekwube Nweze on 05/03/2024.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    let endGamePanel = SKSpriteNode(imageNamed: "Panel.png")
    let endGameLabel = SKLabelNode(fontNamed: "WarioWare Inc.")
    let gameOverLabel = SKLabelNode(fontNamed: "WarioWare Inc.")
    let replayButton = SKSpriteNode(imageNamed: "ReplayPanel1.png")
    let replayTexture1 : SKTexture = SKTexture(imageNamed: "ReplayPanel1.png")
    let replayTexture2 : SKTexture = SKTexture(imageNamed: "ReplayPanel2.png")
    let emptyMedal1 = SKSpriteNode(imageNamed: "EmptyMedal.png")
    let emptyMedal2 = SKSpriteNode(imageNamed: "EmptyMedal.png")
    let emptyMedal3 = SKSpriteNode(imageNamed: "EmptyMedal.png")
    var score : Double = 0
    let background = SKSpriteNode()
    var newHighScore : Bool = false
    var touchStartedInButton : Bool = false

    override init(size: CGSize){
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        background.size = CGSize(width: self.size.width, height: self.size.height)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 1
        addChild(background)
        
        endGamePanel.size = CGSize(width: 1000, height: 900)
        endGamePanel.position = CGPoint(x:self.size.width/2, y: self.size.height/2)
        endGamePanel.zPosition = 2
        addChild(endGamePanel)
        
        replayButton.name = "Replay"
        replayButton.size = CGSize(width: 280, height: 190)
        replayButton.position = CGPoint(x:self.size.width/2, y: self.size.height/2-300)
        replayButton.zPosition = 3
        addChild(replayButton)
        
        gameOverLabel.text = "GAME OVER!"
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.fontSize = 120
        gameOverLabel.zPosition = 100
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.verticalAlignmentMode = .bottom
        gameOverLabel.position = CGPoint(x:self.size.width/2, y: self.size.height/2 + 150)
        addChild(gameOverLabel)
        
        endGameLabel.text = "Score: \(Int(score))"
        if newHighScore {
            endGameLabel.text = "New High Score! \(Int(score))"
        }
        endGameLabel.fontColor = SKColor.white
        endGameLabel.fontSize = 90
        endGameLabel.zPosition = 100
        endGameLabel.horizontalAlignmentMode = .center
        endGameLabel.verticalAlignmentMode = .bottom
        endGameLabel.position = CGPoint(x:self.size.width/2, y: self.size.height/2 + 40)
        addChild(endGameLabel)
        
        emptyMedal1.position = CGPoint(x:self.size.width/2 - 300, y: self.size.height/2 - 100)
        emptyMedal1.size = CGSize(width: 200, height: 200)
        emptyMedal1.zPosition = 3
        addChild(emptyMedal1)
        emptyMedal2.position = CGPoint(x:self.size.width/2, y: self.size.height/2 - 100)
        emptyMedal2.size = CGSize(width: 200, height: 200)
        emptyMedal2.zPosition = 3
        addChild(emptyMedal2)
        emptyMedal3.position = CGPoint(x:self.size.width/2 + 300, y: self.size.height/2 - 100)
        emptyMedal3.size = CGSize(width: 200, height: 200)
        emptyMedal3.zPosition = 3
        addChild(emptyMedal3)
        
        let rotateIntoPlace = SKAction.rotate(byAngle: 2*CGFloat.pi, duration: 1)
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        
        
        if score >= 50 {
            let medal1 = SKSpriteNode(imageNamed: "BronzeMedal.png")
            medal1.size = CGSize(width: 200, height: 200)
            medal1.position = CGPoint(x:self.size.width/2 - 300, y: self.size.height/2 + 500)
            medal1.zPosition = 4
            medal1.alpha = 0.0
            addChild(medal1)
            let moveToPosition = SKAction.move(to: CGPoint(x:self.size.width/2 - 300, y: self.size.height/2 - 100), duration: 0.5)
            let groupAction1 = SKAction.group([moveToPosition, rotateIntoPlace, fadeIn])
            medal1.run(groupAction1)
        }
        
        if score >= 150 {
            let medal2 = SKSpriteNode(imageNamed: "SilverMedal.png")
            medal2.size = CGSize(width: 200, height: 200)
            medal2.position = CGPoint(x:self.size.width/2, y: self.size.height/2 + 500)
            medal2.zPosition = 4
            medal2.alpha = 0.0
            addChild(medal2)
            let moveToPosition2 = SKAction.move(to: CGPoint(x:self.size.width/2, y: self.size.height/2 - 100), duration: 0.5)
            let groupAction2 = SKAction.group([moveToPosition2, rotateIntoPlace, fadeIn])
            medal2.run(groupAction2)
        }
        
        if score >= 250 {
            let medal3 = SKSpriteNode(imageNamed: "GoldMedal.png")
            medal3.size = CGSize(width: 200, height: 200)
            medal3.position = CGPoint(x:self.size.width/2 + 300, y: self.size.height/2 + 500)
            medal3.zPosition = 4
            medal3.alpha = 0.0
            addChild(medal3)
            let moveToPosition3 = SKAction.move(to: CGPoint(x:self.size.width/2 + 300, y: self.size.height/2 - 100), duration: 0.5)
            let groupAction3 = SKAction.group([moveToPosition3, rotateIntoPlace, fadeIn])
            medal3.run(groupAction3)
        }
    }
        
        //want to group movement to same position, and rotation, and transparency but sequence this one medal after the other
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch:UITouch = touches.first! as UITouch
        let touchLocation = touch.location(in: self)
        
        let touchedNode = atPoint(touchLocation)
        if touchedNode.name == "Replay" {
            replayButton.texture = replayTexture2
            touchStartedInButton = true
        } else {
            touchStartedInButton = false
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first! as UITouch
        let touchLocation = touch.location(in: self)
        
        let touchedNode = atPoint(touchLocation)
        if touchedNode.name == "Replay" && touchStartedInButton {
            replayButton.texture = replayTexture2
        } else {
            replayButton.texture = replayTexture1
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first! as UITouch
        let touchLocation = touch.location(in: self)
        
        let touchedNode = atPoint(touchLocation)
        if touchedNode.name == "Replay" && touchStartedInButton {
            replayButton.texture = replayTexture1
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.25)
            self.view?.presentScene(myScene, transition: reveal)
        } else {
            replayButton.texture = replayTexture1
        }
        }
    }
