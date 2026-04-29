//
//  WaveManager.swift
//  archero-echo
//
//  Manages enemy wave spawning and progression.
//

import SpriteKit

struct WaveDef {
    let melee: Int
    let ranged: Int
    let magic: Int
    let boss: Int
}

class WaveManager {

    // MARK: - State

    private(set) var currentWave: Int = 0
    private(set) var enemiesAlive: Int = 0
    private(set) var totalKills: Int = 0
    private(set) var isSpawning: Bool = false
    
    // MARK: - Wave Definitions (63 Waves)
    
    private lazy var predefinedWaves: [WaveDef] = {
        var waves: [WaveDef] = []
        
        // Procedurally generate 62 waves for progression
        for i in 1...62 {
            var melee = 0
            var ranged = 0
            var magic = 0
            
            // Waves 1-15: Melee + Ranged
            if i <= 15 {
                melee = i / 2 + 2
                if i > 5 { ranged = (i - 5) / 3 + 1 }
            }
            // Waves 16-30: Ranged + Magic
            else if i <= 30 {
                ranged = (i - 10) / 2 + 1
                if i > 20 { magic = (i - 20) / 3 + 1 }
            }
            // Waves 31-62: All three types
            else {
                melee = (i - 20) / 4 + 1
                ranged = (i - 25) / 4 + 1
                magic = (i - 30) / 4 + 1
            }
            
            waves.append(WaveDef(melee: melee, ranged: ranged, magic: magic, boss: 0))
        }
        
        // Wave 63: Jad equivalent
        waves.append(WaveDef(melee: 0, ranged: 0, magic: 0, boss: 1))
        
        return waves
    }()

    // MARK: - Callbacks

    var onWaveCleared: (() -> Void)?
    var onEnemyKilled: (() -> Void)?

    // MARK: - Spawning

    /// Start the next wave. Returns the spawned enemies.
    func spawnNextWave(in scene: SKScene, arenaRect: CGRect) -> [EnemyNode] {
        guard currentWave < predefinedWaves.count else { return [] }
        
        let waveDef = predefinedWaves[currentWave]
        currentWave += 1
        
        let count = waveDef.melee + waveDef.ranged + waveDef.magic + waveDef.boss
        enemiesAlive = count
        isSpawning = true

        var enemies: [EnemyNode] = []
        var typesToSpawn: [EnemyType] = []
        
        for _ in 0..<waveDef.melee { typesToSpawn.append(.melee) }
        for _ in 0..<waveDef.ranged { typesToSpawn.append(.ranged) }
        for _ in 0..<waveDef.magic { typesToSpawn.append(.magic) }
        for _ in 0..<waveDef.boss { typesToSpawn.append(.boss) }
        
        typesToSpawn.shuffle()

        for (i, type) in typesToSpawn.enumerated() {
            let enemy = EnemyNode(type: type)
            
            // Boss spawns in the center, others spawn on edges
            if type == .boss {
                enemy.position = CGPoint(x: arenaRect.midX, y: arenaRect.midY)
            } else {
                enemy.position = randomSpawnPosition(arenaRect: arenaRect)
            }

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
