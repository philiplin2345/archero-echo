//
//  JoystickNode.swift
//  archero-echo
//
//  Virtual joystick overlay for player movement input.
//

import SpriteKit

class JoystickNode: SKNode {

    // MARK: - Public State

    /// Whether the joystick is currently being touched.
    private(set) var isActive = false

    /// Normalized direction vector (length 0–1). Zero when not active.
    private(set) var direction = CGPoint.zero

    // MARK: - Configuration

    private let baseRadius: CGFloat = 60
    private let knobRadius: CGFloat = 25
    private let maxDisplacement: CGFloat = 50

    // MARK: - Nodes

    private let baseCircle: SKShapeNode
    private let knobCircle: SKShapeNode
    private var trackingTouch: UITouch?

    // MARK: - Init

    override init() {
        baseCircle = SKShapeNode(circleOfRadius: baseRadius)
        baseCircle.fillColor = SKColor.white.withAlphaComponent(0.15)
        baseCircle.strokeColor = SKColor.white.withAlphaComponent(0.3)
        baseCircle.lineWidth = 2
        baseCircle.zPosition = ZPosition.hud

        knobCircle = SKShapeNode(circleOfRadius: knobRadius)
        knobCircle.fillColor = SKColor.white.withAlphaComponent(0.5)
        knobCircle.strokeColor = SKColor.white.withAlphaComponent(0.7)
        knobCircle.lineWidth = 1.5
        knobCircle.zPosition = ZPosition.hud + 1

        super.init()

        isUserInteractionEnabled = true
        addChild(baseCircle)
        addChild(knobCircle)

        // Start hidden until touched
        alpha = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Manual Control (Called by GameScene)

    func startTracking(at location: CGPoint) {
        isActive = true
        position = location
        alpha = 1
        knobCircle.position = .zero
        direction = .zero
    }

    func updateTracking(at location: CGPoint) {
        guard isActive else { return }
        
        var delta = location - position
        let dist = delta.length

        if dist > maxDisplacement {
            delta = delta.normalized() * maxDisplacement
        }

        knobCircle.position = delta
        direction = delta.normalized()

        // Scale direction magnitude (0–1) based on how far the knob is pulled
        let normalizedMagnitude = min(dist / maxDisplacement, 1.0)
        direction = direction * normalizedMagnitude
    }

    func stopTracking() {
        isActive = false
        direction = .zero
        knobCircle.position = .zero
        alpha = 0
    }
}
