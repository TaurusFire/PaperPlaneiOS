//
//  GameScene.swift
//  Paper Plane Shared
//
//  Created by Chekwube Nweze on 24/02/2024.
//

import SpriteKit

class GameScene: SKScene {
    
    
    fileprivate var label : SKLabelNode?
    
    let plane = SKSpriteNode(imageNamed: "PPSprite90.png")
    let scoreLabel = SKLabelNode(fontNamed: "WarioWare Inc.")
    let highScoreLabel = SKLabelNode(fontNamed: "WarioWare Inc.")
    let passObstacleSound : SKAction = SKAction.playSoundFileNamed("passObstacle.wav", waitForCompletion: false)
    let hitObstacleSound : SKAction = SKAction.playSoundFileNamed("hitObstacle.wav", waitForCompletion: false)
    
    let brownTexture : SKTexture = SKTexture(imageNamed: "BrownWall.png")
    let purpleTexture : SKTexture = SKTexture(imageNamed: "PurpleWall.png")
    let blueTexture : SKTexture = SKTexture(imageNamed: "BlueWall.png")
    let greenTexture : SKTexture = SKTexture(imageNamed: "GreenWall.png")
    let yellowTexture : SKTexture = SKTexture(imageNamed: "YellowWall.png")
    let pinkTexture : SKTexture = SKTexture(imageNamed: "PinkWall.png")
    let redTexture : SKTexture = SKTexture(imageNamed: "RedWall.png")
    let background1 = SKSpriteNode(imageNamed:"BrownWall.png")
    let background2 = SKSpriteNode(imageNamed:"BrownWall.png")
    
    let planeAng5 = SKTexture(imageNamed: "PPSprite5.png")
    let planeAng30 = SKTexture(imageNamed: "PPSprite30.png")
    let planeAng45 = SKTexture(imageNamed: "PPSprite45.png")
    let planeAng60 = SKTexture(imageNamed: "PPSprite60.png")
    let planeAng90 = SKTexture(imageNamed: "PPSprite90.png")
    let scoreKey = "scoreKey"
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    var obstacleOnLeft : Bool = false
    var score : Double = 0
    var highScore : Double = 0
    var newHighScore : Bool {
        score > highScore
    }

    var isTouching : Bool = false
    var touchLocation : CGPoint = CGPoint(x: 0, y: 0)
    
    var obstacleCount : CGFloat = 0
    var level : CGFloat = 0
    
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
    var scoreBonus : CGFloat {
        return 5 * score
    }
    
    var planeAmountToMovePerSec : CGFloat {
        if abs(angle-90) <= 30 {
            return 8*(angle-90)
        } else if abs(angle-90) > 30 && abs(angle-90) < 60 {
            return 10*(angle-90)
        } else {
            return 11*(angle-90)
        }
    }
    
    var obstacleAmountToMovePerSec : CGFloat {
        
        if abs(angle-90) > 15 {
            return min( (3.8 * (-1 * abs(90 - angle)+100)) + scoreBonus + 500, 2000)
        } else {
            return min( (4.3 * (-1 * abs(90 - angle)+100)) + scoreBonus + 500, 2000)
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
        
        background1.name = "background"
        background1.size = CGSize(width: self.size.width, height: self.size.height)
        background1.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background1.isUserInteractionEnabled = false
        background1.zPosition = -1
        background2.name = "background"
        background2.size = CGSize(width: self.size.width, height: self.size.height)
        background2.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - self.size.height)
        background2.isUserInteractionEnabled = false
        background2.zPosition = -1
        addChild(background1)
        addChild(background2)
        
        aloft = true
        plane.name = "plane"
        plane.size = CGSize(width:110, height:120)
        plane.position = CGPoint(x: self.size.width/2, y: self.size.height - 400)
        addChild(plane)
        
        scoreLabel.text = "0"
        scoreLabel.fontColor = SKColor.black
        scoreLabel.fontSize = 100
        scoreLabel.zPosition = 100
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height - 280)
        addChild(scoreLabel)
        
        loadHighScore()
        highScoreLabel.fontColor = SKColor.black
        highScoreLabel.fontSize = 50
        highScoreLabel.zPosition = 100
        highScoreLabel.position = CGPoint(x: self.size.width - 300, y: self.size.height - 150)
        addChild(highScoreLabel)
        
        level = 1
        generateObstacle()
        obstacleCount = 1
    }
    

    
    override func update(_ currentTime: TimeInterval) {
        
        self.scoreLabel.fontColor = .white
        self.highScoreLabel.fontColor = .white
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        
        if isTouching {
            if touchLocation.x < frame.midX {
                //self.angle -= 5
                angleIndex -= 1
            } else {
                //self.angle += 5
                angleIndex += 1
            }
        }
        
        if (abs(angle - 90) == 0){
            plane.texture = planeAng90
        } else if (abs(angle - 90) > 0) && (abs(angle - 90) <= 30) {
            plane.texture = planeAng60
        } else if (abs(angle - 90) > 30) && (abs(angle - 90) <= 45) {
            plane.texture = planeAng45
        } else if (abs(angle - 90) > 45) && (abs(angle - 90) <= 60) {
            plane.texture = planeAng30
        } else if abs(angle - 90) > 60 {
            plane.texture = planeAng5
        }
        
        if (angle - 90) > 0 {
            plane.xScale = -1
        } else {
            plane.xScale = 1
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
        print(obstacleAmountToMovePerSec)
        
        movePlane(dt)
        moveObstacles(dt)
        checkCollisions()
        changeBackground()
        
        if newHighScore {
            self.highScoreLabel.text = "High Score: \(Int(score))"
            self.highScoreLabel.fontColor = .yellow
        }
        
        if !aloft {
            let gameOverScene = GameOverScene(size: self.size)
            gameOverScene.scaleMode = scaleMode
            gameOverScene.score = score
            
            if newHighScore {
                gameOverScene.newHighScore = true
                saveHighScore()
            }
            
            gameOverScene.background.texture = background1.texture
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
             || ((obstacleCount > 100) && (obstacleCount - 120).truncatingRemainder(dividingBy: 30) == 0) {
                    
            if lowestNodeYPosition > 500 {
                generateLapSequence()
            }
        
        //rest of lap obstacles
        } else if ((obstacleCount >= 16) && (obstacleCount < 25))
                    || ((obstacleCount >= 41) && (obstacleCount < 50))
                    || ((obstacleCount >= 66) && (obstacleCount < 75))
                    || ((obstacleCount >= 91) && (obstacleCount < 100))
                    || ((obstacleCount >= 100) && ((obstacleCount - 120).truncatingRemainder(dividingBy: 30) > 0)
                    && ((obstacleCount - 120).truncatingRemainder(dividingBy: 30) < 10))
                    {
            if lowestNodeYPosition > 250 {
                generateLapSequence()
            }
            
        } else {
            if lowestNodeYPosition > 750 {
                generateObstacle()
            }
        }
    }
    
    func obtainTexture() -> SKTexture? {
        switch self.score{
            
        case 16:
            return self.purpleTexture
            
        case 41:
            return self.blueTexture
            
        case 66:
            return self.greenTexture
            
        case 91:
            return self.yellowTexture
            
        case 121:
            return self.pinkTexture
            
        case 151:
            return self.redTexture
            
        default:
            return nil
        }
    }
    
    func changeBackground(){
            if (self.score == 16) || (self.score == 41) || (self.score == 66) || (self.score == 91) ||
                (self.score == 121) || (self.score == 151) {
                self.enumerateChildNodes(withName: "background") { node, _ in
                    let node = node as! SKSpriteNode
                    node.texture = self.obtainTexture()
                }
        }
    }
    
    func generateObstacle(){
        
        
        var obstacle = ObstacleNode()
        let obstacleWidth = 650
        if level == 1 {
            obstacle = ObstacleNode(imageNamed: "SmallObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: obstacleWidth, height: 120)
        } else if level == 2 {
            obstacle = ObstacleNode(imageNamed: "MedObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: obstacleWidth, height: 170)
        } else if level == 3 {
            obstacle = ObstacleNode(imageNamed: "MedObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: obstacleWidth, height: 180)
        } else if level == 4 {
            obstacle = ObstacleNode(imageNamed: "LargeObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: obstacleWidth, height: 220)
        } else if level == 5 {
            obstacle = ObstacleNode(imageNamed: "LargeObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: obstacleWidth, height: 230)
        } else if level == 6 {
            obstacle = ObstacleNode(imageNamed: "LargeObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: obstacleWidth, height: 240)
        } else if level == 7 {
            obstacle = ObstacleNode(imageNamed: "LargeObstacle.png")
            obstacle.name = "obstacle"
            obstacle.size = CGSize(width: obstacleWidth, height: 280)
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
        leftNextLapObstacle.size = CGSize(width: 600, height: 450)
            
        let rightNextLapObstacle = ObstacleNode(imageNamed: "NextLapObstacle.png")
        rightNextLapObstacle.name = "nextLapObstacle"
        rightNextLapObstacle.position = CGPoint(x:self.size.width - (rightNextLapObstacle.frame.width/2), y:-200)
        rightNextLapObstacle.size = CGSize(width: 600, height: 450)
        
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
                    self.run(self.passObstacleSound)
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
                    self.run(self.passObstacleSound)
                }
            }
            
            if node.position.y > self.frame.height + node.size.height/2 {
                node.removeFromParent()
            }
            
        }
        
        enumerateChildNodes(withName: "background"){ node, stop in
            guard let node = node as? SKSpriteNode else {
                return
            }
                    
            //if the bottom of the background will move above the top in the next update
            if node.position.y - node.size.height/2 + amountToMove.y >= self.size.height {
                //set the background to
                node.position.y -= (2*node.size.height)
            }
            
            node.position.y += amountToMove.y
            
            
            
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
        } else if (obstacleCount > 90 ) && (obstacleCount <= 120){
            self.level = 5
        } else if (obstacleCount > 120 ) && (obstacleCount <= 150){
            self.level = 6
        } else {
            self.level = 7
        }
    }
    
    func checkCollisions(){
        
        if abs(angle-90) == 0 {
            enumerateChildNodes(withName: "obstacle") { node, _ in
                let obstacle = node as! SKSpriteNode
                if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 45, 20)) {
                    self.aloft = false
                    self.run(self.hitObstacleSound)
                }
            }
            
            enumerateChildNodes(withName: "nextLapObstacle") { node, _ in
                let obstacle = node as! SKSpriteNode
                if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 45, 20)) {
                    self.aloft = false
                    self.run(self.hitObstacleSound)
                }
            }
        }
            
        if (abs(angle-90) > 0) && (abs(angle-90) <= 30) {
                enumerateChildNodes(withName: "obstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 40, 30)) {
                        self.aloft = false
                        self.run(self.hitObstacleSound)
                    }
                }
                
                enumerateChildNodes(withName: "nextLapObstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 40, 30)) {
                        self.aloft = false
                        self.run(self.hitObstacleSound)
                    }
                }
        }
        
        if (abs(angle-90) > 30) && (abs(angle-90) < 60) {
                enumerateChildNodes(withName: "obstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 37, 40)) {
                        self.aloft = false
                        self.run(self.hitObstacleSound)
                    }
                }
                
                enumerateChildNodes(withName: "nextLapObstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,20,10), CGRectInset(self.plane.frame, 37, 40)) {
                        self.aloft = false
                        self.run(self.hitObstacleSound)
                    }
                }
        }
        
        if (abs(angle-90) == 60) {
                enumerateChildNodes(withName: "obstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,5,10), CGRectInset(self.plane.frame, 35, 50)) {
                        self.aloft = false
                        self.run(self.hitObstacleSound)
                    }
                }
                
                enumerateChildNodes(withName: "nextLapObstacle") { node, _ in
                    let obstacle = node as! SKSpriteNode
                    if CGRectIntersectsRect(CGRectInset(obstacle.frame,5,10), CGRectInset(self.plane.frame, 35, 50)) {
                        self.aloft = false
                        self.run(self.hitObstacleSound)
                    }
                }
        }
        
        }
    
    func saveHighScore(){
        let defaults = UserDefaults.standard
        //if current score is greater than the loaded high score
        defaults.setValue(score, forKey: scoreKey)
    }
    
    
    func loadHighScore(){
        let defaults = UserDefaults.standard
        highScore = defaults.double(forKey: scoreKey)
        highScoreLabel.text = "High Score: \(Int(highScore))"
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch:UITouch = touches.first! as UITouch
        
        isTouching = true
        touchLocation = touch.location(in: self)
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first! as UITouch
        
        isTouching = true
        touchLocation = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }
    
}




