//
//  Constants.swift
//  archero-echo
//
//  Game-wide constants: physics categories, z-positions, and tuning values.
//

import Foundation

// MARK: - Physics Categories (bitmasks)

struct PhysicsCategory {
    static let none:            UInt32 = 0
    static let player:          UInt32 = 0b0000_0001   // 1
    static let enemy:           UInt32 = 0b0000_0010   // 2
    static let bullet:          UInt32 = 0b0000_0100   // 4 (player bullet)
    static let boundary:        UInt32 = 0b0000_1000   // 8
    static let enemyProjectile: UInt32 = 0b0001_0000   // 16
    static let powerup:         UInt32 = 0b0010_0000   // 32
}

// MARK: - Z-Position Layers

struct ZPosition {
    static let background: CGFloat = -10
    static let gameplay:   CGFloat = 0
    static let projectile: CGFloat = 5
    static let player:     CGFloat = 10
    static let enemy:      CGFloat = 10
    static let hud:        CGFloat = 100
    static let overlay:    CGFloat = 200
}

// MARK: - Player Tuning

struct PlayerConfig {
    static let size         = CGSize(width: 40, height: 40)
    static let speed:       CGFloat = 200    // points per second
    static let maxHP:       Int = 100
    static let fireRate:    TimeInterval = 0.4  // seconds between shots
    static let color        = "player"       // asset name or fallback color
}

// MARK: - Enemy Tuning

struct EnemyConfig {
    static let size         = CGSize(width: 36, height: 36)
    static let speed:       CGFloat = 80     // points per second
    static let hp:          Int = 30
    static let damage:      Int = 10         // damage to player on contact
    static let contactCooldown: TimeInterval = 1.0  // seconds between contact damage
    
    // Ranged/Magic logic
    static let rangedRange: CGFloat = 250
    static let magicRange:  CGFloat = 350
    static let fireRate:    TimeInterval = 2.0
    
    // Boss logic
    static let bossHP:      Int = 1500
    static let bossSize     = CGSize(width: 100, height: 100)
    static let bossSpeed:   CGFloat = 50
}

// MARK: - Bullet Tuning

struct BulletConfig {
    static let radius:      CGFloat = 5
    static let speed:       CGFloat = 400    // points per second
    static let damage:      Int = 15
    static let maxRange:    CGFloat = 600    // auto-remove after this distance
    static let enemySpeed:  CGFloat = 250    // slower enemy projectiles
}

// MARK: - Wave Tuning

struct WaveConfig {
    static let baseEnemyCount: Int = 3
    static let enemiesPerWave: Int = 2       // additional enemies each wave
    static let spawnMargin:    CGFloat = 40  // distance from edge
    static let delayBetweenWaves: TimeInterval = 2.0
}

// MARK: - Arena

struct ArenaConfig {
    static let padding: CGFloat = 0  // boundary inset from screen edges
}

// MARK: - Powerups

struct PowerupConfig {
    static let radius: CGFloat = 10
    static let dropChance: CGFloat = 0.05 // 5% chance on enemy death
}
