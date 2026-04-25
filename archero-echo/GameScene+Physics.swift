//
//  GameScene+Physics.swift
//  archero-echo
//
//  Physics contact handling — bullet↔enemy and enemy↔player collisions.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // MARK: - Bullet ↔ Enemy

        if collision == PhysicsCategory.bullet | PhysicsCategory.enemy {
            let bulletNode: BulletNode
            let enemyNode: EnemyNode

            if let b = contact.bodyA.node as? BulletNode, let e = contact.bodyB.node as? EnemyNode {
                bulletNode = b
                enemyNode = e
            } else if let b = contact.bodyB.node as? BulletNode, let e = contact.bodyA.node as? EnemyNode {
                bulletNode = b
                enemyNode = e
            } else {
                return
            }

            // Deal damage
            enemyNode.takeDamage(bulletNode.damage)
            removeBullet(bulletNode)

            // Create hit particle
            spawnHitParticle(at: contact.contactPoint, color: .systemYellow)

            if !enemyNode.isAlive {
                notifyEnemyKilled()
                spawnDeathParticle(at: enemyNode.position)
            }
        }

        // MARK: - Enemy ↔ Player

        if collision == PhysicsCategory.enemy | PhysicsCategory.player {
            let enemyNode: EnemyNode

            if let e = contact.bodyA.node as? EnemyNode {
                enemyNode = e
            } else if let e = contact.bodyB.node as? EnemyNode {
                enemyNode = e
            } else {
                return
            }

            guard enemyNode.isAlive else { return }

            // Check cooldown to prevent damage spam
            let currentTime = CACurrentMediaTime()
            guard currentTime - enemyNode.lastContactDamageTime >= EnemyConfig.contactCooldown else { return }
            enemyNode.lastContactDamageTime = currentTime

            // Damage the player
            let playerNode = self.children
                .compactMap { ($0 as? SKNode)?.childNode(withName: "player") as? PlayerNode }
                .first ?? (self.childNode(withName: "//player") as? PlayerNode)

            // Fallback: access player from the gameplay layer
            if let player = findPlayer() {
                player.takeDamage(EnemyConfig.damage)
                spawnHitParticle(at: contact.contactPoint, color: .systemRed)

                if !player.isAlive {
                    triggerGameOver()
                }
            }
        }
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
