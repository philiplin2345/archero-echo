//
//  EnemyNode.swift
//  archero-echo
//
//  Basic melee enemy that chases the player.
//

import SpriteKit

class EnemyNode: SKSpriteNode {

    // MARK: - Health

    var maxHP: Int = EnemyConfig.hp
    var currentHP: Int = EnemyConfig.hp

    var isAlive: Bool { currentHP > 0 }

    // MARK: - Contact Damage Cooldown

    var lastContactDamageTime: TimeInterval = 0

    // MARK: - Init

    init() {
        let texture = SKTexture(imageNamed: "enemy_sprite")
        super.init(texture: texture, color: .systemRed, size: EnemyConfig.size)
        colorBlendFactor = 1.0
        name = "enemy"
        zPosition = ZPosition.enemy

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Physics

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.friction = 0
        physicsBody?.restitution = 0
        physicsBody?.linearDamping = 0

        physicsBody?.categoryBitMask    = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        physicsBody?.collisionBitMask   = PhysicsCategory.boundary | PhysicsCategory.enemy
    }

    // MARK: - AI: Chase Player

    /// Move toward the player position. Called each frame.
    func chase(playerPosition: CGPoint, deltaTime: TimeInterval) {
        guard isAlive else { return }

        let dir = (playerPosition - position).normalized()
        let velocity = dir * EnemyConfig.speed
        position = position + velocity * CGFloat(deltaTime)

        // Rotate to face movement direction
        let angle = atan2(dir.y, dir.x)
        zRotation = angle - .pi / 2
    }

    // MARK: - Damage

    func takeDamage(_ amount: Int) {
        currentHP = max(0, currentHP - amount)

        // Flash white briefly
        let flashWhite = SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05)
        let flashBack = SKAction.colorize(with: .systemRed, colorBlendFactor: 1.0, duration: 0.1)
        run(SKAction.sequence([flashWhite, flashBack]))

        if !isAlive {
            die()
        }
    }

    private func die() {
        physicsBody = nil

        // Death animation: shrink + fade
        let shrink = SKAction.scale(to: 0, duration: 0.2)
        let fade = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([shrink, fade])
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([group, remove]))
    }
}
