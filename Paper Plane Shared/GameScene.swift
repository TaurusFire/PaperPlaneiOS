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
    var score : Double = 0
    let scoreLabel = SKLabelNode()
    var isTouching : Bool = false
    var touchLocation : CGPoint = CGPoint(x: 0, y: 0)
    
    var obstacleCount : CGFloat = 0
    var level : CGFloat = 0
//    var angle : CGFloat = 90 {
//        didSet {
//            if angle < 30 {
//                angle = 30
//            } else if angle > 150 {
//               angle = 150
//            }
//        }
//    }
    
    var angleRanges: [CGFloat] = [30,40,50,60,70,80,85,90,90,90,95,100,110,120,130,140,150]
    var angleIndex: Int = 8 {
        didSet {
            if angleIndex <= 0 {
                angleIndex = 0
            } else if angleIndex >= angleRanges.count - 1 {
                angleIndex = angleRanges.count - 1
            }
        }
    }
    
    var angle : CGFloat {
        angleRanges[angleIndex]
    }
    
    var planeAmountToMovePerSec : CGFloat {
        if abs(angle-90) < 60 {
            return 11*(angle-90)
        } else {
            return 13*(angle-90)
        }
    }
    
    var obstacleAmountToMovePerSec : CGFloat {
        
        if abs(angle-90) > 15 {
            return min(((-abs(90 - angle) + 160) * 3.2) + 40 * floor(score / 25), 1000)
        } else {
            return min(((-abs(90 - angle) + 130) * 3.5) + 40 * floor(score/25), 1000)
        }
        
    }
    
    var aloft : Bool = true
    
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
        
        aloft = true
        plane.name = "plane"
        plane.size = CGSize(width:200, height:60)
        plane.position = CGPoint(x: self.size.width/2, y: self.size.height - 200)
        addChild(plane)
        
        scoreLabel.text = "0"
        scoreLabel.fontColor = SKColor.black
        scoreLabel.fontSize = 100
        scoreLabel.zPosition = 100
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height - 150)
        addChild(scoreLabel)
        
        level = 1
        generateObstacle()
        obstacleCount = 1
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
                //self.angle -= 5
                angleIndex -= 1
            } else {
                //self.angle += 5
                angleIndex += 1
            }
        }
        
        plane.zRotation = ((angle - 90) * CGFloat.pi) / 180
        
        if plane.zRotation != 0 {
            plane.size = CGSize(width:200, height:60)
        }
        
        if (plane.position.x > self.size.width) && (angle > 90)  {
            plane.position.x = self.size.width
            //angle -= 5
            angleIndex -= 1
        } else if (plane.position.x < 0) && (angle < 90) {
            plane.position.x = 0
            //angle += 5
            angleIndex += 1
        }
        
        
        movePlane(dt)
//        print("""
//              Angle: \(angle),
//              Plane Horizontal Speed: \(planeAmountToMovePerSec), 
//              Obstacle Speed: \(obstacleAmountToMovePerSec),
//              Score \(score),
//              Obstacle Count \(obstacleCount),
//              Level \(level))
//              """)
        
        moveObstacles(dt)
        checkCollisions()
        if !aloft {
            print("You Lose!")
            let gameOverScene = GameOverScene(size: self.size)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.25)
            view?.presentScene(gameOverScene, transition: reveal)
        }
        self.scoreLabel.text = "\(Int(score))"
    }

    func generateObstacleOrLapSequence(_ lowestNodeYPosition: CGFloat){
        //define the logic for when scores affect which obstacles are generated
        
        //first lap obstacle
         if (obstacleCount == 15)
             || (obstacleCount == 40)
             || (obstacleCount == 65)
             || (obstacleCount == 90)
             || ((obstacleCount > 100) && (obstacleCount - 121).truncatingRemainder(dividingBy: 30) == 0) {
                    
            if lowestNodeYPosition > 100 {
                generateLapSequence()
            }
        
        //rest of lap obstacles
        } else if ((obstacleCount >= 16) && (obstacleCount < 25))
                    || ((obstacleCount >= 41) && (obstacleCount < 50))
                    || ((obstacleCount >= 66) && (obstacleCount < 75))
                    || ((obstacleCount >= 91) && (obstacleCount < 100))
                    || ((obstacleCount >= 100) && ((obstacleCount - 121).truncatingRemainder(dividingBy: 30) > 0)
                    && ((obstacleCount - 121).truncatingRemainder(dividingBy: 30) < 10))
                    {
            if lowestNodeYPosition > 1 {
                generateLapSequence()
            }
            
        } else {
            if lowestNodeYPosition > 300 {
                generateObstacle()
            }
        }
    }
    
    
    func generateObstacle(){
        
        
        var obstacle = ObstacleNode()

        if level == 1 {
            obstacle = ObstacleNode(imageNamed: "SmallObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: 1330, height: 30)
            
        } else if level == 2 {
            obstacle = ObstacleNode(imageNamed: "MedObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: 1330, height: 60)
            
        } else if level == 3 {
            obstacle = ObstacleNode(imageNamed: "LargeObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: 1330, height: 80)
            
        } else if level == 4 {
            obstacle = ObstacleNode(imageNamed: "LargeObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: 1330, height: 100)
            
        } else if level == 5 {
            obstacle = ObstacleNode(imageNamed: "LargeObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: 1330, height: 110)
        }
        
        
        if obstacleOnLeft {
                obstacle.position = CGPoint(x:obstacle.frame.width/2 - 50 , y:-50)
            } else {
                obstacle.position = CGPoint(x:self.size.width - (obstacle.frame.width/2) + 50, y:-50)
            }
            
            obstacleOnLeft = !obstacleOnLeft
        
            addChild(obstacle)
            obstacleCount += 1

        }
    
    
    func generateLapSequence(){
                    
        let leftNextLapObstacle = ObstacleNode(imageNamed: "NextLapObstacle.png")
        leftNextLapObstacle.name = "nextLapObstacle"
        leftNextLapObstacle.position = CGPoint(x:leftNextLapObstacle.frame.width/2, y: -200)
        leftNextLapObstacle.size = CGSize(width: 1550, height: 200)
            
        let rightNextLapObstacle = ObstacleNode(imageNamed: "NextLapObstacle.png")
        rightNextLapObstacle.name = "nextLapObstacle"
        rightNextLapObstacle.position = CGPoint(x:self.size.width - (rightNextLapObstacle.frame.width/2), y:-200)
        rightNextLapObstacle.size = CGSize(width: 1550, height: 200)
        
        addChild(leftNextLapObstacle)
        addChild(rightNextLapObstacle)
        obstacleCount += 1

    }
    
    func moveObstacles(_ duration: TimeInterval){
        
        let amountToMove = CGPoint(x:0, y:self.obstacleAmountToMovePerSec * duration)
        let moveUpwards = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: duration)
        var lowestNodeYPosition : CGFloat = self.frame.height //initialize at top of screen
        
        enumerateChildNodes(withName: "obstacle") { node, stop in
            
            guard let node = node as? ObstacleNode else {
                return
            }
            
            if lowestNodeYPosition > node.position.y {
                lowestNodeYPosition = node.position.y
            }
            node.run(moveUpwards)
            
            if node.position.y > self.plane.position.y {
                if node.activated {
                    self.score += 1
                    node.activated = !node.activated
                }
            }
            
            if node.position.y > self.frame.height {
                node.removeFromParent()
            }
            
        }
        
        enumerateChildNodes(withName: "nextLapObstacle"){ node, stop in
            guard let node = node as? ObstacleNode else {
                return
            }
            
            if lowestNodeYPosition > node.position.y {
                lowestNodeYPosition = node.position.y
            }
            
            node.run(moveUpwards)
            
            if node.position.y > self.plane.position.y {
                if node.activated {
                    self.score += 0.5
                    node.activated = !node.activated
                }
            }
            
            if node.position.y > self.frame.height + node.size.height/2 {
                node.removeFromParent()
            }
            
        }
            changeLevel()
            generateObstacleOrLapSequence(lowestNodeYPosition)
        
        }
        
    
    func movePlane(_ duration: TimeInterval){
        let amountToMove = CGPoint(x:self.planeAmountToMovePerSec * duration, y:0)
        let moveSideways = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: duration)
        
        enumerateChildNodes(withName: "plane") { node, stop in
            node.run(moveSideways)
        }
    }
    
    func changeLevel(){
        if obstacleCount <= 15 {
            self.level = 1
        } else if (obstacleCount > 15) && (obstacleCount <= 40){
            self.level = 2
        } else if (obstacleCount > 40 ) && (obstacleCount <= 65) {
            self.level = 3
        } else if (obstacleCount > 65 ) && (obstacleCount <= 90) {
            self.level = 4
        } else {
            self.level = 5
        }
        
    }
    
    func checkCollisions(){
        
        if abs(angle-90) == 0 {
            enumerateChildNodes(withName: "obstacle") { node, _ in
                let obstacle = node as! SKSpriteNode
                if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 60, 20)) {
                    self.aloft = false
                }
            }
            
            enumerateChildNodes(withName: "nextLapObstacle") { node, _ in
                let obstacle = node as! SKSpriteNode
                if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 60, 20)) {
                    self.aloft = false
                }
            }
        }
            
        if (abs(angle-90) > 0) && (abs(angle-90) < 30) {
                enumerateChildNodes(withName: "obstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 50, 35)) {
                        self.aloft = false
                    }
                }
                
                enumerateChildNodes(withName: "nextLapObstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 50, 35)) {
                        self.aloft = false
                    }
                }
        }
        
        if (abs(angle-90) > 30) && (abs(angle-90) < 60) {
                enumerateChildNodes(withName: "obstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 40, 50)) {
                        self.aloft = false
                    }
                }
                
                enumerateChildNodes(withName: "nextLapObstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 40, 50)) {
                        self.aloft = false
                    }
                }
        }
        
        if (abs(angle-90) == 60) {
                enumerateChildNodes(withName: "obstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,5,10), CGRectInset(self.plane.frame, 20, 60)) {
                        self.aloft = false
                    }
                }
                
                enumerateChildNodes(withName: "nextLapObstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,5,10), CGRectInset(self.plane.frame, 20, 60)) {
                        self.aloft = false
                    }
                }
        }
        
        }
        
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        isTouching = true
        touchLocation = touch.location(in: self)
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        isTouching = true
        touchLocation = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        
        isTouching = false
    }
    
}



