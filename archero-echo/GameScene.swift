//
//  GameScene.swift
//  archero-echo
//
//  Main game scene — orchestrates player, enemies, joystick, HUD, and waves.
//

import SpriteKit

class GameScene: SKScene {

    // MARK: - Game Nodes

    private var player: PlayerNode!
    private var joystick: JoystickNode!
    private var hud: HUDNode!
    private var enemies: [EnemyNode] = []
    private var bullets: [BulletNode] = []

    // MARK: - Managers

    private var waveManager = WaveManager()

    // MARK: - State

    private var isGameOver = false
    private var lastUpdateTime: TimeInterval = 0
    private var trackingTouch: UITouch?

    // MARK: - Layers

    private let gameplayLayer = SKNode()
    private let hudLayer = SKNode()

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
        
        setupLayers()
        setupArenaBoundary()
        setupPlayer()
        setupJoystick()
        setupHUD()
        setupWaveManager()

        // Start the first wave after a short delay
        run(SKAction.wait(forDuration: 1.0)) { [weak self] in
            self?.startNextWave()
        }

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        isUserInteractionEnabled = true
    }

    // MARK: - Setup

    private func setupLayers() {
        gameplayLayer.zPosition = ZPosition.gameplay
        hudLayer.zPosition = ZPosition.hud
        addChild(gameplayLayer)
        addChild(hudLayer)
    }

    private func setupArenaBoundary() {
        let arenaRect = CGRect(x: -size.width / 2, y: -size.height / 2,
                               width: size.width, height: size.height)
        let boundary = SKPhysicsBody(edgeLoopFrom: arenaRect)
        boundary.categoryBitMask = PhysicsCategory.boundary
        boundary.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        boundary.contactTestBitMask = PhysicsCategory.none
        boundary.friction = 0
        physicsBody = boundary

        // Draw a subtle border
        let border = SKShapeNode(rect: arenaRect, cornerRadius: 8)
        border.strokeColor = SKColor.white.withAlphaComponent(0.15)
        border.fillColor = .clear
        border.lineWidth = 2
        border.zPosition = ZPosition.background + 1
        addChild(border)

        // Grid pattern for the floor
        drawFloorGrid(in: arenaRect)
    }

    private func drawFloorGrid(in rect: CGRect) {
        let gridSpacing: CGFloat = 60
        let gridColor = SKColor.white.withAlphaComponent(0.04)

        let gridNode = SKNode()
        gridNode.zPosition = ZPosition.background

        // Vertical lines
        var x = rect.minX
        while x <= rect.maxX {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            line.path = path
            line.strokeColor = gridColor
            line.lineWidth = 0.5
            gridNode.addChild(line)
            x += gridSpacing
        }

        // Horizontal lines
        var y = rect.minY
        while y <= rect.maxY {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            line.path = path
            line.strokeColor = gridColor
            line.lineWidth = 0.5
            gridNode.addChild(line)
            y += gridSpacing
        }

        addChild(gridNode)
    }

    private func setupPlayer() {
        player = PlayerNode()
        player.position = .zero
        gameplayLayer.addChild(player)
    }

    private func setupJoystick() {
        joystick = JoystickNode()
        // The joystick positions itself where the user touches.
        // We add it to the HUD layer so it renders on top.
        hudLayer.addChild(joystick)
    }

    private func setupHUD() {
        hud = HUDNode(sceneSize: size)
        hudLayer.addChild(hud)
    }

    private func setupWaveManager() {
        waveManager.onWaveCleared = { [weak self] in
            // Delay before next wave
            self?.run(SKAction.wait(forDuration: WaveConfig.delayBetweenWaves)) {
                self?.startNextWave()
            }
        }
        waveManager.onEnemyKilled = { [weak self] in
            self?.updateHUD()
        }
    }

    // MARK: - Waves

    private func startNextWave() {
        guard !isGameOver else { return }

        let arenaRect = CGRect(x: -size.width / 2, y: -size.height / 2,
                               width: size.width, height: size.height)
        let newEnemies = waveManager.spawnNextWave(in: self, arenaRect: arenaRect)
        for enemy in newEnemies {
            gameplayLayer.addChild(enemy)
            enemies.append(enemy)
        }
        updateHUD()
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        // Calculate delta time
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Clamp dt to avoid huge jumps
        let deltaTime = min(dt, 1.0 / 30.0)

        updatePlayer(deltaTime: deltaTime, currentTime: currentTime)
        updateEnemies(deltaTime: deltaTime, currentTime: currentTime)
        updateBullets(deltaTime: deltaTime)
        updateHUD()
    }

    // MARK: - Player Update

    private func updatePlayer(deltaTime: TimeInterval, currentTime: TimeInterval) {
        // Movement
        if joystick.isActive {
            player.move(direction: joystick.direction, deltaTime: deltaTime)
            player.canShoot = false  // Can't shoot while moving (Archero mechanic!)
        } else {
            player.canShoot = true

            // Auto-shoot at nearest enemy
            let firedBullets = player.tryShoot(enemies: aliveEnemies(), currentTime: currentTime)
            for bullet in firedBullets {
                gameplayLayer.addChild(bullet)
                bullets.append(bullet)
            }
        }
    }

    // MARK: - Enemy Update

    private func updateEnemies(deltaTime: TimeInterval, currentTime: TimeInterval) {
        // Remove dead enemies from tracking array
        enemies.removeAll { !$0.isAlive && $0.parent == nil }

        for enemy in aliveEnemies() {
            enemy.chase(playerPosition: player.position, deltaTime: deltaTime)
            
            // Try shooting (only applies to ranged/magic enemies)
            if let bullet = enemy.tryShoot(targetPosition: player.position, currentTime: currentTime) {
                gameplayLayer.addChild(bullet)
                bullets.append(bullet)
            }
        }
    }

    // MARK: - Bullet Update

    private func updateBullets(deltaTime: TimeInterval) {
        var bulletsToRemove: [BulletNode] = []

        for bullet in bullets {
            let stillAlive = bullet.fly(deltaTime: deltaTime)
            if !stillAlive {
                bulletsToRemove.append(bullet)
            }
        }

        for bullet in bulletsToRemove {
            bullet.removeFromParent()
        }
        bullets.removeAll { $0.parent == nil }
    }

    // MARK: - HUD

    private func updateHUD() {
        hud.update(
            hp: player.currentHP,
            maxHP: player.maxHP,
            wave: waveManager.currentWave,
            kills: waveManager.totalKills
        )
    }

    // MARK: - Game Over

    func triggerGameOver() {
        guard !isGameOver else { return }
        isGameOver = true

        // Stop all enemy and bullet movement
        gameplayLayer.isPaused = true

        let overlay = GameOverOverlay(
            sceneSize: size,
            wave: waveManager.currentWave,
            kills: waveManager.totalKills
        )
        hudLayer.addChild(overlay)
    }

    // MARK: - Helpers

    func aliveEnemies() -> [EnemyNode] {
        return enemies.filter { $0.isAlive }
    }

    func removeBullet(_ bullet: BulletNode) {
        bullet.removeFromParent()
        bullets.removeAll { $0 === bullet }
    }

    func notifyEnemyKilled(at position: CGPoint) {
        waveManager.enemyKilled()
        
        // Chance to spawn powerup
        if CGFloat.random(in: 0...1) <= PowerupConfig.dropChance {
            spawnPowerup(at: position)
        }
    }
    
    private func spawnPowerup(at position: CGPoint) {
        let powerup = PowerupNode()
        powerup.position = position
        gameplayLayer.addChild(powerup)
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver, trackingTouch == nil, let touch = touches.first else { return }
        trackingTouch = touch
        
        let location = touch.location(in: hudLayer)
        joystick.startTracking(at: location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackingTouch, touches.contains(touch) else { return }
        
        let location = touch.location(in: hudLayer)
        joystick.updateTracking(at: location)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackingTouch, touches.contains(touch) else { return }
        trackingTouch = nil
        joystick.stopTracking()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackingTouch, touches.contains(touch) else { return }
        trackingTouch = nil
        joystick.stopTracking()
    }
}
