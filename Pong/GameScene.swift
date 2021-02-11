//
//  GameScene.swift
//  Pong
//
//  Created by Randy Thai on 1/27/21.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let paddle : UInt32 = 0b1
    static let ball : UInt32 = 0b11
    static let border : UInt32 = 0b100
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scalar = 0
    var difficultyNum: Int = 0
    
    var ball = SKSpriteNode()
    var enemy = SKSpriteNode()
    var main = SKSpriteNode()
    
    var topLabel = SKLabelNode()
    var bottomLabel = SKLabelNode()
    
    var score = [Int]()
    
    override func didMove(to view: SKView) {
        
        topLabel = self.childNode(withName: "topLabel") as! SKLabelNode
        bottomLabel = self.childNode(withName: "bottomLabel") as! SKLabelNode
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
        main = self.childNode(withName: "main") as! SKSpriteNode
        
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.paddle | PhysicsCategory.border
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.paddle | PhysicsCategory.border
        ball.name = "Ball"
        
        main.physicsBody?.categoryBitMask = PhysicsCategory.paddle
        main.physicsBody?.collisionBitMask = PhysicsCategory.ball
        main.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        main.name = "Paddle"
        
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.paddle
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.ball
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        enemy.name = "Paddle"
        
        enemy.position.y = (self.frame.height/2) - 80
        enemy.physicsBody?.friction = 0.3
        
        main.position.y = (-self.frame.height/2) + 80
        main.physicsBody?.friction = 0.3
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        
        self.physicsBody = border
        self.physicsBody?.categoryBitMask = PhysicsCategory.border
        self.physicsBody?.collisionBitMask = PhysicsCategory.ball
        self.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        self.name = "Border"
        
        physicsWorld.contactDelegate = self
        
        startGame()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.name == "Border") || (contact.bodyB.node?.name == "Border"){
            return
        }
        let firstBody = contact.bodyA.node as! SKSpriteNode
        let secondBody = contact.bodyB.node as! SKSpriteNode
        
        if ((firstBody.name == "Paddle") && (secondBody.name == "Ball")){
            bounce(item: firstBody, ball: secondBody)
        }else if ((firstBody.name == "Ball") && (secondBody.name == "Paddle")){
            bounce(item: secondBody, ball: firstBody)
        }
    }
    
    func bounce(item: SKSpriteNode, ball: SKSpriteNode){
        print("Contact!  Impulse: \(scalar)")
        if(ball.position.y < 0){
            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: scalar))
        }else if ball.position.y > 0{
            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -scalar))
        }
        
        scalar += difficultyNum
        
    }
    
    func startGame() {
        score = [0,0]
        topLabel.text = "\(score[1])"
        bottomLabel.text = "\(score[0])"
        
        if Int.random(in: 1...2) == 1 {
            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        }else{
            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -10))
        }
        
    }
    
    func addScore(playerWhoWon: SKSpriteNode){
        
        scalar = 0
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        if playerWhoWon == main {
            score[0] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 10))
        } else if playerWhoWon == enemy {
            score[1] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -10...(-5)), dy: -10))
        }
        
        topLabel.text = "\(score[1])"
        bottomLabel.text = "\(score[0])"
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if currentGameType == .player2 {
                if location.y > 0 {
                    
                    enemy.run(SKAction.moveTo(x: location.x, duration: 0.05))
                    
                }
                if location.y < 0 {
                    
                    main.run(SKAction.moveTo(x: location.x, duration: 0.05))
                    
                }
            }else{
            
                main.run(SKAction.moveTo(x: location.x, duration: 0.05))
                
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if currentGameType == .player2 {
                if location.y > 0 {
                    
                    enemy.run(SKAction.moveTo(x: location.x, duration: 0.05))
                    
                }
                if location.y < 0 {
                    
                    main.run(SKAction.moveTo(x: location.x, duration: 0.05))
                    
                }
            }else{
            
                main.run(SKAction.moveTo(x: location.x, duration: 0.05))
                
            }
                        
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        switch currentGameType {
        case.easy:
            enemy.run(SKAction.moveTo(x: ball.position.x, duration: 0.3))
            difficultyNum = 1
            break
            
        case.medium:
            enemy.run(SKAction.moveTo(x: ball.position.x, duration: 0.2))
            difficultyNum = 1
            break
            
        case.hard:
            enemy.run(SKAction.moveTo(x: ball.position.x, duration: 0.1))
            difficultyNum = 2
            break
            
        case.player2:
            difficultyNum = 1
            break
        
        }
            
        if ball.position.y <= main.position.y - 30 {
            addScore(playerWhoWon: enemy)
        } else if ball.position.y >= enemy.position.y + 30 {
            addScore(playerWhoWon: main)
        } else if ball.position.y == enemy.position.y - 15 || ball.position.y == main.position.y + 15{
            
            ball.position = CGPoint(x: 0, y: 0)
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
        }
        
    }
    
}
