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

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard trackingTouch == nil, let touch = touches.first else { return }
        let loc = touch.location(in: self.parent!)

        trackingTouch = touch
        isActive = true
        position = loc
        alpha = 1
        knobCircle.position = .zero
        direction = .zero
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackingTouch, touches.contains(touch) else { return }
        let loc = touch.location(in: self.parent!)

        var delta = loc - position
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackingTouch, touches.contains(touch) else { return }
        resetJoystick()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackingTouch, touches.contains(touch) else { return }
        resetJoystick()
    }

    private func resetJoystick() {
        trackingTouch = nil
        isActive = false
        direction = .zero
        knobCircle.position = .zero
        alpha = 0
    }
}
