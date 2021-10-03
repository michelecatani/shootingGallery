//
//  Target.swift
//  shooting
//
//  Created by Michele Catani on 2021-09-03.
//

import UIKit
import SpriteKit

class Target: SKSpriteNode {
    var target: SKSpriteNode!
    
    func configure(at position: CGPoint, with scale: CGFloat, with speed: CGVector) {
        self.position = position
        
        let target = SKSpriteNode(imageNamed: "target")
        addChild(target)
       
        target.setScale(scale)
        target.physicsBody = SKPhysicsBody(texture: target.texture!, size: target.size)
        target.physicsBody?.velocity = speed
        target.physicsBody?.categoryBitMask = 1
        target.physicsBody?.linearDamping = 0
        target.zPosition = -0.5
        target.physicsBody?.affectedByGravity = false
    }
    
    func destroy() {
        self.removeFromParent()
    }
}
