//
//  GameScene+Physics.swift
//  archero-echo
//
//  Physics contact handling — bullet↔enemy and enemy↔player collisions.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        let categoryA = contact.bodyA.categoryBitMask
        let categoryB = contact.bodyB.categoryBitMask
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        // Helper to check pairs
        func isPair(_ type1: UInt32, _ type2: UInt32) -> Bool {
            return (categoryA == type1 && categoryB == type2) || (categoryA == type2 && categoryB == type1)
        }
        
        // Helper to extract nodes
        func extract<T, U>(_ type1: UInt32, _ type2: UInt32) -> (T?, U?) {
            if categoryA == type1 && categoryB == type2 {
                return (nodeA as? T, nodeB as? U)
            } else {
                return (nodeB as? T, nodeA as? U)
            }
        }

        // 1. Player Bullet ↔ Enemy
        if isPair(PhysicsCategory.bullet, PhysicsCategory.enemy) {
            let (bullet, enemy) = extract(PhysicsCategory.bullet, PhysicsCategory.enemy) as (BulletNode?, EnemyNode?)
            if let bullet = bullet, let enemy = enemy {
                bulletHitEnemy(bullet: bullet, enemy: enemy, contactPoint: contact.contactPoint)
            }
        }
        
        // 2. Player ↔ Enemy (Melee)
        else if isPair(PhysicsCategory.player, PhysicsCategory.enemy) {
            let (player, enemy) = extract(PhysicsCategory.player, PhysicsCategory.enemy) as (PlayerNode?, EnemyNode?)
            if let player = player, let enemy = enemy {
                playerHitByEnemy(player: player, enemy: enemy, contactPoint: contact.contactPoint)
            }
        }
        
        // 3. Player ↔ Enemy Projectile (Ranged/Magic)
        else if isPair(PhysicsCategory.player, PhysicsCategory.enemyProjectile) {
            let (player, projectile) = extract(PhysicsCategory.player, PhysicsCategory.enemyProjectile) as (PlayerNode?, BulletNode?)
            if let player = player, let projectile = projectile {
                playerHitByProjectile(player: player, projectile: projectile, contactPoint: contact.contactPoint)
            }
        }
        
        // 4. Player ↔ Powerup
        else if isPair(PhysicsCategory.player, PhysicsCategory.powerup) {
            let (player, powerup) = extract(PhysicsCategory.player, PhysicsCategory.powerup) as (PlayerNode?, PowerupNode?)
            if let player = player, let powerup = powerup {
                playerCollectedPowerup(player: player, powerup: powerup)
            }
        }
    }
    
    // MARK: - Collision Handlers
    
    private func bulletHitEnemy(bullet: BulletNode, enemy: EnemyNode, contactPoint: CGPoint) {
        enemy.takeDamage(bullet.damage)
        removeBullet(bullet)
        spawnHitParticle(at: contactPoint, color: .systemYellow)

        if !enemy.isAlive {
            notifyEnemyKilled(at: enemy.position)
            spawnDeathParticle(at: enemy.position)
        }
    }
    
    private func playerHitByEnemy(player: PlayerNode, enemy: EnemyNode, contactPoint: CGPoint) {
        guard enemy.isAlive else { return }

        let currentTime = CACurrentMediaTime()
        guard currentTime - enemy.lastContactDamageTime >= EnemyConfig.contactCooldown else { return }
        
        enemy.lastContactDamageTime = currentTime
        player.takeDamage(EnemyConfig.damage)
        spawnHitParticle(at: contactPoint, color: .systemRed)

        if !player.isAlive {
            triggerGameOver()
        }
    }
    
    private func playerHitByProjectile(player: PlayerNode, projectile: BulletNode, contactPoint: CGPoint) {
        player.takeDamage(projectile.damage)
        removeBullet(projectile)
        spawnHitParticle(at: contactPoint, color: .systemRed)
        
        if !player.isAlive {
            triggerGameOver()
        }
    }
    
    private func playerCollectedPowerup(player: PlayerNode, powerup: PowerupNode) {
        player.collectPowerup()
        powerup.removeFromParent()
    }

    // MARK: - Find Player Helper

    private func findPlayer() -> PlayerNode? {
        // Search the gameplay layer for the player node
        for child in children {
            if let player = child as? PlayerNode {
                return player
            }
            for grandchild in child.children {
                if let player = grandchild as? PlayerNode {
                    return player
                }
            }
        }
        return nil
    }

    // MARK: - Visual Effects

    private func spawnHitParticle(at position: CGPoint, color: SKColor) {
        let particleCount = 6
        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            particle.fillColor = color
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = ZPosition.projectile + 1
            addChild(particle)

            let angle = CGFloat.random(in: 0 ..< .pi * 2)
            let distance = CGFloat.random(in: 15...35)
            let dest = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )
            let move = SKAction.move(to: dest, duration: 0.2)
            let fade = SKAction.fadeOut(withDuration: 0.2)
            let shrink = SKAction.scale(to: 0, duration: 0.25)
            let group = SKAction.group([move, fade, shrink])
            particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        }
    }

    private func spawnDeathParticle(at position: CGPoint) {
        let particleCount = 12
        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            particle.fillColor = .systemOrange
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = ZPosition.projectile + 1
            addChild(particle)

            let angle = CGFloat.random(in: 0 ..< .pi * 2)
            let distance = CGFloat.random(in: 25...60)
            let dest = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )
            let move = SKAction.move(to: dest, duration: 0.35)
            let fade = SKAction.fadeOut(withDuration: 0.35)
            let shrink = SKAction.scale(to: 0, duration: 0.4)
            let group = SKAction.group([move, fade, shrink])
            particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        }
    }
}
