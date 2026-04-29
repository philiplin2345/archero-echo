//
//  EnemyNode.swift
//  archero-echo
//
//  Basic melee enemy that chases the player.
//

import SpriteKit

enum EnemyType {
    case melee
    case ranged
    case magic
    case boss
}

class EnemyNode: SKSpriteNode {

    let type: EnemyType

    // MARK: - Health

    var maxHP: Int
    var currentHP: Int

    var isAlive: Bool { currentHP > 0 }

    // MARK: - Contact Damage Cooldown

    var lastContactDamageTime: TimeInterval = 0
    var lastFireTime: TimeInterval = 0

    // MARK: - Init

    init(type: EnemyType = .melee) {
        self.type = type
        
        let hp = type == .boss ? EnemyConfig.bossHP : EnemyConfig.hp
        self.maxHP = hp
        self.currentHP = hp
        
        let size = type == .boss ? EnemyConfig.bossSize : EnemyConfig.size
        
        let texture = SKTexture(imageNamed: type == .boss ? "boss_sprite" : "enemy_sprite")
        
        var nodeColor: UIColor = .systemRed
        switch type {
        case .melee, .boss: nodeColor = .systemRed
        case .ranged: nodeColor = .systemGreen
        case .magic: nodeColor = .systemCyan
        }
        
        super.init(texture: texture, color: nodeColor, size: size)
        colorBlendFactor = 1.0
        name = type == .boss ? "boss" : "enemy"
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

        let distance = position.distance(to: playerPosition)
        let dir = (playerPosition - position).normalized()
        
        // Rotate to face movement direction (or target if standing still)
        let angle = atan2(dir.y, dir.x)
        zRotation = angle - .pi / 2
        
        // Check if we should stop to shoot
        var shouldMove = true
        if type == .ranged && distance <= EnemyConfig.rangedRange {
            shouldMove = false
        } else if type == .magic && distance <= EnemyConfig.magicRange {
            shouldMove = false
        }
        
        if shouldMove {
            let speed = type == .boss ? EnemyConfig.bossSpeed : EnemyConfig.speed
            let velocity = dir * speed
            position = position + velocity * CGFloat(deltaTime)
        }
    }
    
    // MARK: - Shooting
    
    func tryShoot(targetPosition: CGPoint, currentTime: TimeInterval) -> BulletNode? {
        guard isAlive else { return nil }
        guard type == .ranged || type == .magic else { return nil }
        guard currentTime - lastFireTime >= EnemyConfig.fireRate else { return nil }
        
        let distance = position.distance(to: targetPosition)
        let inRange = (type == .ranged && distance <= EnemyConfig.rangedRange) ||
                      (type == .magic && distance <= EnemyConfig.magicRange)
        
        guard inRange else { return nil }
        
        lastFireTime = currentTime
        
        let direction = (targetPosition - position).normalized()
        let projectileType: ProjectileType = type == .ranged ? .enemyRanged : .enemyMagic
        
        let bullet = BulletNode(type: projectileType, direction: direction)
        bullet.position = position
        return bullet
    }

    // MARK: - Damage

    func takeDamage(_ amount: Int) {
        currentHP = max(0, currentHP - amount)

        // Flash white briefly
        let flashColor: UIColor = .white
        let originalColor: UIColor
        switch type {
        case .melee, .boss: originalColor = .systemRed
        case .ranged: originalColor = .systemGreen
        case .magic: originalColor = .systemCyan
        }
        
        let flashWhite = SKAction.colorize(with: flashColor, colorBlendFactor: 1.0, duration: 0.05)
        let flashBack = SKAction.colorize(with: originalColor, colorBlendFactor: 1.0, duration: 0.1)
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
