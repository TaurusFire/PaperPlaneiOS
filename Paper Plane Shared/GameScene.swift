//
//  GameScene.swift
//  Paper Plane Shared
//
//  Created by Chekwube Nweze on 24/02/2024.
//

import SpriteKit

class GameScene: SKScene {
    
    
    fileprivate var label : SKLabelNode?
    
    let plane = SKSpriteNode(imageNamed: "PaperPlaneSprite.png")
    
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    var obstacleOnLeft : Bool = false
    var score : Int = 0
    var isTouching : Bool = false
    var touchLocation : CGPoint = CGPoint(x: 0, y: 0)
    var lowestNodeYPosition : CGFloat = 0
    
    var angle : CGFloat = 90 {
        didSet {
            if angle < 10 {
                angle = 10
            } else if angle > 170 {
               angle = 170
            }
        }
    }
    
    var planeAmountToMovePerSec : CGFloat {
        4*(angle - 90)
    }
    
    var obstacleAmountToMovePerSec : CGFloat {
        (-4*abs(90 - angle) + 90) * 2
    }
    
    var nextObstacleLeft : Bool = true
    
    var generateObstacleCount = 0
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    override init(size: CGSize){
        super.init(size:size)
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
        
        plane.name = "plane"
        plane.size = CGSize(width:200, height:60)
        plane.position = CGPoint(x: self.size.width/2, y: self.size.height - 150)
        
        addChild(plane)
        generateObstacle()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        
        if isTouching {
            if touchLocation.x < self.size.width / 2 {
                self.angle -= 1.5
            } else {
                self.angle += 1.5
            }
        }
        
        plane.zRotation = ((angle - 90) * CGFloat.pi) / 180
        print(lowestNodeYPosition)
        if lowestNodeYPosition > 300 {
            generateObstacle()
        }
        
        movePlane(dt)
        moveObstacles(dt)
    }

    
    func generateObstacle(){
        
        var obstacle = SKSpriteNode(imageNamed: "SmallObstacle.png")
        obstacle.name = "obstacle"
        obstacle.size = CGSize(width: 1300, height: 30)
        
        if (score > 20 && score < 40) {
            obstacle = SKSpriteNode(imageNamed: "MedObstacle.png")
            }
        else if (score > 50) {
            obstacle = SKSpriteNode(imageNamed: "LargeObstacle.png")
        }
        
        if obstacleOnLeft {
            obstacle.position = CGPoint(x:obstacle.frame.width/2, y:0)
        } else {
            obstacle.position = CGPoint(x:self.size.width - (obstacle.frame.width/2), y:0)
        }
        
        obstacleOnLeft = !obstacleOnLeft
        
        addChild(obstacle)
        lowestNodeYPosition = 0
    }
    
    func moveObstacles(_ duration: TimeInterval){
        
        let amountToMove = CGPoint(x:0, y:self.obstacleAmountToMovePerSec * duration)
        let moveUpwards = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: duration)
        
        enumerateChildNodes(withName: "obstacle") { node, stop in
            node.run(moveUpwards)
        }
        
        self.lowestNodeYPosition += amountToMove.y
    }
    
    func movePlane(_ duration: TimeInterval){
        let amountToMove = CGPoint(x:self.planeAmountToMovePerSec * duration, y:0)
        let moveSideways = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: duration)
        
        enumerateChildNodes(withName: "plane") { node, stop in
            node.run(moveSideways)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        print("touch recognized")
        isTouching = true
        touchLocation = touch.location(in: self)
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        print("touch recognized")
        
        isTouching = true
        touchLocation = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        print("touch recognized")
        
        isTouching = false
    }
    
}



