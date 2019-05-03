//
//  GameScene.swift
//  SchoolHouseSkateboarder
//
//  Created by Student on 4/1/19.
//  Copyright © 2019 Student. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1<<2
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum BrickLevel: CGFloat {
        case low = 0.0
        case high = 50.0
    }
    enum GameState {
        case notRunning
        case running
    }
    var bricks = [SKSpriteNode]()
    var gems = [SKSpriteNode]()
    var brickSize = CGSize.zero
    var brickLevel = BrickLevel.low
    var gameState = GameState.notRunning
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed: CGFloat = 5.0
    let gravitySpeed: CGFloat = 1.5
    var score: Int = 0
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    let friction: CGFloat = 0.25
    var lastUpdateTime: TimeInterval?
    let skater = Skater(imageNamed:"skater")
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self
        
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        setupLabels()
        
        skater.setupPhysicsBody()
        addChild(skater)
        
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        startGame()
//
//        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
//        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
//        menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
//        menuLayer.position = CGPoint(x: 0.0, y: 0.0)
//        menuLayer.zPosition = 30
//        menuLayer.name = "menuLayer"
//        menuLayer.display(message: "Tap to Play", score: nil)
//        addChild(menuLayer)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
           // print("Swipe Left")
            skater.position.x -= 10
            return
            //let labelPosition = CGPoint(x: skater.position.x - 50.0, y: swipeLabel.frame.origin.y)
            //swipeLabel.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: swipeLabel.frame.size.width, height: swipeLabel.frame.size.height)
        }
        
        if (sender.direction == .right) {
           // print("Swipe Right")
            skater.position.x += 10
            //let labelPosition = CGPoint(x: self.swipeLabel.frame.origin.x + 50.0, y: self.swipeLabel.frame.origin.y)
            //swipeLabel.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.swipeLabel.frame.size.width, height: self.swipeLabel.frame.size.height)
        }
    }
    
    
    
    func resetSkater() {
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x:skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx:0.0,dy:0.0)
        skater.physicsBody?.angularVelocity = 0.0
    }
    func setupLabels() {
        
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "score")
        scoreTextLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 14.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 14.0, y: frame.size.height - 40.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 18.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        let highscoreTextLabel: SKLabelNode = SKLabelNode(text: "high score")
        highscoreTextLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 20.0)
        highscoreTextLabel.horizontalAlignmentMode = .right
        highscoreTextLabel.fontName = "Courier-Bold"
        highscoreTextLabel.fontSize = 14.0
        highscoreTextLabel.zPosition = 20
        addChild(highscoreTextLabel)
        
        let highscoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highscoreLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 40.0)
        highscoreLabel.horizontalAlignmentMode = .right
        highscoreLabel.fontName = "Courier-Bold"
        highscoreLabel.fontSize = 18.0
        highscoreLabel.name = "highScoreLabel"
        highscoreLabel.zPosition = 20
        addChild(highscoreLabel)
    }
    func updateScoreLabelText() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = String(format: "%04d", score)
        }
    }
    func startGame() {
        gameState = .running
        resetSkater()
        score = 0
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        for brick in bricks{
             brick.removeFromParent()
        }
        
        bricks.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGem(gem)
        }
    }
    func gameOver() {
        gameState = .notRunning
        if score > highScore{
            highScore = score
            updateHighScoreLabelText()
        }
        startGame()
    }
    func spawnBrick (atPosition position: CGPoint) -> SKSpriteNode {
        let brick = SKSpriteNode (imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
        
        brickSize = brick.size
        bricks.append(brick)
        
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf:brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        return brick
    }
    func spawnGem(atPosition position: CGPoint) {
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        
        gems.append (gem)
    }
    func removeGem(_ gem: SKSpriteNode) {
        gem.removeFromParent()
        if let gemIndex = gems.index(of: gem) {
            gems.remove(at: gemIndex)
        }
    }
    func updateBricks(withScrollAmount currentScrollAmound: CGFloat) {
        var farthestRightBrickX: CGFloat = 0.0
        
        for brick in bricks {
            let newX = brick.position.x - currentScrollAmound
            
            if newX < -brickSize.width {
                
                brick.removeFromParent()
                
                if let brickIndex = bricks.index(of: brick) {
                    bricks.remove(at: brickIndex)
                }
            } else {
                
                
                brick.position = CGPoint (x: newX, y: brick.position.y)
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        while farthestRightBrickX < frame.width {
            var brickX = farthestRightBrickX + brickSize.width + 1.0
            let brickY = (brickSize.height / 2.0) + brickLevel.rawValue
            
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 5 && score > 10 {
                let gap = 20.0 * scrollSpeed
                brickX += gap
                
                let randomGemYAmount = CGFloat (arc4random_uniform(150))
                let newGemY = brickY + skater.size.height + randomGemYAmount
                let newGemX = brickX - gap / 2.0
                
                spawnGem(atPosition: CGPoint(x:newGemX, y: newGemY))
            }
            else if randomNumber < 10 && score > 20 {
                if brickLevel == .high {
                    brickLevel = .low
                }
                else if brickLevel == .low {
                    brickLevel = .high
                }
            }
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
            
        }
    }
    func updateGems(withScrollAmount currentScrollAmount: CGFloat) {
        for gem in gems {
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)
            
            if gem.position.x < 0.0 {
                removeGem(gem)
            }
        }
    }
    func updateSkater() {
        if let velocityY = skater.physicsBody?.velocity.dy {
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = false
            }
        }
        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
        
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        
        if isOffScreen || isTippedOver {
            gameOver()
        }
    }
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        let elapsedTime = currentTime - lastScoreUpdateTime
        
        if elapsedTime > 1.0 {
            score += Int(scrollSpeed)
            
            lastScoreUpdateTime = currentTime
            
            updateScoreLabelText()
        }
    }
    func updateHighScoreLabelText() {
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
        
    }
    override func update(_ currentTime: TimeInterval) {
        
        // Called before each frame is rendered
        scrollSpeed += 0.01
        var elapsedTime: TimeInterval = 0.0
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0/60.0
        
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        
        updateBricks(withScrollAmount: currentScrollAmount)
        
        updateSkater()
        
        updateGems(withScrollAmount: currentScrollAmount)
        updateScore(withCurrentTime: currentTime)
    }
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        if skater.isOnGround {
            skater.physicsBody?.applyImpulse(CGVector(dx:0.0,dy:100.0))
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            skater.isOnGround = true
        }
        else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            if let gem = contact.bodyB.node as? SKSpriteNode {
                removeGem(gem)
                
                score += 50
                updateScoreLabelText()
            }
        }
    }
}
