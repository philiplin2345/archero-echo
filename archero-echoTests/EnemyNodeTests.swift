//
//  EnemyNodeTests.swift
//  archero-echoTests
//
//  Unit tests for EnemyNode: health, damage, death, and chase behavior.
//

import Testing
import SpriteKit
@testable import archero_echo

struct EnemyNodeTests {

    // MARK: - Initialization

    @Test func enemyInitializesWithCorrectHP() {
        let enemy = EnemyNode()

        #expect(enemy.currentHP == EnemyConfig.hp)
        #expect(enemy.maxHP == EnemyConfig.hp)
    }

    @Test func enemyStartsAlive() {
        let enemy = EnemyNode()

        #expect(enemy.isAlive == true)
    }

    @Test func enemyHasCorrectName() {
        let enemy = EnemyNode()

        #expect(enemy.name == "enemy")
    }

    @Test func enemyHasCorrectSize() {
        let enemy = EnemyNode()

        #expect(enemy.size == EnemyConfig.size)
    }

    // MARK: - Damage

    @Test func takeDamageReducesHP() {
        let enemy = EnemyNode()
        let damage = 10

        enemy.takeDamage(damage)

        #expect(enemy.currentHP == EnemyConfig.hp - damage)
    }

    @Test func takeDamageMultipleHitsAccumulate() {
        let enemy = EnemyNode()

        enemy.takeDamage(5)
        enemy.takeDamage(5)
        enemy.takeDamage(5)

        #expect(enemy.currentHP == EnemyConfig.hp - 15)
    }

    @Test func hpDoesNotGoBelowZero() {
        let enemy = EnemyNode()
        let massiveDamage = EnemyConfig.hp + 100

        enemy.takeDamage(massiveDamage)

        #expect(enemy.currentHP == 0)
    }

    @Test func zeroDamageDoesNotChangeHP() {
        let enemy = EnemyNode()

        enemy.takeDamage(0)

        #expect(enemy.currentHP == EnemyConfig.hp)
    }

    // MARK: - Death

    @Test func enemyDiesWhenHPReachesZero() {
        let enemy = EnemyNode()

        enemy.takeDamage(EnemyConfig.hp)

        #expect(enemy.isAlive == false)
        #expect(enemy.currentHP == 0)
    }

    @Test func enemyStaysAliveWithOneHP() {
        let enemy = EnemyNode()

        enemy.takeDamage(EnemyConfig.hp - 1)

        #expect(enemy.isAlive == true)
        #expect(enemy.currentHP == 1)
    }

    @Test func enemyPhysicsBodyRemovedOnDeath() {
        let enemy = EnemyNode()

        enemy.takeDamage(EnemyConfig.hp)

        #expect(enemy.physicsBody == nil)
    }

    // MARK: - Chase Behavior

    @Test func chaseMovesEnemyTowardPlayer() {
        let enemy = EnemyNode()
        enemy.position = CGPoint(x: 0, y: 0)
        let playerPosition = CGPoint(x: 100, y: 0)

        enemy.chase(playerPosition: playerPosition, deltaTime: 1.0)

        // Enemy should have moved to the right (positive x)
        #expect(enemy.position.x > 0)
    }

    @Test func chaseDoesNotMoveDeadEnemy() {
        let enemy = EnemyNode()
        enemy.position = CGPoint(x: 0, y: 0)
        let originalPosition = enemy.position

        // Kill the enemy first
        enemy.takeDamage(EnemyConfig.hp)

        // Try to chase
        enemy.chase(playerPosition: CGPoint(x: 100, y: 0), deltaTime: 1.0)

        // Position should not have changed
        #expect(enemy.position.x == originalPosition.x)
        #expect(enemy.position.y == originalPosition.y)
    }

    @Test func chaseMovesByCorrectSpeed() {
        let enemy = EnemyNode()
        enemy.position = CGPoint(x: 0, y: 0)
        let deltaTime: TimeInterval = 1.0

        // Chase directly to the right
        enemy.chase(playerPosition: CGPoint(x: 1000, y: 0), deltaTime: deltaTime)

        // Should have moved approximately EnemyConfig.speed points
        let expectedX = EnemyConfig.speed * CGFloat(deltaTime)
        #expect(abs(enemy.position.x - expectedX) < 1.0)
    }

    // MARK: - Physics Setup

    @Test func enemyHasPhysicsBody() {
        let enemy = EnemyNode()

        #expect(enemy.physicsBody != nil)
    }

    @Test func enemyPhysicsCategoryIsCorrect() {
        let enemy = EnemyNode()

        #expect(enemy.physicsBody?.categoryBitMask == PhysicsCategory.enemy)
    }

    @Test func enemyDetectsContactWithBulletsAndPlayer() {
        let enemy = EnemyNode()
        let expectedMask = PhysicsCategory.bullet | PhysicsCategory.player

        #expect(enemy.physicsBody?.contactTestBitMask == expectedMask)
    }

    // MARK: - Contact Damage Cooldown

    @Test func contactDamageTimeStartsAtZero() {
        let enemy = EnemyNode()

        #expect(enemy.lastContactDamageTime == 0)
    }
}
