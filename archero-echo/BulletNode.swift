//
//  BulletNode.swift
//  archero-echo
//
//  Player projectile that flies in a straight line.
//

import SpriteKit

class BulletNode: SKShapeNode {

    let damage: Int = BulletConfig.damage
    let direction: CGPoint
    let bulletSpeed: CGFloat = BulletConfig.speed

    private var distanceTraveled: CGFloat = 0
    private var previousPosition: CGPoint = .zero

    // MARK: - Init

    init(direction: CGPoint) {
        self.direction = direction.normalized()
        super.init()

        let path = CGMutablePath()
        path.addArc(center: .zero, radius: BulletConfig.radius,
                    startAngle: 0, endAngle: .pi * 2, clockwise: true)
        self.path = path

        fillColor = .systemYellow
        strokeColor = .systemOrange
        lineWidth = 1
        glowWidth = 3
        name = "bullet"
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

        physicsBody?.categoryBitMask    = PhysicsCategory.bullet
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
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
