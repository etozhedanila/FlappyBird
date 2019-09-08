//
//  GameScene.swift
//  Flappy Game
//
//  Created by Виталий Субботин on 19/08/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import SpriteKit

enum Background: String {
    case town
    case land
}


class GameScene: SKScene {
    let pipesVerticalGap: Double = 175
    
    var pipesSpawned = 0
    var finalSpawnNumber = 100
    
    var scores: Int = 0 {
        didSet {
            scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.1), SKAction.scale(to: 1, duration: 0.1)]))
            scoreLabelNode.text = "\(scores)"
        }
    }
    var scoreLabelNode: SKLabelNode!
    var gameOverLabelNode: SKLabelNode!
    
    var hero: SKSpriteNode!
    var moving: SKNode!
    var pipes: SKNode!
    
    let townTexture = SKTexture(imageNamed: "town")
    let landTexture = SKTexture(imageNamed: "land")
    let bottomPipeTexture = SKTexture(imageNamed: "bottomPipe")
    let topPipeTexture = SKTexture(imageNamed: "topPipe")
    
    var finalImageNode: SKSpriteNode!
    
    
    
    let heroCategoryMask: UInt32 = 1 << 0
    let landCategoryMask: UInt32 = 1 << 1
    let pipeCategoryMask: UInt32 = 1 << 2
    let scoreCategoryMask: UInt32 = 1 << 3
    
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        
        self.backgroundColor = SKColor(red: 0.1, green: 0.55, blue: 0.8, alpha: 1.0)
        
        townTexture.filteringMode = .nearest
        landTexture.filteringMode = .nearest
        bottomPipeTexture.filteringMode = .nearest
        topPipeTexture.filteringMode = .nearest
        
        moving = SKNode()
        
        self.addChild(moving)
        pipes = SKNode()
        moving.addChild(pipes)
        startGame()

        
    }
    
    private func startGame() {

        
        moveTexture(texture: landTexture, type: .land)
        moveTexture(texture: townTexture, type: .town)
        
        movePipes()
        
        setupHero()
        
        setupLand()
        
        configureLabels()
    }
    
    private func moveTexture(texture: SKTexture, type: Background) {

       
        let moveSprite = SKAction.moveBy(x: -texture.size().width , y: 0, duration: TimeInterval(0.05 * texture.size().width))
        let resetSprite = SKAction.moveBy(x: texture.size().width , y: 0, duration: 0)
        let moveForever = SKAction.repeatForever(SKAction.sequence([moveSprite, resetSprite]))
        
        for i in 0..<2  {
            let sprite = SKSpriteNode(texture: texture)
            sprite.setScale(2)
            var y = sprite.size.height / 2
            if type == .town {
                sprite.zPosition = -100
                y += landTexture.size().height * 2
            }
            sprite.position = CGPoint(x: CGFloat(i) * sprite.size.width, y: y)
            sprite.run(moveForever)
            self.moving.addChild(sprite)
        }
    }
    
    private func movePipes() {
        
        
        let spawn = SKAction.run(spawnPipes)
        let wait = SKAction.wait(forDuration: 3)
        let spawnForever = SKAction.repeatForever(SKAction.sequence([spawn,wait]))
        self.run(spawnForever)
    }
    
    private func spawnPipes() {
        if pipesSpawned == finalSpawnNumber {
            return
        }
        
        let tmpPipes = SKNode()
        tmpPipes.zPosition = -10
        tmpPipes.position = CGPoint(x: self.frame.size.width + topPipeTexture.size().width, y: 0)
        
        
        let yPosition = Double.random(in: 0...Double(self.frame.size.height / 4)) + Double(self.frame.size.height / 8)
        
        let topPipe = SKSpriteNode(texture: topPipeTexture)

        topPipe.setScale(2)
        topPipe.position = CGPoint(x: 0, y: yPosition + pipesVerticalGap + Double(topPipe.size.height))
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategoryMask
        
        tmpPipes.addChild(topPipe)
        
        let bottomPipe = SKSpriteNode(texture: bottomPipeTexture)

        bottomPipe.setScale(2)
        bottomPipe.position = CGPoint(x: 0, y: yPosition)
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = pipeCategoryMask
        
        tmpPipes.addChild(bottomPipe)
        

        let beerTexture: SKTexture
        let scale: CGFloat
        if pipesSpawned < finalSpawnNumber - 1 {
            let textureName = Int.random(in: 0...1) == 1 ? "beer" : "pizza"
            beerTexture = SKTexture(imageNamed: textureName)
            scale = 0.065
        }
        else {
            beerTexture = SKTexture(imageNamed: "nastya")
            scale = 0.3
        }
        
        beerTexture.filteringMode = .nearest
        let scoreGate = SKSpriteNode(texture: beerTexture)
        
        scoreGate.setScale(scale)
        scoreGate.position = CGPoint(x: Double(topPipe.frame.midX), y: yPosition + pipesVerticalGap / 2 + Double(topPipe.size.height / 2))
        
        scoreGate.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: topPipe.size.width, height: 100))
        
        scoreGate.physicsBody?.isDynamic = false
        scoreGate.physicsBody?.categoryBitMask = scoreCategoryMask
        scoreGate.physicsBody?.contactTestBitMask = heroCategoryMask
        tmpPipes.addChild(scoreGate)
        
        let distance = self.frame.width + 2 * topPipeTexture.size().width
        let move = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(distance * 0.01))
        let remove = SKAction.removeFromParent()
        tmpPipes.run(SKAction.sequence([move,remove]))
        
        pipes.addChild(tmpPipes)
        
        pipesSpawned += 1
    }
    
    private func setupHero() {
        let heroTexture = SKTexture(imageNamed: "hero")
        heroTexture.filteringMode = .nearest
        hero = SKSpriteNode(texture: heroTexture)
        hero.setScale(0.2)
        hero.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height * 0.8)
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.height / 2)
        hero.physicsBody?.isDynamic = true
        hero.physicsBody?.categoryBitMask = heroCategoryMask
        hero.physicsBody?.collisionBitMask = landCategoryMask | pipeCategoryMask
        hero.physicsBody?.contactTestBitMask = landCategoryMask | pipeCategoryMask
        
        self.addChild(hero)
    }
    
    private func setupLand() {
        let land = SKNode()
        land.position = CGPoint(x: 0, y: landTexture.size().height)
        land.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: landTexture.size().height * 2))
        land.physicsBody?.categoryBitMask = landCategoryMask
        land.physicsBody?.isDynamic = false
        
        self.addChild(land)
    }
    
    private func configureLabels() {
        scoreLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabelNode.zPosition = 10
        scoreLabelNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY * 1.5)
        scoreLabelNode.text = "\(scores)"
        
        self.addChild(scoreLabelNode)
        
        gameOverLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabelNode.zPosition = 100
        gameOverLabelNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY * 1.65)
        gameOverLabelNode.alpha = 0

        let text = "WASTED"
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = CGSize(width: 3, height: 3)
        shadow.shadowColor = UIColor.gray
        
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 55), NSAttributedString.Key.shadow: shadow]
    
        let attributedText = NSMutableAttributedString(string: text, attributes: attributes as [NSAttributedString.Key : Any])
        

        gameOverLabelNode.attributedText = attributedText
        
        
        self.addChild(gameOverLabelNode)
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moving.speed > 0 {
            
            hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
            
        }
        else {
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.restart()
            }
            
        }
    }
    
    private func restart() {

        scoreLabelNode.alpha = 1
        gameOverLabelNode.alpha = 0
        finalImageNode.alpha = 0
        pipesSpawned = 0
        
        isUserInteractionEnabled = true
        pipes.removeAllChildren()
        finalImageNode.removeFromParent()
        hero.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height * 0.8)

        scores = 0
        
        movePipes()
        moving.speed = 1
    }
    
    override func update(_ currentTime: TimeInterval) {
        let rotation = hero.physicsBody!.velocity.dy * 0.002
        hero.zRotation = rotation
        
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if moving.speed > 0 {
            
            if contact.bodyA.categoryBitMask == scoreCategoryMask || contact.bodyB.categoryBitMask == scoreCategoryMask {
                
                scores += 1
                contact.bodyA.node?.removeFromParent()
                
                if scores == finalSpawnNumber {
                    finishGame()
                }

            }
            else {
                
                finishGame()

            }
        }
        
    }
    
    private func finishGame() {
        
        scoreLabelNode.alpha = 0
        
        moving.speed = 0
        
        let finalImageName = scores == finalSpawnNumber ? "hero2" : "wasted"
        finalImageNode = SKSpriteNode(texture: SKTexture(imageNamed: finalImageName))
        finalImageNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        finalImageNode.zPosition = 100
        finalImageNode.setScale(0.5)
        finalImageNode.alpha = 0
        
        self.addChild(finalImageNode)
        
        if scores == finalSpawnNumber {
            finalImageNode.setScale(0.01)
            finalImageNode.alpha = 1
            finalImageNode.run(SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: 0.5))
            finalImageNode.run(SKAction.scale(to: 0.5, duration: 0.5))
            
        }
        else {
            finalImageNode.alpha = 1
            gameOverLabelNode.alpha = 1
            print("game over")
        }
        
        self.removeAllActions()
    }
    
    
}
