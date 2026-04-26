//
//  PlayerNodeTests.swift
//  archero-echoTests
//
//  Unit tests for PlayerNode: health, damage, healing, movement, and shooting.
//

import Testing
import SpriteKit
@testable import archero_echo

struct PlayerNodeTests {

    // MARK: - Initialization

    @Test func playerInitializesWithCorrectHP() {
        let player = PlayerNode()

        #expect(player.currentHP == PlayerConfig.maxHP)
        #expect(player.maxHP == PlayerConfig.maxHP)
    }

    @Test func playerStartsAlive() {
        let player = PlayerNode()

        #expect(player.isAlive == true)
    }

    @Test func playerHasCorrectName() {
        let player = PlayerNode()

        #expect(player.name == "player")
    }

    @Test func playerHasCorrectSize() {
        let player = PlayerNode()

        #expect(player.size == PlayerConfig.size)
    }

    @Test func playerCanShootByDefault() {
        let player = PlayerNode()

        #expect(player.canShoot == true)
    }

    // MARK: - Damage

    @Test func takeDamageReducesHP() {
        let player = PlayerNode()
        let damage = 25

        player.takeDamage(damage)

        #expect(player.currentHP == PlayerConfig.maxHP - damage)
    }

    @Test func takeDamageMultipleHitsAccumulate() {
        let player = PlayerNode()

        player.takeDamage(10)
        player.takeDamage(20)
        player.takeDamage(30)

        #expect(player.currentHP == PlayerConfig.maxHP - 60)
    }

    @Test func hpDoesNotGoBelowZero() {
        let player = PlayerNode()

        player.takeDamage(PlayerConfig.maxHP + 500)

        #expect(player.currentHP == 0)
    }

    @Test func playerDiesWhenHPReachesZero() {
        let player = PlayerNode()

        player.takeDamage(PlayerConfig.maxHP)

        #expect(player.isAlive == false)
        #expect(player.currentHP == 0)
    }

    @Test func playerStaysAliveWithOneHP() {
        let player = PlayerNode()

        player.takeDamage(PlayerConfig.maxHP - 1)

        #expect(player.isAlive == true)
        #expect(player.currentHP == 1)
    }

    // MARK: - Healing

    @Test func healIncreasesHP() {
        let player = PlayerNode()
        player.takeDamage(50)

        player.heal(20)

        #expect(player.currentHP == PlayerConfig.maxHP - 50 + 20)
    }

    @Test func healDoesNotExceedMaxHP() {
        let player = PlayerNode()
        player.takeDamage(10)

        player.heal(100)  // Heal way more than the damage taken

        #expect(player.currentHP == PlayerConfig.maxHP)
    }

    @Test func healAtFullHPDoesNothing() {
        let player = PlayerNode()

        player.heal(50)

        #expect(player.currentHP == PlayerConfig.maxHP)
    }

    // MARK: - Movement

    @Test func moveChangesPosition() {
        let player = PlayerNode()
        player.position = CGPoint(x: 0, y: 0)

        // Move to the right
        player.move(direction: CGPoint(x: 1, y: 0), deltaTime: 1.0)

        #expect(player.position.x > 0)
    }

    @Test func moveByCorrectSpeed() {
        let player = PlayerNode()
        player.position = CGPoint(x: 0, y: 0)
        let deltaTime: TimeInterval = 1.0

        // Move right with full input
        player.move(direction: CGPoint(x: 1, y: 0), deltaTime: deltaTime)

        let expectedX = PlayerConfig.speed * CGFloat(deltaTime)
        #expect(abs(player.position.x - expectedX) < 1.0)
    }

    @Test func moveWithZeroDirectionStaysInPlace() {
        let player = PlayerNode()
        player.position = CGPoint(x: 50, y: 50)

        player.move(direction: CGPoint(x: 0, y: 0), deltaTime: 1.0)

        #expect(player.position.x == 50)
        #expect(player.position.y == 50)
    }

    @Test func moveNegativeDirectionMovesBackward() {
        let player = PlayerNode()
        player.position = CGPoint(x: 100, y: 100)

        player.move(direction: CGPoint(x: -1, y: -1), deltaTime: 1.0)

        #expect(player.position.x < 100)
        #expect(player.position.y < 100)
    }

    // MARK: - Shooting

    @Test func cannotShootWhenDisabled() {
        let player = PlayerNode()
        player.canShoot = false

        let enemy = EnemyNode()
        enemy.position = CGPoint(x: 100, y: 0)

        let bullet = player.tryShoot(enemies: [enemy], currentTime: 10.0)

        #expect(bullet == nil)
    }

    @Test func cannotShootWithNoEnemies() {
        let player = PlayerNode()

        let bullet = player.tryShoot(enemies: [], currentTime: 10.0)

        #expect(bullet == nil)
    }

    @Test func canShootAtEnemy() {
        let player = PlayerNode()
        player.position = CGPoint(x: 0, y: 0)

        let enemy = EnemyNode()
        enemy.position = CGPoint(x: 100, y: 0)

        // First shot (currentTime is far enough from lastFireTime of 0)
        let bullet = player.tryShoot(enemies: [enemy], currentTime: 10.0)

        #expect(bullet != nil)
    }

    @Test func fireRateLimitsConsecutiveShots() {
        let player = PlayerNode()
        player.position = CGPoint(x: 0, y: 0)

        let enemy = EnemyNode()
        enemy.position = CGPoint(x: 100, y: 0)

        // First shot at time 10.0
        let bullet1 = player.tryShoot(enemies: [enemy], currentTime: 10.0)
        #expect(bullet1 != nil)

        // Immediate second shot — should be blocked by fire rate
        let bullet2 = player.tryShoot(enemies: [enemy], currentTime: 10.0)
        #expect(bullet2 == nil)

        // Shot after fire rate has elapsed
        let bullet3 = player.tryShoot(enemies: [enemy], currentTime: 10.0 + PlayerConfig.fireRate + 0.01)
        #expect(bullet3 != nil)
    }

    @Test func bulletSpawnsAtPlayerPosition() {
        let player = PlayerNode()
        player.position = CGPoint(x: 42, y: 99)

        let enemy = EnemyNode()
        enemy.position = CGPoint(x: 200, y: 99)

        let bullet = player.tryShoot(enemies: [enemy], currentTime: 10.0)

        #expect(bullet?.position.x == 42)
        #expect(bullet?.position.y == 99)
    }

    @Test func cannotShootWhenDead() {
        let player = PlayerNode()

        player.takeDamage(PlayerConfig.maxHP)

        let enemy = EnemyNode()
        enemy.position = CGPoint(x: 100, y: 0)

        let bullet = player.tryShoot(enemies: [enemy], currentTime: 10.0)

        #expect(bullet == nil)
    }

    // MARK: - Physics Setup

    @Test func playerHasPhysicsBody() {
        let player = PlayerNode()

        #expect(player.physicsBody != nil)
    }

    @Test func playerPhysicsCategoryIsCorrect() {
        let player = PlayerNode()

        #expect(player.physicsBody?.categoryBitMask == PhysicsCategory.player)
    }

    @Test func playerDetectsContactWithEnemies() {
        let player = PlayerNode()

        #expect(player.physicsBody?.contactTestBitMask == PhysicsCategory.enemy)
    }
}
