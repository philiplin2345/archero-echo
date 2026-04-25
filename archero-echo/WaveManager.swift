//
//  WaveManager.swift
//  archero-echo
//
//  Manages enemy wave spawning and progression.
//

import SpriteKit

class WaveManager {

    // MARK: - State

    private(set) var currentWave: Int = 0
    private(set) var enemiesAlive: Int = 0
    private(set) var totalKills: Int = 0
    private(set) var isSpawning: Bool = false

    // MARK: - Callbacks

    var onWaveCleared: (() -> Void)?
    var onEnemyKilled: (() -> Void)?

    // MARK: - Spawning

    /// Start the next wave. Returns the spawned enemies.
    func spawnNextWave(in scene: SKScene, arenaRect: CGRect) -> [EnemyNode] {
        currentWave += 1
        let count = WaveConfig.baseEnemyCount + (currentWave - 1) * WaveConfig.enemiesPerWave
        enemiesAlive = count
        isSpawning = true

        var enemies: [EnemyNode] = []

        for i in 0..<count {
            let enemy = EnemyNode()
            enemy.position = randomSpawnPosition(arenaRect: arenaRect)

            // Stagger spawn with a small delay per enemy
            enemy.alpha = 0
            enemy.setScale(0.3)
            let delay = SKAction.wait(forDuration: Double(i) * 0.15)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
            let spawn = SKAction.group([fadeIn, scaleUp])
            enemy.run(SKAction.sequence([delay, spawn]))

            enemies.append(enemy)
        }

        // Mark spawning complete after all enemies have appeared
        let totalDelay = Double(count) * 0.15 + 0.3
        scene.run(SKAction.wait(forDuration: totalDelay)) { [weak self] in
            self?.isSpawning = false
        }

        return enemies
    }

    /// Call when an enemy dies.
    func enemyKilled() {
        enemiesAlive = max(0, enemiesAlive - 1)
        totalKills += 1
        onEnemyKilled?()

        if enemiesAlive == 0 && !isSpawning {
            onWaveCleared?()
        }
    }

    /// Reset for a new game.
    func reset() {
        currentWave = 0
        enemiesAlive = 0
        totalKills = 0
        isSpawning = false
    }

    // MARK: - Helpers

    /// Pick a random position along the edges of the arena.
    private func randomSpawnPosition(arenaRect: CGRect) -> CGPoint {
        let margin = WaveConfig.spawnMargin
        let edge = Int.random(in: 0...3) // 0=top, 1=bottom, 2=left, 3=right

        switch edge {
        case 0: // top
            return CGPoint(
                x: CGFloat.random(in: arenaRect.minX + margin ... arenaRect.maxX - margin),
                y: arenaRect.maxY - margin
            )
        case 1: // bottom
            return CGPoint(
                x: CGFloat.random(in: arenaRect.minX + margin ... arenaRect.maxX - margin),
                y: arenaRect.minY + margin
            )
        case 2: // left
            return CGPoint(
                x: arenaRect.minX + margin,
                y: CGFloat.random(in: arenaRect.minY + margin ... arenaRect.maxY - margin)
            )
        default: // right
            return CGPoint(
                x: arenaRect.maxX - margin,
                y: CGFloat.random(in: arenaRect.minY + margin ... arenaRect.maxY - margin)
            )
        }
    }
}
