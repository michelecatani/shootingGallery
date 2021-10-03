//
//  GameScene.swift
//  shooting
//
//  Created by Michele Catani on 2021-09-03.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var reload: SKLabelNode!
    var bulletsLabel: SKLabelNode!
    var outLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var gameOver: SKLabelNode!
    var newGameLabel: SKLabelNode!
    var newHighScoreLabel: SKLabelNode!
    
    var highScore: Int!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var timeLeft = 5 {
        didSet {
            timerLabel.text = "\(timeLeft)"
        }
    }
    var timeInterval = 1.0
    var bullets = 6 {
        didSet {
            if bullets == 0 {
                bulletsLabel.text = ""
            }
            else {
                bulletsLabel.text = ""
                for _ in 0..<bullets {
                    bulletsLabel.text?.append("|")
                }
            }
        }
    }
    
    var timer: Timer?
    var gameTimer: Timer?
    
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        
        let defaults = UserDefaults.standard
        highScore = defaults.integer(forKey: "highScore")
        
        let background = SKSpriteNode(imageNamed: "desert")
        background.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        background.size = self.frame.size
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        reload = SKLabelNode(fontNamed: "Chalkduster")
        reload.text = "RELOAD"
        reload.fontColor = .black
        reload.horizontalAlignmentMode = .right
        reload.position = CGPoint(x: 1000, y: 700)
        addChild(reload)
        
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.text = "60"
        timerLabel.fontColor = .black
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.position = CGPoint(x: self.frame.width / 2, y: 700)
        addChild(timerLabel)
        
        newHighScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        newHighScoreLabel.text = ""
        newHighScoreLabel.fontColor = .black
        newHighScoreLabel.horizontalAlignmentMode = .center
        newHighScoreLabel.position = CGPoint(x: self.frame.width / 2, y: (self.frame.height / 2) - 75)
        newHighScoreLabel.isHidden = true
        addChild(newHighScoreLabel)
        
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "Click here for new game!"
        newGameLabel.fontColor = .black
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.position = CGPoint(x: self.frame.width / 2, y: (self.frame.height / 2) - 25)
        newGameLabel.isHidden = true
        addChild(newGameLabel)
        
        gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver.text = "Game over!"
        gameOver.fontColor = .black
        gameOver.horizontalAlignmentMode = .center
        gameOver.position = CGPoint(x: self.frame.width / 2, y: (self.frame.height / 2) + 25)
        gameOver.isHidden = true
        addChild(gameOver)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: 98)
        addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        highScoreLabel.text = "Highscore: \(highScore ?? 0)"
        highScoreLabel.fontColor = .black
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.position = CGPoint(x: self.frame.width / 2, y: 48)
        addChild(highScoreLabel)
        
        bulletsLabel = SKLabelNode(fontNamed: "Chalkduster")
        bulletsLabel.text = "||||||"
        bulletsLabel.fontColor = .black
        bulletsLabel.horizontalAlignmentMode = .right
        bulletsLabel.position = CGPoint(x: 1000, y: 650)
        addChild(bulletsLabel)
        
        outLabel = SKLabelNode(fontNamed: "Chalkduster")
        outLabel.text = "OUT OF AMMO!"
        outLabel.fontColor = .black
        outLabel.horizontalAlignmentMode = .left
        outLabel.position = CGPoint(x: 24, y: 700)
        outLabel.isHidden = true
        addChild(outLabel)
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(newGameLabel) {
            newGame()
            return
        }
        
        if isGameOver {
            return
        }
        
        if tappedNodes.contains(reload) {
            run(SKAction.playSoundFileNamed("reload.mp3", waitForCompletion: true))
            bullets = 6
            outLabel.isHidden = true
            return
        }
        
        if bullets == 0 {
            outLabel.isHidden = false
            return
        }
        
        run(SKAction.playSoundFileNamed("gun.mp3", waitForCompletion: false))
        
        bullets -= 1
        
        for node in tappedNodes {
            guard let tappedTarget = node.parent as? Target else { continue }
            tappedTarget.destroy()
            score += 1
            if let fire = SKEmitterNode(fileNamed: "fire"){
                fire.position = location
                addChild(fire)
            }
        }
    }
    
    @objc func createTarget() {
        var possibleValues = [CGPoint(x: -100, y: self.frame.height / 4), CGPoint(x: -100, y: self.frame.height / 2), CGPoint(x: -100, y: self.frame.height * (3/4))]
        var possibleSizes = [0.075, 0.1, 0.125]
        var possibleSpeeds = [350, 400, 450]
        
        possibleValues.shuffle()
        possibleSizes.shuffle()
        possibleSpeeds.shuffle()
        
        let sprite = Target()
        sprite.configure(at: possibleValues[0], with: CGFloat(possibleSizes[0]), with: CGVector(dx: possibleSpeeds[0], dy: 0))
        
        timeInterval *= 0.99
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        
        addChild(sprite)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        for node in children {
            if node.position.x > 1000 {
                if let newNode = node as? Target {
                    newNode.removeFromParent()
                }
            }
        }
    }
    
    @objc func updateTimer() {
        timeLeft -= 1
        
        if timeLeft == 0 {
            run(SKAction.playSoundFileNamed("gameOver.m4a", waitForCompletion: false))
            isGameOver = true
            newGameLabel.isHidden = false
            gameOver.isHidden = false
            gameTimer?.invalidate()
            timer?.invalidate()
            
            if score > highScore {
                highScore = score
                newHighScoreLabel.text = "\(highScore!) is your new high score!"
                highScoreLabel.text = "Highscore: \(highScore ?? 0)"
                newHighScoreLabel.isHidden = false
                save()
            }
        }
    }
    
    @objc func newGame() {
        for node in children {
            if let newNode = node as? Target {
                newNode.removeFromParent()
            }
        }
        
        isGameOver = false
        
        newGameLabel.isHidden = true
        gameOver.isHidden = true
        newHighScoreLabel.isHidden = true
        outLabel.isHidden = true
        
        bullets = 6
        timeLeft = 60
        timeInterval = 1.0
        score = 0
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(highScore, forKey: "highScore")
    }
}
