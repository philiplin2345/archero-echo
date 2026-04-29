//
//  PowerupNode.swift
//  archero-echo
//
//  A collectible powerup that permanently adds a projectile to the player.
//

import SpriteKit

class PowerupNode: SKShapeNode {
    
    // MARK: - Init
    
    override init() {
        super.init()
        
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: PowerupConfig.radius,
                    startAngle: 0, endAngle: .pi * 2, clockwise: true)
        self.path = path
        
        fillColor = .systemYellow
        strokeColor = .white
        lineWidth = 2
        glowWidth = 4
        name = "powerup"
        zPosition = ZPosition.projectile // Or a new layer like ZPosition.powerup
        
        setupPhysics()
        startPulsing()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Physics
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: PowerupConfig.radius)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.powerup
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    // MARK: - Animation
    
    private func startPulsing() {
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        run(SKAction.repeatForever(pulse))
    }
}
