//
//  BulletNode.swift
//  archero-echo
//
//  Player projectile that flies in a straight line.
//

import SpriteKit

enum ProjectileType {
    case player
    case enemyRanged
    case enemyMagic
}

class BulletNode: SKShapeNode {

    let type: ProjectileType
    let damage: Int = BulletConfig.damage
    let direction: CGPoint
    let bulletSpeed: CGFloat

    private var distanceTraveled: CGFloat = 0
    private var previousPosition: CGPoint = .zero

    // MARK: - Init

    init(type: ProjectileType, direction: CGPoint) {
        self.type = type
        self.direction = direction.normalized()
        self.bulletSpeed = type == .player ? BulletConfig.speed : BulletConfig.enemySpeed
        super.init()

        let path = CGMutablePath()
        path.addArc(center: .zero, radius: BulletConfig.radius,
                    startAngle: 0, endAngle: .pi * 2, clockwise: true)
        self.path = path

        switch type {
        case .player:
            fillColor = .systemYellow
            strokeColor = .systemOrange
        case .enemyRanged:
            fillColor = .systemGreen
            strokeColor = .green
        case .enemyMagic:
            fillColor = .systemCyan
            strokeColor = .systemBlue
        }
        
        lineWidth = 1
        glowWidth = 3
        name = type == .player ? "bullet" : "enemy_bullet"
        zPosition = ZPosition.projectile

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Physics

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: BulletConfig.radius)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0
        physicsBody?.restitution = 0
        physicsBody?.linearDamping = 0

        physicsBody?.categoryBitMask    = type == .player ? PhysicsCategory.bullet : PhysicsCategory.enemyProjectile
        physicsBody?.contactTestBitMask = type == .player ? PhysicsCategory.enemy : PhysicsCategory.player
        physicsBody?.collisionBitMask   = PhysicsCategory.none  // pass through everything
    }

    // MARK: - Movement

    /// Move the bullet forward. Called each frame.
    /// Returns false if the bullet should be removed (out of range).
    func fly(deltaTime: TimeInterval) -> Bool {
        let movement = direction * bulletSpeed * CGFloat(deltaTime)
        position = position + movement
        distanceTraveled += movement.length

        return distanceTraveled < BulletConfig.maxRange
    }
}
