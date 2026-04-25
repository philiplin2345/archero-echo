//
//  GameOverOverlay.swift
//  archero-echo
//
//  Game-over screen with score summary and tap-to-restart.
//

import SpriteKit

class GameOverOverlay: SKNode {

    // MARK: - Init

    init(sceneSize: CGSize, wave: Int, kills: Int) {
        super.init()

        zPosition = ZPosition.overlay
        isUserInteractionEnabled = true
        name = "gameOverOverlay"

        // Dimmed background
        let dimmer = SKShapeNode(rectOf: sceneSize)
        dimmer.fillColor = SKColor.black.withAlphaComponent(0.7)
        dimmer.strokeColor = .clear
        dimmer.zPosition = 0
        addChild(dimmer)

        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = "GAME OVER"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .systemRed
        titleLabel.position = CGPoint(x: 0, y: 60)
        titleLabel.zPosition = 1
        addChild(titleLabel)

        // Stats
        let statsLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        statsLabel.text = "Wave \(wave)  •  \(kills) Kills"
        statsLabel.fontSize = 22
        statsLabel.fontColor = .white
        statsLabel.position = CGPoint(x: 0, y: 10)
        statsLabel.zPosition = 1
        addChild(statsLabel)

        // Restart prompt
        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 20
        restartLabel.fontColor = SKColor.white.withAlphaComponent(0.8)
        restartLabel.position = CGPoint(x: 0, y: -50)
        restartLabel.zPosition = 1
        addChild(restartLabel)

        // Pulse animation on restart label
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        restartLabel.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])))

        // Entrance animation
        alpha = 0
        run(SKAction.fadeIn(withDuration: 0.5))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Touch → Restart

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = self.scene else { return }

        // Reload the game scene
        let newScene = GameScene(size: scene.size)
        newScene.scaleMode = scene.scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        scene.view?.presentScene(newScene, transition: transition)
    }
}
