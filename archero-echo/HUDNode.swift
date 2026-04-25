//
//  HUDNode.swift
//  archero-echo
//
//  In-game heads-up display: health bar and score.
//

import SpriteKit

class HUDNode: SKNode {

    // MARK: - Nodes

    private let healthBarBackground: SKShapeNode
    private let healthBarFill: SKShapeNode
    private let waveLabel: SKLabelNode
    private let killLabel: SKLabelNode

    private let barWidth: CGFloat = 200
    private let barHeight: CGFloat = 16

    // MARK: - Init

    init(sceneSize: CGSize) {
        // Health bar background (dark)
        healthBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: barHeight / 2)
        healthBarBackground.fillColor = SKColor(white: 0.2, alpha: 0.8)
        healthBarBackground.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        healthBarBackground.lineWidth = 1

        // Health bar fill (green → red gradient faked with color)
        healthBarFill = SKShapeNode(rectOf: CGSize(width: barWidth - 4, height: barHeight - 4), cornerRadius: (barHeight - 4) / 2)
        healthBarFill.fillColor = .systemGreen
        healthBarFill.strokeColor = .clear
        healthBarFill.lineWidth = 0

        // Wave label
        waveLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        waveLabel.fontSize = 18
        waveLabel.fontColor = .white
        waveLabel.horizontalAlignmentMode = .left
        waveLabel.verticalAlignmentMode = .center

        // Kill label
        killLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        killLabel.fontSize = 14
        killLabel.fontColor = SKColor(white: 0.8, alpha: 1)
        killLabel.horizontalAlignmentMode = .left
        killLabel.verticalAlignmentMode = .center

        super.init()

        zPosition = ZPosition.hud
        isUserInteractionEnabled = false

        // Position elements relative to top-left of the scene
        let topLeft = CGPoint(x: -sceneSize.width / 2 + 20, y: sceneSize.height / 2 - 50)

        healthBarBackground.position = CGPoint(x: topLeft.x + barWidth / 2, y: topLeft.y)
        healthBarFill.position = healthBarBackground.position

        waveLabel.position = CGPoint(x: topLeft.x, y: topLeft.y - 25)
        killLabel.position = CGPoint(x: topLeft.x, y: topLeft.y - 48)

        addChild(healthBarBackground)
        addChild(healthBarFill)
        addChild(waveLabel)
        addChild(killLabel)

        update(hp: PlayerConfig.maxHP, maxHP: PlayerConfig.maxHP, wave: 0, kills: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update

    func update(hp: Int, maxHP: Int, wave: Int, kills: Int) {
        let ratio = CGFloat(hp) / CGFloat(maxHP)

        // Resize health bar fill
        let fillWidth = max(0, (barWidth - 4) * ratio)
        let fillRect = CGSize(width: fillWidth, height: barHeight - 4)
        let cornerRadius = (barHeight - 4) / 2

        healthBarFill.path = CGPath(roundedRect: CGRect(
            x: -fillWidth / 2,
            y: -(barHeight - 4) / 2,
            width: fillWidth,
            height: barHeight - 4
        ), cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

        // Shift fill to align left edge with the background's left edge
        let bgLeft = healthBarBackground.position.x - barWidth / 2 + 2
        healthBarFill.position.x = bgLeft + fillWidth / 2

        // Color: green → yellow → red
        if ratio > 0.5 {
            healthBarFill.fillColor = .systemGreen
        } else if ratio > 0.25 {
            healthBarFill.fillColor = .systemYellow
        } else {
            healthBarFill.fillColor = .systemRed
        }

        waveLabel.text = wave > 0 ? "WAVE \(wave)" : "GET READY"
        killLabel.text = "Kills: \(kills)"
    }
}
