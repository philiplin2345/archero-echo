//
//  PlayerNode.swift
//  archero-echo
//
//  Player character: movement, auto-shooting, health management.
//

import SpriteKit

class PlayerNode: SKSpriteNode {

    // MARK: - Health

    var maxHP: Int = PlayerConfig.maxHP
    var currentHP: Int = PlayerConfig.maxHP

    var isAlive: Bool { currentHP > 0 }

    // MARK: - Shooting

    private var lastFireTime: TimeInterval = 0
    var canShoot: Bool = true

    // MARK: - Init

    init() {
        let texture = SKTexture(imageNamed: "player_sprite")
        super.init(texture: texture, color: .systemCyan, size: PlayerConfig.size)
        // If no asset exists, colorBlendFactor makes it show the color
        colorBlendFactor = 1.0
        name = "player"
        zPosition = ZPosition.player

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

        physicsBody?.categoryBitMask    = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask   = PhysicsCategory.boundary
    }

    // MARK: - Movement

    /// Move the player in the given direction. Called each frame.
    func move(direction: CGPoint, deltaTime: TimeInterval) {
        let velocity = direction * PlayerConfig.speed
        position = position + velocity * CGFloat(deltaTime)
    }

    // MARK: - Shooting

    /// Try to auto-shoot at the nearest enemy. Returns a BulletNode if fired, nil otherwise.
    func tryShoot(enemies: [EnemyNode], currentTime: TimeInterval) -> BulletNode? {
        guard isAlive, canShoot else { return nil }
        guard currentTime - lastFireTime >= PlayerConfig.fireRate else { return nil }
        guard let target = nearestEnemy(from: enemies) else { return nil }

        lastFireTime = currentTime

        let direction = (target.position - position).normalized()
        let bullet = BulletNode(direction: direction)
        bullet.position = position
        return bullet
    }

    /// Find the nearest alive enemy.
    private func nearestEnemy(from enemies: [EnemyNode]) -> EnemyNode? {
        var closest: EnemyNode?
        var closestDist: CGFloat = .infinity

        for enemy in enemies where enemy.isAlive {
            let dist = position.distance(to: enemy.position)
            if dist < closestDist {
                closestDist = dist
                closest = enemy
            }
        }
        return closest
    }

    // MARK: - Damage

    func takeDamage(_ amount: Int) {
        currentHP = max(0, currentHP - amount)
        
        // Flash red briefly
        let flashRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.05)
        let flashBack = SKAction.colorize(with: .systemCyan, colorBlendFactor: 1.0, duration: 0.15)
        run(SKAction.sequence([flashRed, flashBack]))
    }

    func heal(_ amount: Int) {
        currentHP = min(maxHP, currentHP + amount)
    }
}
