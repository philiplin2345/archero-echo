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
    var projectileCount: Int = 1

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

    /// Try to auto-shoot at the nearest enemy. Returns an array of BulletNodes if fired, empty otherwise.
    func tryShoot(enemies: [EnemyNode], currentTime: TimeInterval) -> [BulletNode] {
        guard isAlive, canShoot else { return [] }
        guard currentTime - lastFireTime >= PlayerConfig.fireRate else { return [] }
        guard let target = nearestEnemy(from: enemies) else { return [] }

        lastFireTime = currentTime

        let baseDirection = (target.position - position).normalized()
        var bullets: [BulletNode] = []
        
        // Spread angle in radians (e.g., 15 degrees)
        let spreadAngle: CGFloat = 15.0 * .pi / 180.0
        let startAngle = -CGFloat(projectileCount - 1) * spreadAngle / 2.0
        
        let baseAngle = atan2(baseDirection.y, baseDirection.x)
        
        for i in 0..<projectileCount {
            let angle = baseAngle + startAngle + CGFloat(i) * spreadAngle
            let dir = CGPoint(x: cos(angle), y: sin(angle))
            let bullet = BulletNode(type: .player, direction: dir)
            bullet.position = position
            bullets.append(bullet)
        }
        
        return bullets
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
    
    // MARK: - Powerups
    
    func collectPowerup() {
        projectileCount += 1
        
        // Flash yellow briefly to indicate powerup collection
        let flash = SKAction.colorize(with: .systemYellow, colorBlendFactor: 1.0, duration: 0.1)
        let flashBack = SKAction.colorize(with: .systemCyan, colorBlendFactor: 1.0, duration: 0.2)
        run(SKAction.sequence([flash, flashBack]))
    }
}
